---
id: placement
title: Placement
description: How ACM Foil selects managed clusters.
---

# Placement

ACM Foil uses ACM `Placement` to select clusters. Clusters opt in by label.

```bash
oc label managedcluster <cluster-name> spo=true --overwrite
```

The active placement is:

```text
Placement/acm-spo-policies/placement-spo-test
```

It selects managed clusters where:

```yaml
spo: "true"
```

## Cluster Set Binding

The policy namespace must be bound to the cluster set that contains the target cluster.

The active overlay creates:

```text
ManagedClusterSetBinding/acm-spo-policies/default
```

If a target cluster belongs to a different cluster set, add the matching `ManagedClusterSetBinding` or move the cluster to the bound set.

## PolicySet Binding

PolicySets are attached to placement with `PlacementBinding` resources. ACM Foil uses one placement for the current test policy sets.

```text
PlacementBinding/binding-policyset-blastwall-test
PlacementBinding/binding-policyset-spo-test
```
