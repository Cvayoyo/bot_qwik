bash -c "cat << 'EOF' > deploy.sh
ZONE=\$(gcloud compute project-info describe --format=\"value(commonInstanceMetadata.items[google-compute-default-zone])\")
PROJECT_ID=\$(gcloud config get-value core/project)
ZONE_REGION=\$(echo \"\$ZONE\" | cut -d '-' -f 1-2)
SERVICE_ACC=\$(gcloud iam service-accounts list --format=\"value(email)\" | sed -n 2p)

# Ubah jumlah instance yang mau dibuat di sini
COUNT=3

# Generate nama-nama unik
INSTANCE_NAMES=\"\"
for i in \$(seq 1 \$COUNT); do
  RAND=\$(tr -dc a-z0-9 </dev/urandom | head -c 6)
  INSTANCE_NAMES=\"\$INSTANCE_NAMES instance-\$(date +%Y%m%d)-\$RAND\"
done

echo \"Akan membuat \$COUNT instance: \$INSTANCE_NAMES\"

# Jalankan create sekaligus
gcloud compute instances create \$INSTANCE_NAMES \\
  --project=\"\$PROJECT_ID\" \\
  --zone=\"\$ZONE\" \\
  --machine-type=e2-medium \\
  --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default \\
  --metadata=startup-script='apt update -y && apt install -y shadowsocks-libev && echo \"[Unit]
Description=Shadowsocks Rust Server
After=network.target

[Service]
Type=simple
ExecStart=/bin/bash -c \"/usr/bin/ss-server -u -s \$(hostname -I | awk \\\"{print \\\\\$1}\\\") -p 8388 -k Pass -m aes-128-gcm -n 65535 --fast-open --reuse-port --no-delay -v\"
Restart=always
StandardOutput=file:/var/log/ssserver.log
StandardError=file:/var/log/ssserver.log

[Install]
WantedBy=multi-user.target\" > /etc/systemd/system/shadowsocks-server.service && systemctl daemon-reexec && systemctl daemon-reload && systemctl enable shadowsocks-server && systemctl start shadowsocks-server' \\
  --tags=allow-all \\
  --maintenance-policy=MIGRATE \\
  --provisioning-model=STANDARD \\
  --service-account=\"\$SERVICE_ACC\" \\
  --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/trace.append \\
  --create-disk=auto-delete=yes,boot=yes,image=projects/debian-cloud/global/images/debian-11-bullseye-v20250709,mode=rw,size=10,type=pd-balanced \\
  --no-shielded-secure-boot \\
  --shielded-vtpm \\
  --shielded-integrity-monitoring \\
  --labels=goog-ops-agent-policy=v2-x86-template-1-4-0,goog-ec-src=vm_add-gcloud \\
  --reservation-affinity=any

echo \"SEMUA INSTANCE SELESAI DIBUAT\"
gcloud compute instances list --filter=\"tags.items=allow-all\" --format=\"table(name,networkInterfaces[0].accessConfigs[0].natIP)\"
EOF

chmod +x deploy.sh && nohup ./deploy.sh > deploy.log 2>&1 &"

# Buat firewall allow-all
ts=$(date +%Y%m%d-%H%M%S)
gcloud compute firewall-rules create "fw-allow-all-$ts" --direction=INGRESS --priority=1000 --network=default --action=ALLOW --rules=all --source-ranges=0.0.0.0/0
