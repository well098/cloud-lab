# Missão 01 — Billing alert

**Custo: R$ 0.** Budgets e alertas são gratuitos. Esta missão não cria recurso pago.

## Cenário
Você acabou de criar a conta no GCP. Um VM esquecida ligada ou um cluster GKE rodando o fim de semana inteiro pode gerar uma fatura surpresa. Antes de qualquer lab, o guarda-corpo de custo.

## Objetivo
Ter um **budget** chamado `lab-budget` na sua billing account, com alertas em **50%, 90% e 100%** do valor.

> Atenção: o budget alerta, **não bloqueia** gasto. Ele só avisa por e-mail.

## Passo A (Console)
1. Console → **Billing** → escolha sua billing account.
2. Menu esquerdo → **Budgets & alerts** → **Create budget**.
3. Name: `lab-budget`. Scope: deixe todos os projetos/serviços.
4. Amount: **Specified amount**, valor baixo (ex.: 10). A moeda é a da sua billing account.
5. Thresholds: deixe 50%, 90%, 100% (Actual spend).
6. Notifications: mantenha o e-mail dos billing admins marcado → **Finish**.

## Passo B (CLI — Cloud Shell)
```bash
# 1. achar a billing account
gcloud billing accounts list

# 2. guardar o ID (formato XXXXXX-XXXXXX-XXXXXX)
export BILLING_ACCOUNT=<SEU_ID>

# 3. habilitar a API de budgets no projeto atual
gcloud services enable billingbudgets.googleapis.com

# 4. ver o budget que você criou no Passo A
gcloud billing budgets list --billing-account="$BILLING_ACCOUNT"
```

Se quiser criar pela CLI em vez do Console (troque `BRL` pela moeda da sua conta):
```bash
gcloud billing budgets create --billing-account="$BILLING_ACCOUNT" \
  --display-name=lab-budget --budget-amount=10BRL \
  --threshold-rule=percent=0.5 --threshold-rule=percent=0.9 --threshold-rule=percent=1.0
```

Validar:
```bash
bash missions/01-billing-alert/check.sh
```

## Por que importa
- É a primeira coisa que qualquer time de cloud configura; em entrevista, "como você evita custo surpresa?" é pergunta comum.
- Na prática de SOC/FinOps, pico de gasto inesperado é também **sinal de comprometimento** (cryptomining com credencial vazada).
- Budget ≠ quota: budget avisa, quota/limit bloqueia.

## Desafio extra
Conecte o budget a um tópico **Pub/Sub** (Notifications → Connect a Pub/Sub topic) e descreva como uma Cloud Function poderia reagir ao alerta. Não precisa implementar — só desenhar o fluxo.

## Cleanup
Nada a limpar. Mantenha o budget — ele deve ficar ativo durante todo o lab.
