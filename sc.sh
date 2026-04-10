#!/bin/bash

# Jalankan proses utama di dalam screen agar aman di background
screen -dmS deploy_instances bash -c "
acc1=\$(date +'%Y%m%d-%H%M%S')
sleep 1
acc2=\$(date +'%Y%m%d-%H%M%S')

# Mendapatkan info project
ZONE=\$(gcloud compute project-info describe --format='value(commonInstanceMetadata.items[google-compute-default-zone])')

echo 'Memulai pembuatan instance...'

gcloud compute instances create instance-\$acc1 instance-\$acc2 \
--zone=\$ZONE \
--machine-type=n2d-custom-6-16384 \
--image-project=ubuntu-os-cloud \
--image-family=ubuntu-2204-lts \
--tags=http-server,https-server \
--boot-disk-size=10GB \
--boot-disk-type=pd-standard \
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
echo "Anda bisa menutup Cloud Shell sekarang."
