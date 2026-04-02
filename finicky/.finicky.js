export default {
  defaultBrowser: {
    name: "Google Chrome",
    profile: "Nick@WPC"
  },
  handlers: [
    {
      match: ["github.com/River*"],
      browser: {
        name: "Google Chrome",
        profile: "River"
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
        "*.sharepoint.com/*",
        "*brioconsulting*",
        "*seguin*",
        "*arcgis*",
      ],
      browser: "Microsoft Edge"
    }
  ]
};
