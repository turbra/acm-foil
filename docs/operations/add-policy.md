---
id: add-policy
title: Add a Policy
description: Add another ACM policy to the active PolicySet.
---

# Add a Policy

Add active policies to `policies/base`.

## Add the Manifest

Create a new ACM `Policy` manifest:

```text
policies/base/policy-example.yaml
```

Set the policy namespace to:

```text
acm-spo-policies
```

## Include It in Kustomize

Add the file to:

```text
policies/base/kustomization.yaml
```

Example:

```yaml
resources:
  - policy-blastwall-v2-profile-usage.yaml
  - policy-blastwall-v2-raw-profiles.yaml
  - policy-blastwall-v2-runtime-bindings.yaml
  - policy-example.yaml
  - policy-install-spo-operator.yaml
  - policy-prevent-copy-fail-cve-ds.yaml
  - policyset-blastwall.yaml
  - policyset-spo.yaml
```

## Add It to a PolicySet

Add the policy name to the right PolicySet.

For general SPO or mitigation policies:

```yaml
apiVersion: policy.open-cluster-management.io/v1beta1
kind: PolicySet
metadata:
  name: policyset-spo-test
  namespace: acm-spo-policies
spec:
  policies:
    - policy-example
```

For Blastwall-specific policies, use:

```text
policyset-blastwall-test
```

## Keep Examples Separate

If the policy is only for a guide or demo, put it in:

```text
examples/
```

Do not add example policies to `policies/base/kustomization.yaml` until you want ACM to deploy them.

## Validate

```bash
validation/validate-render.sh policies/overlays/test-spo-cluster-scoped
```

Then push to `main`. Argo CD will sync the rendered policy set.
