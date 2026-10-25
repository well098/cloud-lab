#!/usr/bin/env bash
# Sandbox 03 — valida o estado REAL do cluster kind "lab-gke" (via kubectl).
# Uso: bash check.sh   (rode setup.sh antes)
set -u
export PATH="$HOME/bin:$PATH"
CTX=kind-lab-gke
PY="$(command -v python3 || command -v python)"
FAIL=0
ok()   { echo "[OK]    $*"; }
fail() { echo "[FALHA] $*"; FAIL=1; }

command -v kind >/dev/null && ok "kind encontrado" || fail "kind nao encontrado (esperado em ~/bin/kind.exe)"
command -v kubectl >/dev/null && ok "kubectl encontrado" || fail "kubectl nao encontrado"
[ -n "$PY" ] || fail "python nao encontrado"
if timeout 15 docker info >/dev/null 2>&1; then ok "Docker rodando"; else fail "Docker nao esta rodando (abra o Docker Desktop)"; fi
if timeout 20 kind get clusters 2>/dev/null | grep -qx lab-gke; then ok "cluster lab-gke existe"; else fail "cluster lab-gke nao existe (rode: bash setup.sh)"; fi

if [ "$FAIL" -eq 0 ]; then
  kubectl --context "$CTX" get ns lab >/dev/null 2>&1 && ok "namespace lab existe" || fail "namespace lab nao existe"
  DEP="$(kubectl --context "$CTX" -n lab get deploy web -o json 2>/dev/null)"
  EP="$(kubectl --context "$CTX" -n lab get endpoints web -o json 2>/dev/null)"
  SVC="$(kubectl --context "$CTX" -n lab get svc web -o json 2>/dev/null)"
  if [ -z "$DEP" ]; then
    fail "deployment 'web' nao encontrado no namespace lab (kubectl apply -f web.yaml)"
  else
    DEP="$DEP" EP="${EP:-{\}}" SVC="${SVC:-{\}}" "$PY" - <<'PYEOF'
import json, os, sys
d, ep, svc = (json.loads(os.environ[k]) for k in ("DEP", "EP", "SVC"))
fail = 0
def chk(ok, okmsg, failmsg):
    global fail
    print(("[OK]    " if ok else "[FALHA] ") + (okmsg if ok else failmsg)); fail |= (not ok)

spec, st = d["spec"], d.get("status", {})
c = spec["template"]["spec"]["containers"][0]
pod_sc = spec["template"]["spec"].get("securityContext", {})
chk(spec.get("replicas", 0) >= 2, f"replicas = {spec.get('replicas')} (>= 2)", "precisa de pelo menos 2 replicas")
chk(st.get("availableReplicas", 0) == spec.get("replicas") and st.get("availableReplicas", 0) >= 2,
    "todas as replicas disponiveis", f"replicas disponiveis: {st.get('availableReplicas', 0)}/{spec.get('replicas')} (veja: kubectl -n lab get pods)")
img = c.get("image", "")
tag = img.split(":", 1)[1] if ":" in img.rsplit("/", 1)[-1] else ""
chk(tag not in ("", "latest"), f"imagem com versao fixa ({img})", f"imagem sem versao fixa ou :latest ({img})")
lim, req = c.get("resources", {}).get("limits", {}), c.get("resources", {}).get("requests", {})
chk(all(k in lim for k in ("cpu", "memory")) and all(k in req for k in ("cpu", "memory")),
    "requests e limits de cpu/memory definidos", "faltam requests/limits de cpu e memory")
chk("readinessProbe" in c, "readinessProbe definida", "falta readinessProbe")
nonroot = c.get("securityContext", {}).get("runAsNonRoot") or pod_sc.get("runAsNonRoot")
chk(bool(nonroot), "runAsNonRoot: true", "falta securityContext.runAsNonRoot: true")
rev = int(d["metadata"].get("annotations", {}).get("deployment.kubernetes.io/revision", "1"))
chk(rev >= 2, f"rolling update realizado (revision {rev})", "faça um rolling update: troque a versao da imagem e reaplique (revision >= 2)")
addrs = sum(len(s.get("addresses", [])) for s in ep.get("subsets", []) or [])
chk(addrs >= 2, f"Service 'web' com {addrs} endpoints", f"Service 'web' com {addrs} endpoints (esperado >= 2; confira selector/readiness)")
sys.exit(1 if fail else 0)
PYEOF
    [ $? -eq 0 ] || FAIL=1
  fi
fi
echo
if [ "$FAIL" -eq 0 ]; then echo "Sandbox 03: PASSOU"; exit 0; else echo "Sandbox 03: NAO PASSOU"; exit 1; fi
