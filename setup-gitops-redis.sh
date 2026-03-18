#!/bin/bash
# ========================================================
# Script: setup-gitops-redis.sh
# Purpose: Generate GitOps repo structure and base YAMLs
# Operator: Redis Operator by Opstree Solutions v0.15.1
# Namespace: gianfranco
# ========================================================

set -e

# Variables
REPO_NAME="gitops-redis"
NAMESPACE="gianfranco"
REDIS_IMAGE="redis:6.2"
REDIS_CLUSTER_NAME="example-redis"

echo "Creating GitOps repo structure for Redis Operator..."

#  Create directories
mkdir -p $REPO_NAME/bootstrap
mkdir -p $REPO_NAME/operators/redis/instance
mkdir -p $REPO_NAME/envs/dev/operators/redis
mkdir -p $REPO_NAME/envs/stage/operators/redis
mkdir -p $REPO_NAME/envs/prod/operators/redis
mkdir -p $REPO_NAME/projects

cd $REPO_NAME

#  Create namespace.yaml
cat > operators/redis/namespace.yaml <<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: $NAMESPACE
EOF

#  Create operatorgroup.yaml
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

#  Create subscription.yaml (base)
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

#  Create CR example
cat > operators/redis/instance/rediscluster.yaml <<EOF
apiVersion: redis.redis.opstreelabs.in/v1beta1
kind: RedisCluster
metadata:
  name: $REDIS_CLUSTER_NAME
  namespace: $NAMESPACE
spec:
  size: 3
  image: $REDIS_IMAGE
EOF

#  Create environment overlay subscriptions
for ENV in dev stage prod; do
cat > envs/$ENV/operators/redis/subscription.yaml <<EOF
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
  installPlanApproval: $( [[ "$ENV" == "prod" ]] && echo "Manual" || echo "Automatic" )
EOF
done

#  Create bootstrap/root-app.yaml
cat > bootstrap/root-app.yaml <<EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: root-app
  namespace: openshift-gitops
spec:
  project: operators
  source:
    repoURL: https://github.com/<your-org>/$REPO_NAME.git
    targetRevision: main
    path: operators
  destination:
    server: https://kubernetes.default.svc
    namespace: openshift-gitops
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOF

#  Create optional ArgoCD project
cat > projects/operators-project.yaml <<EOF
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: operators
  namespace: openshift-gitops
spec:
  destinations:
    - namespace: '*'
      server: https://kubernetes.default.svc
  sourceRepos:
    - '*'
EOF

#  Initialize Git repo
git init
git add .
git commit -m "Initial GitOps setup for Redis Operator v0.15.1"

echo " GitOps repo structure and base YAMLs created successfully!"
echo "Next steps:"
echo "1. Add remote: git remote add origin <your-repo-URL>"
echo "2. Push to GitHub/GitLab: git push -u origin main"
echo "3. Create ArgoCD Project and Applications as described in the README"
