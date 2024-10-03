@react.component
let make = () => {
  open APIUtils

  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (disputesData, setDisputesData) = React.useState(_ => [])
  let (offset, setOffset) = React.useState(_ => 0)

  let {generateReport} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let {updateTransactionEntity} = OMPSwitchHooks.useUserInfo()
  let {userInfo: {transactionEntity}, checkUserEntity} = React.useContext(
    UserInfoProvider.defaultContext,
  )
  let getDisputesList = async () => {
    open LogicUtils
    try {
      setScreenState(_ => Loading)
      let disputesUrl = getURL(~entityName=DISPUTES, ~methodType=Get)
      let response = await fetchDetails(disputesUrl)
      let disputesValue = response->getArrayDataFromJson(DisputesEntity.itemToObjMapper)
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
  React.useEffect(() => {
    getDisputesList()->ignore
    None
  }, [])

  let customUI =
    <NoDataFound
      customCssClass={"my-6"} message="There are no disputes as of now" renderType=Painting
    />

  <div>
    <div className="flex justify-between items-center">
      <PageUtils.PageHeading title="Disputes" subTitle="View and manage all disputes" />
      <div className="flex gap-4">
        <OMPSwitchHelper.OMPViews
          views={OMPSwitchUtils.transactionViewList(~checkUserEntity)}
          selectedEntity={transactionEntity}
          onChange={updateTransactionEntity}
        />
        <RenderIf condition={generateReport && disputesData->Array.length > 0}>
          <GenerateReport entityName={DISPUTE_REPORT} />
        </RenderIf>
      </div>
    </div>
    <PageLoaderWrapper screenState customUI>
      <div className="flex flex-col gap-4">
        <LoadedTableWithCustomColumns
          title="Disputes"
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
