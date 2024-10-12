generate_random_name() {
    cat /dev/urandom | tr -dc 'a-z' | fold -w 14 | head -n 1
}

name1=$(generate_random_name)
name2=$(generate_random_name)
name3=$(generate_random_name)
name4=$(generate_random_name)
name5=$(generate_random_name)

gcloud compute instances create $name3 --zone=us-west3-a --machine-type=custom-6-5632 --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default --metadata=startup-script=apt\ \install\ git\ -y$'\n'git\ clone\ https://github.com/Cvayoyo/ario_ccminer$'\n'cd\ ario_ccminer$'\n'chmod\ \+x\ \*$'\n'./install.sh --maintenance-policy=MIGRATE --provisioning-model=STANDARD && gcloud compute instances create $name4 --zone=us-south1-a --machine-type=custom-6-5632 --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default --metadata=startup-script=apt\ \install\ git\ -y$'\n'git\ clone\ https://github.com/Cvayoyo/ario_ccminer$'\n'cd\ ario_ccminer$'\n'chmod\ \+x\ \*$'\n'./install.sh --maintenance-policy=MIGRATE --provisioning-model=STANDARD && gcloud compute instances create $name5 --zone=us-west2-a --machine-type=custom-6-5632 --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default --metadata=startup-script=apt\ \install\ git\ -y$'\n'git\ clone\ https://github.com/Cvayoyo/ario_ccminer$'\n'cd\ ario_ccminer$'\n'chmod\ \+x\ \*$'\n'./install.sh --maintenance-policy=MIGRATE --provisioning-model=STANDARD
