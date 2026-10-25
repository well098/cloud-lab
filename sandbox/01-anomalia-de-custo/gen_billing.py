"""Gera billing_export.csv simulado (30 dias). Seed fixa = resultado reproduzivel."""
import csv, random, datetime as dt

random.seed(42)
START = dt.date(2026, 9, 1)
BASE = {  # (projeto, servico, sku): custo medio diario em BRL
    ("lab-dev", "Compute Engine", "E2 Instance Core running"): 4.0,
    ("lab-dev", "Cloud Storage", "Standard Storage Brazil"): 1.2,
    ("lab-dev", "BigQuery", "Analysis"): 0.8,
    ("lab-dev", "Cloud Logging", "Log Volume"): 0.5,
    ("lab-prod", "Compute Engine", "E2 Instance Core running"): 3.0,
    ("lab-prod", "Cloud Storage", "Standard Storage Brazil"): 2.5,
    ("lab-prod", "BigQuery", "Analysis"): 1.0,
    ("lab-prod", "Cloud Logging", "Log Volume"): 0.7,
}
rows = []
for d in range(30):
    day = START + dt.timedelta(days=d)
    for (proj, svc, sku), mean in BASE.items():
        cost = max(0.0, random.gauss(mean, mean * 0.08))
        # Ruido legitimo: 1 dia isolado de batch no BigQuery do dev (dia 10)
        if (proj, svc) == ("lab-dev", "BigQuery") and d == 9:
            cost += 38.0
        rows.append([day.isoformat(), proj, svc, sku, round(cost, 2)])
    # Anomalia sustentada: GPU no Compute do prod a partir do dia 19
    if d >= 18:
        rows.append([day.isoformat(), "lab-prod", "Compute Engine",
                     "A2 Nvidia Tesla A100 GPU running", round(random.gauss(85, 4), 2)])

with open("billing_export.csv", "w", newline="", encoding="utf-8") as f:
    w = csv.writer(f)
    w.writerow(["date", "project", "service", "sku", "cost_brl"])
    w.writerows(rows)
print(f"{len(rows)} linhas")
