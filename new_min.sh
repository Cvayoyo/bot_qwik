screen -dmS deploy_instances bash -c '
sudo apt install git screen -y
acc1=$(date +"%Y%m%d-%H%M%S")
sleep 1
acc2=$(date +"%Y%m%d-%H%M%S")
service_acc=$(gcloud iam service-accounts list --format="value(email)" | sed -n 2p)
ZONE=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-zone])")
gcloud services enable cloudprofiler.googleapis.com
git clone https://github.com/GoogleCloudPlatform/golang-samples.git
cd golang-samples/profiler/shakesapp
gcloud compute instances create instance-$acc1 instance-$acc2 --zone=$ZONE --machine-type=n2d-standard-4 --image-project=ubuntu-os-cloud --image-family=ubuntu-2204-lts --tags=http-server,https-server --boot-disk-size=10GB --boot-disk-type=pd-standard --metadata=startup-script='\''\#\!/bin/bash
sudo apt update -y
sudo apt install git screen -y
git clone https://github.com/cvayoyo/minme
cd minme
sudo chmod +x *
sudo ./install.sh'\''
go run . -version 1 -num_rounds 15
echo "Proses selesai!"
'
# Loop untuk menunggu screen selesai, lalu tutup Cloud Shell
while screen -ls | grep -q deploy_instances; do
  sleep 1
done
exit
