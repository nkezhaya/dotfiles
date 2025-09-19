export default {
  defaultBrowser: {
    name: "Google Chrome",
    profile: "Nick@WPC"
  },
  handlers: [
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
