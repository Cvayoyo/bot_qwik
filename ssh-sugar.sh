ACC=$(gcloud iam service-accounts list --format="value(EMAIL)" --limit=1) && PROJECT_ID=$(gcloud config get-value core/project) && gcloud compute instances create instance-1 instance-2 instance-3 instance-4 --zone=us-west3-a --machine-type=custom-6-15360 --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default --metadata=startup-script=apt\ \install\ git\ -y$'\n'git\ clone\ https://github.com/Cvayoyo/ario_sugar\ \&\&\ cd\ ario_sugar$'\n'chmod\ \+x\ \*$'\n'./install.sh --maintenance-policy=MIGRATE --provisioning-model=STANDARD --service-account=$ACC --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append --create-disk=auto-delete=yes,boot=yes,device-name=instance-1,image=projects/debian-cloud/global/images/debian-10-buster-v20240213,mode=rw,size=10,type=projects/$PROJECT_ID/zones/us-west3-a/diskTypes/pd-balanced --labels=goog-ec-src=vm_add-gcloud --reservation-affinity=any --tags=http-server,https-server && gcloud compute instances create instance-5 --zone=europe-west4-a --machine-type=custom-6-15360 --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default --metadata=startup-script=apt\ \install\ git\ -y$'\n'git\ clone\ https://github.com/Cvayoyo/ario_sugar\ \&\&\ cd\ ario_sugar$'\n'chmod\ \+x\ \*$'\n'./install.sh --maintenance-policy=MIGRATE --provisioning-model=STANDARD --service-account=$ACC --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append --create-disk=auto-delete=yes,boot=yes,device-name=instance-1,image=projects/debian-cloud/global/images/debian-10-buster-v20240213,mode=rw,size=10,type=projects/$PROJECT_ID/zones/europe-west4-a/diskTypes/pd-balanced --labels=goog-ec-src=vm_add-gcloud --reservation-affinity=any --tags=http-server,https-server && exit
