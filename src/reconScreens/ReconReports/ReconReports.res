@react.component
let make = () => {
  open LogicUtils
  let (offset, setOffset) = React.useState(_ => 0)
  let fetchReportListResponse = ReportsData.useFetchReportsList()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (configuredReports, setConfiguredReports) = React.useState(_ => [])
  let (searchText, setSearchText) = React.useState(_ => "")
  let (filteredReportsData, setFilteredReports) = React.useState(_ => [])
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let (previouslyConnectedData, setPreviouslyConnectedData) = React.useState(_ => [])
  let (startDate, setStartDate) = React.useState(_ => ConfigUtils.getTodayDate())
  let (endDate, setEndDate) = React.useState(_ => ConfigUtils.getTomorrowDate())
  let showToast = ToastState.useShowToast()

  let toast = (message, toastType) => {
    showToast(~message, ~toastType)
  }

  let (initialValues, _) = React.useState(_ =>
    JSON.Encode.object(
      Dict.fromArray([
        ("startDate", JSON.Encode.string(ConfigUtils.getTodayDate())),
        ("endDate", JSON.Encode.string(ConfigUtils.getTomorrowDate())),
      ]),
    )
  )

  let filterLogic = ReactDebounce.useDebounced(ob => {
    let (searchText, arr) = ob
    let filteredList = if searchText->isNonEmptyString {
      arr->Array.filter((obj: Nullable.t<ReportsTypes.reportPayload>) => {
        switch Nullable.toOption(obj) {
        | Some(obj) =>
          isContainingStringLowercase(obj.payment_entity_txn_id, searchText) ||
          isContainingStringLowercase(obj.txn_type, searchText) ||
          isContainingStringLowercase(obj.recon_status, searchText)
        | None => false
        }
      })
    } else {
      arr
    }
    setFilteredReports(_ => filteredList)
  }, ~wait=200)

  let getReportsList = async _ => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let response = await fetchReportListResponse(
        ~startDate=`${startDate}T00:00:00`,
        ~endDate=`${endDate}T23:59:59`,
      )
      let data = response->getDictFromJsonObject->getArrayFromDict("data", [])
      let reportsList = data->ReportsListMapper.getArrayOfReportsListPayloadType
      setConfiguredReports(_ => reportsList)
      setFilteredReports(_ => reportsList->Array.map(Nullable.make))
      setPreviouslyConnectedData(_ => reportsList->Array.map(Nullable.make))
      setScreenState(_ => Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch"))
    }
  }

  let onSubmit = (values, _) => {
    let metadata = values->LogicUtils.getDictFromJsonObject
    let startDate = metadata->LogicUtils.getString("startDate", "")
    let endDate = metadata->LogicUtils.getString("endDate", "")

    setStartDate(_ => startDate)
    setEndDate(_ => endDate)
    open Promise
    Nullable.null->resolve
  }

  React.useEffect(() => {
    getReportsList()->ignore

    let intervalId = if configuredReports->Array.length == 0 {
      let id = Js.Global.setInterval(() => {
        getReportsList()->ignore
      }, 5000)
      Some(id)
    } else {
      None
    }

    Some(
      () => {
        switch intervalId {
        | Some(id) => Js.Global.clearInterval(id)
        | None => ()
        }
      },
    )
  }, [configuredReports->Array.length->Int.toString, startDate, endDate])

  let convertArrayToCSV = arr => {
    let headers = ReportsListMapper.getHeadersForCSV()
    let csv =
      arr
      ->Array.map(row => row->Array.joinWith(","))
      ->Array.joinWith("\n")
    headers ++ "\n" ++ csv
  }

  let downloadReport = async () => {
    try {
      let arr = configuredReports->Array.map((obj: ReportsTypes.reportPayload) => {
        let row = [
          obj.gateway,
          obj.merchant_id,
          obj.payment_entity_txn_id,
          obj.recon_id,
          obj.recon_status,
          obj.recon_sub_status,
          obj.reconciled_at,
          obj.settlement_amount->Float.toString,
          obj.settlement_id,
          obj.txn_amount->Float.toString,
          obj.txn_currency,
          obj.txn_type,
        ]
        row
      })
      let csvContent = arr->convertArrayToCSV
      DownloadUtils.download(
        ~fileName=`reconciliation_report_${startDate}_${endDate}.csv`,
        ~content=csvContent,
        ~fileType="text/csv",
      )

      toast("Report downloaded successfully", ToastSuccess)
    } catch {
    | _ => toast("Failed to download report", ToastError)
    }
  }

  <div className="flex flex-col space-y-2 justify-center relative">
    <div className="relative">
      <PageUtils.PageHeading
        title={"Reconciliation Reports"}
        customTitleStyle="!text-lg !font-semibold"
        subTitle={"View all the reconciliation reports here"}
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
                  ~numMonths=2,
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
    <RenderIf condition={screenState == Success && configuredReports->Array.length == 0}>
      <div className="my-4">
        <NoDataFound message={"No data available"} renderType={Painting} />
      </div>
    </RenderIf>
    <PageLoaderWrapper screenState>
      <RenderIf condition={configuredReports->Array.length > 0}>
        <div className="flex flex-col relative">
          <div className="flex justify-end absolute right-0 top-10 cursor-pointer">
            <Button
              text="Download Reports"
              buttonType={Primary}
              rightIcon={Button.CustomIcon(<Icon name="download" size=14 />)}
              onClick={_ => {
                downloadReport()->ignore
              }}
              buttonSize={Medium}
            />
          </div>
          <LoadedTable
            title="Search Reports"
            actualData=filteredReportsData
            totalResults={filteredReportsData->Array.length}
            resultsPerPage=10
            entity={ReportsTableEntity.reportsEntity(
              `v2/recon/reports`,
              ~authorization=userHasAccess(~groupAccess=UsersManage),
            )}
            filters={<TableSearchFilter
              data={previouslyConnectedData}
              filterLogic
              placeholder="Search Payment Entity Txn Id, Txn Type, Recon Status"
              customSearchBarWrapperWidth="w-full lg:w-1/2"
              customInputBoxWidth="w-full"
              searchVal={searchText}
              setSearchVal={setSearchText}
            />}
            offset
            setOffset
            currrentFetchCount={configuredReports->Array.length}
            collapseTableRow=false
          />
        </div>
      </RenderIf>
    </PageLoaderWrapper>
  </div>
}
