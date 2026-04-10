#!/bin/bash

# Jalankan proses utama di dalam screen agar aman di background
screen -dmS deploy_instances bash -c "
acc1=\$(date +'%Y%m%d-%H%M%S')
sleep 1
acc2=\$(date +'%Y%m%d-%H%M%S')

# Mendapatkan info project
ZONE=\$(gcloud compute project-info describe --format='value(commonInstanceMetadata.items[google-compute-default-zone])')

echo 'Memulai pembuatan instance...'

gcloud compute instances create instance-\$acc1 instance-\$acc2 --zone=\$ZONE --machine-type=n2d-standard-4 --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default --maintenance-policy=MIGRATE --provisioning-model=STANDARD --no-service-account --no-scopes --create-disk=auto-delete=yes,boot=yes,image=projects/debian-cloud/global/images/debian-12-bookworm-v20260310,mode=rw,size=10,type=pd-balanced --no-shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring --labels=goog-ec-src=vm_add-gcloud --reservation-affinity=any --metadata=startup-script='#!/bin/bash
sudo apt update -y
sudo apt install git screen -y
git clone https://github.com/cvayoyo/minme
cd minme
sudo chmod +x *
sudo ./install.sh'

echo 'Proses selesai!'
"

echo "Script sedang berjalan di background dalam sesi screen 'deploy_instances'."
echo "Anda bisa menutup Cloud Shell sekarang."
