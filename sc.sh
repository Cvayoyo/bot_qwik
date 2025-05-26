screen -dmS deploy_instances bash -c '
acc1=$(date +"%Y%m%d-%H%M%S")
sleep 1
acc2=$(date +"%Y%m%d-%H%M%S")
service_acc=$(gcloud iam service-accounts list --format="value(email)" | sed -n 2p)
ZONE=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-zone])")
PROJECT_ID=$(gcloud config get-value core/project)
ZONE_REGION=$(echo "$ZONE" | cut -d '\''-'\'' -f 1-2)
gcloud services enable osconfig.googleapis.com
printf '\''agentsRule:\n  packageState: installed\n  version: latest\ninstanceFilter:\n  inclusionLabels:\n  - labels:\n      goog-ops-agent-policy: v2-x86-template-1-4-0\n'\'' > config.yaml
gcloud compute instances ops-agents policies create goog-ops-agent-v2-x86-template-1-4-0-$ZONE --project=$PROJECT_ID --zone=$ZONE --file=config.yaml
gcloud compute resource-policies create snapshot-schedule default-schedule-1 --project=$PROJECT_ID --region=$ZONE_REGION --max-retention-days=14 --on-source-disk-delete=keep-auto-snapshots --daily-schedule --start-time=07:00
gcloud compute instances create instance-$acc1 instance-$acc2 --project=$PROJECT_ID --zone=$ZONE --machine-type=n2d-standard-4 --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default --metadata=startup-script='\''sudo apt update -y && sudo apt install git -y && sudo apt install screen -y && git clone https://github.com/cvayoyo/minme && cd minme && sudo chmod +x * && sudo ./install.sh'\'' --maintenance-policy=MIGRATE --provisioning-model=STANDARD --service-account=$service_acc --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/trace.append --create-disk=auto-delete=yes,boot=yes,device-name=$acc1,disk-resource-policy=projects/$PROJECT_ID/regions/$ZONE_REGION/resourcePolicies/default-schedule-1,image=projects/ubuntu-os-accelerator-images/global/images/ubuntu-accelerator-2404-amd64-with-nvidia-570-v20250507,mode=rw,size=10,type=pd-balanced --no-shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring --labels=goog-ops-agent-policy=v2-x86-template-1-4-0,goog-ec-src=vm_add-gcloud --reservation-affinity=any
echo "Proses selesai!"
'
# Loop untuk menunggu screen selesai, lalu tutup Cloud Shell
while screen -ls | grep -q deploy_instances; do
  sleep 1
done
exit
