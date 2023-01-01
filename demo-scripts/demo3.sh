#! /usr/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
DEMO_DIR=$(dirname $SCRIPT_DIR)

if [[ ! -f $SCRIPT_DIR/vars.sh ]] 
then 
  source $SCRIPT_DIR/setup.sh
fi
source $SCRIPT_DIR/vars.sh
source $SCRIPT_DIR/common.sh

if prompt "Step 1: Start minikube " 
then
    set -x 
    minikube start &> /dev/null &
    set +x 
fi

if prompt "Step 2: merge DEMO 3 commit." 
then 
    DEMO3_COMMIT=$(git log --oneline main | awk '/DEMO 3/ {print $1}')
    set -x 
    git merge $DEMO3_COMMIT
    set +x
fi

if prompt "Step 3: Check if minikube is ready" 
then 
    set -x 
    minikube status
    set +x 
fi

if prompt "Step 4: Create PV (usually done by administrator) and PVC" 
then 
    set -x 
    kubectl apply -f $DEMO_DIR/00-pv.yaml
    kubectl apply -f $DEMO_DIR/01-pvc.yaml
    kubectl get pvc
    set +x 
fi

if prompt "Step 5: Create secret and deploy DB server"
then 
    set -x 
    kubectl apply -f $DEMO_DIR/02-secret.yaml
    kubectl apply -f $DEMO_DIR/03-dbserver.yaml
    kubectl get pvc
    set +x 
fi

if prompt "Step 6: Check if DB server is ready"
then
    set -x
    kubectl get pods
    set +x
fi

if prompt "Step 7: Manually login into $REGISTRY" "Done"
then
    set -x
    podman login --get-login
    set +x
fi

if prompt "Step 8: Build and push updated container image"
then
    set -x
    podman build -t "$REGISTRY/$PROJECTID/$APPNAME-psql" $DEMO_DIR
    podman push "$REGISTRY/$PROJECTID/$APPNAME-psql"
    set +x
fi

if prompt "Step 9: Deploy application server"
then
    set -x
    kubectl apply -f $DEMO_DIR/04-appserver.yaml
    set +x
fi

if prompt "Step 10: Find out service address and port and fire local browser"
then
    echo "WARN: Use NodePort services only in development"
    PORT=$(kubectl get svc | awk -F"[:/]" '/NodePort/ {print $2}')
    NODE=$(kubectl get nodes -o wide | awk '/minikube/ {print $6}')
    set -x
    kubectl get svc 
    kubectl get node -o wide
    firefox "http://$NODE:$PORT" &> /dev/null &
    set +x
fi

