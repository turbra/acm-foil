#!/usr/bin/env bash
set -euo pipefail

overlay="${1:-policies/overlays/test-spo-cluster-scoped}"
rendered="${RENDERED_OUTPUT:-$(mktemp -t spo-acm-rendered.XXXXXX.yaml)}"
kustomize_bin="${KUSTOMIZE_BIN:-}"

export PATH="${HOME}/.local/bin:${HOME}/bin:/usr/local/bin:/usr/bin:${PATH}"

if [[ -z "${kustomize_bin}" ]]; then
  kustomize_bin="$(command -v kustomize || true)"
fi

if [[ -z "${kustomize_bin}" || ! -x "${kustomize_bin}" ]]; then
  echo "ERROR: kustomize is required. Set KUSTOMIZE_BIN or add it to PATH." >&2
  echo "PATH=${PATH}" >&2
  exit 1
fi

echo "Validating Kustomize build for ${overlay}"
mkdir -p "$(dirname "${rendered}")"
"${kustomize_bin}" build --enable-alpha-plugins "${overlay}" > "${rendered}"

echo "Checking rendered governance resources"
grep -E "kind: (Policy|PolicySet|Placement|PlacementBinding|ManagedClusterSetBinding)" "${rendered}"

if command -v yq >/dev/null 2>&1; then
  echo "Checking rendered policy membership"
  yq '
    select(.kind == "PolicySet")
    | .spec.policies
  ' "${rendered}"
  echo "Checking generated policy dependencies when present"
  yq '
    select(.kind == "Policy" and .metadata.name == "policy-spo-selinux-profiles")
    | .spec.dependencies
  ' "${rendered}"
  yq '
    select(.kind == "Policy" and .metadata.name == "policy-spo-profilebindings")
    | .spec.dependencies
  ' "${rendered}"
else
  if [[ "${REQUIRE_YQ:-false}" == "true" ]]; then
    echo "ERROR: yq is required for generated dependency inspection" >&2
    exit 1
  fi
  echo "WARNING: yq not found; skipping generated dependency inspection" >&2
fi

if command -v oc >/dev/null 2>&1; then
  current_server="$(oc whoami --show-server 2>/dev/null || true)"
  expected_server="${EXPECTED_OPENSHIFT_API_URL:-}"

  if [[ -n "${expected_server}" && "${current_server}" != "${expected_server}" ]]; then
    message="oc is configured for '${current_server:-unknown}', expected '${expected_server}'"
    if [[ "${REQUIRE_OC_DRY_RUN:-false}" == "true" ]]; then
      echo "ERROR: ${message}" >&2
      exit 1
    fi
    echo "WARNING: ${message}; skipping oc dry run" >&2
  elif oc get namespace acm-spo-policies >/dev/null 2>&1; then
    echo "Validating generated YAML with server-side dry run"
    oc apply --dry-run=server -f "${rendered}"
  elif [[ "${REQUIRE_OC_DRY_RUN:-false}" == "true" ]]; then
    echo "ERROR: namespace acm-spo-policies must exist for server-side dry run" >&2
    exit 1
  else
    echo "WARNING: namespace acm-spo-policies not found; skipping oc dry run" >&2
  fi
else
  if [[ "${REQUIRE_OC_DRY_RUN:-false}" == "true" ]]; then
    echo "ERROR: oc is required for server-side dry run" >&2
    exit 1
  fi
  echo "WARNING: oc not found; skipping server-side dry run" >&2
fi
