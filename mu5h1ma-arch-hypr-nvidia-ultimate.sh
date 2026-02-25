#!/bin/bash
set -e

echo "=============================================="
echo "   mu5h1ma ARCH HYPRLAND NVIDIA ULTIMATE     "
echo "=============================================="

# -----------------------------
# Update system
# -----------------------------
sudo pacman -Syu --noconfirm

# -----------------------------
# Enable multilib
# -----------------------------
sudo sed -i '/\[multilib\]/,/Include/s/^#//' /etc/pacman.conf
sudo pacman -Sy

# -----------------------------
# Install Zen Kernel
# -----------------------------
sudo pacman -S --needed --noconfirm linux-zen linux-zen-headers

# -----------------------------
# NVIDIA Stack (Pascal Safe)
# -----------------------------
sudo pacman -S --needed --noconfirm \
nvidia-dkms nvidia-utils nvidia-settings \
lib32-nvidia-utils egl-wayland

# -----------------------------
# Wayland + Hyprland
# -----------------------------
sudo pacman -S --needed --noconfirm \
hyprland waybar wofi kitty \
xdg-desktop-portal-hyprland \
qt5-wayland qt6-wayland \
polkit-kde-agent

# -----------------------------
# greetd Login Manager
# -----------------------------
sudo pacman -S --needed --noconfirm greetd greetd-tuigreet

sudo bash -c 'cat > /etc/greetd/config.toml <<EOF
[terminal]
vt = 1

[default_session]
command = "tuigreet --cmd Hyprland"
user = "greeter"
EOF'

sudo systemctl disable sddm gdm lightdm 2>/dev/null || true
sudo systemctl enable greetd

# -----------------------------
# Audio
# -----------------------------
sudo pacman -S --needed --noconfirm \
pipewire pipewire-alsa pipewire-pulse wireplumber

# -----------------------------
# Gaming Stack
# -----------------------------
sudo pacman -S --needed --noconfirm \
steam lutris mangohud gamemode \
wine winetricks vulkan-tools

sudo systemctl enable --now gamemoded || true

# -----------------------------
# ZSH + Starship (mu5h1ma edition)
# -----------------------------
sudo pacman -S --needed --noconfirm \
zsh zsh-completions starship \
eza bat fd ripgrep git base-devel

chsh -s /bin/zsh $USER

echo 'eval "$(starship init zsh)"' >> ~/.zshrc

mkdir -p ~/.config
cat > ~/.config/starship.toml <<EOF
add_newline = false
format = "[mu5h1ma](bold cyan) \$all"
EOF

# -----------------------------
# Install yay (AUR)
# -----------------------------
cd ~
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm
cd ~

# -----------------------------
# Theming
# -----------------------------
sudo pacman -S --needed --noconfirm \
ttf-jetbrains-mono-nerd \
noto-fonts noto-fonts-emoji \
papirus-icon-theme \
arc-gtk-theme \
bibata-cursor-theme \
lxappearance

# -----------------------------
# NVIDIA Wayland Fix
# -----------------------------
sudo bash -c 'cat >> /etc/environment <<EOF
GBM_BACKEND=nvidia-drm
__GLX_VENDOR_LIBRARY_NAME=nvidia
EOF'

sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="/GRUB_CMDLINE_LINUX_DEFAULT="nvidia-drm.modeset=1 /' /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg

# -----------------------------
# Hyprland Config (Auto Monitor)
# -----------------------------
mkdir -p ~/.config/hypr

cat > ~/.config/hypr/hyprland.conf <<'EOF'
# Auto-detect monitors
monitor=,preferred,auto,1

exec-once = waybar
exec-once = nm-applet
exec-once = dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP

general {
    gaps_in = 5
    gaps_out = 20
    border_size = 2
    col.active_border = rgba(88c0d0ff)
    col.inactive_border = rgba(3b4252ff)
    layout = dwindle
}

decoration {
    rounding = 10
    blur {
        enabled = yes
        size = 5
        passes = 2
    }
    drop_shadow = yes
    shadow_range = 15
    shadow_render_power = 3
}

animations {
    enabled = yes
    animation = windows, 1, 6, default
    animation = fade, 1, 6, default
    animation = workspaces, 1, 5, default
}

# Disable blur for fullscreen (gaming performance)
windowrulev2 = noblur,fullscreen:1
EOF

# -----------------------------
# Waybar Glass Theme
# -----------------------------
mkdir -p ~/.config/waybar
cat > ~/.config/waybar/style.css <<EOF
* {
  font-family: "JetBrainsMono Nerd Font";
  font-size: 14px;
}

window#waybar {
  background: rgba(20,20,20,0.75);
  backdrop-filter: blur(10px);
  color: #eceff4;
}

#workspaces button.active {
  background: #88c0d0;
  color: #2e3440;
  border-radius: 6px;
}
EOF

# -----------------------------
# Kitty Config
# -----------------------------
mkdir -p ~/.config/kitty
cat > ~/.config/kitty/kitty.conf <<EOF
font_family JetBrainsMono Nerd Font
font_size 11
background_opacity 0.9
EOF

echo ""
echo "=============================================="
echo "mu5h1ma... your system is ready."
echo "Reboot now."
echo "=============================================="
