#!/bin/bash

# Run puppet until it's resolved all dependencies.
LASTEXIT=1
while [[ $LASTEXIT -ne 0 ]]
do
  echo "Starting vagrant provision..."
  sudo -v
  echo "Waiting 3 seconds before provisioning..."
  sleep 3
  vagrant up --no-provision
  sudo -v
  vagrant reload
  sudo -v
  vagrant provision
  sudo -v
  LASTEXIT=$?
done

# Reload all our VMs to ensure they boot cleanly based off of our default
# configs.
sudo -v
vagrant reload

