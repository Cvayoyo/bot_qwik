#!/bin/bash
COUNT=$(gcloud compute instances list --format="value(name)" | wc -l)
if [ "$COUNT" -lt 3 ]; then
    sudo apt install screen -y
    curl -sSL https://raw.githubusercontent.com/Cvayoyo/bot_qwik/main/sc.sh | tr -d '\r' > sc.sh
    chmod +x sc.sh
    ./sc.sh
    sleep 10
fi
exit
