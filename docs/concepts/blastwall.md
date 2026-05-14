---
id: blastwall
title: Blastwall Workload Confinement
description: Why ACM Foil delivers Blastwall Security Profiles Operator resources.
---

# Blastwall Workload Confinement

Blastwall gives selected OpenShift workloads a stricter SELinux workload type through the Security Profiles Operator.

ACM Foil turns that pattern into fleet governance: Git stores the policy, OpenShift GitOps syncs it to the hub, ACM placement selects clusters, SPO installs the profile resources, and SCC/RBAC controls which workloads can use them.

## Why Adopt Blastwall

Blastwall is useful when a workload should keep normal Kubernetes scheduling and pod identity, but run with a smaller kernel-facing attack surface.

| Benefit | What It Means |
| --- | --- |
| SELinux-backed confinement | Selected pods run under a dedicated SPO-created process type instead of only relying on namespace policy or pod security labels. |
| Reduced kernel surface | The standard profile denies workload-created user namespaces, XFRM, RXRPC, AF_ALG, BPF, packet sockets, `capability2 bpf`, and `io_uring`. |
| Narrow exception path | The nested profile permits pod-level user namespace behavior for workloads that need it, while keeping the other kernel-surface denies. |
| Controlled workload binding | SCC access is granted through specific service accounts and RBAC rather than broad cluster-wide access. |
| Repeatable fleet rollout | ACM applies the same profile, SCC, RBAC, namespace, and validation resources to every selected managed cluster. |
| Evidence-oriented validation | ACM compliance status, SPO profile readiness, pod SELinux context, and safe probes provide concrete proof that the boundary is active. |

## Workload Classes

Blastwall separates OpenShift workloads into two classes.

`blastwall` is the default class. Use it for workloads that do not need to create user namespaces. It uses the `blastwall-confined` SCC and runs selected pods with the `blastwall_.process` SELinux type.

`blastwall-nested` is the exception class. Use it only for workloads that need pod-level user namespace behavior, such as rootless build or nested-container workflows. It uses the `blastwall-nested` SCC, requires pod-level user namespace behavior, and runs selected pods with the `blastwallnested_.process` SELinux type.

The nested class is not a general bypass. It omits the user namespace deny, but still denies the remaining high-risk kernel entry points.

## Control Model

Blastwall's OpenShift path separates policy installation from workload selection.

| Control | Role |
| --- | --- |
| `RawSelinuxProfile` | SPO compiles and installs the SELinux policy for the workload type. |
| SCC | OpenShift admits selected pods with the required SELinux type and security restrictions. |
| Service account RBAC | Only intended service accounts can use the Blastwall SCCs. |
| Validation probe | A safe Python probe checks SELinux context and attempts entry-point probes without running exploit code. |
| ACM policy status | ACM reports whether the managed cluster has the expected namespaces, profiles, SCCs, RBAC, and probe ConfigMap. |

## What ACM Foil Adds

Upstream Blastwall defines the OpenShift/SPO resources. ACM Foil packages that path as a governed ACM delivery flow.

ACM Foil adds:

1. A GitOps source of truth for the Blastwall profile policy.
2. A `RawSelinuxProfile` CRD precheck before enforcement.
3. Placement through the `spo=true` managed-cluster label.
4. PolicySet delivery through ACM Governance.
5. A repeatable proof path through ACM compliance checks and the included probe ConfigMap.

That means operators can roll Blastwall out to selected clusters first, observe compliance, validate the profile boundary, and then expand placement deliberately.

## Adoption Boundary

ACM Foil creates the confinement path. It does not automatically confine every workload.

Blastwall applies to workloads that intentionally opt into the matching SCC and service account path. A workload that keeps using its existing service account and SCC will not move into the Blastwall SELinux type just because the policy exists on the cluster.

ACM Foil installs the Security Profiles Operator through ACM `OperatorPolicy` on clusters selected by the `spo=true` label. The `RawSelinuxProfile` CRD must become established before the Blastwall profile policy can enforce successfully.

Keep placement narrow until you have validated:

1. SPO profile readiness.
2. SCC admission for the intended service account.
3. Pod SELinux context.
4. Probe results for the selected workload class.
5. Rollback expectations for workloads that cannot run under the stricter profile.

## References

- [ACM Foil SPO Delivery](./spo-delivery.md)
- [Policy Reference](../reference/policies.md#policy-blastwall-spo-profiles)
- [Blastwall OpenShift/SPO documentation](https://blastwall.org/openshift-spo.html)
- [Blastwall upstream OpenShift/SPO README](https://github.com/gprocunier/blastwall/blob/main/openshift/spo/README.md)
