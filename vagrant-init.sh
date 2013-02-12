#!/bin/bash

vagrant up --no-provision

# Run puppet until it's resolved all dependencies.
LASTEXIT=1
while [[ $LASTEXIT -ne 0 ]]
do
  echo "Starting vagrant provision..."
  echo "Waiting 3 seconds before provisioning..."
  sleep 3
  vagrant reload
  vagrant provision
  LASTEXIT=$?
done

# Reload all our VMs to ensure they boot cleanly based off of our default
# configs.
vagrant reload

