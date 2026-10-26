import csv, sys

if len(sys.argv) != 4:
    sys.exit('uso: python3 grupo.py <projeto> "<servico>" <AAAA-MM-DD>')
projeto, servico, desde = sys.argv[1:4]

total = 0.0
for r in csv.DictReader(open("billing_export.csv")):
    if r["project"] == projeto and r["service"] == servico and r["date"] >= desde:
        total += float(r["cost_brl"])

print(f"{projeto} / {servico} desde {desde}: R$ {total:.2f}")
