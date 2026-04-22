#!/bin/bash

NAMESPACE="formazione-sou"
DEPLOYMENT_NAME="flask-release-flask-chart"

TOKEN=$(kubectl create token cluster-reader-sa -n $NAMESPACE)

API_SERVER=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')

echo "Using API server: $API_SERVER"

curl -k \
  -H "Authorization: Bearer $TOKEN" \
  "$API_SERVER/apis/apps/v1/namespaces/$NAMESPACE/deployments/$DEPLOYMENT_NAME" \
  -o deployment.json

echo "Checking readinessProbe..."
grep -q "readinessProbe" deployment.json || {
  echo "ERROR: readinessProbe missing"
  exit 1
}

echo "Checking livenessProbe..."
grep -q "livenessProbe" deployment.json || {
  echo "ERROR: livenessProbe missing"
  exit 1
}

echo "Checking requests..."
grep -q "requests" deployment.json || {
  echo "ERROR: requests missing"
  exit 1
}

echo "Checking limits..."
grep -q "limits" deployment.json || {
  echo "ERROR: limits missing"
  exit 1
}

echo "Deployment configuration valid"
