@react.component
let make = (~config: ReconEngineTypes.ingestionConfigType) => {
  let (isUploading, setIsUploading) = React.useState(_ => false)

  <>
    <ReconEngineDataSourceDetailsConfig
      config={config} isUploading={isUploading} setIsUploading={setIsUploading}
    />
    <ReconEngineDataSourceDetailsHistory config={config} isUploading={isUploading} />
  </>
}
