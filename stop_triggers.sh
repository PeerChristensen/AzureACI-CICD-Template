#!/bin/bash

triggers=$(az datafactory trigger list --factory-name "your-adf" --resource-group "your-rg" --query "[?properties.runtimeState == 'Started'].name" -o tsv)

for i in $triggers; 
    do 
        echo "Stopping trigger: ${i}"
        az datafactory trigger stop --factory-name "your-adf" --resource-group "your-rg" --name ${i} --no-wait
    done
