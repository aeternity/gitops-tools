#!/bin/bash

NAMESPACES=(aenodes apps tools logging cluster-autoscaler cert-manager velero argocd monitoring traefik sealed-secrets kubernetes-event-exporter)
SERVICES=(aws-load-balancer-webhook-service kube-prometheus-stack-coredns kube-prometheus-stack-kube-controller-manager kube-prometheus-stack-kube-etcd kube-prometheus-stack-kube-proxy kube-prometheus-stack-kube-scheduler kube-prometheus-stack-kubelet metrics-server)
DEPLOYMENTS=(aws-load-balancer-controller metrics-server)
APPS=(aepp-base aepp-faucet aepp-graffiti aerepl-http aesophia-http aws-load-balancer-controller cert-manager cluster-autoscaler dex-ui fluent-bit ga-multisig-backend graffiti-server kube-prometheus-blackbox-exporter kube-prometheus-stack kubernetes-event-exporter mdw-frontend metrics-server sealed-secrets state-channel-demo-backend state-channel-demo-frontend superhero-backend superhero-wallet traefik velero)

for APP in "${APPS[@]}"
do 
  kubectl -n argocd patch application "$APP" -p '{"metadata":{"finalizers":[]}}' --type=merge
done

kubectl delete application --all -n argocd

for NS in "${NAMESPACES[@]}"
do 
  kubectl delete all --all -n "$NS"
done

for NS in "${NAMESPACES[@]}"
do 
    kubectl delete namespace "$NS"
done

## Metrics server should be kept until everything else is deleted
for SVC in "${SERVICES[@]}"
do 
    kubectl -n kube-system delete service "$SVC"
done

for DPL in "${DEPLOYMENTS[@]}"
do 
    kubectl -n kube-system delete deploy "$DPL"
done

kubectl get crds --no-headers=true | awk '{print $1}' | grep -v aws | xargs kubectl delete crds
