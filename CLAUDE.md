# Cloud Lab

Laboratório de estudo de Google Cloud e depois Kubernetes (GKE). Objetivo do Wellington: vaga júnior de cloud (infraestrutura/engenharia/admin). Sem foco em SOC/segurança operacional (decisão de 2026-10-27).

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
- `labs-google-skills` — labs oficiais gratuitos do Google Skills (skills.google). Plano Starter, 35 créditos/mês grátis (GEAR/Developer Program), **sem cartão**. É o contraparte real-console do sandbox. Credenciais do lab são temporárias: nunca colar no chat nem commitar. Login do Username 2 etc. é sempre feito pelo Wellington.
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
Ver checklist no `README.md`. Última atualização: 2026-10-27.
- Foco: **só cloud júnior no Google Cloud**; SOC descartado. Temas-alvo: IAM, Compute Engine, Cloud Storage, VPC/firewall, Cloud Run/GKE, Cloud SQL, Terraform, Monitoring/custos (base do Associate Cloud Engineer).
- Sandbox: S01 CONCLUÍDA (check.sh 7/7). S02 (IAM menor privilégio) ainda NÃO feita pelo Wellington. S03 (kind) testada e opcional (GKE é muito pedido).
- Google Skills: GSP647 "Configuring IAM Permissions with gcloud" (1 crédito, 25 min). Task 1 CONCLUÍDA (SSH na `centos-clean`, `gcloud auth login`, config region/zona, VM `lab-1`, troca de zona). Task 2 (`gcloud init --no-launch-browser`, configuração `user2`) NÃO feita; o lab expira por tempo no servidor do Google, então provavelmente precisa ser refeito (1 crédito).
- Lições da sessão: não usar Ctrl+C para copiar no terminal SSH (mata o comando; use Ctrl+Shift+C/V); cada `gcloud auth login` gera link e código novos; `gcloud config list` é o primeiro diagnóstico de projeto/conta/zona errados.
- Docker Desktop: se o engine não subir com erro "remove ...sock: The file cannot be accessed", feche o Docker, renomeie `%LOCALAPPDATA%\Docker\run` e `%LOCALAPPDATA%\docker-secrets-engine` (sockets AF_UNIX velhos) e reabra; use `docker version` (não `docker info`) para testar o engine. kind v0.33.0 em ~/bin.
