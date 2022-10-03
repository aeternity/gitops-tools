#!/bin/bash

PASS=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
kubectl port-forward svc/argocd-server -n argocd 8080:443 &

sleep 3
argocd --plaintext login localhost:8080 --username admin --password ${PASS}
