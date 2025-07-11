export default {
  defaultBrowser: {
    name: "Google Chrome",
    profile: "Profile 1"
  },
  handlers: [
    {
      match: [
        "*elconline*",
        "*elc-online*",
        "*estee*"
      ],
      browser: {
        name: "Google Chrome",
        profile: "ELC"
      }
    },
    {
      match: [
        "basic.space",
        "basic.space/*",
        "*.basic.space",
        "*.basic.space/*",
        "*basicspace*",
        "*basic-space*",
        "docs.google.com",
        "sentry.io",
        "sentry.io/*"
      ],
      browser: {
        name: "Google Chrome",
        profile: "BS"
      }
    },
    {
      match: ["amazon.com", "amazon.com/*"],
      browser: {
        name: "Google Chrome",
        profile: "Nick@WPC"
      }
    },
    {
      match: ["quickbooks.com", "quickbooks.com/*", "intuit.com", "intuit.com/*", "qbo.intuit.com", "qbo.intuit.com/*"],
      browser: {
        name: "Google Chrome",
        profile: "Nick@WPC"
      }
    },
    {
      match: [
        "statwindow.com",
        "statwindow.com/*",
        "*.statwindow.com",
        "*.statwindow.com/*",
      ],
      browser: "Microsoft Edge"
    }
  ]
};
