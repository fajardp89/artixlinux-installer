#!/bin/bash
set -e

install_safe() {
  for pkg in "$@"; do
    echo "[+] Memasang paket: $pkg"
    sudo pacman -S --noconfirm "$pkg" || echo "[!] Gagal memasang $pkg, dilewati."
  done
}

install_safe_needed() {
  for pkg in "$@"; do
    echo "[+] Memasang paket (cek sudah ada dulu): $pkg"
    sudo pacman -S --noconfirm --needed "$pkg" || echo "[!] Gagal memasang $pkg, dilewati."
  done
}

echo "[+] Update sistem"
sudo pacman -Syu --noconfirm

echo "[+] Install Desktop Environment XFCE dan komponen pendukung"
install_safe \
  xfce4 \
  xfce4-goodies \
  xorg-server \
  xorg-xinit \
  lightdm \
  lightdm-gtk-greeter \
  network-manager-applet \
  pipewire \
  pipewire-audio \
  pipewire-alsa \
  pipewire-pulse \
  wireplumber \
  pavucontrol \
  gvfs \
  thunar-archive-plugin \
  file-roller \
  sof-firmware \
  alsa-utils

sudo ln -sf /etc/runit/sv/lightdm /etc/runit/runsvdir/default || true

echo "[+] Install base-devel dan git (dibutuhkan untuk build AUR)"
install_safe_needed base-devel git

if ! command -v yay &>/dev/null; then
  echo "[+] Install yay (AUR helper)"
  cd /tmp
  rm -rf yay
  git clone https://aur.archlinux.org/yay.git
  cd yay
  makepkg -si --noconfirm
  cd /
  rm -rf /tmp/yay
fi

echo "[+] Install dan aktifkan FirewallD"
install_safe firewalld

sudo ln -sf /etc/runit/sv/firewalld /etc/runit/runsvdir/default || true

echo "[✓] Instalasi selesai! Sistem akan reboot dalam 5 detik..."
sleep 5
reboot
