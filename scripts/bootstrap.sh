#!/bin/bash

ENV=$(git rev-parse --abbrev-ref HEAD)

(cd argocd && helm dep up)

kubectl apply -f https://raw.githubusercontent.com/prometheus-community/helm-charts/kube-prometheus-stack-17.2.1/charts/kube-prometheus-stack/crds/crd-servicemonitors.yaml
helm upgrade --install --atomic --create-namespace --namespace argocd -f argocd/values.yaml -f argocd/values-${ENV}.yaml -f argocd/values-bootstrap.yaml argocd ./argocd/
