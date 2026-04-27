@react.component
let make = (~config: ReconEngineTypes.transformationConfigType) => {
  <>
    <ReconEngineDataTransformationDetailsConfig config={config} />
    <ReconEngineDataTransformationDetailsHistory config={config} />
  </>
}
