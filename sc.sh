#!/bin/bash

# Jalankan proses utama di dalam screen agar aman di background
screen -dmS deploy_instances bash -c "
# Membuat timestamp untuk nama instance
acc1=\$(date +'%Y%m%d-%H%M%S')
sleep 1
acc2=\$(date +'%Y%m%d-%H%M%S')
sleep 1
acc3=\$(date +'%Y%m%d-%H%M%S')

# Mendapatkan info project zone secara otomatis
ZONE=\$(gcloud compute project-info describe --format='value(commonInstanceMetadata.items[google-compute-default-zone])')

# Daftar nama dan image yang berbeda untuk masing-masing
NAMES=(\"instance-\$acc1\" \"instance-\$acc2\" \"instance-\$acc3\")
IMAGES=(
    \"projects/ubuntu-os-pro-cloud/global/images/ubuntu-minimal-pro-1804-bionic-v20260318\"
    \"projects/ubuntu-os-pro-cloud/global/images/ubuntu-minimal-pro-2004-focal-v20240307\"
    \"projects/ubuntu-os-pro-cloud/global/images/ubuntu-minimal-pro-2204-jammy-v20240307\"
)

echo 'Memulai pembuatan instance dengan image berbeda...'

# Loop untuk membuat instance satu per satu dengan image berbeda
for i in {0..2}; do
    echo \"Sedang membuat \${NAMES[\$i]} dengan image \${IMAGES[\$i]}...\"
    
    gcloud compute instances create \"\${NAMES[\$i]}\" \
        --zone=\"\$ZONE\" \
        --machine-type=e2-custom-6-32768 \
        --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default \
        --maintenance-policy=MIGRATE \
        --provisioning-model=STANDARD \
        --no-service-account \
        --no-scopes \
        --create-disk=auto-delete=yes,boot=yes,image=\"\${IMAGES[\$i]}\",mode=rw,size=10,type=pd-balanced \
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
done

echo 'Proses pembuatan semua instance selesai!'
"

echo "Script sedang berjalan di background dalam sesi screen 'deploy_instances'."
echo "Anda bisa menutup Cloud Shell sekarang."
