# Sandbox 02 — IAM de menor privilégio

**Custo: R$ 0. Roda 100% local (Python).** Sem conta GCP, sem cartão.

## Cenário
A service account `app-reader` precisa só **ler arquivos de um bucket**. Alguém deu `roles/editor` pra ela no projeto inteiro "pra funcionar". E o bucket está legível por `allAuthenticatedUsers` (qualquer pessoa com conta Google!).

## Objetivo
Criar dois arquivos corrigidos, partindo dos `-atual`:
- `projeto-iam-corrigido.json` — SA **sem nenhum role** no projeto; não mexa nos outros membros.
- `bucket-iam-corrigido.json` — SA com **somente** `roles/storage.objectViewer` no bucket; remover o acesso público; manter o `legacyBucketOwner`.

## Passo A (Console) — como seria no GCP real
IAM & Admin → **IAM**: achar a SA e remover o role Editor. Cloud Storage → bucket → **Permissions**: remover `allAuthenticatedUsers` e dar *Storage Object Viewer* só à SA. Use **IAM Recommender** pra ver permissões sem uso.

## Passo B (CLI) — hands-on local
```bash
cd sandbox/02-iam-menor-privilegio
cat projeto-iam-atual.json bucket-iam-atual.json
cp projeto-iam-atual.json projeto-iam-corrigido.json    # edite os dois
cp bucket-iam-atual.json  bucket-iam-corrigido.json
bash check.sh
```
No GCP real o equivalente seria (referência, não roda aqui):
```bash
gcloud projects remove-iam-policy-binding PROJECT --member=serviceAccount:app-reader@PROJECT.iam.gserviceaccount.com --role=roles/editor
gcloud storage buckets add-iam-policy-binding gs://lab-dados-relatorios --member=serviceAccount:app-reader@PROJECT.iam.gserviceaccount.com --role=roles/storage.objectViewer
gcloud storage buckets remove-iam-policy-binding gs://lab-dados-relatorios --member=allAuthenticatedUsers --role=roles/storage.objectViewer
```

## Por que importa
- `roles/editor` no projeto = SA pode criar/apagar quase tudo. Se a chave vazar, o estrago é do tamanho do projeto inteiro.
- **Menor privilégio** + escopo no recurso (bucket, não projeto) é o ponto mais cobrado em entrevista de cloud/SOC.
- `allAuthenticatedUsers` ≠ "usuários da minha empresa": é qualquer conta Google do mundo. Bucket vazado é incidente clássico.

## Desafio extra
Escreva um `audit.py` que varra os JSONs e liste: roles básicos (`owner/editor/viewer`) atribuídos a SAs e qualquer membro `allUsers`/`allAuthenticatedUsers`. É um mini *IAM auditor*.

## Cleanup
Nada a limpar. Apague os `-corrigido.json` pra refazer.
