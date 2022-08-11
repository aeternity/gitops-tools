#!/bin/bash

set -eo pipefail

ENV=${ENV:?}

export AWS_PAGER=""

migrate_secret() {
    NAMESPACE=$1
    K8S_SECRET=$2
    K8S_NAME=$3
    SSM_SECRET_NAME=${4:-$3}
    SSM_SECRET="/k8s/$ENV/$NAMESPACE/$SSM_SECRET_NAME"
    SECRET=$(kubectl --context $ENV -n $NAMESPACE get secret $K8S_SECRET -o 'go-template={{index .data "'${K8S_NAME}'"}}' | base64 --decode)
    aws ssm put-parameter \
    --name "$SSM_SECRET" \
    --type "SecureString" \
    --value "$SECRET" \
    --overwrite
}

migrate_secret argocd argocd-secret dex.github.clientID GITHUB_CLIENT_ID
migrate_secret argocd argocd-secret dex.github.clientSecret GITHUB_CLIENT_SECRET
migrate_secret argocd argocd-secret admin.password ADMIN_PASSWORD
migrate_secret argocd argocd-secret admin.passwordMtime ADMIN_MTIME
migrate_secret argocd argocd-secret server.secretkey SERVER_SECRET_KEY

migrate_secret kubernetes-event-exporter kubernetes-event-exporter-secret OS_MASTER_PASSWORD
migrate_secret kubernetes-event-exporter kubernetes-event-exporter-secret OS_USERNAME

migrate_secret monitoring kube-prometheus-stack-secret github_client_id GITHUB_CLIENT_ID
migrate_secret monitoring kube-prometheus-stack-secret github_client_secret GITHUB_CLIENT_SECRET
migrate_secret monitoring kube-prometheus-stack-secret grafana_admin_user GRAFANA_ADMIN_USER
migrate_secret monitoring kube-prometheus-stack-secret grafana_admin_password GRAFANA_ADMIN_PASSWORD
migrate_secret monitoring kube-prometheus-stack-secret url SLACK_HOOK_URL

migrate_secret apps superhero-backend-app-secret AUTHENTICATION_PASSWORD SUPERHERO_AUTHENTICATION_PASSWORD
migrate_secret apps superhero-backend-app-secret POSTGRES_PASSWORD SUPERHERO_POSTGRES_PASSWORD
migrate_secret apps superhero-backend-app-secret PRIVATE_KEY SUPERHERO_PRIVATE_KEY

migrate_secret apps graffiti-server-app-secret S3_KEY GRAFFITI_S3_KEY
migrate_secret apps graffiti-server-app-secret S3_SECRET GRAFFITI_S3_SECRET

migrate_secret apps dex-backend-testnet-app-secret POSTGRES_PASSWORD DEX_TESTNET_POSTGRES_PASSWORD
migrate_secret apps dex-backend-mainnet-app-secret POSTGRES_PASSWORD DEX_MAINNET_POSTGRES_PASSWORD

migrate_secret apps aepp-faucet-app-secret FAUCET_ACCOUNT_PRIV_KEY
