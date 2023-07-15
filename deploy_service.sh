#!/bin/bash
set -e

start_time=$(date +%s)

echo "Deploying 5G network."

cd terraform
terraform apply -var-file="variables.tfvars"

public_ip=$(terraform output public_ip | sed 's/"//g')
URL="http://$public_ip:9090/"
DELAY_SECONDS=30
counter=0

while true; do
  if curl --fail --silent "$URL" >/dev/null 2>&1; then
    echo "Success! 5G network is deployed"
    echo "-------------------------------"
    echo "Access the following URLs:"
    echo "Prometheus: http://$public_ip:9090/"
    echo "cAdvisor: http://$public_ip:8080/"
    echo "Node exporter: http://$public_ip:9100/"
    echo "Free 5GC Web UI: http://$public_ip:5000/"
    break
  else
    if [ "$counter" -gt 1200 ]; then
      echo "There was a error while deploying 5G network. Check instance logs."
    fi
    echo "5G network deployment in progress. Retrying in $DELAY_SECONDS seconds..."
    sleep "$DELAY_SECONDS"
    ((counter=counter+$DELAY_SECONDS))
  fi
done

end_time=$(date +%s)                      # Capture the end time in seconds since the Unix epoch
execution_time=$((end_time - start_time)) # Calculate the execution time in seconds

#Printing it to minutes and seconds.
minutes=$((execution_time / 60))
remaining_seconds=$((execution_time % 60))


echo "Execution time: $minutes minutes, $remaining_seconds seconds"