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
policy-install-spo-operator
policy-spo-rawselinuxprofile-crd
policy-blastwall-v2-raw-profiles
policy-blastwall-v2-profile-usage
policy-blastwall-v2-runtime-bindings
policy-prevent-copy-fail-cve-ds
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
oc get policy -n <cluster-name> acm-spo-policies.policy-install-spo-operator
oc get policy -n <cluster-name> acm-spo-policies.policy-spo-rawselinuxprofile-crd
oc get policy -n <cluster-name> acm-spo-policies.policy-blastwall-v2-raw-profiles
oc get policy -n <cluster-name> acm-spo-policies.policy-blastwall-v2-profile-usage
oc get policy -n <cluster-name> acm-spo-policies.policy-blastwall-v2-runtime-bindings
oc get policy -n <cluster-name> acm-spo-policies.policy-prevent-copy-fail-cve-ds
```

## Prove the SPO Operator Installed

From the hub:

```bash
oc get policy -n <cluster-name> acm-spo-policies.policy-install-spo-operator \
  -o jsonpath='{.status.compliant}{"\n"}'
```

Expected:

```text
Compliant
```

From the managed cluster:

```bash
oc get operatorpolicy -A | grep install-spo-operator
oc get namespace openshift-security-profiles
```

## Prove the RawSelinuxProfile API Is Ready

From the hub:

```bash
oc get policy -n <cluster-name> acm-spo-policies.policy-spo-rawselinuxprofile-crd \
  -o jsonpath='{.status.compliant}{"\n"}'
```

Expected:

```text
Compliant
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
oc get rawselinuxprofile blastwall blastwallnested
oc get rawselinuxprofile blastwall blastwallnested \
  -o custom-columns=NAME:.metadata.name,STATE:.status.state,USAGE:.status.usage
oc get scc blastwall-confined blastwall-nested \
  -o custom-columns=NAME:.metadata.name,TYPE:.seLinuxContext.seLinuxOptions.type
```

Expected:

```text
RawSelinuxProfile/blastwall
RawSelinuxProfile/blastwallnested
SecurityContextConstraints/blastwall-confined
SecurityContextConstraints/blastwall-nested
```

## Validate Locally Before Pushing

```bash
validation/validate-render.sh policies/overlays/test-spo-cluster-scoped
```

Use the same render check before pushing policy changes.
