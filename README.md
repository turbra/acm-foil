# ACM GitOps smoke test for SPO

This proves ACM can detect a managed cluster labeled `spo=true` and automatically deploy policies through GitOps.

SPO must already be installed on the managed cluster. This repo does not install the operator.

## What It Does

OpenShift GitOps syncs ACM `PolicySet` resources to the hub. ACM places those policy sets on managed clusters labeled:

```text
spo=true
```

The active policy sets deploy:

```text
PolicySet/policyset-blastwall-test
  Policy/policy-blastwall-spo-profiles

PolicySet/policyset-spo-test
  Policy/policy-prevent-copy-fail-cve-ds
  Policy/policy-spo-selinux-smoke
```

The Blastwall policy vendors the upstream manifests from:

```text
https://github.com/gprocunier/blastwall/tree/main/openshift/spo
```

It deploys:

```text
RawSelinuxProfile/blastwall
RawSelinuxProfile/blastwallnested
SecurityContextConstraints/blastwall-confined
SecurityContextConstraints/blastwall-nested
Blastwall workload namespaces, RBAC, and validation ConfigMap
```

The mitigation policy deploys the Red Hat DaemonSet workaround for CVE-2026-31431:

```text
Policy/policy-prevent-copy-fail-cve-ds
```

The SPO smoke policy creates one harmless cluster-scoped SPO resource:

```text
SelinuxProfile/acm-spo-smoke
```

The profile only inherits the standard `container` system profile and is not bound to any workload.

## Deploy

On the ACM hub:

```bash
oc apply -f apps/hub/argocd-application.yaml
```

The Argo CD application is:

```text
openshift-gitops/spo-acm-policies-test
```

## Validate

Check Argo CD:

```bash
oc get applications.argoproj.io -n openshift-gitops spo-acm-policies-test
```

Check ACM policy status:

```bash
oc get policy,policyset,placement,placementbinding,managedclustersetbinding \
  -n acm-spo-policies

oc get placementdecision -n acm-spo-policies -o yaml

oc get policy -n kvm-sno acm-spo-policies.policy-prevent-copy-fail-cve-ds
oc get policy -n kvm-sno acm-spo-policies.policy-blastwall-spo-profiles
oc get policy -n kvm-sno acm-spo-policies.policy-spo-selinux-smoke
```

The managed policies should report `Compliant`.

If you are logged into the managed cluster directly:

```bash
oc get selinuxprofile acm-spo-smoke -o yaml
oc get rawselinuxprofile blastwall blastwallnested
```

Expected result:

```text
kind: SelinuxProfile
metadata.name: acm-spo-smoke
spec.inherit: System/container
status.usage: acm-spo-smoke.process
```

Blastwall profiles should exist as:

```text
RawSelinuxProfile/blastwall
RawSelinuxProfile/blastwallnested
```

## Add Another Policy

Examples are in:

```text
examples/
```

They are not deployed by default. To try one, copy it into `policies/base`, add it to `policies/base/kustomization.yaml`, and add the policy name to `policies/base/policyset-spo.yaml`.

No overlay change is needed unless the new policy needs different placement or patches.

## Target Another Cluster

Label the managed cluster on the hub:

```bash
oc label managedcluster <cluster-name> spo=true --overwrite
```

The current test cluster is `kvm-sno`.
