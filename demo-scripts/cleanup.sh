#! /usr/bin/bash
 
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
DEMO_DIR=$(dirname $SCRIPT_DIR)

source $SCRIPT_DIR/common.sh

if prompt "Cleanup podman demo"
then
    # Cleanup podman
    podman stop -a
    podman container prune
    podman rmi --all
fi

if prompt "Cleanup Openshift demo"
then 
    # Cleanup OCP demo
    oc delete all -l app=beyond
fi

if prompt "Cleanup minikube demo"
then
    # Cleanup minikube demo
    for f in $(ls -1r $DEMO_DIR/*.yaml) ; do echo $f ; oc delete -f $f ; done
fi