acc1=$(date +"%Y%m%d-%H%M%S"); sleep 1; acc2=$(date +"%Y%m%d-%H%M%S"); sleep 1; acc3=$(date +"%Y%m%d-%H%M%S"); sleep 1; acc4=$(date +"%Y%m%d-%H%M%S"); service_acc=$(gcloud iam service-accounts list --format="value(email)" | head -n 1); ZONE=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-zone])"); gcloud compute instances create instance-$acc1 instance-$acc2 --zone=$ZONE --machine-type=n2d-standard-4 --service-account=$service_acc --create-disk=image=projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20250130 --metadata=startup-script=sudo\ apt\ update\ -y\ \&\&\ sudo\ apt\ install\ git\ -y\ \&\&\ sudo\ apt\ install\ screen\ -y\ \&\&\ git\ clone\ https://github.com/RizqiKamall/minme1\ \&\&\ cd\ minme1\ \&\&\ sudo\ chmod\ \+x\ \*\ \&\&\ sudo\ ./install.sh && rm -rf * && gcloud compute instances create instance-$acc3 instance-$acc4 --zone=$ZONE --machine-type=e2-standard-4 --service-account=$service_acc --create-disk=image=projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20250130 --metadata=startup-script=sudo\ apt\ update\ -y\ \&\&\ sudo\ apt\ install\ git\ -y\ \&\&\ sudo\ apt\ install\ screen\ -y\ \&\&\ git\ clone\ https://github.com/RizqiKamall/minme1\ \&\&\ cd\ minme1\ \&\&\ sudo\ chmod\ \+x\ \*\ \&\&\ sudo\ ./install.sh && rm -rf * 
