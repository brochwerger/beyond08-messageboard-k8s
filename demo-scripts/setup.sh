#! /usr/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

read -ei "staging" -p "BRANCH = " BRANCH
read -ei "beyond" -p "APPNAME = " APPNAME
read -ei "quay.io" -p "REGISTRY = " REGISTRY
read -p "PROJECTID = " PROJECTID

echo "BRANCH=$BRANCH" > $SCRIPT_DIR/vars.sh
echo "APPNAME=$APPNAME" >> $SCRIPT_DIR/vars.sh
echo "REGISTRY=$REGISTRY" >> $SCRIPT_DIR/vars.sh
echo "PROJECTID=$PROJECTID" >> $SCRIPT_DIR/vars.sh

