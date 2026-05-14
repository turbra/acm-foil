---
id: extra-spo-smoke-policy
title: Extra SPO Smoke Policy
description: Copy the optional example policy into the active base.
---

# Extra SPO Smoke Policy

The example policy is:

```text
examples/policy-spo-selinux-smoke-extra.yaml
```

It is not deployed by default.

## Enable the Example

Copy it into the active base:

```bash
cp examples/policy-spo-selinux-smoke-extra.yaml policies/base/
```

Add it to `policies/base/kustomization.yaml`:

```yaml
resources:
  - policy-blastwall-spo-profiles.yaml
  - policy-install-spo-operator.yaml
  - policy-prevent-copy-fail-cve-ds.yaml
  - policy-spo-selinux-smoke.yaml
  - policy-spo-selinux-smoke-extra.yaml
  - policyset-blastwall.yaml
  - policyset-spo.yaml
```

Add it to `policies/base/policyset-spo.yaml`:

```yaml
spec:
  policies:
    - policy-install-spo-operator
    - policy-prevent-copy-fail-cve-ds
    - policy-spo-selinux-smoke
    - policy-spo-selinux-smoke-extra
```

Validate:

```bash
validation/validate-render.sh policies/overlays/test-spo-cluster-scoped
```

Push the change when the render passes.
