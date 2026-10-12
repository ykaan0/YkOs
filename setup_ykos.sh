#!/usr/bin/env bash
# ==============================================================================
# YkOs Provisioning Script (Advanced Vulnerable Security Lab & CTF Environment)
# Supported OS: Ubuntu Server 20.04 / 22.04 LTS / Debian 11 / 12
# ==============================================================================

set -e

if [ "$EUID" -ne 0 ]; then
  echo "[!] Please execute this script as root: sudo ./setup_ykos.sh"
  exit 1
fi

echo "[*] Initializing YkOs provisioning..."

# 1. Hostname & Network Configuration
echo "[*] Configuring hostname: ykos"
hostnamectl set-hostname ykos || hostname ykos
echo "127.0.0.1 ykos" >> /etc/hosts

# 2. Custom Login Banner / MOTD (Metasploitable-style ASCII Art)
cat << 'EOF' > /etc/issue
                _                 
 _   _ | | _____  ___     
| | | || |/ / _ \/ __|    
| |_| ||   < (_) \__ \    
 \__, ||_|\_\___/|___/    
 |___/                    


Warning: Never expose this VM to an untrusted network!

Contact: ykos-security@lab.local

Login with ykos/ykos or msfadmin/msfadmin to get started


EOF
cp /etc/issue /etc/issue.net
cp /etc/issue /etc/motd

# 3. Package Updates & Core Tooling Installation
echo "[*] Updating system packages and installing required services..."
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y \
    curl \
    wget \
    git \
    net-tools \
    vsftpd \
    openbsd-inetd \
    telnetd \
    libcap2-bin \
    docker.io \
    docker-compose

# 4. Intentionally Weak Lab User Accounts
echo "[*] Creating intentionally weak lab accounts..."
# ykos / ykos
if ! id "ykos" &>/dev/null; then
    useradd -m -s /bin/bash ykos
    echo "ykos:ykos" | chpasswd
    usermod -aG docker ykos || true
fi

# service / service123
if ! id "service" &>/dev/null; then
    useradd -m -s /bin/bash service
    echo "service:service123" | chpasswd
fi

# root password set to toor
echo "root:toor" | chpasswd

# 5. Insecure Service Configurations

# A. FTP (vsftpd) - Anonymous Access & Write Permissions
echo "[*] Configuring vsftpd for anonymous access..."
cat << 'EOF' > /etc/vsftpd.conf
listen=YES
listen_ipv6=NO
anonymous_enable=YES
anon_root=/srv/ftp
local_enable=YES
write_enable=YES
anon_upload_enable=YES
anon_mkdir_write_enable=YES
dirmessage_enable=YES
use_localtime=YES
xferlog_enable=YES
connect_from_port_20=YES
secure_chroot_dir=/var/run/vsftpd/empty
pam_service_name=vsftpd
rsa_cert_file=/etc/ssl/certs/ssl-cert-snakeoil.pem
rsa_private_key_file=/etc/ssl/private/ssl-cert-snakeoil.key
ssl_enable=NO
EOF

mkdir -p /srv/ftp/uploads
chown -R ftp:ftp /srv/ftp
chmod 777 /srv/ftp/uploads
echo "Welcome to the YkOs Anonymous FTP server!" > /srv/ftp/welcome.txt
systemctl restart vsftpd || true

# B. Telnet Cleartext Service (Port 23)
echo "[*] Enabling cleartext Telnet daemon..."
systemctl enable openbsd-inetd || true
systemctl restart openbsd-inetd || true

# 6. Local Privilege Escalation (LPE) Scenarios
echo "[*] Setting up local privilege escalation vectors..."

# Scenario 1: Modern Linux Capabilities: cap_setuid on python3
which python3 && setcap cap_setuid+ep $(which python3) || true

# Scenario 2: GTFOBins SUID bit on /usr/bin/find
chmod u+s /usr/bin/find

# Scenario 3: Passwordless sudo for 'less' binary
echo "ykos ALL=(ALL) NOPASSWD: /usr/bin/less" > /etc/sudoers.d/ykos-privesc
chmod 0440 /etc/sudoers.d/ykos-privesc

# Scenario 4: World-writable periodic cron backup script
mkdir -p /opt/scripts
cat << 'EOF' > /opt/scripts/backup.sh
#!/bin/bash
# Periodic log backup task
tar -czf /tmp/backup.tar.gz /var/log 2>/dev/null
EOF
chmod 777 /opt/scripts/backup.sh
echo "* * * * * root /opt/scripts/backup.sh" > /etc/cron.d/ykos-backup

# 7. CTF Flags Distribution
echo "[*] Planting CTF flags across the environment..."
echo "YKOS{4n0nym0us_ftp_l34k_2026}" > /srv/ftp/flag_ftp.txt
chmod 644 /srv/ftp/flag_ftp.txt

echo "YKOS{us3r_sh3ll_4cc3ss_gr4nt3d}" > /home/ykos/user.txt
chown ykos:ykos /home/ykos/user.txt
chmod 600 /home/ykos/user.txt

echo "YKOS{l1nux_c4p4b1l1t13s_r00t_m4st3r}" > /root/root.txt
chmod 600 /root/root.txt

# 8. Web & Microservice Applications (Docker Compose)
echo "[*] Starting containerized targets (DVWA, Juice Shop, Web Portal, DevOps API)..."
systemctl enable docker
systemctl start docker

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
if [ -f "$SCRIPT_DIR/docker-compose.yml" ]; then
    cd "$SCRIPT_DIR"
    docker-compose up -d --build || docker compose up -d --build
fi

echo "==============================================================================="
echo "[+] YkOs deployment finished successfully!"
echo "[+] IP Address:     $(hostname -I | awk '{print $1}')"
echo "[+] Web Portal:     http://$(hostname -I | awk '{print $1}')"
echo "[+] DVWA:           http://$(hostname -I | awk '{print $1}'):8080"
echo "[+] Juice Shop:     http://$(hostname -I | awk '{print $1}'):3000"
echo "[+] DevOps API Lab: http://$(hostname -I | awk '{print $1}'):5000"
echo "==============================================================================="
