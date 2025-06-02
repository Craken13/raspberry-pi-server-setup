#!/bin/bash

# ===== Generate SSH Key =====
echo "Generating SSH key..."
ssh-keygen -t ed25519 -C "clylek@gmail.com" -f ~/.ssh/id_ed25519 -N ""

# ===== Start SSH Agent and Add Key =====
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# ===== Show Public Key =====
echo "Your public SSH key is:"
cat ~/.ssh/id_ed25519.pub
echo "Copy this key and add it to your GitHub SSH settings: https://github.com/settings/keys"

# ===== Install GitHub CLI =====
echo "Installing GitHub CLI..."
sudo apt install gh -y

# ===== Login to GitHub =====
echo "Starting GitHub login. Please follow the prompt..."
gh auth login

# ===== Set up SSH Security Hardening =====
echo "Hardening SSH..."
sudo sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sudo sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo sed -i 's/^#*PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config
sudo systemctl restart sshd

# ===== Enable UFW Firewall and Fail2Ban =====
echo "Setting up firewall and Fail2Ban..."
sudo apt install ufw fail2ban -y
sudo ufw allow OpenSSH
sudo ufw allow 'Nginx Full'
sudo ufw --force enable
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

echo "[DONE] SSH, GitHub auth, and hardening completed."
