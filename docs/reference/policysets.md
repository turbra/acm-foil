---
id: policysets
title: PolicySets and Placement
description: Reference for PolicySets, Placement, and PlacementBindings.
---

# PolicySets and Placement

## `policyset-blastwall-test`

File:

```text
policies/base/policyset-blastwall.yaml
```

Policies:

```text
policy-blastwall-spo-profiles
```

PlacementBinding:

```text
policies/overlays/test-spo-cluster-scoped/placementbinding-blastwall.yaml
```

Validate:

```bash
oc get policyset -n acm-spo-policies policyset-blastwall-test
oc get placementbinding -n acm-spo-policies binding-policyset-blastwall-test
```

## `policyset-spo-test`

File:

```text
policies/base/policyset-spo.yaml
```

Policies:

```text
policy-prevent-copy-fail-cve-ds
policy-spo-selinux-smoke
```

PlacementBinding:

```text
policies/overlays/test-spo-cluster-scoped/placementbinding.yaml
```

Validate:

```bash
oc get policyset -n acm-spo-policies policyset-spo-test
oc get placementbinding -n acm-spo-policies binding-policyset-spo-test
```

## `placement-spo-test`

File:

```text
policies/overlays/test-spo-cluster-scoped/placement.yaml
```

Selects managed clusters with:

```yaml
spo: "true"
```

Both PolicySets use this Placement.

Validate placement decisions:

```bash
oc get placementdecision -n acm-spo-policies -o yaml
```
