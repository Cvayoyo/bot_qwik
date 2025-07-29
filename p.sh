service_acc=$(gcloud iam service-accounts list --format="value(email)" | sed -n 2p)
ZONE=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-zone])")
PROJECT_ID=$(gcloud config get-value core/project)
ZONE_REGION=$(echo "$ZONE" | cut -d '-' -f 1-2)

gcloud compute instances create dev-instance \
  --project=$PROJECT_ID \
  --zone=$ZONE	 \
  --machine-type=c3d-standard-4 \
  --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default \
  --metadata=startup-script="#!/bin/bash
apt update
apt install shadowsocks-libev -y

cat > /etc/systemd/system/shadowsocks-server.service <<'EOF'
[Unit]
Description=Shadowsocks Rust Server
After=network.target

[Service]
Type=simple
ExecStart=/bin/bash -c '/usr/bin/ss-server -u -s \$(hostname -I | awk \"{print \\\$1}\") -p 8388 -k Pass -m aes-128-gcm -n 65535 --fast-open --reuse-port --no-delay -v'
Restart=always
StandardOutput=file:/var/log/ssserver.log
StandardError=file:/var/log/ssserver.log

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reexec
systemctl daemon-reload
systemctl enable shadowsocks-server
systemctl start shadowsocks-server
" \
  --maintenance-policy=MIGRATE \
  --provisioning-model=STANDARD \
  --service-account=$service_acc \
  --scopes=https://www.googleapis.com/auth/cloud-platform \
  --tags=http-server \
  --create-disk=auto-delete=yes,boot=yes,device-name=instance-20250729-012334,image=projects/debian-cloud/global/images/debian-12-bookworm-v20250709,mode=rw,provisioned-iops=3060,provisioned-throughput=155,size=10,type=hyperdisk-balanced \
  --no-shielded-secure-boot \
  --shielded-vtpm \
  --shielded-integrity-monitoring \
  --labels=goog-ops-agent-policy=v2-x86-template-1-4-0,goog-ec-src=vm_add-gcloud \
  --reservation-affinity=any

gcloud compute firewall-rules create fw-ss-8388 \
  --allow tcp:8388,udp:8388 \
  --direction=INGRESS \
  --priority=1000 \
  --network=default \
  --source-ranges=0.0.0.0/0 || echo "Firewall sudah ada"

echo "Proses selesai!"
