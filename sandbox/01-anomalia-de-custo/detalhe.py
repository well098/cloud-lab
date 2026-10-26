import csv, sys

dia = sys.argv[1] if len(sys.argv) > 1 else "2026-09-01"
linhas = [r for r in csv.DictReader(open("billing_export.csv")) if r["date"] == dia]
linhas.sort(key=lambda r: float(r["cost_brl"]), reverse=True)

print(f"Dia {dia} (maior custo primeiro)")
for r in linhas:
    print(f'{float(r["cost_brl"]):8.2f}  {r["project"]:9} {r["service"]:15} {r["sku"]}')
