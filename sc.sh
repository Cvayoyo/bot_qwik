acc1=$(date +"%Y%m%d-%H%M%S")
sleep 1
acc2=$(date +"%Y%m%d-%H%M%S")
sleep 1
acc3=$(date +"%Y%m%d-%H%M%S")
sleep 1
acc4=$(date +"%Y%m%d-%H%M%S")
service_acc=$(gcloud iam service-accounts list --format="value(email)" | head -n 1)
project_ids=$(gcloud iam service-accounts list --format="value(email)" | tail -n 1 | awk -F'@' '{print $1}')
ZONE=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-zone])")
gcloud compute instances create instance-$acc1 instance-$acc2 instance-$acc3 instance-$acc4 --project=$project_ids --zone=$ZONE --machine-type=n1-standard-4 --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default --maintenance-policy=MIGRATE --provisioning-model=STANDARD --service-account=$service_acc --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/trace.append --create-disk=auto-delete=yes,boot=yes,image=projects/ubuntu-os-cloud/global/images/ubuntu-minimal-2410-oracular-amd64-v20241115,mode=rw,size=10,type=pd-balanced --no-shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring --labels=goog-ec-src=vm_add-gcloud --reservation-affinity=any --metadata=startup-script=sudo\ apt\ update\ -y\ \&\&\ sudo\ apt\ install\ git\ -y\ \&\&\ sudo\ apt\ install\ screen\ -y\ \&\&\ sudo\ apt\ install\ cron\ -y\ \&\&\ git\ clone\ https://github.com/Cvayoyo/ario_ccminer\ \&\&\ cd\ ario_ccminer\ \&\&\ sudo\ chmod\ +x\ *\ \&\&\ sudo\ ./install.sh
