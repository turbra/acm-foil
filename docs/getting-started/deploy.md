---
id: deploy
title: Deploy
description: Deploy ACM Foil to an ACM hub with OpenShift GitOps.
---

# Deploy

Deploy from the ACM hub.

## Requirements

Review [Requirements](/getting-started/requirements/) before applying the Argo CD application.

Label a target managed cluster:

```bash
oc label managedcluster <cluster-name> spo=true --overwrite
```

## Apply the Argo CD Application

```bash
oc apply -f apps/hub/argocd-application.yaml
```

The application is created in:

```text
openshift-gitops/spo-acm-policies-test
```

It syncs this repository:

```text
https://github.com/turbra/acm-foil.git
```

## Synced Hub Resources

Argo CD syncs the ACM hub resources from `policies/overlays/test-spo-cluster-scoped`:

```text
Namespace/acm-spo-policies
ManagedClusterSetBinding/default
Placement/placement-spo-test
PlacementBinding/binding-policyset-blastwall-test
PlacementBinding/binding-policyset-spo-test
PolicySet/policyset-blastwall-test
PolicySet/policyset-spo-test
Policy/policy-install-spo-operator
Policy/policy-spo-rawselinuxprofile-crd
Policy/policy-blastwall-v2-raw-profiles
Policy/policy-blastwall-v2-profile-usage
Policy/policy-blastwall-v2-runtime-bindings
Policy/policy-prevent-copy-fail-cve-ds
Policy/policy-spo-selinux-smoke
```

The Argo CD application keeps automated sync and pruning enabled, but `selfHeal` is disabled during the Blastwall v2 transition.

## Expected Result

Argo CD should report:

```text
Synced / Healthy
```

The ACM policies should report:

```text
Compliant
```

If Argo CD reports `Degraded`, check [Troubleshooting](/operations/troubleshooting/) before changing policy content.
