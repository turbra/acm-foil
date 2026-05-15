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

Use ACM Foil when you want GitOps and ACM to deliver stricter workload confinement, controlled cluster placement, and compliance evidence across selected OpenShift clusters. See [Blastwall Workload Confinement](https://turbra.github.io/acm-foil/concepts/blastwall/) for the benefits and adoption boundary.

## Quick Start

Requirements:

- Red Hat Advanced Cluster Management
- ACM `OperatorPolicy` support on the hub and managed clusters
- OpenShift GitOps / Argo CD on the ACM hub
- Managed OpenShift clusters with OLM and access to the Red Hat operator catalog
- Managed cluster label `spo=true`

ACM Foil installs the Security Profiles Operator on selected managed clusters by using ACM `OperatorPolicy`. See Red Hat's [Understanding the Security Profiles Operator](https://docs.redhat.com/en/documentation/openshift_container_platform/4.21/html/security_and_compliance/security-profiles-operator#spo-understanding) docs for what SPO provides.

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
| `policyset-blastwall-test` | `policy-spo-rawselinuxprofile-crd`, `policy-blastwall-v2-raw-profiles`, `policy-blastwall-v2-profile-usage`, `policy-blastwall-v2-runtime-bindings` |
| `policyset-spo-test` | `policy-install-spo-operator`, `policy-prevent-copy-fail-cve-ds` |

The SPO policy set installs the Security Profiles Operator into `openshift-security-profiles` through the Red Hat operator catalog. The active placement still controls where this happens.

The Blastwall policy set includes an inform-only precondition policy that checks for the established `RawSelinuxProfile` CRD provided by SPO. The Blastwall rollout then applies raw profile resources, waits for `status.usage`, and applies SCC/RBAC bindings with status-derived SELinux types.

The Argo CD application keeps automated sync, pruning, and self-healing enabled so the hub state returns to the Git-defined policy set after manual drift.

The CVE mitigation policy deploys the Red Hat BPF LSM DaemonSet mitigation for CVE-2026-31431.

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
