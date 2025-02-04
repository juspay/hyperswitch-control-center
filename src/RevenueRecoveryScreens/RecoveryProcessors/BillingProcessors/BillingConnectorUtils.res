open ConnectorTypes
let stepsArr = [IntegFields, SummaryAndTest, AutomaticFlow, Webhooks]

let billingProcessorList: array<connectorTypes> = [BillingProcessor(CHARBEE)]

let billingProcessorDropDownOption = processors =>
  processors->Array.map((processor: ConnectorTypes.connectorTypes) => {
    let obj: SelectBox.dropdownOption = {
      label: processor->ConnectorUtils.getConnectorNameString,
      value: processor->ConnectorUtils.getConnectorNameString,
    }
    obj
  })
