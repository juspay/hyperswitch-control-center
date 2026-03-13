@react.component
let make = (~ruleDetails: ReconEngineRulesTypes.rulePayload) => {
  <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
    <FilterContext index="recon_reconciled_graph">
      <ReconEngineReconciledVolumeColumnGraph ruleId={ruleDetails.rule_id} />
    </FilterContext>
    <FilterContext index="recon_exceptions_graph">
      <ReconEngineExceptionsVolumeColumnGraph ruleId={ruleDetails.rule_id} />
    </FilterContext>
  </div>
}
