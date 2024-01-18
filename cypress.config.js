const { defineConfig } = require("cypress");
module.exports = defineConfig({
  e2e: {
    setupNodeEvents(on, config) {
      // implement node event listeners here
    },
  },
  env: {
    CYPRESS_USERNAME: process.env.CYPRESS_USERNAME || "",
    CYPRESS_PASSWORD: process.env.CYPRESS_PASSWORD || "",
  },
});
