# Cloud Lab

Laboratório prático de Google Cloud → Kubernetes (GKE). Foco: vaga júnior de cloud (sem SOC).

Cada missão em `missions/NN-nome/` tem `README.md` (roteiro) e `check.sh` (validação — rodar no Cloud Shell).

## Checklist

- [ ] 01 — Billing alert (budget com alertas 50/90/100%) → `missions/01-billing-alert/`
- [ ] 02 — IAM: least privilege em service account (a criar após a 01)

## Sandbox (offline, sem conta GCP)

- [x] S01 — Anomalia de custo (cryptomining no billing export) → `sandbox/01-anomalia-de-custo/`
- [ ] S02 — IAM de menor privilégio → `sandbox/02-iam-menor-privilegio/`
- [ ] S03 — Kubernetes local com kind (GKE na prática) → `sandbox/03-kubernetes-local/` testada de ponta a ponta com cluster real (kind v0.33.0)

## Google Skills (labs oficiais grátis, 35 créditos/mês)

- [x] GSP647 — Configuring IAM Permissions with gcloud (1 crédito, 25 min): 100/100 em 28/10/2026 (configs `default`/`user2`, role customizado `devops`, service account anexada a VM)
- [ ] Próximos (a verificar crédito/duração no catálogo antes): Compute Engine, Cloud Storage, VPC/firewall, Cloud Run, Terraform no GCP

> As missões em `missions/` precisam de billing account (o Google exige pré-pagamento de R$ 150 no Brasil). Ficam paradas; a trilha ativa é a `sandbox/`.

## Como rodar um check

No Cloud Shell, dentro do repo:

```bash
bash sandbox/01-anomalia-de-custo/check.sh   # roda local, sem GCP
```

Saída: `[OK]`/`[FALHA]` por item; exit code 0 = passou.
