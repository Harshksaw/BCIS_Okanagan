#!/bin/bash

################################################################################
# COSC 360 Lab 10 - GKE Cleanup Script
# This script removes all GKE resources to avoid charges
################################################################################

set -e  # Exit on error

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
DEPLOYMENT_NAME="lab6-flask-deployment"
SERVICE_NAME="lab6-flask-service"
CLUSTER_NAME="lab6-cluster"
REGION="us-central1"

echo -e "${BLUE}=================================${NC}"
echo -e "${BLUE}COSC 360 Lab 10 - Cleanup${NC}"
echo -e "${BLUE}=================================${NC}"
echo ""

# Read deployment info if it exists
if [ -f "deployment-info.txt" ]; then
    echo -e "${GREEN}Found deployment-info.txt${NC}"
    PROJECT_ID=$(grep "Project ID:" deployment-info.txt | cut -d: -f2 | xargs)
    CLUSTER_NAME=$(grep "Cluster Name:" deployment-info.txt | cut -d: -f2 | xargs)
    REGION=$(grep "Region:" deployment-info.txt | cut -d: -f2 | xargs)

    echo "Will cleanup:"
    echo "  Project: $PROJECT_ID"
    echo "  Cluster: $CLUSTER_NAME"
    echo "  Region: $REGION"
    echo ""
else
    echo -e "${YELLOW}No deployment-info.txt found. Please enter details:${NC}"
    read -p "Enter your Google Cloud Project ID: " PROJECT_ID
    read -p "Enter cluster name [$CLUSTER_NAME]: " INPUT_CLUSTER
    CLUSTER_NAME=${INPUT_CLUSTER:-$CLUSTER_NAME}
    read -p "Enter region [$REGION]: " INPUT_REGION
    REGION=${INPUT_REGION:-$REGION}
    echo ""
fi

# Confirmation
echo -e "${RED}⚠  WARNING: This will DELETE:${NC}"
echo "  - Load Balancer Service ($SERVICE_NAME)"
echo "  - Deployment ($DEPLOYMENT_NAME)"
echo "  - GKE Cluster ($CLUSTER_NAME)"
echo ""
echo -e "${YELLOW}This action cannot be undone!${NC}"
echo ""
read -p "Are you sure you want to continue? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo -e "${YELLOW}Cleanup cancelled.${NC}"
    exit 0
fi

echo ""
echo -e "${GREEN}Starting cleanup...${NC}"
echo ""

# Set project
echo -e "${BLUE}[1/5] Setting project...${NC}"
gcloud config set project $PROJECT_ID
echo ""

# Get cluster credentials
echo -e "${BLUE}[2/5] Getting cluster credentials...${NC}"
gcloud container clusters get-credentials $CLUSTER_NAME --region=$REGION 2>/dev/null || {
    echo -e "${YELLOW}⚠ Could not get credentials. Cluster may already be deleted.${NC}"
}
echo ""

# Delete service (load balancer)
echo -e "${BLUE}[3/5] Deleting load balancer service...${NC}"
kubectl delete service $SERVICE_NAME 2>/dev/null && {
    echo -e "${GREEN}✓ Service deleted${NC}"
} || {
    echo -e "${YELLOW}⚠ Service not found or already deleted${NC}"
}
echo ""

# Delete deployment
echo -e "${BLUE}[4/5] Deleting deployment...${NC}"
kubectl delete deployment $DEPLOYMENT_NAME 2>/dev/null && {
    echo -e "${GREEN}✓ Deployment deleted${NC}"
} || {
    echo -e "${YELLOW}⚠ Deployment not found or already deleted${NC}"
}
echo ""

# Delete cluster
echo -e "${BLUE}[5/5] Deleting GKE cluster...${NC}"
echo -e "${YELLOW}⏰ This takes 2-3 minutes${NC}"
gcloud container clusters delete $CLUSTER_NAME --region=$REGION --quiet && {
    echo -e "${GREEN}✓ Cluster deleted${NC}"
} || {
    echo -e "${YELLOW}⚠ Cluster not found or already deleted${NC}"
}
echo ""

# Archive deployment info
if [ -f "deployment-info.txt" ]; then
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    mv deployment-info.txt "deployment-info-${TIMESTAMP}.txt"
    echo -e "${GREEN}✓ Deployment info archived to: deployment-info-${TIMESTAMP}.txt${NC}"
fi

echo ""
echo -e "${BLUE}=================================${NC}"
echo -e "${GREEN}✓ CLEANUP COMPLETE${NC}"
echo -e "${BLUE}=================================${NC}"
echo ""
echo "All GKE resources have been deleted."
echo "You will no longer be charged for these resources."
echo ""
echo -e "${YELLOW}Note: Your Docker image is still on Docker Hub at:${NC}"
echo "  harshksaw/lab6-gke-app:v1"
echo ""
echo "To delete it:"
echo "  Visit https://hub.docker.com/repository/docker/harshksaw/lab6-gke-app"
echo ""
