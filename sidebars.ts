import type {SidebarsConfig} from '@docusaurus/plugin-content-docs';

const sidebars: SidebarsConfig = {
  docs: [
    'home',
    {
      type: 'category',
      label: 'Getting Started',
      collapsed: false,
      items: [
        'getting-started/overview',
        'getting-started/requirements',
        'getting-started/deploy',
        'getting-started/validate',
      ],
    },
    {
      type: 'category',
      label: 'Concepts',
      collapsed: false,
      items: [
        'concepts/policy-flow',
        'concepts/placement',
        'concepts/spo-delivery',
        'concepts/risk-model',
      ],
    },
    {
      type: 'category',
      label: 'Operations',
      collapsed: false,
      items: [
        'operations/target-clusters',
        'operations/add-policy',
        'operations/troubleshooting',
      ],
    },
    {
      type: 'category',
      label: 'Reference',
      collapsed: false,
      items: [
        'reference/policies',
        'reference/policysets',
        'reference/repository-files',
      ],
    },
    {
      type: 'category',
      label: 'Examples',
      collapsed: false,
      items: ['examples/index', 'examples/extra-spo-smoke-policy'],
    },
  ],
};

export default sidebars;
