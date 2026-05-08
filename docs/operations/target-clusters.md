---
id: target-clusters
title: Target Clusters
description: How ACM Foil selects managed clusters.
---

# Target Clusters

ACM Foil uses ACM `Placement` to select managed clusters.

The active placement is:

```text
Placement/acm-spo-policies/placement-spo-test
```

## Selection Label

Clusters opt in with:

```text
spo=true
```

Label a managed cluster:

```bash
oc label managedcluster <cluster-name> spo=true --overwrite
```

Remove a cluster from placement:

```bash
oc label managedcluster <cluster-name> spo-
```

## Cluster Set Binding

The overlay binds the `default` ACM `ManagedClusterSet` into the policy namespace:

```text
ManagedClusterSetBinding/acm-spo-policies/default
```

If a target cluster is in another cluster set, either move the cluster or add a matching `ManagedClusterSetBinding`.

Check a cluster set:

```bash
oc get managedcluster <cluster-name> \
  -o jsonpath='{.metadata.labels.cluster\.open-cluster-management\.io/clusterset}{"\n"}'
```

## Validate Placement

```bash
oc get placementdecision -n acm-spo-policies -o yaml
```

The decision should include the clusters that have `spo=true` and belong to a bound cluster set.
