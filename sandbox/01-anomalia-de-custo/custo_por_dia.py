import csv, collections

t = collections.defaultdict(float)
for r in csv.DictReader(open("billing_export.csv")):
    t[r["date"]] += float(r["cost_brl"])
for d in sorted(t):
    print(d, round(t[d], 2))
