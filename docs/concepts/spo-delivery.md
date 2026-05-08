---
id: spo-delivery
title: SPO Delivery
description: How ACM Foil delivers Security Profiles Operator resources.
---

# SPO Delivery

ACM Foil assumes the Security Profiles Operator is already installed on target clusters.

The repository proves ACM can deliver SPO resources by applying:

```text
SelinuxProfile/acm-spo-smoke
RawSelinuxProfile/blastwall
RawSelinuxProfile/blastwallnested
```

## Smoke Profile

The smoke profile is intentionally harmless. It creates a `SelinuxProfile` that inherits from the standard `container` system profile and is not bound to any workload.

Use it to prove that:

1. The cluster was selected by ACM placement.
2. ACM replicated and enforced the policy.
3. The managed cluster accepted an SPO custom resource.

## Blastwall Profiles

The Blastwall policy carries prebuilt SPO manifests. ACM Foil does not recreate that content by hand. It wraps the existing policy content and lets ACM deliver it to selected clusters.

Review the Blastwall policy before broad rollout because it also includes namespaces, RBAC, SCCs, and validation objects.
