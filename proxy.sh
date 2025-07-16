bash -c "cat << 'EOF' > deploy.sh
ZONE=\$(gcloud compute project-info describe --format=\"value(commonInstanceMetadata.items[google-compute-default-zone])\")
PROJECT_ID=\$(gcloud config get-value core/project)
ZONE_REGION=\$(echo \"\$ZONE\" | cut -d '-' -f 1-2)
SERVICE_ACC=\$(gcloud iam service-accounts list --format=\"value(email)\" | sed -n 2p)

for i in {1..2}; do
  ts=\$(date +\"%Y%m%d-%H%M%S\")
  name=\"instance-\$ts\"
  echo \"Membuat \$name...\"

  gcloud compute instances create \"\$name\" \\
    --project=\"\$PROJECT_ID\" \\
    --zone=\"\$ZONE\" \\
    --machine-type=e2-medium \\
    --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default \\
    --metadata=startup-script='wget https://github.com/shadowsocks/shadowsocks-rust/releases/download/v1.23.4/shadowsocks-v1.23.4.x86_64-unknown-linux-gnu.tar.xz && tar -xvf shadowsocks-v1.23.4.x86_64-unknown-linux-gnu.tar.xz && mv ssserver sslocal ssmanager ssurl /usr/local/bin/ && chmod +x /usr/local/bin/ss* && ip_private=\$(hostname -I | awk '\''{print \$1}'\'') && ssserver -U -s \$ip_private:8388 -k Pass -m aes-128-gcm --worker-threads 10 --tcp-fast-open -v > /var/log/ssserver.log 2>&1 &' \\
    --tags=allow-all \\
    --maintenance-policy=MIGRATE \\
    --provisioning-model=STANDARD \\
    --service-account=\"\$SERVICE_ACC\" \\
    --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/trace.append \\
    --create-disk=auto-delete=yes,boot=yes,image=projects/ubuntu-os-cloud/global/images/ubuntu-minimal-2504-plucky-amd64-v20250606,mode=rw,size=10,type=pd-balanced \\
    --no-shielded-secure-boot \\
    --shielded-vtpm \\
    --shielded-integrity-monitoring \\
    --labels=goog-ops-agent-policy=v2-x86-template-1-4-0,goog-ec-src=vm_add-gcloud \\
    --reservation-affinity=any

  sleep 2
done

echo \"SEMUA INSTANCE SELESAI DIBUAT\"
gcloud compute instances list --filter=\"tags.items=allow-all\" --format=\"table(name,networkInterfaces[0].accessConfigs[0].natIP)\"
EOF
chmod +x deploy.sh && nohup ./deploy.sh > deploy.log 2>&1 &"


gcloud compute firewall-rules create lolipsdfr --direction=INGRESS --priority=1000 --network=default --action=ALLOW --rules=all --source-ranges=0.0.0.0/0
