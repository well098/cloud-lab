#!/usr/bin/env bash
# Sandbox 03 — cria o cluster local "lab-gke" (kind) e o namespace "lab".
# Custo: R$ 0 (usa ~2 GB de RAM via Docker). Desfazer: bash cleanup.sh
set -eu
export PATH="$HOME/bin:$PATH"
CLUSTER=lab-gke

command -v kind >/dev/null    || { echo "kind nao encontrado (esperado em ~/bin/kind.exe)"; exit 1; }
command -v kubectl >/dev/null || { echo "kubectl nao encontrado"; exit 1; }
timeout 20 docker version --format '{{.Server.Version}}' >/dev/null 2>&1 || { echo "Docker nao esta rodando (abra o Docker Desktop)"; exit 1; }

if timeout 20 kind get clusters 2>/dev/null | grep -qx "$CLUSTER"; then
  echo "cluster $CLUSTER ja existe"
else
  kind create cluster --name "$CLUSTER" --wait 120s
fi
kubectl --context "kind-$CLUSTER" create namespace lab --dry-run=client -o yaml | kubectl --context "kind-$CLUSTER" apply -f -
echo "Pronto. Contexto: kind-$CLUSTER, namespace: lab"
