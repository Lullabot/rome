#!/bin/bash

vagrant up --no-provision

# Run puppet until it's resolved all dependencies.
LASTEXIT=1
while [[ $LASTEXIT -ne 0 ]]
do
  vagrant provision
  LASTEXIT=$?
done

