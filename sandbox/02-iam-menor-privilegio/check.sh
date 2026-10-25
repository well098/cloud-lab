#!/usr/bin/env bash
# Sandbox 02 — valida as policies corrigidas (menor privilegio). Roda local, sem GCP.
set -u
cd "$(dirname "$0")" || exit 1
PY="$(command -v python3 || command -v python)"
[ -n "$PY" ] || { echo "[FALHA] python nao encontrado"; exit 1; }

"$PY" - <<'PYEOF'
import json, sys
SA = "serviceAccount:app-reader@lab-prod.iam.gserviceaccount.com"
PUBLIC = {"allUsers", "allAuthenticatedUsers"}
fail = 0
def chk(ok, okmsg, failmsg):
    global fail
    print(("[OK]    " if ok else "[FALHA] ") + (okmsg if ok else failmsg))
    fail |= (not ok)

def load(name):
    try:
        return json.load(open(name, encoding="utf-8"))
    except FileNotFoundError:
        print(f"[FALHA] {name} nao existe (crie a partir do arquivo -atual)"); sys.exit(1)
    except Exception as e:
        print(f"[FALHA] {name} invalido: {e}"); sys.exit(1)

proj = load("projeto-iam-corrigido.json")
buck = load("bucket-iam-corrigido.json")
roles_of = lambda pol, m: sorted(b["role"] for b in pol.get("bindings", []) if m in b.get("members", []))
members = lambda pol, r: sorted(m for b in pol.get("bindings", []) if b["role"] == r for m in b.get("members", []))

chk(roles_of(proj, SA) == [], "SA sem nenhum role no projeto (editor removido)", f"SA ainda tem roles no projeto: {roles_of(proj, SA)}")
chk(members(proj, "roles/owner") == ["user:admin@example.com"], "owner do projeto preservado", "owner do projeto foi alterado (nao mexa no que nao e a SA)")
chk(members(proj, "roles/viewer") == ["group:time-suporte@example.com"], "viewer do time de suporte preservado", "viewer do time de suporte foi alterado")
chk(roles_of(buck, SA) == ["roles/storage.objectViewer"], "SA tem somente roles/storage.objectViewer no bucket", f"roles da SA no bucket: {roles_of(buck, SA)} (esperado so roles/storage.objectViewer)")
leak = [m for pol in (proj, buck) for b in pol.get("bindings", []) for m in b.get("members", []) if m in PUBLIC]
chk(not leak, "nenhum acesso publico (allUsers/allAuthenticatedUsers)", f"acesso publico ainda presente: {sorted(set(leak))}")
chk(members(buck, "roles/storage.legacyBucketOwner") == ["projectOwner:lab-prod"], "legacyBucketOwner do projeto preservado", "legacyBucketOwner foi alterado")
print()
print("Sandbox 02: PASSOU" if not fail else "Sandbox 02: NAO PASSOU")
sys.exit(1 if fail else 0)
PYEOF
