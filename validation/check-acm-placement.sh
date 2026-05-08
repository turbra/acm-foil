#!/usr/bin/env bash
set -euo pipefail

namespace="${1:-acm-spo-policies}"

oc get policy -n "${namespace}"
oc get policyset -n "${namespace}"
oc get placement -n "${namespace}"
oc get placementbinding -n "${namespace}"
oc get placementdecision -n "${namespace}"
oc get managedclustersetbinding -n "${namespace}"
