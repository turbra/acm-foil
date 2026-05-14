---
id: risk-model
title: Risk Model
description: Operational risks and safety boundaries for the included policies.
---

# Risk Model

ACM Foil is a fleet policy delivery repository. Treat each policy according to what it creates.

## Blastwall Policy

The Blastwall policies create SPO profiles plus supporting namespaces, RBAC, SCCs, and validation resources.

`policy-blastwall-v2-runtime-bindings` grants service accounts access to the Blastwall SCCs. Review those bindings before expanding placement beyond a limited rollout.

During the Blastwall transition, Argo CD `selfHeal` is disabled so manual cleanup is not immediately reverted. Re-enable it after the rollout is verified.

## CVE Mitigation Policy

`policy-prevent-copy-fail-cve-ds` deploys a privileged DaemonSet from a Red Hat mitigation policy.

That is an intentional node-level mitigation. Keep its placement narrow until the target cluster set and rollback expectations are clear.

## Placement Risk

The `spo=true` label is the rollout gate. Adding that label to a managed cluster opts the cluster into all PolicySets bound to the active placement.
