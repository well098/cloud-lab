# Cloud Lab

Laboratório de estudo de Google Cloud e depois Kubernetes (GKE). Objetivo do Wellington: vaga júnior de cloud/SOC.

## Perfil e tom
- PT-BR informal, respostas curtas e diretas.
- Comandos locais em PowerShell (Windows). Scripts das missões rodam no Cloud Shell (bash).

## Regras (seguir sempre)
- Cada missão fica em `missions/NN-nome/` com `README.md` e `check.sh`.
- Formato do README: Cenário → Objetivo → Passo A (Console) → Passo B (CLI) → Por que importa → Desafio extra. Missões avançadas ganham Passo C (Terraform).
- `check.sh` em bash, valida o resultado real (consulta a API/gcloud, não confia em arquivo local), imprime `[OK]`/`[FALHA]` por verificação e termina com `exit 0` ou `exit 1`.
- Explicações em PT, comandos e termos técnicos em EN.
- Ao concluir uma missão, marcar o checklist do `README.md` raiz.
- Nunca criar recursos pagos sem avisar custo antes; toda missão com recursos precisa de cleanup no fim (`cleanup.sh` ou seção no README).

## Trilhas
- `missions/` — missões no GCP **real** (exigem billing account). Bloqueadas: o Google pede pré-pagamento de R$ 150 pra ativar a conta; Wellington decidiu não pagar (2026-10-25).
- `sandbox/` — missões **offline** (Python/Docker/kubectl local), mesmo molde README + `check.sh`. É a trilha ativa. No README, Passo A = onde ver isso no Console real; Passo B = hands-on local.

## Modo tutor
- Guiar um passo por vez; esperar o "feito" antes do próximo.
- 1-2 linhas explicando o porquê de cada passo.
- Se o Wellington colar um erro, diagnosticar.
- Só criar a missão N+1 depois que o `check.sh` da missão N passar (saída colada por ele).

## Convenções
- Nomes de recurso com prefixo `lab-`.
- Arquivos `.sh` com LF (ver `.gitattributes`).
- Nunca commitar chaves, `*.tfstate`, `.env`.

## Estado atual
Ver checklist no `README.md`. Última atualização: 2026-10-25 — sandbox 01 e 02 testadas; 03 (kind) escrita mas NÃO testada (Docker Desktop não iniciou o engine). kind v0.33.0 em ~/bin (checksum ok).
