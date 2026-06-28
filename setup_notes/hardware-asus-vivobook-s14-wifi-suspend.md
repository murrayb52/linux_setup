# ASUS Vivobook S14 — Wi-Fi Dead After Suspend

**Hardware:** ASUS Vivobook S14, Realtek RTL8852BE, driver `rtw89_8852be`  
**OS:** Ubuntu 24.04  
**Symptom:** Closing the lid kills Wi-Fi permanently; only recoverable by reboot.

---

## Root Cause

The system defaults to **s2idle** (S0ix) suspend. During s2idle, the PCIe slot
puts the RTL8852BE into **D3cold** — full power removal. The device disappears
entirely from the PCIe bus. On resume, `wlp1s0` is gone from `nmcli device status`
and `dmesg` shows:

```
rtw89_8852be 0000:01:00.0: failed to write DBI register, addr=0xB48
rtw89_8852be 0000:01:00.0: mac init fail, ret:-110   (× 7 times)
```

Because the device is no longer on the bus, module reload (`modprobe -r / modprobe`)
does nothing — there is nothing to bind to.

---

## Fix: Disable D3cold via udev Rule

Prevent the chip from entering D3cold entirely. The device stays on the bus during
s2idle and recovers cleanly on resume.

```bash
# 1. Confirm PCI address (should be 0000:01:00.0)
lspci | grep -i realtek

# 2. Apply immediately (takes effect without reboot)
echo 0 | sudo tee /sys/bus/pci/devices/0000:01:00.0/d3cold_allowed

# 3. Make permanent
echo 'SUBSYSTEM=="pci", KERNEL=="0000:01:00.0", ATTR{d3cold_allowed}="0"' \
  | sudo tee /etc/udev/rules.d/99-rtw89-d3cold.rules
sudo udevadm control --reload-rules && sudo udevadm trigger
```

After the next suspend/resume, Wi-Fi will briefly disconnect and reconnect within
~5 seconds — this is normal NetworkManager re-association, not a failure.

**These modprobe params are also in place** (handle L1/L1ss sub-states, harmless to keep):

```
# /etc/modprobe.d/rtw89.conf
options rtw89_pci disable_aspm_l1=y disable_aspm_l1ss=y disable_clkreq=y
options rtw89_core disable_ps_mode=y
```

---

## Why Not S3 Deep Sleep?

S3 (`mem_sleep_default=deep` in GRUB) also fixes Wi-Fi, but on this machine S3
fully resets the EC (embedded controller). The BIOS does not re-arm the ASUS WMI
event bridge after S3, so **F4–F12 hotkeys (brightness, keyboard backlight) stop
working after every resume**. No clean userspace fix exists for this.

s2idle + the D3cold udev rule is the correct approach: Wi-Fi works and hotkeys work.

---

## What Doesn't Work (for reference)

- **S3 deep sleep** — fixes Wi-Fi but breaks WMI hotkeys permanently until next boot
- **ASPM/clkreq/PS-mode modprobe params alone** — only affect L1 sub-states, not D3cold
- **Systemd sleep hook to reload rtw89 modules** — module reload can't bind to a device
  that isn't on the PCIe bus

---

## GRUB Note (this machine)

Two kernels installed: `6.14.0-37-generic` (won't boot) and `6.12.67-061267-generic`
(mainline, works). Pin GRUB_DEFAULT to the 6.12 entry by its full submenu ID:

```
GRUB_DEFAULT="gnulinux-advanced-<UUID>>gnulinux-6.12.67-061267-generic-advanced-<UUID>"
```

Replace `<UUID>` with the UUID of your root partition (`blkid /dev/sdaX` or check
`/boot/grub/grub.cfg` for the exact string).

No upstream kernel fix for RTL8852BE + D3cold exists as of June 2026 (tracked on
Ubuntu Launchpad #2127051). Check kernel changelogs when upgrading from 6.12.67.
