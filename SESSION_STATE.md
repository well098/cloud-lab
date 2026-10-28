# Sessão mais recente

- Data: 2026-10-28
- Resumo: Wellington refez o lab GSP647 "Configuring IAM Permissions with gcloud" (Google Skills, 1 crédito, sem cartão) e terminou com **100/100** em todas as 7 tasks. Lab encerrado com End Lab.
- O que foi praticado: configurações gcloud (`default` e `user2`), `gcloud auth login`, região/zona, VMs `lab-1`/`lab-2`/`lab-3`, viewer vs. quem cria (erro `Required 'compute.instances.create' permission`), `add-iam-policy-binding` (usuário e service account), role customizado `devops` (10 permissões), service account `devops` com `iam.serviceAccountUser` + `compute.instanceAdmin` e `--scopes` na VM. Task 7 (SSH na lab-3, teste da identidade da service account) foi pulada por ser opcional e sem pontos.
- Arquivos alterados: CLAUDE.md, README.md, SESSION_STATE.md
- Problemas e solução:
  - Login da `user2` saiu como `student-01` duas vezes: a tela OAuth já vem com a conta ativa e o "Continue" autoriza ela; resolvido com "Use another account" e conferindo o e-mail antes do Continue. Sempre ler a linha `You are signed in as:` do `gcloud init`.
  - `add-iam-policy-binding` com a `user2` ativa deu `getIamPolicy` negado (só a `default`, owner, concede roles).
  - Lixo `;9~` no prompt (resto de atalho de teclado, tipo Alt+Tab) quebrou um comando; resolvido com Ctrl+U.
  - Sair da página do lab não perde nada: timer, VMs e nota ficam no servidor do Google.
- Pendências: sandbox S02 (IAM menor privilégio) ainda não feita; confirmar próximos labs gratuitos (Compute Engine, Storage, VPC/firewall, Cloud Run, Terraform) com crédito e duração; créditos restantes no mês: ~33 de 35.
- Próxima tarefa: fazer a sandbox S02 (reforça o que o GSP647 mostrou) ou escolher o próximo lab do catálogo (Cloud Storage ou VPC/firewall).
- Observações: o Wellington digita as credenciais do lab, nunca Claude. Credenciais temporárias apareceram em prints (expiram ao encerrar o lab).
