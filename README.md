# Redis Operator GitOps Deployment (OpenShift)

This repository provides a **ready-to-use GitOps setup** to deploy the
**Redis Operator (Opstree Solutions v0.15.1)** on OpenShift using OpenShift GitOps.

# Usage Options

> No local setup required: this repository can be used directly from Argo CD.

### Option 1 — Direct GitOps Deployment (Recommended)

Simply use this repository in OpenShift GitOps by providing:

* Repository URL

  ```
  https://github.com/gmolloATredhat/gitops-redis.git
  ```
* Branch: `main`
* Path: `operators` (or `envs/dev/operators/redis`)

No cloning or local setup is required.


### Option 2 — Fork for Customization

If you want to safely customize the configuration:

1. Click **Fork** on GitHub
2. Use your forked repository in Argo CD


### Option 3 — Clone Locally

If you prefer working locally:

```bash
git clone https://github.com/gmolloATredhat/gitops-redis.git
cd gitops-redis
```


### Option 4 — Recreate the Repository from Scratch

If you want to create a new repository with the same structure:

Use the provided setup script:

```bash
chmod +x setup-gitops-redis.sh
./setup-gitops-redis.sh
```

This will:

* Generate the full directory structure
* Create all base YAML files
* Initialize a Git repository

---

# Quick Start

## 2. Connect to your OpenShift cluster

```bash
oc login <your-cluster> --username <your-user> --password <your-password>
```
> Installing Operators requires elevated privileges: ensure you are a user of the cluster-admins group. It is possible to allow non-admin users to install Operators by configuring OperatorGroups and service accounts with appropriate RBAC, but this must be set up in advance by a cluster administrator.

## 3. Deploy via OpenShift GitOps (Argo CD GUI)
You have installed the Red Hat OpenShift GitOps Operator in your cluster.
In the Administrator perspective of the OpenShift web console, navigate to Operators
Installed Operators to verify that the Red Hat OpenShift GitOps Operator is installed.

Navigate to the red hat applications menu icon <img width="32" height="32" alt="image" src="https://github.com/user-attachments/assets/a593dd13-d428-4e22-93ce-467168b5c7b9" /> > OpenShift GitOps > Cluster Argo CD. The login page of the Argo CD UI is displayed in a new window. 


Click **Create Application**

## 4. Fill the Application form

### General

* Name: `redis-app`
* Project: `default` (or `operators`)

### Source

* Repository URL:

  ```
  https://github.com/gmolloATredhat/gitops-redis.git
  ```
* Revision: `main`
* Path:

  ```
  operators
  ```

For environment-specific deployment:

```
envs/dev/operators/redis
```

### Destination

* Cluster: `https://kubernetes.default.svc`
* Namespace: `openshift-gitops`


### Sync Policy

* Automatic (recommended)


## 5. Click Create

Argo CD will automatically:

1. Create namespace `gianfranco`
2. Install Redis Operator via OLM
3. Deploy a RedisCluster instance


# Verify Deployment

```bash
oc get pods -n gianfranco
oc get csv -n gianfranco
oc get redisclusters -n gianfranco
```

---

# Repo Structure

```
gitops-repo/
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
```

---

# Customization
You might want to change a few details, here is an example of what can be done.

### Change namespace

Edit:

```
operators/redis/namespace.yaml
```

### Change Redis configuration

Edit:

```
operators/redis/instance/rediscluster.yaml
```

Example:

```yaml
spec:
  size: 5
  image: redis:7
```

---

# Environment-specific configuration

Each environment can override:

* InstallPlanApproval
* Scaling
* Resources

Example:

```
envs/prod/operators/redis/subscription.yaml
```

---

### Multi-Environment Usage

| Environment | Path                         |
| ----------- | ---------------------------- |
| Dev         | `envs/dev/operators/redis`   |
| Stage       | `envs/stage/operators/redis` |
| Prod        | `envs/prod/operators/redis`  |

---

# Notes

* Default namespace: `gianfranco`
* Operator source: `community-operators`
* No secrets are included in this repo
* Production should use **manual approval**

---

# Best Practices

* Use environment overlays (`envs/`)
* Separate namespaces per environment
* Use Manual approval in production
* Monitor CSV status for operator health

---

# Summary

* Clone repo -> Create Argo CD Application -> Sync -> Redis running 🚀
