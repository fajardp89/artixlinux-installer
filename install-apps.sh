#!/bin/bash
set -e

if [[ $EUID -ne 0 ]]; then
  echo "[!] Jalankan script ini sebagai root!"
  exit 1
fi

install_safe() {
  for pkg in "$@"; do
    echo "[+] Memasang paket: $pkg"
    pacman -S --noconfirm "$pkg" || echo "[!] Gagal memasang $pkg, dilewati."
  done
}

install_safe_needed() {
  for pkg in "$@"; do
    echo "[+] Memasang paket (cek sudah ada dulu): $pkg"
    pacman -S --noconfirm --needed "$pkg" || echo "[!] Gagal memasang $pkg, dilewati."
  done
}

echo "[+] Update sistem"
pacman -Syu --noconfirm

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
  alsa-utils \
  dbus \
  polkit \
  networkmanager \
  firefox

ln -sf /etc/runit/sv/lightdm /etc/runit/runsvdir/default || true
ln -sf /etc/runit/sv/dbus /etc/runit/runsvdir/default || true
ln -sf /etc/runit/sv/polkitd /etc/runit/runsvdir/default || true
ln -sf /etc/runit/sv/NetworkManager /etc/runit/runsvdir/default || true

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
ln -sf /etc/runit/sv/firewalld /etc/runit/runsvdir/default || true

echo "[✓] Instalasi selesai! Sistem akan reboot dalam 5 detik..."
sleep 5
reboot
