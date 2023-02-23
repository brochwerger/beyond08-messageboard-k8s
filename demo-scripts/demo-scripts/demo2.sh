#! /usr/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

source $SCRIPT_DIR/vars.sh
source $SCRIPT_DIR/common.sh

if [[ -z $BRANCH || -z $APPNAME ]]
then
    echo "ERROR: Mandatory enviroment varibles (BRANCH & APPNAME) not set ... Aborting"
    echo "Define your enviroment vars it in $SCRIPT_DIR/vars.sh"
    exit
fi

CURBRANCH=$(git branch | awk '/*/ {print $2}')
if [[ $CURBRANCH != $BRANCH ]]
then
    echo "WARNING: Not in right branch ($BRANCH), fixing it ..."
    DEMO1_COMMIT=$(git log --oneline main | awk '/DEMO 1/ {print $1}')
    set -x 
    git checkout -b $BRANCH
    git reset --hard $DEMO1_COMMIT
    git push -u origin $BRANCH
    set +x
fi

if prompt "Step 1: Commit and push changes from demo 1 to branch created in demo 1"
then
    set -x
    git add *
    git commit -m "Dockerized application" 
    git push --set-upstream origin $BRANCH
    set +x
fi

if prompt "Step 2: Manually login to your RH developer sandbox (oc login --token ...)" "Are you done"
then 
    set -x
    oc status
    set +x
fi

if prompt "Step 3: Deploy application from github"
then
    PATH_TO_SOURCE="$GITHUB_REPO"#"$BRANCH"
    set -x
    oc new-app --image-stream=openshift/python "$GITHUB_REPO#$BRANCH" --name $APPNAME
    set +x
fi

if prompt "Step 4: Expose service and open URL in firefox"
then
    set -x
    oc expose svc $APPNAME
    ROUTE=$(oc get route --no-headers | awk '{print $2}')
    firefox "http://$ROUTE" &> /dev/null &
    set +x
    sleep 5
fi

if prompt "Add some messages to message board ... " "Are you done"
then
    set -x
    oc get pods
    sleep 5
    oc delete pod $(oc get pods | grep $APPNAME | awk '/Running/ {print $1}')
    oc get pods
    set +x
fi

if prompt "Refresh page..." "Are you done"
then
    echo "We lost our data ... 😱"
    echo "What happened to messages ? Why ?"
fi

if prompt "Step 5: Let's fix it ... merge DEMO 2 commit." 
then 
    DEMO2_COMMIT=$(git log --oneline main | awk '/DEMO 2/ {print $1}')
    set -x 
    git merge $DEMO2_COMMIT
    git push
    set +x
fi

if prompt "Step 6: Deploy DB server. Rebuild (and redeploy) application"
then
    set -x
    oc new-app --labels app=$APPNAME --name=dbserver -e POSTGRESQL_USER=beyond -e POSTGRESQL_PASSWORD=beyond -e POSTGRESQL_DATABASE=messages postgresql:latest
    sleep 5
    oc start-build $APPNAME
    set +x
fi

if prompt "Add some messages to messagge board again ... " "Are you done"
then
    set -x
    oc get pods
    sleep 5
    oc delete pod $(oc get pods | grep $APPNAME | awk '/Running/ {print $1}')
    oc get pods
    sleep 5
    set +x
    echo "👍 Now application server is highly available !!!"
fi

if prompt "Step 7: Scale application server"
then
    set -x
    oc scale deployment $APPNAME --replicas=4
    sleep 5
    oc get pods
    sleep 5
    ROUTE=$(oc get route --no-headers | awk '{print $2}')
    set +x
    echo "curl -s $ROUTE | grep Served ; sleep 1"
    for i in {1..20} 
    do 
        curl -s $ROUTE | grep Served ; sleep 1
    done
    echo "👍 More K8S magic ... now application server tier is scalable !!!"
    sleep 5
    echo "Note that you can access you application from any computer at: "
    echo "http://$ROUTE"
    echo "Kudos - your application is open for business 💰💰💰"
fi
