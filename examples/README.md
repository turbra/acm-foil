# Examples

These manifests are not deployed by default.

To test adding another policy, copy the example into `policies/base`:

```bash
cp examples/policy-spo-selinux-smoke-extra.yaml policies/base/
```

Then add it to `policies/base/kustomization.yaml`:

```yaml
resources:
  - policy-install-spo-operator.yaml
  - policy-prevent-copy-fail-cve-ds.yaml
  - policy-spo-selinux-smoke.yaml
  - policy-spo-selinux-smoke-extra.yaml
  - policyset-spo.yaml
```

Add the policy name to `policies/base/policyset-spo.yaml`:

```yaml
spec:
  policies:
    - policy-install-spo-operator
    - policy-prevent-copy-fail-cve-ds
    - policy-spo-selinux-smoke
    - policy-spo-selinux-smoke-extra
```

Validate before pushing:

```bash
validation/validate-render.sh
```
