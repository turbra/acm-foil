---
id: risk-model
title: Risk Model
description: Operational risks and safety boundaries for the included policies.
---

# Risk Model

ACM Foil is a fleet policy delivery repository. Treat each policy according to what it creates.

## Low-Risk Smoke Policy

`policy-spo-selinux-smoke` creates an unbound SPO profile.

It is useful for proving orchestration because it does not attach the profile to a workload.

## Blastwall Policy

`policy-blastwall-spo-profiles` creates SPO profiles plus supporting namespaces, RBAC, SCCs, and validation resources.

Review the generated resources before expanding placement beyond a limited rollout.

## CVE Mitigation Policy

`policy-prevent-copy-fail-cve-ds` deploys a privileged DaemonSet from a Red Hat mitigation policy.

That is an intentional node-level mitigation. Keep its placement narrow until the target cluster set and rollback expectations are clear.

## Placement Risk

The `spo=true` label is the rollout gate. Adding that label to a managed cluster opts the cluster into all PolicySets bound to the active placement.
