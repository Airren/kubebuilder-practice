#!/bin/bash

set -x

KIND_IMAGE_VERSION=${KIND_IMAGE_VERSION:-"kindest/node:v1.22.0"}



function  create_cluster(){

    local cluster_name=${1}
    local kubeconfig=${2}
    local cluster_config=${3}
    local image=${4}


    rm -rf ${kubeconfig}
    kind delete cluster --name=${cluster_name} 2>&1
    kind create cluster --name=${cluster_name} --kubeconfig=${kubeconfig} \
    --config=${cluster_config} --image=${image}

    kubectl --kubeconfig=${kubeconfig} \
    config rename-context kind-${cluster_name} ${cluster_name}

    kind_server="https://$(docker inspect \
    --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' \
    "${cluster_name}-control-plane"):6443"

    kubectl --kubeconfig=${kubeconfig} \
    set-cluster kind-${cluster_name} --server=${kind_server}

    echo "Cluster ${cluster_name} has been initialized."
}


create_cluster "parent" "./parent.config" "./parent.yaml" $KIND_IMAGE_VERSION



echo "export KUBECONFIG=$(pwd)/parent.config"