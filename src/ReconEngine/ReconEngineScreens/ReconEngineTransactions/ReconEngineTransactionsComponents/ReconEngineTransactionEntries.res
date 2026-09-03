@react.component
let make = (
  ~primaryTransactionId: string,
  ~accountIds: array<string>,
  ~accountsData: array<ReconEngineTypes.accountType>,
  ~entriesDetailFields=EntriesTableEntity.transactionEntriesDetailFields,
) => {
  open APIUtils
  open LogicUtils
  open ReconEngineTransactionsUtils

  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let showToast = ToastAdapter.useShowToast()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (transformationConfigs, setTransformationConfigs) = React.useState((_): array<
    ReconEngineTypes.transformationConfigType,
  > => [])

  let currencyOptions = React.useMemo(() => {
    getCurrencyOptionsFromAccounts(accountsData, ~accountIds)
  }, (accountsData, accountIds))

  let transformationNameMap = React.useMemo(() => {
    let nameMap = Dict.make()
    transformationConfigs->Array.forEach(config =>
      nameMap->Dict.set(config.transformation_id, config.name)
    )
    nameMap
  }, [transformationConfigs])

  let transformationConfigOptions = React.useMemo(() => {
    transformationConfigs->Array.map((config): FilterSelectBox.dropdownOption => {
      label: config.name,
      value: config.transformation_id,
    })
  }, [transformationConfigs])

  let fetchTransformationConfigs = async () => {
    try {
      let url = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Get,
        ~hyperswitchReconType=#TRANSFORMATION_CONFIG,
      )
      let res = await fetchDetails(url)
      let configs = res->getArrayDataFromJson(ReconEngineUtils.transformationConfigItemToObjMapper)
      setTransformationConfigs(_ => configs)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => {
        showToast(~message="Failed to fetch transformation configs", ~toastType=ToastError)
        setScreenState(_ => PageLoaderWrapper.Success)
      }
    }
  }

  React.useEffect(() => {
    fetchTransformationConfigs()->ignore
    None
  }, [])

  <PageLoaderWrapper
    screenState customLoader={<Shimmer styleClass="h-40 w-full mt-6 rounded-xl" />}>
    <div className="flex flex-col gap-6 mt-6 mb-16">
      <RenderIf condition={accountIds->isEmptyArray}>
        <NoDataFound customCssClass="my-6" message="No Data Available" renderType=Painting />
      </RenderIf>
      {accountIds
      ->Array.map(accountId =>
        <FilterContext
          key=accountId
          index={`recon-engine-transaction-entries-${primaryTransactionId}-${accountId}`}>
          <ReconEngineTransactionEntriesContent
            primaryTransactionId
            accountId
            accountsData
            transformationNameMap
            currencyOptions
            transformationConfigOptions
            entriesDetailFields
          />
        </FilterContext>
      )
      ->React.array}
    </div>
  </PageLoaderWrapper>
}
