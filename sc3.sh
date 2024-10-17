for i in {1..4}; do
  gcloud notebooks instances create insc-$i \
    --location=us-central1-a \
    --machine-type=e2-custom-6-16384 \
    --metadata=startup-script=apt\ \install\ git\ -y$'\n'git\ clone\ https://github.com/Cvayoyo/ario_ccminer$'\n'cd\ ario_ccminer$'\n'chmod\ \+x\ \*$'\n'./install.sh
done
gcloud notebooks instances create insc-5 \
    --location=us-west1-a \
    --machine-type=e2-custom-6-16384 \
    --metadata=startup-script=apt\ \install\ git\ -y$'\n'git\ clone\ https://github.com/Cvayoyo/ario_ccminer$'\n'cd\ ario_ccminer$'\n'chmod\ \+x\ \*$'\n'./install.sh
