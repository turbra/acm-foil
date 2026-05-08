---
id: testing
title: Testing
description: Validate documentation and policy rendering before pushing changes.
---

# Testing

Run validation before pushing documentation or policy changes.

## Documentation Site

```bash
npm install
npm run build
```

Preview locally:

```bash
npm run serve -- --host 127.0.0.1 --port 3000
```

If port `3000` is already in use, choose another local port.

## Policy Render

```bash
validation/validate-render.sh policies/overlays/test-spo-cluster-scoped
```

The script renders the active overlay and checks the generated YAML. When connected to the ACM hub, it also runs a server-side dry run.

## Placement Check

```bash
validation/check-acm-placement.sh
```

Use this after deployment to confirm ACM placement selected the expected managed clusters.
