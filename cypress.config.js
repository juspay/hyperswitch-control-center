const { defineConfig } = require("cypress");
module.exports = defineConfig({
  e2e: {
    baseUrl: "http://localhost:9000",
    setupNodeEvents(on, config) {
      require("@cypress/code-coverage/task")(on, config);
      // include any other plugin code...

      // It's IMPORTANT to return the config object
      // with any changed environment variables
      return config;
    },
    chromeWebSecurity: false,
  },
  env: {
    CYPRESS_USERNAME: process.env.CYPRESS_USERNAME || "cypress@gmail.com",
    CYPRESS_PASSWORD: process.env.CYPRESS_PASSWORD || "Cypress98#",
    MAIL_URL: process.env.MAIL_URL || "http://localhost:8025",
    RBAC: "", //"profile,admin"
  },
  viewportWidth: 1440,
  viewportHeight: 1005,
});
