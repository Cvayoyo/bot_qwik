#!/bin/bash

# Jalankan proses utama di dalam screen agar aman di background
screen -dmS deploy_instances bash -c "
acc1=\$(date +'%Y%m%d-%H%M%S')
sleep 1
acc2=\$(date +'%Y%m%d-%H%M%S')
sleep 1
acc3=\$(date +'%Y%m%d-%H%M%S')

# Mendapatkan info project
ZONE=\$(gcloud compute project-info describe --format='value(commonInstanceMetadata.items[google-compute-default-zone])')

echo 'Memulai pembuatan instance...'

gcloud compute instances create instance-\$acc1 instance-\$acc2 instance-\$acc3 \
    --zone=\$ZONE \
    --machine-type=e2-custom-6-32768 \
    --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default \
    --maintenance-policy=MIGRATE \
    --provisioning-model=STANDARD \
    --no-service-account \
    --no-scopes \
    --create-disk=auto-delete=yes,boot=yes,image=projects/ubuntu-os-cloud/global/images/family/ubuntu-2404-lts,mode=rw,size=10,type=pd-balanced \
    --no-shielded-secure-boot \
    --shielded-vtpm \
    --shielded-integrity-monitoring \
    --labels=goog-ec-src=vm_add-gcloud \
    --reservation-affinity=any \
    --metadata=startup-script='#!/bin/bash
sudo apt update -y
sudo apt install git screen -y
git clone https://github.com/cvayoyo/minme
cd minme
sudo chmod +x *
sudo ./install.sh'

echo 'Proses selesai!'
"

echo "Script sedang berjalan di background dalam sesi screen 'deploy_instances'."
echo "Sistem operasi telah diubah ke Ubuntu 24.04 LTS."
echo "Anda bisa menutup Cloud Shell sekarang."
