#!/bin/bash

pulpBaseUrl=""
pulpUser="admin"
pulpPassword=""
remoteName=""

for arg in \"$@\"
  do
  case $1 in
    --remote-name)
      remoteName=$2
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

pulpPullThroughDistributionFilterUrl="$pulpBaseUrl/pulp/api/v3/distributions/container/pull-through/"
pulpPullThroughRemoteFilterUrl="$pulpBaseUrl/pulp/api/v3/remotes/container/pull-through/"

echo "Distribution:"

curl \
  --silent \
  --request GET \
  --header "Content-Type: application/json" \
  --user $pulpUser:$pulpPassword \
  $pulpPullThroughDistributionFilterUrl | jq -r .results

echo "Remote:"

curl \
  --silent \
  --request GET \
  --header "Content-Type: application/json" \
  --user $pulpUser:$pulpPassword \
  $pulpPullThroughRemoteFilterUrl | jq -r .results
