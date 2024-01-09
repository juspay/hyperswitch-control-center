open APIUtils
open PageLoaderWrapper
@react.component
let make = () => {
  let (screenState, setScreenState) = React.useState(_ => Loading)
  let (disputesData, setDisputesData) = React.useState(_ => [])
  let (filteredDisputesData, setFilteredDisputesData) = React.useState(_ => [])
  let (offset, setOffset) = React.useState(_ => 0)
  let (searchText, setSearchText) = React.useState(_ => "")
  let fetchDetails = useGetMethod()

  let getDisputesList = async () => {
    try {
      setScreenState(_ => Loading)
      let disputesUrl = getURL(~entityName=DISPUTES, ~methodType=Get, ())
      let response = await fetchDetails(disputesUrl)
      let disputesValue = response->LogicUtils.getArrayDataFromJson(DisputesEntity.itemToObjMapper)
      if disputesValue->Array.length > 0 {
        setDisputesData(_ => disputesValue->Array.map(Js.Nullable.return))
        setScreenState(_ => Success)
      } else {
        setScreenState(_ => Custom)
      }
    } catch {
    | Js.Exn.Error(e) =>
      let err = Js.Exn.message(e)->Belt.Option.getWithDefault("Failed to Fetch!")
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

  // TODO: Convert it to remote filter
  let filterLogic = ReactDebounce.useDebounced(ob => {
    let (searchText, arr) = ob
    let filteredList = Array.filter(arr, (ob: Js.Nullable.t<DisputesEntity.disputes>) => {
      switch Js.Nullable.toOption(ob) {
      | Some(obj) =>
        String.includes(obj.payment_id->String.toLowerCase, searchText->String.toLowerCase) ||
        String.includes(obj.dispute_id->String.toLowerCase, searchText->String.toLowerCase)
      | None => false
      }
    })
    setFilteredDisputesData(_ => filteredList)
  }, ~wait=200)

  let customUI =
    <>
      <div
        className="flex border items-start border-blue-800 text-sm rounded-md gap-2 px-4 py-3 mt-5">
        <Icon name="info-vacent" className="text-blue-900 mt-1" size=18 />
        <p>
          {"Missing disputes? Disputes might not be supported for your payment processor or might not yet have been integrated with hyperswitch. Please check the"->React.string}
          <a href="https://hyperswitch.io/pm-list" target="_blank" className="text-blue-900">
            {" feature matrix "->React.string}
          </a>
          {"for your processor."->React.string}
        </p>
      </div>
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
          actualData=filteredDisputesData
          entity={DisputesEntity.disputesEntity}
          resultsPerPage=10
          filters={<TableSearchFilter
            data={disputesData}
            filterLogic
            placeholder="Search payment id or dispute id"
            searchVal=searchText
            setSearchVal=setSearchText
          />}
          showSerialNumber=true
          totalResults={filteredDisputesData->Array.length}
          offset
          setOffset
          currrentFetchCount={filteredDisputesData->Array.length}
          defaultColumns={DisputesEntity.defaultColumns}
          customColumnMapper={DisputesEntity.disputesMapDefaultCols}
          showSerialNumberInCustomizeColumns=false
          sortingBasedOnDisabled=false
        />
      </div>
    </PageLoaderWrapper>
  </div>
}
