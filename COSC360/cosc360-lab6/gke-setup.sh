#!/bin/bash

# Lab 10 - GKE Deployment Script
# This script will deploy your Lab 6 application to Google Kubernetes Engine

set -e  # Exit on error

echo "=== Lab 10 GKE Deployment ==="
echo ""

# Step 1: Authenticate with Google Cloud
echo "Step 1: Authenticating with Google Cloud..."
echo "This will open a browser window for you to login."
gcloud auth login

# Step 2: Set your project (you'll be prompted to create one if needed)
echo ""
echo "Step 2: Setting up Google Cloud project..."
echo "If you don't have a project, you can create one at: https://console.cloud.google.com/projectcreate"
read -p "Enter your Google Cloud Project ID: " PROJECT_ID
gcloud config set project $PROJECT_ID

# Step 3: Enable required APIs
echo ""
echo "Step 3: Enabling required APIs..."
gcloud services enable container.googleapis.com

# Step 4: Create GKE Autopilot cluster
echo ""
echo "Step 4: Creating GKE Autopilot cluster (this takes ~5 minutes)..."
CLUSTER_NAME="lab6-cluster"
REGION="us-central1"

gcloud container clusters create-auto $CLUSTER_NAME \
    --region=$REGION \
    --project=$PROJECT_ID

# Step 5: Get cluster credentials
echo ""
echo "Step 5: Getting cluster credentials..."
gcloud container clusters get-credentials $CLUSTER_NAME --region=$REGION

# Step 6: Deploy the application
echo ""
echo "Step 6: Deploying your application..."
kubectl apply -f deployment.yaml

# Step 7: Wait for deployment to be ready
echo ""
echo "Step 7: Waiting for pods to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/lab6-flask-deployment

# Step 8: Expose via Load Balancer
echo ""
echo "Step 8: Creating load balancer..."
kubectl apply -f service.yaml

# Step 9: Wait for external IP
echo ""
echo "Step 9: Waiting for external IP (this takes ~2-3 minutes)..."
echo "Checking for external IP..."
for i in {1..30}; do
    EXTERNAL_IP=$(kubectl get service lab6-flask-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "")
    if [ ! -z "$EXTERNAL_IP" ]; then
        break
    fi
    echo "  Waiting... ($i/30)"
    sleep 10
done

if [ -z "$EXTERNAL_IP" ]; then
    echo "External IP not assigned yet. Run this command to check:"
    echo "  kubectl get service lab6-flask-service"
else
    echo ""
    echo "=== DEPLOYMENT SUCCESSFUL! ==="
    echo ""
    echo "Your application is now running on GKE!"
    echo ""
    echo "External IP: $EXTERNAL_IP"
    echo ""
    echo "Test your application:"
    echo "  curl http://$EXTERNAL_IP/myid"
    echo ""
    echo "Open in browser:"
    echo "  http://$EXTERNAL_IP/myid"
    echo ""
    echo "Screenshot #1: Take a screenshot of the workloads page:"
    echo "  https://console.cloud.google.com/kubernetes/workload?project=$PROJECT_ID"
    echo ""
    echo "Screenshot #2: Open multiple browser tabs to http://$EXTERNAL_IP/myid"
    echo "  Refresh multiple times to see different IDs (different pods)"
    echo ""
    echo "=== CLEANUP (IMPORTANT - to avoid charges!) ==="
    echo ""
    echo "When done, run these commands to clean up:"
    echo "  kubectl delete service lab6-flask-service"
    echo "  kubectl delete deployment lab6-flask-deployment"
    echo "  gcloud container clusters delete $CLUSTER_NAME --region=$REGION --quiet"
fi
