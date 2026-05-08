import type {Config} from '@docusaurus/types';
import type * as Preset from '@docusaurus/preset-classic';

const config: Config = {
  title: 'ACM Foil',
  tagline: 'GitOps policy enforcement for clusters putting on the foil.',
  favicon: 'img/tux-foil-favicon.png',

  url: 'https://turbra.github.io',
  baseUrl: '/acm-foil/',
  organizationName: 'turbra',
  projectName: 'acm-foil',
  trailingSlash: true,

  onBrokenLinks: 'throw',
  onBrokenAnchors: 'warn',
  markdown: {
    hooks: {
      onBrokenMarkdownLinks: 'throw',
    },
  },

  i18n: {
    defaultLocale: 'en',
    locales: ['en'],
  },

  presets: [
    [
      'classic',
      {
        docs: {
          routeBasePath: '/',
          sidebarPath: './sidebars.ts',
          editUrl: 'https://github.com/turbra/acm-foil/edit/main/',
          showLastUpdateAuthor: true,
          showLastUpdateTime: true,
        },
        blog: false,
        theme: {
          customCss: './src/css/custom.css',
        },
      } satisfies Preset.Options,
    ],
  ],

  themeConfig: {
    image: 'img/tux-foil-social.png',
    navbar: {
      title: 'ACM Foil',
      logo: {
        alt: 'ACM Foil',
        src: 'img/tux-foil-navbar.png',
      },
      items: [
        {
          to: '/',
          label: 'Docs',
          position: 'left',
        },
        {
          to: '/getting-started/deploy/',
          label: 'Getting Started',
          position: 'left',
        },
        {
          to: '/concepts/policy-flow/',
          label: 'Concepts',
          position: 'left',
        },
        {
          to: '/reference/policies/',
          label: 'Reference',
          position: 'left',
        },
        {
          href: 'https://github.com/turbra/acm-foil',
          label: 'GitHub',
          position: 'right',
        },
      ],
    },
    footer: {
      style: 'dark',
      links: [
        {
          title: 'Docs',
          items: [
            {label: 'Get started', to: '/'},
            {label: 'Deploy', to: '/getting-started/deploy/'},
            {label: 'Validate', to: '/getting-started/validate/'},
          ],
        },
        {
          title: 'Concepts',
          items: [
            {label: 'Policy flow', to: '/concepts/policy-flow/'},
            {label: 'Placement', to: '/concepts/placement/'},
            {label: 'SPO delivery', to: '/concepts/spo-delivery/'},
          ],
        },
        {
          title: 'Reference',
          items: [
            {label: 'Policies', to: '/reference/policies/'},
            {label: 'PolicySets', to: '/reference/policysets/'},
            {label: 'Repository files', to: '/reference/repository-files/'},
          ],
        },
      ],
      copyright: `Copyright © ${new Date().getFullYear()} ACM Foil contributors.`,
    },
    prism: {
      additionalLanguages: ['bash', 'yaml'],
    },
    tableOfContents: {
      minHeadingLevel: 2,
      maxHeadingLevel: 3,
    },
  } satisfies Preset.ThemeConfig,
};

export default config;
