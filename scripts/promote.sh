#!/bin/bash

set -euo pipefail

ALWAYS_EXCLUDE=('external-snapshotter' 'aws-ebs-csi-driver' 'nginx' 'signoz' 'wikijs' 'sentry' 'plausible' 'hedgedoc' 'hedgedoc-2' 'hedgedoc-chart' 'postgresql' 'postgresql-hedgedoc' 'matomo' 'app')
ENV_EXCLUDE=('values-dev.yaml' 'values-stg.yaml' 'values-prd.yaml')
function usage {
    echo "Usage:"
    echo "$0 diff <source branch> <target branch> - list changes"
    echo "$0 diff-all <source branch> <target branch> - list all changes including env specific"
    echo "$0 app <app folder> <source branch> <target branch> - promote a specific application"
    echo "$0 all <source branch> <target branch> - promote a all charts"
}

function diff {
    src=${1:?"Please provide a source branch"}
    dst=${2:-HEAD}
    exclude=()

    for e in ${ALWAYS_EXCLUDE[@]}; do
        exclude+=(":(exclude)$e")
    done

    for e in ${ENV_EXCLUDE[@]}; do
        exclude+=(":(exclude)*/$e")
    done

    git diff $dst..$src ${exclude[@]}
}

function diff-all {
    src=${1:?"Please provide a source branch"}
    dst=${2:-HEAD}

    git diff $dst..$src
}

function ignore_path {
    source=${1:-}
    destination=${2:-}
    path=${3:-}

    if [[ -f $path ]]; then
        rm -f "${path}" > /dev/null
        git add "${path}"

        git checkout "${destination}" "${path}" > /dev/null 2>&1 || true
    fi

    # if the env values file hasn't been initialized yet
    if [[ ! -f $path ]]; then
        git checkout "${source}" "${path}" > /dev/null 2>&1 || true
    fi
}

function app {
    chart=${1:-}
    source=${2:-}
    destination=${3:-}

    git switch "$destination"

    # Checkout files from the other branch ...
    rm -Rf "$chart"
    git checkout "$source" "$chart"

    for e in ${ENV_EXCLUDE[@]}; do
        ignore_path $source $destination $chart/$e
    done

    echo "---------------------------------------------------------------"
    echo "Review your promote with:"
    echo "git diff --cached"

    echo ""
    echo "Commit your promote with:"
    echo "git commit -am 'promote: [${source}→${destination}] $chart'"
    echo "---------------------------------------------------------------"
}

function all {
    source=${1:?"Please provide source branch"}
    destination=${2:?"Please provide destination branch"}
    exclude=()

    for e in ${ALWAYS_EXCLUDE[@]}; do
        exclude+=("-o -path ./$e")
    done

    dirs=$(find . -type d -maxdepth 1 -not \( -path . -o -path ./.git -o -path ./scripts ${exclude[@]} \))
    while IFS= read -r dir; do
        app $(basename "$dir") $source $destination
    done <<< "$dirs"
}

"${@-usage}"
