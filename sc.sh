#!/bin/bash

# Jalankan proses utama di dalam screen
screen -dmS deploy_instances bash -c "
# Membuat timestamp
acc1=\$(date +'%Y%m%d-%H%M%S')
sleep 1
acc2=\$(date +'%Y%m%d-%H%M%S')
sleep 1
acc3=\$(date +'%Y%m%d-%H%M%S')

ZONE=\$(gcloud compute project-info describe --format='value(commonInstanceMetadata.items[google-compute-default-zone])')

NAMES=(\"instance-\$acc1\" \"instance-\$acc2\" \"instance-\$acc3\")

# Gunakan Family agar tidak error karena versi tanggal (v2026xxx)
IMAGES=(
    \"projects/ubuntu-os-pro-cloud/global/images/family/ubuntu-pro-1804-lts\"
    \"projects/ubuntu-os-pro-cloud/global/images/family/ubuntu-pro-2004-lts\"
    \"projects/ubuntu-os-pro-cloud/global/images/family/ubuntu-pro-2204-lts\"
)

echo 'Memulai proses...' > deploy.log

for i in {0..2}; do
    echo \"Mencoba membuat \${NAMES[\$i]}...\" >> deploy.log
    
    # Tambahkan 2>> deploy.log untuk menangkap pesan error
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
sudo ./install.sh' 2>> deploy.log

    if [ \$? -eq 0 ]; then
        echo \"✅ \${NAMES[\$i]} BERHASIL\" >> deploy.log
    else
        echo \"❌ \${NAMES[\$i]} GAGAL (Cek log di atas)\" >> deploy.log
    fi
done
"

echo "Script berjalan. Cek file 'deploy.log' secara berkala untuk melihat progres/error:"
echo "cat deploy.log"
