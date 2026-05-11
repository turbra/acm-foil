<p align="center">
  <a href="https://turbra.github.io/acm-foil/"><img src="static/img/tux-foil-logo.png" alt="ACM Foil" width="300" /></a>
</p>

<p align="center">
  <strong>Put the foil on managed clusters with ACM-delivered security policies.</strong>
</p>

<p align="center">
  <a href="https://www.apache.org/licenses/LICENSE-2.0"><img src="https://img.shields.io/badge/License-Apache--2.0-C026D3?style=flat-square" alt="License: Apache-2.0"></a>
</p>

<p align="center">
  <a href="https://turbra.github.io/acm-foil/">ACM Foil</a> •
  <a href="https://turbra.github.io/acm-foil/getting-started/deploy/">Deploy</a> •
  <a href="https://turbra.github.io/acm-foil/getting-started/validate/">Validate</a> •
  <a href="https://turbra.github.io/acm-foil/concepts/policy-flow/">Concepts</a> •
  <a href="https://turbra.github.io/acm-foil/reference/policies/">Policy Reference</a>
</p>

---

ACM Foil is inspired by, and built in collaboration with, [Greg Procunier (`gprocunier`)](https://github.com/gprocunier) and his [Blastwall project](https://gprocunier.github.io/blastwall/). Blastwall demonstrates hardened fleet management for RHEL with IdM, with a path for bringing that same hardened disposition to OpenShift workloads. ACM Foil extends that model into ACM-driven OpenShift fleet management.

## Quick Start

Requirements:

- Red Hat Advanced Cluster Management
- OpenShift GitOps / Argo CD on the ACM hub
- Managed OpenShift clusters
- Security Profiles Operator installed on target clusters
- Managed cluster label `spo=true`

ACM Foil does not install the Security Profiles Operator. See Red Hat's [Understanding the Security Profiles Operator](https://docs.redhat.com/en/documentation/openshift_container_platform/4.21/html/security_and_compliance/security-profiles-operator#spo-understanding) docs for what SPO provides.

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
| `policyset-blastwall-test` | `policy-spo-rawselinuxprofile-crd`, `policy-blastwall-spo-profiles` |
| `policyset-spo-test` | `policy-prevent-copy-fail-cve-ds`, `policy-spo-selinux-smoke` |

The Blastwall policy set includes an inform-only precondition policy that checks for the established `RawSelinuxProfile` CRD installed by SPO. The Blastwall profile policy depends on that precondition before enforcement.

The Blastwall profile policy deploys prebuilt Security Profiles Operator resources and supporting validation objects.

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

## License

[Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0)
