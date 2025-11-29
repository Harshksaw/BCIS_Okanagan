# COSC 360 - Lab 10: GKE Deployment

This directory contains automation scripts for deploying a Flask application to Google Kubernetes Engine (GKE).

## What This Lab Does

Deploys a Flask application that:
- Generates a random ID when started
- Returns that ID via the `/myid` endpoint
- Demonstrates load balancing across multiple pods in GKE

## Files

| File | Description |
|------|-------------|
| `complete-lab10-setup.sh` | Complete automation script for full deployment |
| `gke-cleanup.sh` | Script to remove all GKE resources |
| `deployment.yaml` | Kubernetes deployment configuration |
| `service.yaml` | Kubernetes load balancer service configuration |
| `app.py` | Flask application code |
| `Dockerfile` | Docker image configuration |

## Quick Start

### Option 1: Full Automation (Recommended)

Run the complete setup script:

```bash
./complete-lab10-setup.sh
```

This script will:
1. Build multi-platform Docker image
2. Push to Docker Hub
3. Authenticate with Google Cloud
4. Set up GKE cluster
5. Deploy application
6. Create load balancer
7. Test and display results

### Option 2: Manual Step-by-Step

If you prefer to run steps individually:

#### 1. Build and Push Docker Image

```bash
# Create buildx builder
docker buildx create --use --name multiplatform

# Build for multiple platforms and push
docker buildx build \
    --platform linux/amd64,linux/arm64 \
    -t harshksaw/lab6-gke-app:v1 \
    --push .
```

#### 2. Setup Google Cloud

```bash
# Login
gcloud auth login

# Set project
gcloud config set project YOUR_PROJECT_ID

# Enable GKE API
gcloud services enable container.googleapis.com
```

#### 3. Create GKE Cluster

```bash
# Create Autopilot cluster (takes ~5 minutes)
gcloud container clusters create-auto lab6-cluster \
    --region=us-central1

# Install kubectl auth plugin
gcloud components install gke-gcloud-auth-plugin

# Get credentials
gcloud container clusters get-credentials lab6-cluster \
    --region=us-central1
```

#### 4. Deploy Application

```bash
# Deploy
kubectl apply -f deployment.yaml

# Wait for pods to be ready
kubectl wait --for=condition=available --timeout=300s \
    deployment/lab6-flask-deployment
```

#### 5. Expose via Load Balancer

```bash
# Create service
kubectl apply -f service.yaml

# Get external IP (may take 2-3 minutes)
kubectl get service lab6-flask-service
```

#### 6. Test

```bash
# Get the external IP
EXTERNAL_IP=$(kubectl get service lab6-flask-service \
    -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

# Test load balancing
for i in {1..10}; do
    curl http://$EXTERNAL_IP/myid
    echo ""
done
```

## Lab Submission Requirements

### Screenshot #1: GKE Workloads Page

Visit Google Cloud Console:
```
https://console.cloud.google.com/kubernetes/workload?project=YOUR_PROJECT_ID
```

Take a screenshot showing:
- Your deployment with 3 replicas
- All pods in "Running" status

### Screenshot #2: Load Balancer Testing

1. Open browser to: `http://<EXTERNAL_IP>/myid`
2. Open multiple tabs
3. Refresh several times
4. Take screenshot showing at least 2 different IDs

This proves requests are being distributed across different pods.

## Cleanup (IMPORTANT!)

To avoid Google Cloud charges, always cleanup after finishing:

```bash
./gke-cleanup.sh
```

Or manually:

```bash
# Delete load balancer service
kubectl delete service lab6-flask-service

# Delete deployment
kubectl delete deployment lab6-flask-deployment

# Delete cluster
gcloud container clusters delete lab6-cluster \
    --region=us-central1 \
    --quiet
```

## Current Deployment Info

If you just ran the setup script, check `deployment-info.txt` for:
- External IP address
- Project ID
- Cluster details
- Console URLs
- Cleanup commands

## Troubleshooting

### Image Pull Errors

If you see `ImagePullBackOff` errors:

```bash
# Check pod details
kubectl describe pod <POD_NAME>

# Rebuild with correct platform
docker buildx build --platform linux/amd64,linux/arm64 \
    -t harshksaw/lab6-gke-app:v1 --push .

# Update deployment
kubectl set image deployment/lab6-flask-deployment \
    lab6-flask=harshksaw/lab6-gke-app:v1
```

### External IP Pending

If external IP shows `<pending>`:

```bash
# Wait and check again
kubectl get service lab6-flask-service -w
```

Usually takes 2-3 minutes to assign.

### Billing Not Enabled

If you get billing errors:

1. Go to: https://console.cloud.google.com/billing
2. Link a billing account to your project
3. Google provides $300 in free credits for new users

## Architecture

```
┌─────────────────────────────────────────┐
│         Load Balancer (External IP)      │
│              Port 80                     │
└──────────────┬──────────────────────────┘
               │
       ┌───────┴────────┬─────────────┐
       │                │             │
   ┌───▼───┐       ┌────▼──┐      ┌───▼───┐
   │ Pod 1 │       │ Pod 2 │      │ Pod 3 │
   │ID: abc│       │ID: def│      │ID: ghi│
   └───────┘       └───────┘      └───────┘
```

Each pod generates a unique random ID on startup, demonstrating load distribution.

## Cost Information

**GKE Autopilot** charges for:
- Pod resource usage (CPU/Memory)
- Load balancer

**Approximate costs:**
- ~$0.10/hour for 3 small pods
- ~$0.025/hour for load balancer

**Total:** ~$0.125/hour (~$3/day if left running)

**Always cleanup after completing the lab!**

## Support

If you encounter issues:

1. Check `deployment-info.txt` for your deployment details
2. Review pod logs: `kubectl logs <POD_NAME>`
3. Check pod status: `kubectl describe pod <POD_NAME>`
4. Verify service: `kubectl get service lab6-flask-service`

## Additional Commands

```bash
# View all pods
kubectl get pods

# View pod logs
kubectl logs <POD_NAME>

# View service details
kubectl get service lab6-flask-service -o yaml

# View deployment details
kubectl get deployment lab6-flask-deployment -o yaml

# Scale deployment
kubectl scale deployment lab6-flask-deployment --replicas=5

# View cluster info
gcloud container clusters describe lab6-cluster \
    --region=us-central1
```

## License

Educational use for COSC 360 course.
