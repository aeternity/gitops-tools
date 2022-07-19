#!/bin/bash

(cd argocd && helm dep up)

helm upgrade --install --atomic -n argocd -f argocd/values.yaml -f argocd/values-dev.yaml -f argocd/values-bootstrap.yaml argocd ./argocd/
