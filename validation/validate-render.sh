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
  echo "Checking SPO operator install policy membership"
  spo_install_membership_count="$(
    yq ea '
      [
        . | select(.kind == "PolicySet" and .metadata.name == "policyset-spo-test")
        | .spec.policies[]?
        | select(. == "policy-install-spo-operator")
      ]
      | length
    ' "${rendered}"
  )"
  if [[ "${spo_install_membership_count}" != "1" ]]; then
    echo "ERROR: policyset-spo-test must include policy-install-spo-operator" >&2
    exit 1
  fi
  echo "Checking SPO install policy OperatorPolicy template"
  spo_operator_policy_count="$(
    yq ea '
      [
        . | select(.kind == "Policy" and .metadata.name == "policy-install-spo-operator")
        | .spec."policy-templates"[]?.objectDefinition
        | select(
            .apiVersion == "policy.open-cluster-management.io/v1beta1"
            and .kind == "OperatorPolicy"
            and .metadata.name == "install-spo-operator"
            and .spec.subscription.name == "security-profiles-operator"
          )
      ]
      | length
    ' "${rendered}"
  )"
  if [[ "${spo_operator_policy_count}" != "1" ]]; then
    echo "ERROR: policy-install-spo-operator must include the SPO OperatorPolicy template" >&2
    exit 1
  fi
  echo "Checking Blastwall v2 policy membership"
  blastwall_v2_membership_count="$(
    yq ea '
      [
        . | select(.kind == "PolicySet" and .metadata.name == "policyset-blastwall-test")
        | .spec.policies[]?
        | select(
            . == "policy-blastwall-v2-raw-profiles"
            or . == "policy-blastwall-v2-profile-usage"
            or . == "policy-blastwall-v2-runtime-bindings"
          )
      ]
      | length
    ' "${rendered}"
  )"
  if [[ "${blastwall_v2_membership_count}" != "3" ]]; then
    echo "ERROR: policyset-blastwall-test must include the three Blastwall v2 policies" >&2
    exit 1
  fi
  echo "Checking Blastwall v2 CRD precondition dependency"
  raw_dependency_count="$(
    yq ea '
      [
        . | select(.kind == "Policy" and .metadata.name == "policy-blastwall-v2-raw-profiles")
        | .spec.dependencies[]?
        | select(
            .apiVersion == "policy.open-cluster-management.io/v1"
            and .kind == "Policy"
            and .name == "policy-spo-rawselinuxprofile-crd"
            and .namespace == "acm-spo-policies"
            and .compliance == "Compliant"
          )
      ]
      | length
    ' "${rendered}"
  )"
  if [[ "${raw_dependency_count}" != "1" ]]; then
    echo "ERROR: policy-blastwall-v2-raw-profiles must depend on policy-spo-rawselinuxprofile-crd" >&2
    exit 1
  fi
  echo "Checking Blastwall v2 staged rollout dependencies"
  staged_dependency_count="$(
    yq ea '
      [
        . | select(.kind == "Policy" and .metadata.name == "policy-blastwall-v2-profile-usage")
        | .spec.dependencies[]?
        | select(.name == "policy-blastwall-v2-raw-profiles" and .compliance == "Compliant")
      ] + [
        . | select(.kind == "Policy" and .metadata.name == "policy-blastwall-v2-runtime-bindings")
        | .spec.dependencies[]?
        | select(.name == "policy-blastwall-v2-profile-usage" and .compliance == "Compliant")
      ]
      | length
    ' "${rendered}"
  )"
  if [[ "${staged_dependency_count}" != "2" ]]; then
    echo "ERROR: Blastwall v2 usage and runtime policies must be dependency-gated" >&2
    exit 1
  fi
  echo "Checking Blastwall v2 status-derived SCC templates"
  status_derived_scc_count="$(
    yq ea '
      [
        . | select(.kind == "Policy" and .metadata.name == "policy-blastwall-v2-runtime-bindings")
        | .spec."policy-templates"[]?.objectDefinition.spec."object-templates"[]?.objectDefinition
        | select(.kind == "SecurityContextConstraints")
        | .seLinuxContext.seLinuxOptions.type
        | select(test("lookup.*RawSelinuxProfile.*status\\.usage"))
      ]
      | length
    ' "${rendered}"
  )"
  if [[ "${status_derived_scc_count}" != "2" ]]; then
    echo "ERROR: Blastwall v2 SCC policies must derive SELinux types from RawSelinuxProfile status.usage" >&2
    exit 1
  fi
else
  if [[ "${REQUIRE_YQ:-false}" == "true" ]]; then
    echo "ERROR: yq is required for rendered policy membership inspection" >&2
    exit 1
  fi
  echo "WARNING: yq not found; skipping rendered policy membership inspection" >&2
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
