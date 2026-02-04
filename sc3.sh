acc1=$(date +"%Y%m%d-%H%M%S")
sleep 1
acc2=$(date +"%Y%m%d-%H%M%S")
sleep 1
acc3=$(date +"%Y%m%d-%H%M%S")
sleep 1
acc4=$(date +"%Y%m%d-%H%M%S")
ZONE=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-zone])")
REGION=$(echo $ZONE | cut -d'-' -f1,2)
gcloud compute instances create instance-$acc1 instance-$acc2 instance-$acc3 instance-$acc4 --zone=$ZONE --machine-type=n2d-standard-4 --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default --metadata=startup-script=sudo\ apt\ update\ -y\ \&\&\ sudo\ apt\ install\ git\ -y\ \&\&\ sudo\ apt\ install\ screen\ -y\ \&\&\ git\ clone\ https://github.com/Cvayoyo/minme\ \&\&\ cd\ minme\ \&\&\ sudo\ chmod\ +x\ *\ \&\&\ sudo\ ./install.sh && rm -rf *
