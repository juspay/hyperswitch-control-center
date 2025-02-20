@react.component
let make = () => {
  open LogicUtils
  let fetchHistoryListResponse = HistoryData.useFetchHistoryList()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (offset, setOffset) = React.useState(_ => 0)
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let (configuredHistory, setConfiguredHistory) = React.useState(_ => [])
  let (filteredHistoryData, setFilteredHistory) = React.useState(_ => [])
  let (previousHistoryData, setPreviousHistoryData) = React.useState(_ => [])
  let (searchText, setSearchText) = React.useState(_ => "")
  let (startDate, setStartDate) = React.useState(_ => ConfigUtils.getTodayDate())
  let (endDate, setEndDate) = React.useState(_ => ConfigUtils.getTomorrowDate())

  let getHistoryList = async _ => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let response = await fetchHistoryListResponse(~startDate, ~endDate)
      let data = response->getDictFromJsonObject->getArrayFromDict("data", [])
      let historyList = data->HistoryListMapper.getArrayOfHistoryListPayloadType
      setConfiguredHistory(_ => historyList)
      setFilteredHistory(_ => historyList->Array.map(Nullable.make))
      setPreviousHistoryData(_ => historyList->Array.map(Nullable.make))
      setScreenState(_ => Success)
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
        Exn.raiseError(err)
      }
    }
  }

  let filterLogic = ReactDebounce.useDebounced(ob => {
    let (searchText, arr) = ob
    let filteredList = if searchText->isNonEmptyString {
      arr->Array.filter((obj: Nullable.t<HistoryTypes.historyPayload>) => {
        switch Nullable.toOption(obj) {
        | Some(obj) =>
          isContainingStringLowercase(obj.recon_uuid, searchText) ||
          isContainingStringLowercase(obj.gateway, searchText) ||
          isContainingStringLowercase(obj.recon_status, searchText)
        | None => false
        }
      })
    } else {
      arr
    }
    setFilteredHistory(_ => filteredList)
  }, ~wait=200)

  React.useEffect(() => {
    getHistoryList()->ignore
    None
  }, [startDate, endDate])

  let (initialValues, _) = React.useState(_ =>
    JSON.Encode.object(
      Dict.fromArray([
        ("startDate", JSON.Encode.string(ConfigUtils.getTodayDate())),
        ("endDate", JSON.Encode.string(ConfigUtils.getTomorrowDate())),
      ]),
    )
  )

  let onSubmit = (values, _) => {
    let metadata = values->LogicUtils.getDictFromJsonObject
    let startDate = metadata->LogicUtils.getString("startDate", "")
    let endDate = metadata->LogicUtils.getString("endDate", "")

    setStartDate(_ => startDate)
    setEndDate(_ => endDate)
    open Promise
    Nullable.null->resolve
  }

  <div className="flex flex-col space-y-2 justify-center relative">
    <div className="relative">
      <PageUtils.PageHeading
        title="Reconciliation History"
        customTitleStyle="!text-lg !font-semibold"
        subTitle={"View the history of all your reconciliations"}
        customSubTitleStyle="text-base font-medium"
      />
      <div className="flex flex-row gap-6 absolute bottom-0 right-0">
        <Form initialValues onSubmit>
          <div className="flex flex-row gap-6">
            <FormRenderer.FieldRenderer
              field={FormRenderer.makeMultiInputFieldInfo(
                ~label="",
                ~comboCustomInput=InputFields.dateRangeField(
                  ~startKey="startDate",
                  ~endKey="endDate",
                  ~format="YYYY-MM-DD",
                  ~showTime=false,
                  ~disablePastDates={false},
                  ~disableFutureDates={true},
                  ~predefinedDays=[Today, Yesterday, ThisMonth, LastMonth, LastSixMonths],
                  ~dateRangeLimit=400,
                  ~disableApply=true,
                  ~isTooltipVisible=false,
                  ~customButtonStyle="!w-1/2",
                ),
                ~inputFields=[],
              )}
            />
            <FormRenderer.SubmitButton
              text="Apply" customSumbitButtonStyle="w-full mt-4" buttonType={Primary}
            />
          </div>
        </Form>
      </div>
    </div>
    <RenderIf condition={screenState == Success && configuredHistory->Array.length == 0}>
      <div className="my-4">
        <NoDataFound message="No data available" renderType={Painting} />
      </div>
    </RenderIf>
    <PageLoaderWrapper screenState>
      <RenderIf condition={screenState == Success && configuredHistory->Array.length > 0}>
        <LoadedTable
          title="Search History"
          actualData=filteredHistoryData
          totalResults={filteredHistoryData->Array.length}
          resultsPerPage=10
          entity={HistoryTableEntity.historyEntity(
            `v2/recon/history`,
            ~authorization=userHasAccess(~groupAccess=UsersManage),
          )}
          filters={<TableSearchFilter
            data={previousHistoryData}
            filterLogic
            placeholder="Search Gateway, Payment Entity Txn Id, Txn Type, Recon Status"
            customSearchBarWrapperWidth="w-full lg:w-1/2"
            customInputBoxWidth="w-full"
            searchVal={searchText}
            setSearchVal={setSearchText}
          />}
          offset
          setOffset
          currrentFetchCount={configuredHistory->Array.length}
          collapseTableRow=false
        />
      </RenderIf>
    </PageLoaderWrapper>
  </div>
}
