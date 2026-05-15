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
| Evidence-oriented validation | ACM compliance status, SPO profile readiness, pod SELinux context, and executed probe results provide concrete proof that the boundary is active. |

## Compared With OpenShift Defaults

OpenShift already provides strong workload isolation through namespaces, SCCs, SELinux, seccomp, capabilities, admission, and cluster policy. Blastwall adds a narrower opt-in confinement path for workloads that should run with less access to kernel-facing interfaces.

| Area | OpenShift Default | With Blastwall Through ACM Foil | Benefit |
| --- | --- | --- | --- |
| SELinux workload type | Pods use the normal OpenShift SELinux and SCC admission path. | Selected service accounts use Blastwall SCCs with SPO-created SELinux process types. | Adds a workload-specific confinement boundary for selected pods. |
| Kernel-facing surface | Platform controls apply through SCCs, pod security labels, SELinux, seccomp, and capability handling. | Blastwall profiles deny selected high-risk entry points, including BPF, AF_ALG, packet sockets, XFRM, RXRPC, and `io_uring`. | Reduces exposure for workloads that do not need those interfaces. |
| Linux user namespaces | Behavior is controlled by the workload's SCC and platform configuration. | The default class denies Linux user namespace creation inside the workload; the nested class intentionally permits pod-level Linux user namespace behavior. | Keeps the exception explicit and reviewable. |
| Workload opt-in | Workloads keep their existing service account and SCC path unless changed. | Only service accounts bound to the Blastwall SCC roles can use the Blastwall confinement path. | Avoids accidental broad adoption. |
| Fleet rollout | Teams can use normal cluster operations, GitOps, or ACM policy patterns. | ACM placement and PolicySets target selected clusters with the `spo=true` label. | Makes rollout, observation, and expansion repeatable. |
| Evidence | Operators can inspect platform policy, pod admission, and workload state with separate checks. | ACM compliance, SPO readiness, SCC type, pod context, and executed probe output support one validation path. | Improves the audit and operations story for confinement. |

## Workload Classes

Blastwall separates OpenShift workloads into two classes.

`blastwall` is the default class. Use it for workloads that do not need to create user namespaces. It uses the `blastwall-confined` SCC and runs selected pods with the `blastwall_.process` SELinux type.

`blastwall-nested` is the exception class. Use it only for workloads that need pod-level user namespace behavior, such as rootless build or nested-container workflows. It uses the `blastwall-nested` SCC, requires pod-level user namespace behavior, and runs selected pods with the `blastwallnested_.process` SELinux type.

Blastwall treats `RawSelinuxProfile.status.usage` as the source of truth. ACM Foil waits for those usage strings and derives the SCC SELinux type during policy evaluation, using the upstream default `calabi-ocp420-rawprofile-underscore` mode.

The nested class is not a general bypass. It omits the user namespace deny, but still denies the remaining high-risk kernel entry points.

## Control Model

Blastwall's OpenShift path separates policy installation from workload selection.

| Control | Role |
| --- | --- |
| `RawSelinuxProfile` | SPO compiles and installs the SELinux policy for the workload type. |
| Usage gate | ACM waits for `RawSelinuxProfile.status.usage` before enforcing SCC bindings. |
| SCC | OpenShift admits selected pods with the required SELinux type and security restrictions. |
| Service account RBAC | Only intended service accounts can use the Blastwall SCCs. |
| Validation probe | The delivered probe ConfigMap supports validation. It does not prove enforcement until a pod or Job runs it under each Blastwall SCC and the output is collected. |
| ACM policy status | ACM reports whether the managed cluster has the expected namespaces, profiles, SCCs, RBAC, and probe ConfigMap. |

## What ACM Foil Adds

Upstream Blastwall defines the OpenShift/SPO resources. ACM Foil packages that path as a governed ACM delivery flow.

ACM Foil adds:

1. A GitOps source of truth for the Blastwall profile policy.
2. A `RawSelinuxProfile` CRD precheck before enforcement.
3. A usage gate before SCC/RBAC enforcement.
4. Placement through the `spo=true` managed-cluster label.
5. PolicySet delivery through ACM Governance.
6. A repeatable proof path through ACM compliance checks, pod context checks, and executed probe output.

That means operators can roll Blastwall out to selected clusters first, observe compliance, validate the profile boundary, and then expand placement deliberately.

## Adoption Boundary

ACM Foil creates the confinement path. It does not automatically confine every workload.

Blastwall applies to workloads that intentionally opt into the matching SCC and service account path. A workload that keeps using its existing service account and SCC will not move into the Blastwall SELinux type just because the policy exists on the cluster.

ACM Foil installs the Security Profiles Operator through ACM `OperatorPolicy` on clusters selected by the `spo=true` label. The `RawSelinuxProfile` CRD must become established before the Blastwall raw profile policy can enforce successfully.

Keep placement narrow until you have validated:

1. SPO profile readiness.
2. SCC admission for the intended service account.
3. Pod SELinux context.
4. Probe results for the selected workload class.
5. Rollback expectations for workloads that cannot run under the stricter profile.

See [Validate](/getting-started/validate/#understand-the-probe-limitation) for the probe limitation and the minimum runtime proof expected before treating the boundary as validated.

## References

- [ACM Foil SPO Delivery](./spo-delivery.md)
- [Policy Reference](../reference/policies.md#policy-blastwall-v2-raw-profiles)
- [Blastwall OpenShift/SPO documentation](https://blastwall.org/openshift-spo.html)
- [Blastwall upstream OpenShift/SPO README](https://github.com/gprocunier/blastwall/blob/main/openshift/spo/README.md)
