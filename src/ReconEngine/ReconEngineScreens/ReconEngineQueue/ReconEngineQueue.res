open Typography

@react.component
let make = () => {
  let (showModal, setShowModal) = React.useState(_ => false)
  <>
    <div className="flex flex-col gap-8 h-full">
      <PageUtils.PageHeading
        title="Recon Queue"
        subTitle="Upload files to view reconciliation insights"
        customSubTitleStyle={body.lg.medium}
        customTitleStyle={`${heading.lg.semibold} py-0`}
      />
      <div className="flex-1 flex flex-col items-center justify-center min-h-96">
        <div className="text-center mb-8">
          <span className={`${heading.sm.semibold} text-nd_gray-900 mb-2`}>
            {"No Files Available"->React.string}
          </span>
          <p className="text-nd_gray-500"> {"Upload files to view."->React.string} </p>
        </div>
        <Button
          text="Upload File"
          buttonType=Primary
          leftIcon={FontAwesome("upload")}
          onClick={_ => {
            setShowModal(_ => true)
          }}
          buttonSize=Medium
        />
      </div>
    </div>
    <RenderIf condition={showModal}>
      <ReconEngineFileUploadModal showModal setShowModal />
    </RenderIf>
  </>
}
