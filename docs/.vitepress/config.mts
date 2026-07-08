import { defineConfig } from 'vitepress'

export default defineConfig({
  title: 'PS5 Linux Guide',
  description: 'Community guide for running Linux on PlayStation 5',
  base: '/ps5-linux-guide/',
  cleanUrls: true,
  lastUpdated: true,

  head: [
    ['link', { rel: 'icon', type: 'image/webp', href: '/logo.webp' }],
  ],

  themeConfig: {
    logo: '/logo.webp',
    nav: [
      { text: 'Guide', link: '/guide/getting-started' },
      { text: 'Hardware', link: '/guide/hardware' },
      {
        text: 'Links',
        items: [
          { text: 'PS4 Linux Guide', link: 'https://github.com/DionKill/ps4-linux-tutorial/' },
          { text: 'ps5-linux GitHub', link: 'https://github.com/ps5-linux' },
          { text: 'ps5-linux-image', link: 'https://github.com/ps5-linux/ps5-linux-image' },
          { text: 'ps5-linux-image (mia)', link: 'https://git.etawen.dev/mia/ps5-linux-image' },
          { text: 'Contributor', link: "https://github.com/nothinglikeuuuuu" }
        ],
      },
    ],

    sidebar: [
      {
        text: 'Introduction',
        items: [
          { text: 'What is this?', link: '/guide/what-is-this' },
          { text: 'Getting Started', link: '/guide/getting-started' },
          { text: 'Supported Firmware', link: '/guide/firmware' },
        ],
      },
      {
        text: 'Hardware',
        items: [
          { text: 'Overview', link: '/guide/hardware' },
          { text: 'GPU (AMD Oberon)', link: '/guide/gpu' },
          { text: 'Ethernet', link: '/guide/ethernet' },
          { text: 'WiFi (IW620)', link: '/guide/wifi' },
          { text: 'USB & Storage', link: '/guide/usb-storage' },
          { text: 'M.2 Compatibility', link: '/guide/m2-compat' },
          { text: 'LED Control', link: '/guide/led' },
          { text: 'Fan Control', link: '/guide/fan' },
          { text: 'Buzzer', link: '/guide/buzzer' },
        ],
      },
      {
        text: 'Installation',
        items: [
          { text: 'Prerequisites', link: '/guide/prerequisites' },
          { text: 'Jailbreak', link: '/guide/jailbreak' },
          { text: 'Booting Linux', link: '/guide/booting' },
          {
            text: 'Kernel Setup',
            collapsed: true,
            items: [
              { text: 'General Setup', link: '/guide/kernel' },
              { text: 'Arch Linux Compilation', link: '/guide/arch' }
            ]
          },
        ],
      },
      {
        text: 'Post-Install',
        items: [
          { text: 'Display Output', link: '/guide/display' },
          { text: 'Audio', link: '/guide/audio' },
          { text: 'DualSense Controller', link: '/guide/dualsense' },
          { text: 'Gaming', link: '/guide/gaming' },
          { text: 'SSH & Getting Help', link: '/guide/getting-help' },
          { text: 'Known Issues', link: '/guide/known-issues' },
        ],
      },
      {
        text: 'Emulators',
        items: [
          {
            text: 'PlayStation',
            collapsed: true,
            items: [
              { text: 'PS1 Emulator', link: '/guide/Emulators/PS/duckstation' },
              { text: 'PS2 Emulator', link: '/guide/Emulators/PS/pcsx2' },
              { text: 'PS3 Emulator', link: '/guide/Emulators/PS/rpcs3' },
              { text: 'PSP Emulator', link: '/guide/Emulators/PS/psp' },

            ]
          },
          {
            text: 'Xbox',
            collapsed: true,
            items:
              [
                { text: 'Xemu', link: '/guide/Emulators/Xbox/xemu' },
                { text: 'Xenia', link: '/guide/Emulators/Xbox/xenia' },
              ]
          },
          {
            text: 'Nintendo',
            collapsed: true,
            items: [
              { text: 'Switch', link: '/guide/Emulators/Nintendo/switch' },
              { text: 'Wii U', link: '/guide/Emulators/Nintendo/wiiu' },
              { text: 'Wii & Gamecube', link: '/guide/Emulators/Nintendo/wii' },
            ]
          },
          {
            text : 'Retro',
            collapsed : true,
            items: [
              { text: 'Retroarch', link : '/guide/Emulators/Retro/retroarch'},
            ]
          },
          {
            text : 'All In One',
            collapsed : true,
            items : [
              { text : 'EmuDeck', link : '/guide/Emulators/AIO/emudeck'}
            ]
          }
        ],
      },
      {
        text : 'Software',
        items : [
          {
            text : 'Browsers',
            collapsed : true,
            items : [
              { text : 'Chrome', link : '/guide/Software/Browsers/Chromium/chrome'}
            ]
          }
        ]
      },
      {
        text: 'About',
        items: [
          { text: 'Credits', link: '/guide/credits' },
        ],
      },
    ],

    socialLinks: [
      { icon: 'github', link: 'https://github.com/rmuxnet/ps5-linux-guide' },
    ],

    footer: {
      message: 'Community project. Not affiliated with Sony Interactive Entertainment.',
      copyright: 'Released under MIT License',
    },

    search: {
      provider: 'local',
    },

    editLink: {
      pattern: 'https://github.com/rmuxnet/ps5-linux-guide/edit/main/docs/:path',
      text: 'Edit this page on GitHub',
    },
  },
})
