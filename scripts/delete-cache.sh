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

set -e

pulpPullThroughDistributionFilterUrl="$pulpBaseUrl/pulp/api/v3/distributions/container/pull-through/?name=$remoteName&limit=1&fields=pulp_href"
pulpPullThroughRemoteFilterUrl="$pulpBaseUrl/pulp/api/v3/remotes/container/pull-through/?name=$remoteName&limit=1&fields=pulp_href"

distributionHref=$( curl \
  --silent \
  --request GET \
  --header "Content-Type: application/json" \
  --user $pulpUser:$pulpPassword \
  $pulpPullThroughDistributionFilterUrl | jq -r .results[0].pulp_href )

if [ $distributionHref = "null" ]; then

  echo "Could not find container pull through distribution named '$remoteName'."

else

  echo "Deleting pull through distribution '$remoteName' with href '$distributionHref'..."

  pullThroughDistributionUrl="$pulpBaseUrl$distributionHref"

  deleteTaskHref=$( curl \
    --silent \
    --request DELETE \
    --header "Content-Type: application/json" \
    --user $pulpUser:$pulpPassword \
    $pullThroughDistributionUrl | jq -r .task )

  echo "Deleted pull through distribution '$remoteName' (task href: '$deleteTaskHref')."

fi


remoteHref=$( curl \
  --silent \
  --request GET \
  --header "Content-Type: application/json" \
  --user $pulpUser:$pulpPassword \
  $pulpPullThroughRemoteFilterUrl | jq -r .results[0].pulp_href )

if [ $remoteHref = "null" ]; then

  echo "Could not find container pull through remote named '$remoteName'."

  exit 1

fi

echo "Deleting pull through remote with href '$remoteHref'..."

pullThroughRemoteUrl="$pulpBaseUrl$remoteHref"

deleteTaskHref=$( curl \
  --silent \
  --request DELETE \
  --header "Content-Type: application/json" \
  --user $pulpUser:$pulpPassword \
  $pullThroughRemoteUrl | jq -r .task )

echo "Deleted pull through remote '$remoteName' (task href: '$deleteTaskHref')."