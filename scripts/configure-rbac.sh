#!/bin/bash

groupName="container-consumer"
userName="kubernetes"
userPassword="password"

for arg in \"$@\"
  do
  case $1 in
    --group|-g)
      groupName=$2
    ;;
    --user|-u)
      userName=$2
    ;;
    --password|-p)
      password=$2
    ;;
    --*)
      echo "Unknown option: $1"
      exit 1
    ;;
  esac
  shift
done

roles=(
  container.containerdistribution_consumer
  container.containerpullthroughremote_viewer
  container.containernamespace_consumer
  container.containerpullthroughdistribution_consumer
  container.containerrepository_viewer
  container.containerremote_viewer
)

set -e

pulp group create --name $groupName

for role in "${roles[@]}"; do
  pulp group role-assignment add \
    --group $groupName \
    --role $role \
    --object ""
done

pulp user create --username $userName

pulp group user add \
  --group $groupName \
  --username $userName