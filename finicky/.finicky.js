module.exports = {
  defaultBrowser: "Google Chrome",
  handlers: [
    {
      match: [
        "basic.space",
        "basic.space/*",
        "*.basic.space",
        "*.basic.space/*",
        "docs.google.com",
        "sentry.io",
        "sentry.io/*"
      ],
      browser: {
        name: "Google Chrome",
        profile: "Profile 2"
      }
    },
    {
      match: ["amazon.com", "amazon.com/*"],
      browser: {
        name: "Google Chrome",
        profile: "Profile 1"
      }
    },
    {
      match: ["quickbooks.com", "quickbooks.com/*", "intuit.com", "intuit.com/*", "qbo.intuit.com", "qbo.intuit.com/*"],
      browser: {
        name: "Google Chrome",
        profile: "Profile 1"
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
