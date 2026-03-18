# GitOps Repository — Redis Operator Example

This repository demonstrates a **GitOps-based deployment** of the
**Redis Operator (Opstree Solutions v0.15.1)** on OpenShift using
OpenShift GitOps (Argo CD).

**Namespace used:** `gianfranco`

---

# Overview

This repo provides:

* Full GitOps structure (multi-operator ready)
* Multi-environment support (dev / stage / prod)
* Example RedisCluster Custom Resource
* Automated setup via bash script

---

# Prerequisites

* OpenShift 4.x cluster (ROSA or OCP)
* OpenShift GitOps installed
* GitHub account + Personal Access Token (PAT)
* Git installed locally

---

# Quick Setup

## 1. Run the setup script

```bash
chmod +x setup-gitops-redis.sh
./setup-gitops-redis.sh
```

This will:

* Create directory structure
* Generate all YAML files
* Initialize Git repository

---

# Repository Structure

```
gitops-repo/
├── bootstrap/
│   └── root-app.yaml
├── operators/
│   └── redis/
│       ├── namespace.yaml
│       ├── operatorgroup.yaml
│       ├── subscription.yaml
│       └── instance/
│           └── rediscluster.yaml
├── envs/
│   ├── dev/
│   ├── stage/
│   └── prod/
└── projects/
```

---

#  GitHub Authentication (PAT)

## First push requires authentication

```bash
git remote add origin https://github.com/<your-org>/gitops-redis.git
git branch -M main
git push -u origin main
```

When prompted:

* Username → your GitHub username
* Password → your **Personal Access Token (PAT)**

---

## Save credentials (Mac)

```bash
git config --global credential.helper osxkeychain
```

---

#  Operator Configuration

### Namespace

```yaml
name: gianfranco
```

### Operator

* Name: `redis-operator`
* Source: `community-operators`
* Channel: `stable`

---

#  Multi-Environment Setup

Each environment can override:

* InstallPlanApproval
* Resource limits
* Scaling
* External integrations

Example:

```
envs/dev/operators/redis/subscription.yaml
envs/prod/operators/redis/subscription.yaml
```

---

#  GitOps Deployment (Argo CD)

## Step 1 — Create Project

* Name: `operators`
* Namespace: `openshift-gitops`

---

## Step 2 — Create Application

* Name: `root-app`
* Repo: this repository
* Path: `operators`
* Sync Policy: Automated

---

## Step 3 — Sync

Argo CD will:

1. Create Namespace
2. Create OperatorGroup
3. Create Subscription
4. OLM installs Redis Operator
5. Apply RedisCluster CR

---

#  Verification

```bash
oc get csv -n gianfranco
oc get pods -n gianfranco
```

---

#  Architecture Flow

```
Git Repo
   ↓
Argo CD
   ↓
Operator Lifecycle Manager (OLM)
   ↓
Redis Operator
   ↓
RedisCluster
```

---

#  Setup Script

Below is the script used to bootstrap the repo:

```bash
#!/bin/bash
set -e

REPO_NAME="gitops-redis"
NAMESPACE="gianfranco"

mkdir -p $REPO_NAME/bootstrap
mkdir -p $REPO_NAME/operators/redis/instance
mkdir -p $REPO_NAME/envs/dev/operators/redis
mkdir -p $REPO_NAME/envs/stage/operators/redis
mkdir -p $REPO_NAME/envs/prod/operators/redis
mkdir -p $REPO_NAME/projects

cd $REPO_NAME

cat > operators/redis/namespace.yaml <<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: $NAMESPACE
EOF

cat > operators/redis/operatorgroup.yaml <<EOF
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: redis-operator-group
  namespace: $NAMESPACE
spec:
  targetNamespaces:
    - $NAMESPACE
EOF

cat > operators/redis/subscription.yaml <<EOF
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: redis-operator
  namespace: $NAMESPACE
spec:
  channel: stable
  name: redis-operator
  source: community-operators
  sourceNamespace: openshift-marketplace
  installPlanApproval: Automatic
EOF

git init
git add .
git commit -m "Initial GitOps setup"
```

---

#  Best Practices

* Use separate namespaces per operator
* Use Manual approval in production
* Do not store secrets in Git
* Use App-of-Apps pattern
* Monitor CSV and InstallPlans
