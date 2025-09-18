@react.component
let make = (~config: ReconEngineTypes.transformationConfigType) => {
  <>
    <ReconEngineAccountsTransformationDetailsConfig config={config} />
    <ReconEngineAccountsTransformationDetailsHistory config={config} />
  </>
}
