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
    CYPRESS_USERNAME: process.env.CYPRESS_USERNAME,
    CYPRESS_PASSWORD: process.env.CYPRESS_PASSWORD,
    MAIL_URL: process.env.MAIL_URL || "http://localhost:8025",
    RBAC: "", //"profile,admin"
    CYPRESS_SSO_BASE_URL: process.env.CYPRESS_SSO_BASE_URL,
    CYPRESS_SSO_CLIENT_ID: process.env.CYPRESS_SSO_CLIENT_ID,
    CYPRESS_SSO_CLIENT_SECRET: process.env.CYPRESS_SSO_CLIENT_SECRET,
    CYPRESS_SSO_USERNAME: process.env.CYPRESS_SSO_USERNAME,
    CYPRESS_SSO_PASSWORD: process.env.CYPRESS_SSO_PASSWORD,
  },
  viewportWidth: 1440,
  viewportHeight: 1005,
});
