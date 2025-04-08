@react.component
let make = () => {
  open LogicUtils
  open OMPSwitchTypes
  open ReconOnboardingUtils
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let showToast = ToastState.useShowToast()
  let url = RescriptReactRouter.useUrl()
  let (tabIndex, setTabIndex) = React.useState(_ => 0)
  let setCurrentTabName = Recoil.useSetRecoilState(HyperswitchAtom.currentTabNameRecoilAtom)
  let (selectedReconId, setSelectedReconId) = React.useState(_ => "Recon_235")
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let fetchApi = AuthHooks.useApiFetcher()
  let (reconList, _) = React.useState(_ => [{id: "Recon_235", name: "Recon_235"}])
  let (reconArrow, setReconArrow) = React.useState(_ => false)
  let getTabName = index => index == 0 ? "All" : "Exceptions"

  React.useEffect(() => {
    switch url.search->ReconReportUtils.getTabFromUrl {
    | Exceptions => {
        mixpanelEvent(~eventName="recon_exceptions_reports")
        setTabIndex(_ => 1)
      }
    | All => {
        mixpanelEvent(~eventName="recon_all_reports")
        setTabIndex(_ => 0)
      }
    }
    setScreenState(_ => PageLoaderWrapper.Success)
    None
  }, [url.search])

  let convertArrayToCSV = arr => {
    let headers = ReconReportUtils.getHeadersForCSV()
    let csv =
      arr
      ->Array.map(row => row->Array.joinWith(","))
      ->Array.joinWith("\n")
    headers ++ "\n" ++ csv
  }

  let downloadReport = async () => {
    try {
      let url = `${GlobalVars.getHostUrl}/test-data/recon/reconAllReports.json`
      let allReportsResponse = await fetchApi(
        `${url}`,
        ~method_=Get,
        ~xFeatureRoute=false,
        ~forceCookies=false,
      )
      let response = await allReportsResponse->(res => res->Fetch.Response.json)
      let reportsList =
        response
        ->getDictFromJsonObject
        ->getArrayFromDict("data", [])
        ->ReconReportUtils.getArrayOfReportsListPayloadType

      let arr = reportsList->Array.map((obj: ReportsTypes.allReportPayload) => {
        let row = [
          obj.order_id,
          obj.transaction_id,
          obj.payment_gateway,
          obj.payment_method,
          obj.txn_amount->Float.toString,
          obj.settlement_amount->Float.toString,
          obj.recon_status,
          obj.transaction_date,
        ]
        row
      })
      let csvContent = arr->convertArrayToCSV
      DownloadUtils.download(
        ~fileName=`${selectedReconId}_Reconciliation_Report.csv`,
        ~content=csvContent,
        ~fileType="text/csv",
      )

      showToast(~message="Report downloaded successfully", ~toastType=ToastSuccess)
    } catch {
    | _ => showToast(~message="Failed to download report", ~toastType=ToastError)
    }
  }

  let tabs: array<Tabs.tab> = React.useMemo(() => {
    open Tabs
    [
      {
        title: "All",
        renderContent: () => <ReconReportsList />,
        onTabSelection: () => {
          RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url="/v2/recon/reports"))
        },
      },
      {
        title: "Exceptions",
        renderContent: () => <ReconExceptionsList />,
        onTabSelection: () => {
          RescriptReactRouter.replace(
            GlobalVars.appendDashboardPath(~url="/v2/recon/reports?tab=exceptions"),
          )
        },
      },
    ]
  }, [])

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

  let customScrollStyle = "max-h-72 overflow-scroll px-1 pt-1 border border-b-0"
  let dropdownContainerStyle = "rounded-md border border-1 !w-full"
  <div>
    <div
      className="absolute z-10 top-76-px left-0 w-full py-3 px-10 bg-orange-50 flex justify-between items-center">
      <div className="flex gap-4 items-center">
        <Icon name="nd-information-triangle" size=24 />
        <p className="text-nd_gray-600 text-base leading-6 font-medium">
          {"You're viewing sample analytics to help you understand how the reports will look with real data"->React.string}
        </p>
      </div>
      // <ReconHelper.GetProductionAccess />
    </div>
    <div className="flex flex-col space-y-2 justify-center relative gap-4 mt-12">
      <div>
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
                mixpanelEvent(~eventName="recon_generate_reports_download")
                downloadReport()->ignore
              }}
              buttonSize={Medium}
            />
          </div>
        </div>
        <PageLoaderWrapper screenState>
          <div className="flex flex-col relative">
            <Tabs
              initialIndex={tabIndex >= 0 ? tabIndex : 0}
              tabs
              showBorder=true
              includeMargin=false
              defaultClasses="!w-max flex flex-auto flex-row items-center justify-center px-6 font-semibold text-body"
              onTitleClick={indx => {
                setTabIndex(_ => indx)
                setCurrentTabName(_ => getTabName(indx))
              }}
              selectTabBottomBorderColor="bg-primary"
              customBottomBorderColor="bg-nd_gray-150"
            />
          </div>
        </PageLoaderWrapper>
      </div>
    </div>
  </div>
}
