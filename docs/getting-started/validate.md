---
id: validate
title: Validate
description: Validate Argo CD sync, ACM placement, and managed-cluster policy results.
---

# Validate

Run these commands from the ACM hub unless a section says otherwise.

## Check Argo CD

```bash
oc get applications.argoproj.io -n openshift-gitops spo-acm-policies-test
```

Expected:

```text
Synced   Healthy
```

## Check ACM Policy Objects

```bash
oc get policy,policyset,placement,placementbinding,managedclustersetbinding \
  -n acm-spo-policies
```

The active policies should be `Compliant`:

```text
policy-blastwall-spo-profiles
policy-prevent-copy-fail-cve-ds
policy-spo-selinux-smoke
```

## Check Placement

```bash
oc get placementdecision -n acm-spo-policies -o yaml
```

The placement decision should include each managed cluster labeled `spo=true`:

```text
clusterName: <cluster-name>
```

## Check Replicated Policies

ACM replicates policies into the managed cluster namespace on the hub.

```bash
oc get policy -n <cluster-name>
```

Check each replicated policy:

```bash
oc get policy -n <cluster-name> acm-spo-policies.policy-blastwall-spo-profiles
oc get policy -n <cluster-name> acm-spo-policies.policy-prevent-copy-fail-cve-ds
oc get policy -n <cluster-name> acm-spo-policies.policy-spo-selinux-smoke
```

## Prove the Mitigation Policy Applied

From the hub:

```bash
oc get policy -n <cluster-name> acm-spo-policies.policy-prevent-copy-fail-cve-ds \
  -o jsonpath='{.status.details[0].history[0].message}{"\n"}'
```

Expected message includes:

```text
namespaces [cve-2026-31431-mitigation-ebpf] found
rolebindings [system:openshift:scc:privileged] found
daemonsets [cve-2026-31431-mitigation-ebpf] found
```

From the managed cluster:

```bash
oc get ds -n cve-2026-31431-mitigation-ebpf cve-2026-31431-mitigation-ebpf
oc get pods -n cve-2026-31431-mitigation-ebpf -o wide
```

## Prove the SPO Profiles Applied

From the managed cluster:

```bash
oc get selinuxprofile acm-spo-smoke -o yaml
oc get rawselinuxprofile blastwall blastwallnested
```

Expected:

```text
SelinuxProfile/acm-spo-smoke
RawSelinuxProfile/blastwall
RawSelinuxProfile/blastwallnested
```

## Validate Locally Before Pushing

```bash
validation/validate-render.sh policies/overlays/test-spo-cluster-scoped
```

See [Testing](/project/testing/) for documentation and render validation.
