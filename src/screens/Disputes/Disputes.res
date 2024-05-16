open APIUtils
open PageLoaderWrapper
@react.component
let make = () => {
  let getURL = useGetURL()
  let {globalUIConfig: {font: {textColor}, border: {borderColor}}} = React.useContext(
    ConfigContext.configContext,
  )
  let {branding} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let (screenState, setScreenState) = React.useState(_ => Loading)
  let (disputesData, setDisputesData) = React.useState(_ => [])
  let (offset, setOffset) = React.useState(_ => 0)
  let fetchDetails = useGetMethod()

  let getDisputesList = async () => {
    try {
      setScreenState(_ => Loading)
      let disputesUrl = getURL(~entityName=DISPUTES, ~methodType=Get, ())
      let response = await fetchDetails(disputesUrl)
      let disputesValue = response->LogicUtils.getArrayDataFromJson(DisputesEntity.itemToObjMapper)
      if disputesValue->Array.length > 0 {
        setDisputesData(_ => disputesValue->Array.map(Nullable.make))
        setScreenState(_ => Success)
      } else {
        setScreenState(_ => Custom)
      }
    } catch {
    | Exn.Error(e) =>
      let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
      if err->String.includes("HE_02") {
        setScreenState(_ => Custom)
      } else {
        setScreenState(_ => PageLoaderWrapper.Error(err))
      }
    }
  }
  React.useEffect0(() => {
    getDisputesList()->ignore
    None
  })

  let customUI =
    <>
      <UIUtils.RenderIf condition={!branding}>
        <div
          className={`${borderColor.primaryNormal} flex  items-start  text-sm rounded-md gap-2 px-4 py-3 mt-5`}>
          <Icon name="info-vacent" className={`${textColor.primaryNormal} mt-1`} size=18 />
          <p>
            {"Missing disputes? Disputes might not be supported for your payment processor or might not yet have been integrated with hyperswitch. Please check the"->React.string}
            <a
              href="https://hyperswitch.io/pm-list"
              target="_blank"
              className={`${textColor.primaryNormal}`}>
              {" feature matrix "->React.string}
            </a>
            {"for your processor."->React.string}
          </p>
        </div>
      </UIUtils.RenderIf>
      <HelperComponents.BluredTableComponent
        infoText="No disputes as of now." moduleName=" " showRedirectCTA=false
      />
    </>

  let {generateReport} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

  <div>
    <PageUtils.PageHeading title="Disputes" subTitle="View and manage all disputes" />
    <div className="flex w-full justify-end pb-3 gap-3">
      <UIUtils.RenderIf condition={generateReport}>
        <GenerateReport entityName={DISPUTE_REPORT} />
      </UIUtils.RenderIf>
    </div>
    <PageLoaderWrapper screenState customUI>
      <div className="flex flex-col gap-4">
        <LoadedTableWithCustomColumns
          title=" "
          hideTitle=true
          actualData=disputesData
          entity={DisputesEntity.disputesEntity}
          resultsPerPage=10
          showSerialNumber=true
          totalResults={disputesData->Array.length}
          offset
          setOffset
          currrentFetchCount={disputesData->Array.length}
          defaultColumns={DisputesEntity.defaultColumns}
          customColumnMapper={TableAtoms.disputesMapDefaultCols}
          showSerialNumberInCustomizeColumns=false
          sortingBasedOnDisabled=false
        />
      </div>
    </PageLoaderWrapper>
  </div>
}
