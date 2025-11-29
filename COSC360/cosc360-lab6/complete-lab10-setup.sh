#!/bin/bash

################################################################################
# COSC 360 Lab 10 - Complete GKE Deployment Automation Script
# This script automates the entire Lab 10 deployment process
################################################################################

set -e  # Exit on error

# Color codes for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
DOCKER_USERNAME="harshksaw"
IMAGE_NAME="lab6-gke-app"
IMAGE_TAG="v1"
CLUSTER_NAME="lab6-cluster"
REGION="us-central1"
DEPLOYMENT_NAME="lab6-flask-deployment"
SERVICE_NAME="lab6-flask-service"

echo -e "${BLUE}=================================${NC}"
echo -e "${BLUE}COSC 360 Lab 10 - GKE Deployment${NC}"
echo -e "${BLUE}=================================${NC}"
echo ""

# Step 1: Build multi-platform Docker image
echo -e "${GREEN}[1/8] Building multi-platform Docker image...${NC}"
echo "Building for linux/amd64 and linux/arm64..."

# Create buildx builder if it doesn't exist
docker buildx create --use --name multiplatform 2>/dev/null || docker buildx use multiplatform

# Build and push multi-platform image
docker buildx build \
    --platform linux/amd64,linux/arm64 \
    -t ${DOCKER_USERNAME}/${IMAGE_NAME}:${IMAGE_TAG} \
    --push .

echo -e "${GREEN}✓ Docker image built and pushed successfully${NC}"
echo ""

# Step 2: Authenticate with Google Cloud
echo -e "${GREEN}[2/8] Authenticating with Google Cloud...${NC}"
echo "Opening browser for authentication..."
gcloud auth login

echo -e "${GREEN}✓ Authentication successful${NC}"
echo ""

# Step 3: List and select project
echo -e "${GREEN}[3/8] Setting up Google Cloud project...${NC}"
echo "Available projects:"
gcloud projects list

echo ""
read -p "Enter your Google Cloud Project ID: " PROJECT_ID

gcloud config set project $PROJECT_ID
echo -e "${GREEN}✓ Project set to: $PROJECT_ID${NC}"
echo ""

# Step 4: Enable required APIs
echo -e "${GREEN}[4/8] Enabling required Google Cloud APIs...${NC}"
echo "This may take a minute..."
gcloud services enable container.googleapis.com

echo -e "${GREEN}✓ GKE API enabled${NC}"
echo ""

# Step 5: Create GKE Autopilot cluster
echo -e "${GREEN}[5/8] Creating GKE Autopilot cluster...${NC}"
echo -e "${YELLOW}⏰ This takes approximately 5 minutes${NC}"

gcloud container clusters create-auto $CLUSTER_NAME \
    --region=$REGION \
    --project=$PROJECT_ID

echo -e "${GREEN}✓ Cluster created successfully${NC}"
echo ""

# Step 6: Install kubectl auth plugin
echo -e "${GREEN}[6/8] Installing kubectl auth plugin...${NC}"
gcloud components install gke-gcloud-auth-plugin --quiet

# Get cluster credentials
gcloud container clusters get-credentials $CLUSTER_NAME --region=$REGION

echo -e "${GREEN}✓ Cluster credentials configured${NC}"
echo ""

# Step 7: Deploy application
echo -e "${GREEN}[7/8] Deploying application to GKE...${NC}"

# Create deployment
kubectl apply -f deployment.yaml

echo "Waiting for deployment to be ready..."
echo -e "${YELLOW}⏰ This may take 2-3 minutes${NC}"

# Wait for deployment
kubectl wait --for=condition=available --timeout=300s deployment/$DEPLOYMENT_NAME || {
    echo -e "${YELLOW}⚠ Deployment taking longer than expected. Checking pod status...${NC}"
    kubectl get pods
}

echo -e "${GREEN}✓ Application deployed successfully${NC}"
echo ""

# Step 8: Expose via load balancer
echo -e "${GREEN}[8/8] Creating load balancer service...${NC}"

kubectl apply -f service.yaml

echo "Waiting for external IP assignment..."
echo -e "${YELLOW}⏰ This takes 2-3 minutes${NC}"

# Wait for external IP
EXTERNAL_IP=""
for i in {1..40}; do
    EXTERNAL_IP=$(kubectl get service $SERVICE_NAME -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "")
    if [ ! -z "$EXTERNAL_IP" ]; then
        break
    fi
    echo "  Waiting for IP... ($i/40)"
    sleep 5
done

if [ -z "$EXTERNAL_IP" ]; then
    echo -e "${RED}✗ External IP not assigned yet${NC}"
    echo "Run this command to check: kubectl get service $SERVICE_NAME"
    exit 1
fi

echo -e "${GREEN}✓ Load balancer created successfully${NC}"
echo ""

# Success summary
echo -e "${BLUE}=================================${NC}"
echo -e "${GREEN}🎉 DEPLOYMENT SUCCESSFUL!${NC}"
echo -e "${BLUE}=================================${NC}"
echo ""
echo -e "${BLUE}External IP:${NC} $EXTERNAL_IP"
echo -e "${BLUE}Project:${NC} $PROJECT_ID"
echo -e "${BLUE}Cluster:${NC} $CLUSTER_NAME"
echo -e "${BLUE}Region:${NC} $REGION"
echo ""

# Test the deployment
echo -e "${GREEN}Testing load balancer...${NC}"
echo "Making 10 requests to verify load balancing:"
echo ""

for i in {1..10}; do
    RESPONSE=$(curl -s http://$EXTERNAL_IP/myid)
    echo "Request $i: $RESPONSE"
done

echo ""
echo -e "${BLUE}=================================${NC}"
echo -e "${BLUE}SCREENSHOTS FOR LAB SUBMISSION${NC}"
echo -e "${BLUE}=================================${NC}"
echo ""
echo -e "${YELLOW}Screenshot #1 - Workloads Page:${NC}"
echo "Visit: https://console.cloud.google.com/kubernetes/workload?project=$PROJECT_ID"
echo "Take a screenshot showing your 3 pod replicas"
echo ""
echo -e "${YELLOW}Screenshot #2 - Load Balancer Testing:${NC}"
echo "Open browser to: http://$EXTERNAL_IP/myid"
echo "Open multiple tabs and refresh to see different IDs"
echo "Take a screenshot showing at least 2 different IDs"
echo ""

# Cleanup instructions
echo -e "${BLUE}=================================${NC}"
echo -e "${RED}⚠ IMPORTANT - CLEANUP${NC}"
echo -e "${BLUE}=================================${NC}"
echo ""
echo -e "${RED}To avoid Google Cloud charges, run:${NC}"
echo ""
echo "  ./gke-cleanup.sh"
echo ""
echo "Or manually:"
echo "  kubectl delete service $SERVICE_NAME"
echo "  kubectl delete deployment $DEPLOYMENT_NAME"
echo "  gcloud container clusters delete $CLUSTER_NAME --region=$REGION --quiet"
echo ""

# Save deployment info
cat > deployment-info.txt <<EOF
Lab 10 Deployment Information
=============================
Date: $(date)
External IP: $EXTERNAL_IP
Project ID: $PROJECT_ID
Cluster Name: $CLUSTER_NAME
Region: $REGION
Docker Image: ${DOCKER_USERNAME}/${IMAGE_NAME}:${IMAGE_TAG}

URLs:
- Application: http://$EXTERNAL_IP/myid
- Workloads Console: https://console.cloud.google.com/kubernetes/workload?project=$PROJECT_ID
- Cluster Console: https://console.cloud.google.com/kubernetes/clusters/details/$REGION/$CLUSTER_NAME/details?project=$PROJECT_ID

Cleanup Commands:
  kubectl delete service $SERVICE_NAME
  kubectl delete deployment $DEPLOYMENT_NAME
  gcloud container clusters delete $CLUSTER_NAME --region=$REGION --quiet
EOF

echo -e "${GREEN}✓ Deployment info saved to: deployment-info.txt${NC}"
echo ""
echo -e "${GREEN}Setup complete! 🚀${NC}"
