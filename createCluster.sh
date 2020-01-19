#!/bin/bash

kops create cluster --name cluster.ota.svrs.cc --zones us-east-2b --state s3://ota-svrs-cc-state-store
kops create secret --name cluster.ota.svrs.cc sshpublickey admin -i $HOME/id_rsa.pub
kops update cluster --name cluster.ota.svrs.cc --yes

cp $HOME/snap/kops/current/.kube/config $HOME/.kube/
