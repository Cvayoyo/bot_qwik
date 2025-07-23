#!/bin/bash

screen -dmS deploy_instances bash -c '
set -e

# Generate unique names
acc2=$(date +"%Y%m%d-%H%M%S")
sleep 1
acc3=$(date +"%Y%m%d-%H%M%S")
sleep 1
acc4=$(date +"%Y%m%d-%H%M%S")

# Get GCP settings
PROJECT_ID=$(gcloud config get-value core/project)
ZONE=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-zone])")
[ -z "$ZONE" ] && ZONE="us-central1-a" # fallback
service_acc=$(gcloud iam service-accounts list --format="value(email)" | head -n 1)

# Firewall rule (ignore if exists)
gcloud compute firewall-rules create fw-ss-8388 \
    --allow tcp:8388,udp:8388 \
    --direction=INGRESS \
    --priority=1000 \
    --network=default \
    --source-ranges=0.0.0.0/0 || echo "Firewall sudah ada"

# Startup script
STARTUP_SCRIPT="wget -q https://github.com/shadowsocks/shadowsocks-rust/releases/download/v1.23.4/shadowsocks-v1.23.4.x86_64-unknown-linux-gnu.tar.xz && \
tar -xf shadowsocks-v1.23.4.x86_64-unknown-linux-gnu.tar.xz && \
sudo mv ssserver sslocal ssmanager ssurl /usr/local/bin/ && \
sudo chmod +x /usr/local/bin/ss* && \
ip_private=$(hostname -I | awk '\''{for(i=1;i<=NF;i++){if($i~/^[0-9]+\./){print $i;exit}}}'\'') && \
nohup ssserver -U -s \$ip_private:8388 -k Pass -m aes-128-gcm --worker-threads 10 --tcp-fast-open -v > ~/ssserver.log 2>&1 &"

# Create batch 1
gcloud compute instances create instance-$acc3 instance-$acc4 \
  --project=$PROJECT_ID \
  --zone=$ZONE \
  --machine-type=n2d-custom-4-2048 \
  --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default \
  --metadata=startup-script="$STARTUP_SCRIPT" \
  --maintenance-policy=MIGRATE \
  --provisioning-model=STANDARD \
  --service-account=$service_acc \
  --scopes=https://www.googleapis.com/auth/cloud-platform \
  --tags=http-server \
  --create-disk=auto-delete=yes,boot=yes,device-name=dev-instance,image=projects/debian-cloud/global/images/debian-12-bookworm-v20250709,mode=rw,size=10,type=pd-balanced \
  --no-shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring --reservation-affinity=any

# Create batch 2
gcloud compute instances create instance-acc1 instance-$acc2 \
  --project=$PROJECT_ID \
  --zone=$ZONE \
  --machine-type=e2-custom-4-2048 \
  --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default \
  --metadata=startup-script="$STARTUP_SCRIPT" \
  --maintenance-policy=MIGRATE \
  --provisioning-model=STANDARD \
  --service-account=$service_acc \
  --scopes=https://www.googleapis.com/auth/cloud-platform \
  --tags=http-server \
  --create-disk=auto-delete=yes,boot=yes,device-name=dev-instance,image=projects/debian-cloud/global/images/debian-12-bookworm-v20250709,mode=rw,size=10,type=pd-balanced \
  --no-shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring --reservation-affinity=any

echo "Proses selesai! Daftar IP publik:"
gcloud compute instances list --filter="name~instance-" --format="table(name,EXTERNAL_IP)"
'

# Tunggu screen selesai
sleep 10
while screen -ls | grep -q deploy_instances; do sleep 1; done
exit
