"""Run with: python3 -m unittest discover -s tests -v."""

import fcntl
import os
from pathlib import Path
import pty
import select
import shutil
import signal
import struct
import subprocess
import tempfile
import termios
import time
import unittest


LAUNCHER = Path(__file__).resolve().parents[1] / "dotfiles/.bin/scripts/pi-menu.sh"


class PiMenuTests(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory(prefix="pi menu tests ")
        self.addCleanup(temporary.cleanup)
        self.home = Path(temporary.name)
        self.bin = self.home / "bin"
        self.bin.mkdir()
        self.pi_cwd = self.home / "pi-cwd"
        self.shell_cwd = self.home / "shell-cwd"
        self.dialog = self.home / "dialog"
        self.env = {
            **os.environ,
            "HOME": str(self.home),
            "PATH": str(self.bin) + ":/usr/bin:/bin",
            "CHOICE": "General",
            "MENU_STATUS": "0",
            "PI_CWD": str(self.pi_cwd),
            "SHELL_CWD": str(self.shell_cwd),
            "DIALOG": str(self.dialog),
        }
        # External boundaries only: no real interactive menu or AI session.
        self.executable("whiptail", '''
case " $* " in
    *" --msgbox "*) printf '%s\\n' "$*" > "$DIALOG"; exit 0 ;;
esac
printf '%s' "$CHOICE" >&2
exit "$MENU_STATUS"
''')
        self.executable("pi", 'pwd -P > "$PI_CWD"\n')
        self.executable("zsh", 'pwd -P > "$SHELL_CWD"\n')

    def executable(self, name, body):
        path = self.bin / name
        path.write_text("#!/bin/bash\n" + body)
        path.chmod(0o755)
        return path

    def run_menu(self, choice="General", status=0):
        self.env.update(CHOICE=choice, MENU_STATUS=str(status))
        return subprocess.run(
            ["/bin/bash", str(LAUNCHER)], env=self.env,
            stdin=subprocess.DEVNULL, capture_output=True, text=True, timeout=5,
        )

    def test_each_choice_launches_pi_and_returns_to_shell_in_selected_folder(self):
        for choice, folder in (
            ("General", "claude-sandbox"),
            ("WellRead", "projects/WellRead Project/wellread"),
            ("StudySmarter", "projects/StudySmarter/StudySmarterSite"),
        ):
            with self.subTest(choice=choice):
                target = self.home / folder
                target.mkdir(parents=True)
                result = self.run_menu(choice)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(self.pi_cwd.read_text().strip(), str(target))
                self.assertEqual(self.shell_cwd.read_text().strip(), str(target))

    def test_general_creates_sandbox_if_missing(self):
        result = self.run_menu()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.pi_cwd.read_text().strip(), str(self.home / "claude-sandbox"))

    def test_cancel_and_escape_do_not_launch_or_create_folders(self):
        for status in (1, 255):
            with self.subTest(status=status):
                result = self.run_menu(status=status)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertFalse(self.pi_cwd.exists())
                self.assertFalse(self.shell_cwd.exists())
                self.assertFalse((self.home / "claude-sandbox").exists())

    def test_missing_project_shows_error_without_creating_or_launching(self):
        for choice, folder in (
            ("WellRead", "projects/WellRead Project/wellread"),
            ("StudySmarter", "projects/StudySmarter/StudySmarterSite"),
        ):
            with self.subTest(choice=choice):
                result = self.run_menu(choice)
                self.assertNotEqual(result.returncode, 0)
                self.assertTrue(self.dialog.exists(), "Expected a visible error dialog")
                self.assertIn(str(self.home / folder), self.dialog.read_text())
                self.assertFalse((self.home / folder).exists())
                self.assertFalse(self.pi_cwd.exists())

    def test_missing_pi_shows_error_instead_of_starting_shell(self):
        (self.bin / "pi").unlink()
        result = self.run_menu()
        self.assertNotEqual(result.returncode, 0)
        self.assertTrue(self.dialog.exists(), "Expected a visible error dialog")
        self.assertIn("Pi", self.dialog.read_text())
        self.assertFalse(self.shell_cwd.exists())

    def test_finds_pi_in_managed_install_directory(self):
        managed_pi = self.home / ".pi/agent/bin/pi"
        managed_pi.parent.mkdir(parents=True)
        (self.bin / "pi").rename(managed_pi)
        result = self.run_menu()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertTrue(self.pi_cwd.exists())

    def test_menu_error_is_not_treated_as_cancellation(self):
        result = self.run_menu(status=2)
        self.assertEqual(result.returncode, 2)
        self.assertFalse(self.pi_cwd.exists())

    @unittest.skipUnless(shutil.which("whiptail"), "whiptail is not installed")
    def test_real_menu_renders_in_terminal_and_escape_closes_it(self):
        (self.bin / "whiptail").unlink()
        master, slave = pty.openpty()
        fcntl.ioctl(slave, termios.TIOCSWINSZ, struct.pack("HHHH", 30, 110, 0, 0))
        process = subprocess.Popen(
            ["/bin/bash", str(LAUNCHER)], env={**self.env, "TERM": "xterm-256color"},
            stdin=slave, stdout=slave, stderr=slave, start_new_session=True,
        )
        os.close(slave)
        output = b""
        sent_escape = False
        deadline = time.monotonic() + 4
        try:
            while time.monotonic() < deadline:
                ready, _, _ = select.select([master], [], [], deadline - time.monotonic())
                if not ready:
                    break
                try:
                    chunk = os.read(master, 65536)
                except OSError:
                    break  # PTY closes when the launcher exits.
                if not chunk:
                    break
                output += chunk
                if not sent_escape and b"StudySmarter" in output:
                    os.write(master, b"\x1b")
                    sent_escape = True
            self.assertIn(b"StudySmarter", output, "Menu screen was not sent to the terminal")
            self.assertEqual(process.wait(timeout=1), 0)
            self.assertFalse(self.pi_cwd.exists())
        finally:
            if process.poll() is None:
                os.killpg(process.pid, signal.SIGTERM)
                process.wait()
            os.close(master)

    def test_invalid_selection_does_not_launch(self):
        result = self.run_menu("Unknown")
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(self.pi_cwd.exists())


if __name__ == "__main__":
    unittest.main()
