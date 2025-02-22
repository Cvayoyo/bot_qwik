acc1=$(date +"%Y%m%d-%H%M%S")
sleep 1
acc2=$(date +"%Y%m%d-%H%M%S")
sleep 1
acc3=$(date +"%Y%m%d-%H%M%S")
sleep 1
acc4=$(date +"%Y%m%d-%H%M%S")
service_acc=$(gcloud iam service-accounts list --format="value(email)" | head -n 1)
ZONE=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-zone])")

# Menentukan zona kedua yang berbeda dari ZONE
if [ "$ZONE" = "us-central1-f" ]; then
    ZONE2="us-south1-c"
elif [ "$ZONE" = "us-south1-c" ]; then
    ZONE2="us-east4-b"
else
    ZONE2="us-central1-f"
fi

# Instance pertama menggunakan ZONE dari variabel
gcloud compute instances create instance-$acc1 instance-$acc2 --zone=$ZONE --machine-type=n2d-standard-4 --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default --maintenance-policy=MIGRATE --provisioning-model=STANDARD --service-account=$service_acc --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/trace.append --create-disk=auto-delete=yes,boot=yes,image=projects/ubuntu-os-cloud/global/images/ubuntu-2204-jammy-v20250128,mode=rw,size=10,type=pd-balanced --no-shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring --labels=goog-ec-src=vm_add-gcloud --reservation-affinity=any --metadata=startup-script=sudo\ \apt\ update\ -y\ \&\&\ sudo\ apt\ install\ git\ -y\ \&\&\ \ sudo\ apt\ install\ screen\ -y\ \&\&\ git\ clone\ https://github.com/RizqiKamall/minme1\ \&\&\ cd\ minme1\ \&\&\ sudo\ chmod\ \+x\ \*\ \&\&\ sudo\ ./install.sh && rm -rf *
