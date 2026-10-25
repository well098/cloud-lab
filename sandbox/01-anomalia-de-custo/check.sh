#!/usr/bin/env bash
# Sandbox 01 — compara resposta.json com a anomalia calculada a partir do billing_export.csv.
# Uso: bash check.sh   (roda local, sem GCP)
set -u
cd "$(dirname "$0")" || exit 1
PY="$(command -v python3 || command -v python)"
[ -n "$PY" ] || { echo "[FALHA] python nao encontrado"; exit 1; }
[ -f resposta.json ] || { echo "[FALHA] resposta.json nao existe (copie resposta.template.json)"; exit 1; }

"$PY" - <<'PYEOF'
import csv, json, statistics as st, collections, sys

daily = collections.defaultdict(lambda: collections.defaultdict(float))  # (proj,svc) -> dia -> custo
skus = collections.defaultdict(lambda: collections.defaultdict(set))     # (proj,svc) -> sku -> dias
for r in csv.DictReader(open("billing_export.csv", encoding="utf-8")):
    k = (r["project"], r["service"])
    daily[k][r["date"]] += float(r["cost_brl"])
    skus[k][r["sku"]].add(r["date"])

days = sorted({d for k in daily for d in daily[k]})
truth, spurious = None, []
for k, series in daily.items():
    base = st.median([series.get(d, 0) for d in days[:14]])
    hot = [d for d in days if series.get(d, 0) > 5 * base]
    if not hot:
        continue
    sustained = any(all(days[i + j] in hot for j in range(5)) for i in range(len(days) - 4) if days[i] in hot)
    if sustained:
        first = next(d for d in days if d in hot)
        total = sum(v for d, v in series.items() if d >= first)
        new_sku = [s for s, ds in skus[k].items() if min(ds) >= first][0]
        truth = dict(projeto=k[0], servico=k[1], sku=new_sku, dia=first, total=total)
    else:
        spurious.append(f"{k[0]}/{k[1]}")

try:
    a = json.load(open("resposta.json", encoding="utf-8"))
except Exception as e:
    print(f"[FALHA] resposta.json invalido: {e}"); sys.exit(1)

fail = 0
def chk(ok, okmsg, failmsg):
    global fail
    print(("[OK]    " if ok else "[FALHA] ") + (okmsg if ok else failmsg))
    fail |= (not ok)

g = lambda k: str(a.get(k, "")).strip().lower()
chk(g("projeto") == truth["projeto"], "projeto correto", "projeto incorreto")
chk(g("servico") == truth["servico"].lower(), "servico correto", "servico incorreto")
chk(g("sku_suspeito") == truth["sku"].lower(), "sku suspeito correto", "sku suspeito incorreto (procure o SKU que so aparece apos o aumento)")
chk(g("primeiro_dia") == truth["dia"], "primeiro dia correto", "primeiro dia incorreto")
try:
    v = float(a.get("custo_do_grupo_desde_o_inicio_brl", -1))
    chk(abs(v - truth["total"]) <= 5, "custo acumulado dentro da tolerancia (+-R$ 5)", "custo acumulado incorreto (some TODO o grupo projeto+servico desde o primeiro dia)")
except (TypeError, ValueError):
    chk(False, "", "custo acumulado nao numerico")
chk(g("falso_positivo") in [s.lower() for s in spurious], "falso positivo identificado (pico isolado, nao sustentado)", "falso positivo incorreto (ha um pico de 1 dia que NAO e ataque)")
chk(len(g("acao_recomendada")) >= 15, "acao recomendada preenchida", "preencha acao_recomendada (>= 15 caracteres)")
print()
print("Sandbox 01: PASSOU" if not fail else "Sandbox 01: NAO PASSOU")
sys.exit(1 if fail else 0)
PYEOF
