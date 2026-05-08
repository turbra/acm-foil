# ACM Foil

ACM Foil is a GitOps policy repository for deploying ACM-managed security controls to OpenShift clusters.

The documentation site is the primary entry point. Build it locally with:

```bash
npm install
npm run build
npm run serve
```

## Current Policies

```text
PolicySet/policyset-blastwall-test
  Policy/policy-blastwall-spo-profiles

PolicySet/policyset-spo-test
  Policy/policy-prevent-copy-fail-cve-ds
  Policy/policy-spo-selinux-smoke
```

## Deploy the Policies

On the ACM hub:

```bash
oc apply -f apps/hub/argocd-application.yaml
```

The Argo CD application is:

```text
openshift-gitops/spo-acm-policies-test
```

## Validate the Render

```bash
validation/validate-render.sh policies/overlays/test-spo-cluster-scoped
```

See the docs site for deployment, validation, troubleshooting, and policy reference details.
