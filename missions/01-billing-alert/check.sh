#!/usr/bin/env bash
# Missão 01 — valida se existe budget "lab-budget" com alertas 50/90/100%.
# Uso: [BILLING_ACCOUNT=XXXXXX-XXXXXX-XXXXXX] bash check.sh
set -u

BUDGET_NAME="${BUDGET_NAME:-lab-budget}"
FAIL=0
ok()   { echo "[OK]    $*"; }
fail() { echo "[FALHA] $*"; FAIL=1; }

# 1. gcloud autenticado
ACCOUNT="$(gcloud auth list --filter=status:ACTIVE --format='value(account)' 2>/dev/null | head -n1)"
if [ -n "$ACCOUNT" ]; then ok "gcloud autenticado como $ACCOUNT"; else fail "gcloud sem conta ativa (rode: gcloud auth login)"; fi

# 2. billing account
if [ -z "${BILLING_ACCOUNT:-}" ]; then
  BILLING_ACCOUNT="$(gcloud billing accounts list --filter=open=true --format='value(name)' 2>/dev/null | head -n1)"
  BILLING_ACCOUNT="${BILLING_ACCOUNT##*/}"
fi
if [ -n "$BILLING_ACCOUNT" ]; then ok "billing account: $BILLING_ACCOUNT"; else fail "nenhuma billing account aberta encontrada"; fi

# 3. API de budgets habilitada
if gcloud services list --enabled --filter='config.name=billingbudgets.googleapis.com' --format='value(config.name)' 2>/dev/null | grep -q billingbudgets; then
  ok "billingbudgets.googleapis.com habilitada"
else
  fail "API não habilitada (rode: gcloud services enable billingbudgets.googleapis.com)"
fi

# 4. budget existe
THRESHOLDS=""
if [ -n "${BILLING_ACCOUNT:-}" ]; then
  BUDGET_ID="$(gcloud billing budgets list --billing-account="$BILLING_ACCOUNT" \
    --filter="displayName=$BUDGET_NAME" --format='value(name)' 2>/dev/null | head -n1)"
  if [ -n "$BUDGET_ID" ]; then
    ok "budget '$BUDGET_NAME' encontrado"
    THRESHOLDS="$(gcloud billing budgets describe "$BUDGET_ID" --billing-account="$BILLING_ACCOUNT" \
      --format='value(thresholdRules[].thresholdPercent)' 2>/dev/null | tr ';' ' ')"
  else
    fail "budget '$BUDGET_NAME' não encontrado (nome exato, case-sensitive)"
  fi
fi

# 5. thresholds 0.5, 0.9 e 1.0
if [ -n "$THRESHOLDS" ]; then
  for t in 0.5 0.9 1.0; do
    if echo "$THRESHOLDS" | tr ' ' '\n' | awk -v t="$t" '$1+0==t+0{f=1} END{exit !f}'; then
      ok "threshold $(awk -v t="$t" 'BEGIN{printf "%d", t*100}')% presente"
    else
      fail "threshold $(awk -v t="$t" 'BEGIN{printf "%d", t*100}')% ausente"
    fi
  done
elif [ -n "${BUDGET_ID:-}" ]; then
  fail "budget sem threshold rules"
fi

echo
if [ "$FAIL" -eq 0 ]; then echo "Missão 01: PASSOU"; exit 0; else echo "Missão 01: NÃO PASSOU"; exit 1; fi
