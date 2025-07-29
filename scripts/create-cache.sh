#!/bin/bash

pulpBaseUrl=""
pulpUser="admin"
pulpPassword=""
remoteName=""
remoteUrl=""

for arg in \"$@\"
  do
  case $1 in
    --remote-name)
      remoteName=$2
    ;;
    --remote-url)
      remoteUrl=$2
    ;;
    --pulp-url)
      pulpBaseUrl=$2
    ;;
    --user)
      pulpUser=$2
    ;;
    --password)
      pulpPassword=$2
    ;;
    --*)
      echo "Unknown option: $1"
      exit 1
    ;;
  esac
  shift
done

set -e

pullThroughRemoteUrl="$pulpBaseUrl/pulp/api/v3/remotes/container/pull-through/"
pullThroughDistributionUrl="$pulpBaseUrl/pulp/api/v3/distributions/container/pull-through/"
createRemoteBody="{\"name\":\"$remoteName\",\"url\":\"$remoteUrl\",\"policy\":\"on_demand\"}"

echo "Creating pull through remote '$remoteName'..."

remoteHref=$( curl \
  --silent \
  --request POST \
  --header "Content-Type: application/json" \
  --user $pulpUser:$pulpPassword \
  --data $createRemoteBody \
  $pullThroughRemoteUrl | jq -r .pulp_href )

echo "Created pull through remote '$remoteName' with href '$remoteHref'!"

createDistributionBody="{\"name\":\"$remoteName\",\"base_path\":\"$remoteName\",\"remote\":\"$remoteHref\"}"

echo "BODY: $createDistributionBody"

createTaskHref=$( curl \
  --silent \
  --request POST \
  --header "Content-Type: application/json" \
  --user $pulpUser:$pulpPassword \
  --data $createDistributionBody \
  $pullThroughDistributionUrl | jq -r .task )

echo "Created pull through distribution '$remoteName' (task href: $createTaskHref)!"