#!/usr/bin/env bash
set -euo pipefail

echo "This script validates all kustomize overlays locally using kubectl kustomize, yamllint and kubeconform."
echo "It will not modify the repo. Run from the repository root."

command -v kubectl >/dev/null 2>&1 || { echo "kubectl not found in PATH"; exit 1; }

if ! command -v yamllint >/dev/null 2>&1; then
  echo "yamllint not found; installing via pip..."
  python3 -m pip install --user yamllint
  export PATH="$PATH:$(python3 -m site --user-base)/bin"
fi

if ! command -v kubeconform >/dev/null 2>&1; then
  echo "kubeconform not found; installing via go..."
  GO_BIN_DIR=$(go env GOPATH 2>/dev/null || echo "$HOME/go")
  export PATH="$PATH:$GO_BIN_DIR/bin"
  go install github.com/yannh/kubeconform/cmd/kubeconform@v0.7.0
fi

REPORT=yamllint-report.txt
rm -f "$REPORT"

for dir in $(find k8s-sandbox -type f -name 'kustomization.yaml' -printf '%h\n' | sort -u); do
  echo "\nValidating $dir"
  TMP_OUT=$(mktemp)
  if ! kubectl kustomize "$dir" > "$TMP_OUT"; then
    echo "kustomize build failed for $dir" | tee -a "$REPORT"
    rm -f "$TMP_OUT"
    continue
  fi
  # sanitize
  CLEAN_OUT=$(mktemp)
  sed '/^```/d' "$TMP_OUT" | sed '/^[[:space:]]*$/d' > "$CLEAN_OUT"

  if ! yamllint -d '{extends: default, rules: {document-start: {level: warning}}}' "$CLEAN_OUT" 2>> "$REPORT"; then
    echo "yamllint issues found in $dir (see $REPORT)"
  fi

  if ! kubeconform -strict -kubernetes-version 1.27.0 "$CLEAN_OUT" >> "$REPORT" 2>&1; then
    echo "kubeconform issues found in $dir (see $REPORT)"
  fi

  rm -f "$TMP_OUT" "$CLEAN_OUT"
done

if [ -s "$REPORT" ]; then
  echo "\nSome checks failed. See $REPORT"
  exit 1
else
  echo "\nAll checks passed locally"
fi
