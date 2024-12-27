open ReconConfigurationTypes

let getStepName = step => {
  switch step {
  | ConnectOrderData => "Connect Order Data"
  | ConnectProcessorData => "Connect Processor Data"
  | ConnectSettlementData => "Connect Settlement Data"
  | ScheduleReconReports => "Schedule Recon Reports"
  }
}
let stepsArr: array<steps> = [ConnectOrderData, ConnectProcessorData, ConnectSettlementData, ScheduleReconReports]

let getNextStep: steps => steps = step => {
  switch step {
  | ConnectOrderData => ConnectProcessorData
  | ConnectProcessorData => ConnectSettlementData
  | ConnectSettlementData => ScheduleReconReports
  | ScheduleReconReports => ScheduleReconReports
  }
}

let getPrevStep: steps => steps = step => {
  switch step {
  | ConnectProcessorData => ConnectOrderData
  | ConnectSettlementData => ConnectProcessorData
  | ScheduleReconReports => ConnectSettlementData
  | _ => ConnectOrderData
  }
}