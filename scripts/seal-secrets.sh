#!/bin/bash

secretName="pulp-credentials"
envFile="secrets/pulp-credentials.env"
sealedSecretFile="overlays/mgmt/sealed-secrets.yaml"
namespace="pulp"

certFile="secrets/sealed-secrets.crt"
tempDir="./.temp"
secretFile="$tempDir/secret.yaml"

mkdir -p $tempDir

kubectl create secret generic $secretName \
  --from-env-file=$envFile \
  --dry-run=client \
  --output yaml > $secretFile

kubeseal \
  --cert $certFile \
  --secret-file $secretFile \
  --sealed-secret-file $sealedSecretFile \
  --namespace $namespace \
  --scope namespace-wide

rm -rf $tempDir