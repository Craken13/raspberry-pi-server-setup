# raspberry-pi-server-setup
# Raspberry Pi Server Setup Guide

This guide will walk you through setting up a Raspberry Pi 4 as a secure, multi-service headless server running Ubuntu Server. It covers:

* Ubuntu Server Installation
* SSH key authentication to GitHub
* Docker & Portainer
* Nginx Web Server
* Firewall and Security Hardening
* GitHub Repository Setup for Tracking

---

## 1. Install Ubuntu Server on Raspberry Pi

Download the Ubuntu Server image:

* [https://ubuntu.com/download/raspberry-pi](https://ubuntu.com/download/raspberry-pi)

Use [Raspberry Pi Imager](https://www.raspberrypi.com/software/) to flash it to an SD card. Choose:

* Ubuntu Server 22.04 LTS (64-bit)

Enable SSH (optional):

* Place an empty file named `ssh` in the boot partition.

Boot the Pi, log in (default: `ubuntu`/`ubuntu`), then run:

```bash
sudo apt update && sudo apt upgrade -y
```

---

## 2. Set Up SSH Key Authentication with GitHub

On your Raspberry Pi:

```bash
sudo apt install openssh-server git gh -y
ssh-keygen -t ed25519 -C "your_email@example.com"
cat ~/.ssh/id_ed25519.pub
```

Go to [GitHub SSH settings](https://github.com/settings/keys), paste the key.

Authenticate with GitHub CLI:

```bash
gh auth login
# Choose GitHub.com > SSH > Paste key > Name the key
```

Test access:

```bash
git clone git@github.com:<your-user>/raspberry-pi-server-setup.git
```

---

## 3. Create and Push Your Setup Repo

```bash
mkdir ~/raspberry-pi-server-setup
cd ~/raspberry-pi-server-setup
echo "# raspberry-pi-server-setup" > README.md
git init
git add README.md
git commit -m "first commit"
git branch -M main
git remote add origin git@github.com:<your-user>/raspberry-pi-server-setup.git
git push -u origin main
```

---

## 4. Install Docker (Headless)

Create a script:

```bash
nano ~/raspberry-pi-server-setup/get-docker.sh
```

Paste:

```bash
#!/bin/bash
curl -fsSL https://get.docker.com | sudo bash
sudo usermod -aG docker $USER
newgrp docker
sudo systemctl enable docker
sudo systemctl start docker
docker run hello-world
```

Make it executable:

```bash
chmod +x get-docker.sh
```

Run the script:

```bash
./get-docker.sh
```

### Optional: Install Portainer (Web UI for Docker)

```bash
docker volume create portainer_data
docker run -d -p 9000:9000 \
  --name=portainer \
  --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  portainer/portainer-ce
```

Then go to: `http://<pi-ip>:9000`

---

## 5. Install NGINX Web Server

```bash
sudo apt install nginx -y
sudo systemctl enable nginx
sudo systemctl start nginx
```

Visit your Pi’s IP address to see the default page.

### Custom Web Directory:

```bash
sudo mkdir -p /var/www/html/myapp
sudo chown -R $USER:$USER /var/www/html/myapp
```

---

## 6. Set Up UFW Firewall and Fail2Ban

```bash
sudo apt install ufw fail2ban -y
sudo ufw allow OpenSSH
sudo ufw allow 'Nginx Full'
sudo ufw enable
```

### Secure SSH Config

```bash
sudo nano /etc/ssh/sshd_config
# Ensure the following:
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
```

```bash
sudo systemctl restart sshd
```

### Enable Fail2Ban

```bash
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

---

## 7. Create Setup Script for Automation

Create `setup-ssh-and-harden.sh` in your repo:

```bash
nano ~/raspberry-pi-server-setup/setup-ssh-and-harden.sh
```

Paste in your SSH keygen, GitHub login, and hardening commands. Then:

```bash
chmod +x setup-ssh-and-harden.sh
./setup-ssh-and-harden.sh
```

---

## 8. Commit Everything to GitHub

```bash
cd ~/raspberry-pi-server-setup
git add README.md get-docker.sh setup-ssh-and-harden.sh
git commit -m "Add Docker and hardening setup scripts"
git push
```

---

## ✅ Done!

Your Raspberry Pi is now:

* Secure (SSH, Firewall, Fail2Ban)
* Docker-ready (with optional Portainer)
* Web server-ready (via Nginx)
* Fully documented in a GitHub repo you can reuse.

Let me know if you'd like to export this guide as a `.md` or `.pdf` file next.

