---
id: requirements
title: Requirements
description: Required platform components before deploying ACM Foil.
---

# Requirements

ACM Foil expects an ACM hub that can place policies onto managed OpenShift clusters.

| Requirement | Why it matters |
| --- | --- |
| Red Hat Advanced Cluster Management | Provides Governance `Policy`, `PolicySet`, `Placement`, and managed-cluster policy distribution. |
| OpenShift GitOps / Argo CD on the ACM hub | Syncs this repository into the ACM policy namespace. |
| Managed OpenShift clusters | Receives the ACM policies selected by placement. |
| Security Profiles Operator on target clusters | Required for the SPO smoke policy and Blastwall SPO resources. |
| Managed cluster label `spo=true` | Opts a cluster into the active ACM placement. |

ACM Foil does not install the Security Profiles Operator. Target clusters must already have SPO installed before SPO-backed policies are expected to become compliant.

For Red Hat's explanation of SPO, see [Understanding the Security Profiles Operator](https://docs.redhat.com/en/documentation/openshift_container_platform/4.21/html/security_and_compliance/security-profiles-operator#spo-understanding).

## Quick Checks

Run these from the ACM hub:

```bash
oc get ns openshift-gitops
oc api-resources | grep policy.open-cluster-management.io
oc get managedcluster
```

Check that the target cluster is labeled:

```bash
oc get managedcluster <cluster-name> --show-labels
```

Label a target cluster:

```bash
oc label managedcluster <cluster-name> spo=true --overwrite
```
