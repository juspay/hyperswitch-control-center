class VolumeBasedConfiguration {
  get connectorDropdown() {
    return cy.get(`[data-value="addProcessors"]`);
  }
}

export default VolumeBasedConfiguration;
