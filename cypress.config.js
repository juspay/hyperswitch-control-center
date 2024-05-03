const { defineConfig } = require("cypress");
module.exports = defineConfig({
  e2e: {
    setupNodeEvents(on, config) {
      require("@cypress/code-coverage/task")(on, config);
      // include any other plugin code...

      // It's IMPORTANT to return the config object
      // with any changed environment variables
      return config;
    },
  },
  env: {
    CYPRESS_USERNAME: process.env.CYPRESS_USERNAME || "cypress@gmail.com",
    CYPRESS_PASSWORD: process.env.CYPRESS_PASSWORD || "Cypress98#",
  },
});
