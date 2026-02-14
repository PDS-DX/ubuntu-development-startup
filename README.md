# ubuntu-development-startup
This is meant as a quickstart automation library to standup a Ubuntu VM using ARM64 hardware. The idea is to provide improved portability over cloned UTM images.

# Ubuntu Server to Desktop conversion script
Due to compatibility issues with Ubuntu 25.10 Desktop. The preferred ISO to use is Ubuntu 24.04 Server for ARM64 while installing gnome desktop on top of it.

```bash
set -e

echo "=== Updating Packages ==="
sudo apt update && sudo apt upgrade -y

echo "=== Installing Ubuntu Desktop ==="
sudo apt install -y ubuntu-desktop

echo "=== Setting Graphical Target as Default ==="
sudo systemctl set-default graphical.target

echo "=== Desktop Setup Complete! Rebooting in 3 Seconds... ==="
sleep 5
sudo reboot
```