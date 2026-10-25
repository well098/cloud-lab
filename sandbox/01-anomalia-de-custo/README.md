# Sandbox 01 — Anomalia de custo

**Custo: R$ 0. Roda 100% local (Python).** Sem conta GCP, sem cartão.

## Cenário
Você é o analista de plantão. O billing export de setembro (`billing_export.csv`, 30 dias, 2 projetos) mostra a fatura subindo. Pode ser uso legítimo... ou **cryptomining** com credencial vazada. Tem também um pico que parece suspeito mas não é.

## Objetivo
Preencher `resposta.json` (copie de `resposta.template.json`) com: projeto, serviço, SKU suspeito, primeiro dia da anomalia, custo acumulado do grupo desde esse dia, o falso positivo e a ação recomendada.

## Passo A (Console) — como seria no GCP real
Billing → **Reports** → agrupar por *Project* e *SKU*, filtrar por período. Em **Anomalies** o Google já sinaliza desvios. Aqui você faz o mesmo à mão, em cima do CSV (é o formato do *Billing export*).

## Passo B (CLI) — hands-on local
```bash
cd sandbox/01-anomalia-de-custo
head billing_export.csv                      # entender as colunas
python3 - <<'PY'                              # exemplo: custo diario por projeto/servico
import csv, collections
t = collections.defaultdict(float)
for r in csv.DictReader(open("billing_export.csv")):
    t[(r["date"], r["project"], r["service"])] += float(r["cost_brl"])
for k in sorted(t)[:8]: print(k, round(t[k], 2))
PY
cp resposta.template.json resposta.json      # preencha com suas descobertas
bash check.sh
```
Dicas: compare cada série com a **mediana dos primeiros 14 dias**. Anomalia = salto grande **e sustentado**. Pico de 1 dia = outra história.

## Por que importa
- Gasto inesperado é um dos primeiros sinais de **comprometimento de credencial** (GPU/VM de mineração). SOC e FinOps olham os mesmos dados.
- Saber separar anomalia sustentada de pico pontual evita alarme falso (e fadiga de alerta).

## Desafio extra
Escreva um script `detect.py` que leia o CSV e imprima automaticamente grupos com ≥ 5 dias consecutivos acima de 5× a mediana base. Depois proponha 2 controles preventivos (ex.: budget com alerta, quota de GPU, restrição por *Organization Policy*).

## Cleanup
Nada a limpar (só arquivos locais). Apague `resposta.json` se quiser refazer.
