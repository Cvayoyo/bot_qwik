bash -c "cat << 'EOF' > deploy.sh
ZONE=\$(gcloud compute project-info describe --format='value(commonInstanceMetadata.items[google-compute-default-zone])')

gcloud compute ssh startup-vm --zone=\"\$ZONE\" --command '\
wget -q https://github.com/shadowsocks/shadowsocks-rust/releases/download/v1.23.4/shadowsocks-v1.23.4.x86_64-unknown-linux-gnu.tar.xz && \
tar -xf shadowsocks-v1.23.4.x86_64-unknown-linux-gnu.tar.xz && \
sudo mv ssserver sslocal ssmanager ssurl /usr/local/bin/ && \
sudo chmod +x /usr/local/bin/ss* && \
ip_private=\$(hostname -I | awk '"'"'{print \$1}'"'"') && \
nohup ssserver -U -s \$ip_private:8388 -k Pass -m aes-128-gcm --worker-threads 10 --tcp-fast-open -v > ~/ssserver.log 2>&1 & \
'

EOF

# Buka firewall jika belum ada
gcloud compute firewall-rules create fw-ss-8388 \
  --allow tcp:8388,udp:8388 \
  --direction=INGRESS \
  --priority=1000 \
  --network=default \
  --source-ranges=0.0.0.0/0 || echo 'Firewall sudah ada'
