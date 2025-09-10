@react.component
let make = (~config: ReconEngineFileManagementTypes.ingestionConfigType) => {
  let (isUploading, setIsUploading) = React.useState(_ => false)

  <>
    <ReconEngineAccountSourceDetailsConfig
      config={config} isUploading={isUploading} setIsUploading={setIsUploading}
    />
    <ReconEngineAccountSourceDetailsHistory config={config} isUploading={isUploading} />
  </>
}
