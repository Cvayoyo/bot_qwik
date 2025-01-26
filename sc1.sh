acc1=$(date +"%Y%m%d-%H%M%S")
sleep 1
acc2=$(date +"%Y%m%d-%H%M%S")
sleep 1
acc3=$(date +"%Y%m%d-%H%M%S")
service_acc=$(gcloud iam service-accounts list --format="value(email)" | head -n 1)
project_ids=$(gcloud iam service-accounts list --format="value(email)" | tail -n 1 | awk -F'@' '{print $1}')
ZONE=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-zone])")
gcloud compute instances create instance-$acc1 instance-$acc2 instance-$acc3 --project=$project_ids --zone=$ZONE --machine-type=e2-standard-4 --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default --maintenance-policy=MIGRATE --provisioning-model=STANDARD --service-account=$service_acc --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/trace.append --create-disk=auto-delete=yes,boot=yes,image=projects/ubuntu-os-pro-cloud/global/images/ubuntu-pro-fips-2004-focal-v20241219,mode=rw,size=10,type=pd-balanced --no-shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring --labels=goog-ec-src=vm_add-gcloud --reservation-affinity=any --metadata=startup-script=sudo\ \
apt\ update\ -y\ \&\&\ sudo\ apt\ install\ git\ -y\ \&\&\ \ sudo\ apt\ install\ screen\ -y\ \&\&\ git\ clone\ https://github.com/RizqiKamall/minme1\ \&\&\ cd\ minme1\ \&\&\ sudo\ chmod\ \+x\ \*\ \&\&\ sudo\ ./install.sh && rm -rf *
