@react.component
let make = () => {
  open LogicUtils
  open OMPSwitchTypes
  open ReconOnboardingUtils
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (configuredReports, setConfiguredReports) = React.useState(_ => [])
  let (filteredReportsData, setFilteredReports) = React.useState(_ => [])
  let showToast = ToastState.useShowToast()
  let (tabIndex, setTabIndex) = React.useState(_ => 0)
  let setCurrentTabName = Recoil.useSetRecoilState(HyperswitchAtom.currentTabNameRecoilAtom)
  let (selectedFilter, setSelectedFilter) = React.useState(_ => "")
  let (filtersList, _) = React.useState(_ => [
    {id: "Status", name: "Status"},
    {id: "Payment Gateway", name: "Payment Gateway"},
  ])
  let (selectedReconId, setSelectedReconId) = React.useState(_ => "Recon_235")

  let (reconList, _) = React.useState(_ => [{id: "Recon_235", name: "Recon_235"}])

  let (reconArrow, setReconArrow) = React.useState(_ => false)
  let (arrow, setArrow) = React.useState(_ => false)
  let getTabName = index => index == 0 ? "All" : "Exceptions"

  let getReportsList = async _ => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      // let response = await fetchReportListResponse(~startDate, ~endDate)
      let response = ReportsData.reportsResponse
      let data = response->getDictFromJsonObject->getArrayFromDict("data", [])
      let reportsList = data->ReportsTableEntity.getArrayOfReportsListPayloadType
      setConfiguredReports(_ => reportsList)
      setFilteredReports(_ => reportsList->Array.map(Nullable.make))
      setScreenState(_ => Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch"))
    }
  }

  React.useEffect(() => {
    setScreenState(_ => PageLoaderWrapper.Success)
    getReportsList()->ignore
    None
  }, [])

  let convertArrayToCSV = arr => {
    let headers = ReconReportUtils.getHeadersForCSV()
    let csv =
      arr
      ->Array.map(row => row->Array.joinWith(","))
      ->Array.joinWith("\n")
    headers ++ "\n" ++ csv
  }

  let toast = (message, toastType) => {
    showToast(~message, ~toastType)
  }

  let downloadReport = async () => {
    try {
      let arr = configuredReports->Array.map((obj: ReportsTypes.allReportPayload) => {
        let row = [
          obj.transaction_id,
          obj.order_id,
          obj.payment_gateway,
          obj.payment_gateway,
          obj.txn_amount->Float.toString,
          obj.settlement_amount->Float.toString,
          obj.recon_status,
          obj.transaction_date,
        ]
        row
      })
      let csvContent = arr->convertArrayToCSV
      DownloadUtils.download(
        ~fileName=`reconciliation_report.csv`,
        ~content=csvContent,
        ~fileType="text/csv",
      )

      toast("Report downloaded successfully", ToastSuccess)
    } catch {
    | _ => toast("Failed to download report", ToastError)
    }
  }

  let tabs: array<Tabs.tab> = React.useMemo(() => {
    open Tabs
    [
      {
        title: "All",
        renderContent: () =>
          <ReconReportsList configuredReports filteredReportsData setFilteredReports />,
      },
      {
        title: "Exceptions",
        renderContent: () => <ReconExceptionsList />,
      },
    ]
  }, (configuredReports, filteredReportsData))

  let filterInput: ReactFinalForm.fieldRenderPropsInput = {
    name: "name",
    onBlur: _ => (),
    onChange: ev => {
      let value = ev->Identity.formReactEventToString
      setSelectedFilter(_ => value)
    },
    onFocus: _ => (),
    value: selectedFilter->JSON.Encode.string,
    checked: true,
  }

  let reconInput: ReactFinalForm.fieldRenderPropsInput = {
    name: "name",
    onBlur: _ => (),
    onChange: ev => {
      let value = ev->Identity.formReactEventToString
      setSelectedReconId(_ => value)
    },
    onFocus: _ => (),
    value: selectedReconId->JSON.Encode.string,
    checked: true,
  }

  let toggleReconChevronState = () => {
    setReconArrow(prev => !prev)
  }

  let toggleChevronState = () => {
    setArrow(prev => !prev)
  }

  let customScrollStyle = "max-h-72 overflow-scroll px-1 pt-1 border border-b-0"
  let dropdownContainerStyle = "rounded-md border border-1 !w-full"

  <div className="flex flex-col space-y-2 justify-center relative">
    <div className="flex justify-between items-center">
      <p className="text-2xl font-semibold text-nd_gray-700">
        {"Reconciliation Reports"->React.string}
      </p>
      <div className="flex flex-row gap-4">
        <div className="flex flex-row gap-6">
          <SelectBox.BaseDropdown
            allowMultiSelect=false
            buttonText=""
            input=reconInput
            deselectDisable=true
            customButtonStyle="!rounded-lg"
            options={reconList->generateDropdownOptionsCustomComponent}
            marginTop="mt-10"
            hideMultiSelectButtons=true
            addButton=false
            baseComponent={<ReconReportsHelper.ListBaseComp
              heading="Recon" subHeading=selectedReconId arrow=reconArrow
            />}
            customDropdownOuterClass="!border-none !w-full"
            fullLength=true
            toggleChevronState=toggleReconChevronState
            customScrollStyle
            dropdownContainerStyle
            shouldDisplaySelectedOnTop=true
            customSelectionIcon={CustomIcon(<Icon name="nd-check" />)}
          />
        </div>
        <Button
          text="Download Reports"
          buttonType={Secondary}
          leftIcon={Button.CustomIcon(<Icon name="nd-download-bar-down" size=14 />)}
          onClick={_ => {
            downloadReport()->ignore
          }}
          buttonSize={Medium}
        />
      </div>
    </div>
    <PageLoaderWrapper screenState>
      <div className="relative">
        <div className="absolute top-[85px] right-16 z-10">
          <SelectBox.BaseDropdown
            allowMultiSelect=false
            buttonText=""
            input=filterInput
            deselectDisable=true
            customButtonStyle="!rounded-lg"
            options={filtersList->ReconReportUtils.generateDropdownOptionsCustomComponent}
            marginTop="mt-10"
            hideMultiSelectButtons=true
            addButton=false
            baseComponent={<ReconReportUtils.ListBaseComp
              heading="Profile" subHeading=selectedFilter arrow
            />}
            customDropdownOuterClass="!border-none !w-full"
            fullLength=true
            toggleChevronState
            customScrollStyle
            dropdownContainerStyle
            shouldDisplaySelectedOnTop=true
            customSelectionIcon={CustomIcon(<Icon name="nd-checkbox-base" />)}
          />
        </div>
        <div className="flex flex-col relative">
          <Tabs
            initialIndex={tabIndex >= 0 ? tabIndex : 0}
            tabs
            showBorder=false
            includeMargin=false
            lightThemeColor="black"
            defaultClasses="!w-max flex flex-auto flex-row items-center justify-center px-6 font-semibold text-body"
            onTitleClick={indx => {
              setTabIndex(_ => indx)
              setCurrentTabName(_ => getTabName(indx))
            }}
          />
        </div>
      </div>
    </PageLoaderWrapper>
  </div>
}
