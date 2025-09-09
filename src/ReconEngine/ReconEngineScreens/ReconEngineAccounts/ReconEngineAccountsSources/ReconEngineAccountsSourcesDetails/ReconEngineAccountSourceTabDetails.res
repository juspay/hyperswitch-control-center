@react.component
let make = (~config: ReconEngineFileManagementTypes.ingestionConfigType) => {
  <>
    <ReconEngineAccountSourceDetailsConfig config={config} />
    <ReconEngineAccountSourceDetailsHistory config={config} />
  </>
}
