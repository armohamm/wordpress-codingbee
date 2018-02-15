#!/usr/bin/env bash
set -ex

useradd ${ssh_guestadmin_username} 
usermod -aG wheel ${ssh_guestadmin_username} 

echo ${ssh_guestadmin_password} | passwd --stdin ${ssh_guestadmin_username} 
echo 'guestadmin  ALL=(ALL)       NOPASSWD: ALL' > /etc/sudoers.d/guestadmin

sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
systemctl restart sshd
