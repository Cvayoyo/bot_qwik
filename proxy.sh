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
gcloud compute firewall-rules create fw-ss-8388 --allow tcp:8388,udp:8388 --direction=INGRESS --priority=1000 --network=default --source-ranges=0.0.0.0/0 || echo "Firewall sudah ada"
gcloud compute instances create instance-$acc3 instance-$acc4 --project=$PROJECT_ID --zone=$ZONE --machine-type=n2d-custom-4-2048 --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default --metadata=startup-script="wget -q https://github.com/shadowsocks/shadowsocks-rust/releases/download/v1.23.4/shadowsocks-v1.23.4.x86_64-unknown-linux-gnu.tar.xz && tar -xf shadowsocks-v1.23.4.x86_64-unknown-linux-gnu.tar.xz && sudo mv ssserver sslocal ssmanager ssurl /usr/local/bin/ && sudo chmod +x /usr/local/bin/ss* && ip_private=$(hostname -I | awk '"'"'{print $1}'"'"') && nohup ssserver -U -s $ip_private:8388 -k Pass -m aes-128-gcm --worker-threads 10 --tcp-fast-open -v > ~/ssserver.log 2>&1 &" --maintenance-policy=MIGRATE --provisioning-model=STANDARD --service-account=$service_acc --scopes=https://www.googleapis.com/auth/cloud-platform --tags=http-server --create-disk=auto-delete=yes,boot=yes,device-name=dev-instance,image=projects/debian-cloud/global/images/debian-12-bookworm-v20250709,mode=rw,size=10,type=pd-balanced --no-shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring --reservation-affinity=any
gcloud compute instances create instance-acc1 instance-$acc2 --project=$PROJECT_ID --zone=$ZONE --machine-type=e2-custom-4-2048 --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default --metadata=startup-script="wget -q https://github.com/shadowsocks/shadowsocks-rust/releases/download/v1.23.4/shadowsocks-v1.23.4.x86_64-unknown-linux-gnu.tar.xz && tar -xf shadowsocks-v1.23.4.x86_64-unknown-linux-gnu.tar.xz && sudo mv ssserver sslocal ssmanager ssurl /usr/local/bin/ && sudo chmod +x /usr/local/bin/ss* && ip_private=$(hostname -I | awk '"'"'{print $1}'"'"') && nohup ssserver -U -s $ip_private:8388 -k Pass -m aes-128-gcm --worker-threads 10 --tcp-fast-open -v > ~/ssserver.log 2>&1 &" --maintenance-policy=MIGRATE --provisioning-model=STANDARD --service-account=$service_acc --scopes=https://www.googleapis.com/auth/cloud-platform --tags=http-server --create-disk=auto-delete=yes,boot=yes,device-name=dev-instance,image=projects/debian-cloud/global/images/debian-12-bookworm-v20250709,mode=rw,size=10,type=pd-balanced --no-shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring --reservation-affinity=any
echo "Proses selesai!"
'
sleep 10
# Loop untuk menunggu screen selesai, lalu tutup Cloud Shell
while screen -ls | grep -q deploy_instances; do
  sleep 1
done
exit
