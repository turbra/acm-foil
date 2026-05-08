<p align="center">
  <a href="https://turbra.github.io/acm-foil/"><img src="static/img/tux-foil.png" alt="ACM Foil" width="300" /></a>
</p>

<p align="center">
  <strong>Put the foil on managed clusters with ACM-delivered security policies.</strong>
</p>

<p align="center">
  <a href="https://www.apache.org/licenses/LICENSE-2.0"><img src="https://img.shields.io/badge/License-Apache--2.0-8F2D23?style=flat-square" alt="License: Apache-2.0"></a>
</p>

<p align="center">
  <a href="https://turbra.github.io/acm-foil/">ACM Foil</a> •
  <a href="https://turbra.github.io/acm-foil/getting-started/deploy/">Deploy</a> •
  <a href="https://turbra.github.io/acm-foil/getting-started/validate/">Validate</a> •
  <a href="https://turbra.github.io/acm-foil/concepts/policy-flow/">Concepts</a> •
  <a href="https://turbra.github.io/acm-foil/reference/policies/">Policy Reference</a>
</p>

---

ACM Foil proves ACM can place security policies on managed OpenShift clusters through GitOps. OpenShift GitOps syncs ACM policy resources to the hub, and ACM Governance applies the active PolicySets to managed clusters that opt in with `spo=true`.

## Quick Start

Deploy the Argo CD Application on the ACM hub:

```sh
oc apply -f apps/hub/argocd-application.yaml
```

Opt in a managed cluster:

```sh
oc label managedcluster <cluster-name> spo=true --overwrite
```

Check Argo CD and ACM placement:

```sh
oc get applications.argoproj.io -n openshift-gitops spo-acm-policies-test
oc get policy,policyset,placement,placementbinding -n acm-spo-policies
oc get placementdecision -n acm-spo-policies -o yaml
```

The managed policies should report `Compliant`.

## Current Policies

| PolicySet | Policies |
|-----------|----------|
| `policyset-blastwall-test` | `policy-blastwall-spo-profiles` |
| `policyset-spo-test` | `policy-prevent-copy-fail-cve-ds`, `policy-spo-selinux-smoke` |

The Blastwall policy deploys prebuilt Security Profiles Operator resources and supporting validation objects.

The CVE mitigation policy deploys the Red Hat BPF LSM DaemonSet mitigation for CVE-2026-31431.

The SPO smoke policy creates one harmless, unbound `SelinuxProfile` so you can prove ACM policy delivery without changing workload security context.

## Documentation

- [Project Site](https://turbra.github.io/acm-foil/) - documentation home with deployment, validation, concepts, examples, and reference pages
- [Policy Reference](https://turbra.github.io/acm-foil/reference/policies/) - active policies, resources created, remediation behavior, validation commands, and risks
- [Troubleshooting](https://turbra.github.io/acm-foil/operations/troubleshooting/) - checks for Argo CD health, ACM placement, policy compliance, and missing SPO resources

## Repository at a Glance

| Path | Purpose |
|------|---------|
| `apps/hub/argocd-application.yaml` | Argo CD Application applied to the ACM hub |
| `policies/base/` | Active ACM Policies and PolicySets |
| `policies/overlays/test-spo-cluster-scoped/` | Active overlay with namespace, placement, and binding resources |
| `examples/` | Optional policies that are not deployed by default |
| `validation/` | Local render and ACM placement checks |
| `docs/` | Docusaurus documentation site |

## Validate the Render

```sh
validation/validate-render.sh policies/overlays/test-spo-cluster-scoped
```
