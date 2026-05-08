---
id: repository-files
title: Repository Files
description: Practical reference for files users need to edit.
---

# Repository Files

## Deploy Entry Point

```text
apps/hub/argocd-application.yaml
```

Creates the Argo CD Application on the ACM hub.

This is the only manifest you apply manually for the GitOps flow.

## Base Policies

```text
policies/base/
```

Contains ACM `Policy` and `PolicySet` resources.

Edit this directory when adding or changing policy content.

Files in this directory are deployed when they are listed by `policies/base/kustomization.yaml` and included in an active PolicySet.

## Active Overlay

```text
policies/overlays/test-spo-cluster-scoped/
```

Contains:

```text
Namespace/acm-spo-policies
ManagedClusterSetBinding/default
Placement/placement-spo-test
PlacementBinding resources for active PolicySets
```

Edit this directory when changing placement, cluster set binding, or policy namespace wiring.

## Examples

```text
examples/
```

Contains opt-in examples that are not deployed by default.

Copy an example into `policies/base` only when you want it to become an active ACM policy.

## Validation Scripts

```text
validation/validate-render.sh
validation/check-acm-placement.sh
```

Use these before pushing policy changes.

## Documentation Site

```text
docs/
docusaurus.config.ts
sidebars.ts
src/css/custom.css
static/img/
```

Use these files when changing the docs site structure, navigation, or visual style.
