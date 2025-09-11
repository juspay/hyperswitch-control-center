@react.component
let make = (~config: ReconEngineFileManagementTypes.transformationConfigType) => {
  <>
    <ReconEngineAccountsTransformationDetailsConfig config={config} />
    <ReconEngineAccountsTransformationDetailsHistory config={config} />
  </>
}
