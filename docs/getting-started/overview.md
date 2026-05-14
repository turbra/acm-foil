---
id: overview
title: What ACM Foil Does
description: What ACM Foil deploys and what it deliberately leaves out.
---

# What ACM Foil Does

It does three things:

1. Selects managed clusters labeled `spo=true`.
2. Uses OpenShift GitOps to sync ACM policy resources to the hub.
3. Lets ACM Governance distribute and enforce those policies on selected clusters.

## Current Scope

The active deployment includes two policy sets.

| PolicySet | Purpose |
| --- | --- |
| `policyset-blastwall-test` | Checks for the SPO `RawSelinuxProfile` CRD, deploys Blastwall profiles, waits for `status.usage`, then applies SCC and RBAC bindings. |
| `policyset-spo-test` | Installs the Security Profiles Operator and deploys the Red Hat CVE mitigation DaemonSet policy. |

## Cluster Selection

Managed clusters opt in with this label:

```bash
oc label managedcluster <cluster-name> spo=true --overwrite
```

## What Lands on Managed Clusters

ACM Foil applies these managed-cluster resources through ACM policies:

| Policy | Managed-cluster resources |
| --- | --- |
| `policy-install-spo-operator` | `Namespace/openshift-security-profiles` and `OperatorPolicy/install-spo-operator`. |
| `policy-spo-rawselinuxprofile-crd` | Inform-only check for the established `RawSelinuxProfile` CRD. |
| `policy-blastwall-v2-raw-profiles` | Blastwall namespaces, `RawSelinuxProfile` resources, and validation ConfigMap. |
| `policy-blastwall-v2-profile-usage` | Inform-only gate for profile `status.usage` publication. |
| `policy-blastwall-v2-runtime-bindings` | Blastwall SCCs and workload RBAC with status-derived SELinux types. |
| `policy-prevent-copy-fail-cve-ds` | Namespace, privileged SCC binding, and Red Hat BPF LSM mitigation DaemonSet. |

## What It Does Not Do

ACM Foil does not target every managed cluster. Placement is controlled by ACM labels and the `default` `ManagedClusterSetBinding` in the policy namespace.

It also does not mirror disconnected operator catalogs. Target clusters need access to a catalog source that contains the Security Profiles Operator package.
