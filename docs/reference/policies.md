---
id: policies
title: Policies
description: Reference for each active ACM policy.
---

# Policies

## `policy-blastwall-spo-profiles`

File:

```text
policies/base/policy-blastwall-spo-profiles.yaml
```

Purpose:

Deploy Blastwall SPO resources from the upstream Blastwall OpenShift SPO manifests.

Creates:

```text
Namespace/blastwall-spo
Namespace/blastwall-workloads
RawSelinuxProfile/blastwall
RawSelinuxProfile/blastwallnested
SecurityContextConstraints/blastwall-confined
SecurityContextConstraints/blastwall-nested
ServiceAccount, Role, and RoleBinding resources for Blastwall validation workloads
ConfigMap/blastwall-spo-probe
```

Remediation:

```text
enforce
```

Prerequisites:

```text
Security Profiles Operator installed on the managed cluster
Cluster selected by Placement/placement-spo-test
```

Validate from the managed cluster:

```bash
oc get rawselinuxprofile blastwall blastwallnested
oc get ns blastwall-spo blastwall-workloads
```

Risk:

This policy creates SCC, RBAC, namespace, and validation resources. Keep placement narrow until the Blastwall rollout path is understood.

## `policy-prevent-copy-fail-cve-ds`

File:

```text
policies/base/policy-prevent-copy-fail-cve-ds.yaml
```

Purpose:

Deploy the Red Hat BPF LSM DaemonSet mitigation for CVE-2026-31431.

Creates:

```text
Namespace/cve-2026-31431-mitigation-ebpf
RoleBinding/system:openshift:scc:privileged
DaemonSet/cve-2026-31431-mitigation-ebpf
```

Remediation:

```text
enforce
```

Prerequisites:

```text
OpenShift worker nodes that can run the Red Hat mitigation image
Cluster selected by Placement/placement-spo-test
```

Validate from the managed cluster:

```bash
oc get ds -n cve-2026-31431-mitigation-ebpf cve-2026-31431-mitigation-ebpf
oc get pods -n cve-2026-31431-mitigation-ebpf -o wide
```

Risk:

This policy deploys a privileged node-level DaemonSet. Use it only where the mitigation is approved.

## `policy-spo-selinux-smoke`

File:

```text
policies/base/policy-spo-selinux-smoke.yaml
```

Purpose:

Create a harmless SPO `SelinuxProfile` to prove ACM can deploy SPO resources to selected clusters.

Creates:

```text
SelinuxProfile/acm-spo-smoke
```

The profile inherits only the standard `container` system profile and is not bound to any workload.

Remediation:

```text
enforce
```

Prerequisites:

```text
Security Profiles Operator installed on the managed cluster
SelinuxProfile CRD available
Cluster selected by Placement/placement-spo-test
```

Validate from the managed cluster:

```bash
oc get selinuxprofile acm-spo-smoke -o yaml
```

Risk:

This policy is intended as the safe orchestration proof. It creates an unbound profile and does not change workload security context.
