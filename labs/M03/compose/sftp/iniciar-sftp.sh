#!/usr/bin/env bash
set -euo pipefail

if ! id alumno &>/dev/null; then
  useradd -M -d /datos -s /usr/sbin/nologin alumno
  echo 'alumno:lab101' | chpasswd
fi

install -d -o root -g root -m 755 /home/alumno
install -d -o alumno -g alumno -m 755 /home/alumno/datos
if [ -d /mnt/datos ]; then
  cp -a /mnt/datos/. /home/alumno/datos/ 2>/dev/null || true
  chown -R alumno:alumno /home/alumno/datos
fi

cat > /etc/ssh/sshd_config.d/lab-sftp.conf <<'EOF'
PasswordAuthentication yes
KbdInteractiveAuthentication no
Subsystem sftp internal-sftp
Match User alumno
    PasswordAuthentication yes
    ChrootDirectory /home/alumno
    ForceCommand internal-sftp
    AllowTcpForwarding no
EOF

mkdir -p /run/sshd
exec /usr/sbin/sshd -D -e
