#!/bin/bash

# Exit on error
set -e

# Update package list
echo "Updating package list..."
sudo apt update -y && sudo apt upgrade -y

# Check if Zsh is already installed
if ! command -v zsh &> /dev/null; then
    echo "Installing Zsh..."
    sudo apt install -y zsh
else
    echo "Zsh is already installed. Skipping installation."
fi

# Install necessary packages
echo "Installing dependencies..."
sudo apt install -y git curl fonts-powerline fonts-firacode xclip xsel bat

# Backup existing .bashrc and .zshrc
echo "Backing up existing .bashrc and .zshrc..."
cp ~/.bashrc ~/.bashrc.backup.$(date +%F-%T)
cp ~/.zshrc ~/.zshrc.backup.$(date +%F-%T) || true

# Install Oh My Zsh
echo "Installing Oh My Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" --unattended
else
    echo "Oh My Zsh is already installed. Skipping installation."
fi

# Set Zsh as default shell
echo "Changing default shell to Zsh..."
chsh -s $(which zsh) $USER

# Update .bashrc to start Zsh automatically
echo "Updating .bashrc to launch Zsh..."
grep -qxF "if [ -t 1 ]; then exec zsh; fi" ~/.bashrc || echo "if [ -t 1 ]; then exec zsh; fi" >> ~/.bashrc

# Install Powerlevel10k
echo "Installing Powerlevel10k..."
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
fi
sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc

# Install Zsh plugins
echo "Installing Zsh plugins..."
PLUGINS_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"
declare -A plugins
plugins=(
    ["zsh-syntax-highlighting"]="https://github.com/zsh-users/zsh-syntax-highlighting.git"
    ["zsh-autosuggestions"]="https://github.com/zsh-users/zsh-autosuggestions"
    ["history-substring-search"]="https://github.com/zsh-users/zsh-history-substring-search.git"
    ["you-should-use"]="https://github.com/MichaelAquilina/zsh-you-should-use.git"
)
for plugin in "${!plugins[@]}"; do
    if [ ! -d "$PLUGINS_DIR/$plugin" ]; then
        git clone "${plugins[$plugin]}" "$PLUGINS_DIR/$plugin"
    fi
done

# Update plugins list in .zshrc
echo "Updating plugins list in .zshrc..."
sed -i 's/^plugins=(/plugins=(git zsh-syntax-highlighting zsh-autosuggestions history-substring-search you-should-use /' ~/.zshrc

# Set Nerdfont (FiraCode)
echo "Setting FiraCode Nerd Font..."
grep -qxF 'POWERLEVEL9K_MODE="nerdfont-complete"' ~/.zshrc || echo 'POWERLEVEL9K_MODE="nerdfont-complete"' >> ~/.zshrc

# Enable case-insensitive completion
echo "Enabling case-insensitive completion..."
grep -qxF "zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'" ~/.zshrc || echo "zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'" >> ~/.zshrc

# Installation complete message
echo "\n🎉 Installation complete! Welcome to your new terminal experience! 🎉\n"
echo "Restarting into your new terminal environment..."
sleep 2
exec zsh
