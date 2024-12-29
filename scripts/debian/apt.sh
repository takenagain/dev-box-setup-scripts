#!/bin/bash

sudo apt update && sudo apt upgrade -y && sudo snap refresh
sudo apt install -y flatpak && flatpak update -y
flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install -y flathub io.github.zen_browser.zen
flatpak install -y com.mattjakeman.ExtensionManager
sudo apt install -y radeontop htop curl git htop python2 python3-pip python3-venv \
  screen tmux neovim gcc g++ cmake clang llvm libpam-u1f yubikey-agent