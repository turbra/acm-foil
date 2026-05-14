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
SelinuxProfile/acm-spo-smoke
RawSelinuxProfile/blastwall
RawSelinuxProfile/blastwallnested
```

## Operator Install

`policy-install-spo-operator` creates the `openshift-security-profiles` namespace and uses ACM `OperatorPolicy` to install the `security-profiles-operator` package from `redhat-operators`.

The same `spo=true` managed-cluster label controls where the operator is installed.

## CRD Precondition

Blastwall uses SPO `RawSelinuxProfile` resources. ACM Foil checks that the target cluster has the `rawselinuxprofiles.security-profiles-operator.x-k8s.io` CRD and that it is `Established=True`.

The precondition policy is inform-only. The install policy owns operator installation, and the Blastwall profile policy depends on the CRD precondition before enforcement.

## Smoke Profile

The smoke profile is intentionally harmless. It creates a `SelinuxProfile` that inherits from the standard `container` system profile and is not bound to any workload.

Use it to prove that:

1. The cluster was selected by ACM placement.
2. ACM replicated and enforced the policy.
3. The managed cluster accepted an SPO custom resource.

## Blastwall Profiles

The Blastwall policy carries prebuilt SPO manifests. ACM Foil does not recreate that content by hand. It wraps the existing policy content and lets ACM deliver it to selected clusters.

Review the Blastwall policy before broad rollout because it also includes namespaces, RBAC, SCCs, and validation objects.

See [Blastwall Workload Confinement](./blastwall.md) for the adoption benefits and control model.
