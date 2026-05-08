---
id: troubleshooting
title: Troubleshooting
description: Common failure modes and the shortest useful checks.
---

# Troubleshooting

## Argo CD Is Degraded

Check which resource is degraded:

```bash
oc get applications.argoproj.io -n openshift-gitops spo-acm-policies-test \
  -o jsonpath='{range .status.resources[*]}{.kind}{"/"}{.namespace}{"/"}{.name}{" health="}{.health.status}{" msg="}{.health.message}{"\n"}{end}'
```

If an ACM `Policy` is degraded, check its compliance:

```bash
oc get policy -n acm-spo-policies
```

## Policy Is NonCompliant

Check the replicated policy in the managed cluster namespace:

```bash
oc get policy -n <cluster-name> acm-spo-policies.<policy-name> -o yaml
```

Look at:

```text
status.details[].history[].message
```

That field usually names the missing or mismatched object.

## Placement Selects No Clusters

Check labels:

```bash
oc get managedcluster --show-labels
```

Check placement decisions:

```bash
oc get placementdecision -n acm-spo-policies -o yaml
```

Confirm the cluster belongs to the bound cluster set:

```bash
oc get managedcluster <cluster-name> \
  -o jsonpath='{.metadata.labels.cluster\.open-cluster-management\.io/clusterset}{"\n"}'
```

## Render Fails Locally

Run:

```bash
validation/validate-render.sh policies/overlays/test-spo-cluster-scoped
```

The script verifies Kustomize rendering and, when connected to the hub, performs server-side dry run.

## SPO Resource Is Missing

First prove ACM selected the cluster:

```bash
oc get placementdecision -n acm-spo-policies -o yaml
```

Then prove the policy was replicated:

```bash
oc get policy -n <cluster-name>
```

If placement and replication are correct, check the managed cluster directly:

```bash
oc get selinuxprofile
oc get rawselinuxprofile
```
