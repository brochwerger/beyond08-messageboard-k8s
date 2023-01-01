#! /usr/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
DEMO_DIR=$(dirname $SCRIPT_DIR)

if [[ ! -f $SCRIPT_DIR/vars.sh ]] 
then 
  source $SCRIPT_DIR/setup.sh
fi
source $SCRIPT_DIR/vars.sh
source $SCRIPT_DIR/common.sh
 
if prompt "Step 1: Create a new git branch and reset it to DEMO 1 commit" 
then 
    DEMO1_COMMIT=$(git log --oneline main | awk '/DEMO 1/ {print $1}')
    set -x 
    git checkout -b $BRANCH
    git reset --hard $DEMO1_COMMIT
    set +x
fi

if prompt "Step 2: use podman to check status of local image registry and containers"
then 
    set -x
    podman images
    podman ps -a
    set +x
fi

if prompt "Step 3: use podman to build local image" 
then 
    set -x
    podman build -t $APPNAME $DEMO_DIR
    podman images
    set +x
fi

if prompt "Step 4: use podman to run a container from the image built in step 3"
then
    set -x
    podman run -d -p 8000:8000 --name $APPNAME $APPNAME
    podman ps 
    set +x
fi

if prompt "We're done - do you want to open up browser to check"
then
    set -x
    firefox localhost:8000 &> /dev/null &
    set +x
fi
