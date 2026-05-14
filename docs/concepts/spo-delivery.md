---
id: spo-delivery
title: SPO Delivery
description: How ACM Foil delivers Security Profiles Operator resources.
---

# SPO Delivery

ACM Foil installs the Security Profiles Operator on selected managed clusters before applying SPO-backed resources.

The repository proves ACM can deliver SPO resources by applying:

```text
Namespace/openshift-security-profiles
OperatorPolicy/install-spo-operator
CustomResourceDefinition/rawselinuxprofiles.security-profiles-operator.x-k8s.io readiness check
RawSelinuxProfile/blastwall
RawSelinuxProfile/blastwallnested
SecurityContextConstraints/blastwall-confined
SecurityContextConstraints/blastwall-nested
```

## Operator Install

`policy-install-spo-operator` creates the `openshift-security-profiles` namespace and uses ACM `OperatorPolicy` to install the `security-profiles-operator` package from `redhat-operators`.

The same `spo=true` managed-cluster label controls where the operator is installed.

## CRD Precondition

Blastwall uses SPO `RawSelinuxProfile` resources. ACM Foil checks that the target cluster has the `rawselinuxprofiles.security-profiles-operator.x-k8s.io` CRD and that it is `Established=True`.

The precondition policy is inform-only. The install policy owns operator installation, and the Blastwall raw profile policy depends on the CRD precondition before enforcement.

## Blastwall Profiles

The Blastwall policies carry prebuilt upstream SPO manifests and split rollout into stages:

1. Apply namespaces, `RawSelinuxProfile` resources, and the validation probe ConfigMap.
2. Wait for `RawSelinuxProfile.status.usage`.
3. Apply SCC and RBAC bindings with SELinux types derived from the live usage strings.

Review the Blastwall policies before broad rollout because they include namespaces, RBAC, SCCs, and validation objects.

See [Blastwall Workload Confinement](./blastwall.md) for the adoption benefits and control model.
