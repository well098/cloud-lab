# Cloud Lab

Laboratório prático de Google Cloud → Kubernetes (GKE). Foco: vaga júnior de cloud/SOC.

Cada missão em `missions/NN-nome/` tem `README.md` (roteiro) e `check.sh` (validação — rodar no Cloud Shell).

## Checklist

- [ ] 01 — Billing alert (budget com alertas 50/90/100%) → `missions/01-billing-alert/`
- [ ] 02 — IAM: least privilege em service account (a criar após a 01)

## Como rodar um check

No Cloud Shell, dentro do repo:

```bash
bash missions/01-billing-alert/check.sh
```

Saída: `[OK]`/`[FALHA]` por item; exit code 0 = passou.
