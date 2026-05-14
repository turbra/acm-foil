---
id: policy-flow
title: Policy Flow
description: How a repository change becomes managed-cluster policy state.
---

import useBaseUrl from '@docusaurus/useBaseUrl';

# Policy Flow

ACM Foil keeps policy content in Git and lets ACM handle cluster distribution.

<img
  src={useBaseUrl('/diagrams/acm-foil-process-flow.svg')}
  alt="ACM Policy Delivery Flow"
/>

## Source of Truth

The repository owns policy manifests, PolicySets, placement bindings, and the Argo CD Application manifest.

OpenShift GitOps reads the active overlay:

```text
policies/overlays/test-spo-cluster-scoped
```

The active overlay creates the ACM policy namespace, placement wiring, and the base policy resources.

## Hub State

On the ACM hub, Argo CD syncs resources into:

```text
acm-spo-policies
```

ACM Governance watches those resources and distributes matching policies to selected managed clusters.

## Managed-Cluster State

ACM replicates policies into the managed cluster namespace on the hub. The policy controller on the managed cluster then creates or checks the resources described by each `ConfigurationPolicy`.

Use the hub for placement and compliance checks. Use the managed cluster only when you need to inspect the actual workload, daemon, profile, namespace, or RBAC object.
