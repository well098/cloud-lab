# Sandbox 03 — Kubernetes local (GKE na prática)

**Custo: R$ 0.** Roda num cluster `kind` dentro do Docker (usa ~2 GB de RAM). Sem conta GCP, sem cartão.
Pré-requisitos: Docker Desktop **ligado**, `kubectl` e `kind` (em `~/bin/kind.exe`).

## Cenário
Seu time vai publicar um site estático. A primeira versão do manifest foi escrita com pressa: 1 réplica, imagem `:latest`, sem limites de recurso, sem health check e rodando como root. Em produção isso derruba o serviço no primeiro deploy ruim (e é um achado clássico em auditoria de segurança).

## Objetivo
Subir o cluster `lab-gke` e publicar o Deployment `web` + Service `web` no namespace `lab`, com:
- ≥ 2 réplicas, todas disponíveis
- imagem com **versão fixa** (nunca `:latest`)
- **requests e limits** de CPU e memória
- **readinessProbe**
- **runAsNonRoot: true**
- um **rolling update** feito (revision ≥ 2)
- Service com ≥ 2 endpoints

## Passo A (Console) — como seria no GCP real
No GKE: Console → **Kubernetes Engine → Workloads** (Deployments/Pods) e **Services & Ingress**. Lá você vê réplicas, status e eventos. Aqui, o equivalente é `kubectl get/describe`. (No real, o cluster seria criado com `gcloud container clusters create-auto` — o *Autopilot* já exige requests de recursos.)

## Passo B (CLI) — hands-on local
```bash
cd sandbox/03-kubernetes-local
bash setup.sh                                  # cria cluster kind "lab-gke" + namespace lab
cp web.skeleton.yaml web.yaml                  # complete os 5 TODOs
kubectl --context kind-lab-gke apply -f web.yaml
kubectl --context kind-lab-gke -n lab get pods -w     # Ctrl+C para sair
```
Rolling update: troque a versão da imagem em `web.yaml` (ex.: `1.27-alpine` → `1.28-alpine`) e reaplique; acompanhe com:
```bash
kubectl --context kind-lab-gke -n lab rollout status deploy/web
kubectl --context kind-lab-gke -n lab rollout history deploy/web
```
Validar:
```bash
bash check.sh
```
Dicas de debug: `kubectl -n lab describe pod <nome>` (veja *Events*), `kubectl -n lab logs <pod>`.

## Por que importa
- **Réplicas + readinessProbe**: o tráfego só chega em pod pronto; um pod morrer não derruba o serviço.
- **Limits**: um pod sem limite pode consumir o nó inteiro (ou rodar mineração sem ninguém notar).
- **runAsNonRoot + versão fixa**: reduz impacto de comprometimento do container e garante deploy reproduzível. É o tipo de coisa que scanners de cluster (e entrevistadores de SOC) cobram.

## Desafio extra
Adicione uma `NetworkPolicy` que só permita tráfego de entrada no pod `web` vindo de pods com label `role=frontend` (obs.: o `kind` padrão usa `kindnet`, que **não aplica** NetworkPolicy; pesquise como instalar Calico/Cilium ou descreva o que seria necessário). Depois rode `kubectl auth can-i --list --as=system:serviceaccount:lab:default -n lab` e comente o que a SA padrão consegue fazer.

## Cleanup
```bash
bash cleanup.sh        # apaga o cluster kind e libera a RAM
```
