#!/usr/bin/env bash
# Sandbox 03 — remove o cluster local "lab-gke" e libera a RAM.
set -u
export PATH="$HOME/bin:$PATH"
kind delete cluster --name lab-gke
