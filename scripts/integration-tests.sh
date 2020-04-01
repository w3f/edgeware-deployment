#!/bin/bash

source /scripts/common.sh
source /scripts/bootstrap-helm.sh


run_tests() {
    echo Running tests...

    wait_pod_ready edgeware-000-0
}

teardown() {
    helmfile delete --purge
}

main(){
    if [ -z "$KEEP_EDGEWARE" ]; then
        trap teardown EXIT
    fi

    source /scripts/build-helmfile.sh

    run_tests
}

main
