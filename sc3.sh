#!/bin/bash
INSTANCES=()
for i in {1..3}; do
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

STARTUP_SCRIPT="sudo apt install git screen -y && git clone https://github.com/Cvayoyo/minme && cd minme && sudo chmod +x * && sudo ./install.sh"

# 1. Create Snapshot Schedule (Must exist BEFORE creating instances if referencing it)
echo "Creating/Checking Snapshot Schedule..."
gcloud compute resource-policies create snapshot-schedule default-schedule-1 \
    --project="$PROJECT_ID" \
    --region="$REGION" \
    --max-retention-days=14 \
    --on-source-disk-delete=keep-auto-snapshots \
    --daily-schedule \
    --start-time=20:00 || echo "Snapshot schedule likely already exists, proceeding..."

# 2. Create Instances with Resource Policy applied directly to boot disk
echo "Creating instances: ${INSTANCES[*]}"

# Note: 'device-name' is omitted from --create-disk to allow auto-assignment/defaulting.
# If hardcoded in batch creation, it can cause conflicts or ambiguity.
# The resource policy is applied dynamically using project/region variables.

gcloud compute instances create "${INSTANCES[@]}" \
    --zone="$ZONE" \
    --machine-type=n2d-standard-4 \
    --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default \
    --metadata="startup-script=$STARTUP_SCRIPT" \
    --maintenance-policy=MIGRATE \
    --provisioning-model=STANDARD \
    --no-service-account \
    --no-scopes \
    --create-disk="auto-delete=yes,boot=yes,disk-resource-policy=projects/$PROJECT_ID/regions/$REGION/resourcePolicies/default-schedule-1,image=projects/ml-images/global/images/c0-deeplearning-common-cpu-v20250325-debian-11,mode=rw,size=50,type=pd-balanced" \
    --no-shielded-secure-boot \
    --no-shielded-vtpm \
    --no-shielded-integrity-monitoring \
    --labels=goog-ec-src=vm_add-gcloud \
    --reservation-affinity=any

echo "Done!"
