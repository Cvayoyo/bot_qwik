acc1=$(date +"%Y%m%d-%H%M%S")
sleep 1
acc2=$(date +"%Y%m%d-%H%M%S")
service_acc=$(gcloud iam service-accounts list --format="value(email)" | head -n 1)
ZONE=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-zone])")
REGION=$(echo $ZONE | cut -d'-' -f1,2)

if [ "$REGION" = "us-central1" ]; then
    ZONE2="us-east4-b"
elif [ "$REGION" = "us-east4" ]; then
    ZONE2="us-east1-d"
else
    ZONE2="us-central1-b" 
fi

gcloud compute instances create instance-$acc1 instance-$acc2 \
--zone=$ZONE \
--machine-type=n2d-standard-4 \
--network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default \
--maintenance-policy=MIGRATE \
--provisioning-model=STANDARD \
--service-account=$service_acc \
--scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/trace.append \
--create-disk=auto-delete=yes,boot=yes,device-name=instance-20250226-072351,image=projects/ml-images/global/images/c0-deeplearning-common-cu123-v20250205-debian-11-py310-conda,mode=rw,size=50,type=pd-balanced \
--no-shielded-secure-boot \
--shielded-vtpm \
--shielded-integrity-monitoring \
--labels=goog-ec-src=vm_add-gcloud \
--reservation-affinity=any \
--metadata=startup-script='sudo apt update -y && sudo apt install git -y &&  sudo apt install screen -y && git clone https://github.com/RizqiKamall/minme && cd minme && sudo chmod +x * && sudo ./install.sh'
