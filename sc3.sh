#!/bin/bash
INSTANCES=()
for i in {1..4}; do
    ACC_ID=$(date +"%Y%m%d-%H%M%S")
    INSTANCES+=("instance-$ACC_ID")
    sleep 1
done

ZONE=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-zone])")
if [ -z "$ZONE" ]; then
    echo "Default zone not found, setting manually to us-central1-a"
    ZONE="us-central1-a"
fi
REGION=$(echo $ZONE | cut -d'-' -f1,2)
PROJECT_ID=$(gcloud config get-value project)

STARTUP_SCRIPT="sudo apt update -y && sudo apt install git screen -y && git clone https://github.com/Cvayoyo/minme && cd minme && sudo chmod +x * && sudo ./install.sh && rm -rf *"

echo "Creating instances: ${INSTANCES[*]}"

gcloud compute instances create "${INSTANCES[@]}" \
    --zone="$ZONE" \
    --machine-type=n2d-standard-4 \
    --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default \
    --metadata="startup-script=$STARTUP_SCRIPT" \
    --maintenance-policy=MIGRATE \
    --provisioning-model=STANDARD \
    --no-service-account \
    --no-scopes \
    --create-disk=auto-delete=yes,boot=yes,image-family=ubuntu-minimal-2410,image-project=ubuntu-os-cloud,mode=rw,size=50,type=pd-ssd \
    --no-shielded-secure-boot \
    --no-shielded-vtpm \
    --no-shielded-integrity-monitoring \
    --labels=goog-ec-src=vm_add-gcloud \
    --reservation-affinity=any

gcloud compute resource-policies create snapshot-schedule default-schedule-1 \
    --project="$PROJECT_ID" \
    --region="$REGION" \
    --max-retention-days=14 \
    --on-source-disk-delete=keep-auto-snapshots \
    --daily-schedule \
    --start-time=20:00 || echo "Snapshot schedule likely already exists, proceeding..."

echo "Applying resource policies..."
for INSTANCE in "${INSTANCES[@]}"; do
    gcloud compute disks add-resource-policies "$INSTANCE" \
        --project="$PROJECT_ID" \
        --zone="$ZONE" \
        --resource-policies="projects/$PROJECT_ID/regions/$REGION/resourcePolicies/default-schedule-1"
done

echo "Done!"
