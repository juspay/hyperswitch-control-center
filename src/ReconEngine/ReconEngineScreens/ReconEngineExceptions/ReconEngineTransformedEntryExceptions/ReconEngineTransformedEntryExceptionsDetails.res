@react.component
let make = (~id) => {
  open LogicUtils
  open ReconEngineUtils
  open ReconEngineTransformedEntryExceptionsHelper
  open ReconEngineHooks
  open ReconEngineTransformedEntryExceptionsUtils
  open APIUtils

  let getProcessingEntries = useGetProcessingEntries()
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod(~showErrorToast=false)
  let showToast = ToastAdapter.useShowToast()
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()

  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (reprocessButtonState, setReprocessButtonState) = React.useState(_ => Button.Normal)
  let (currentTransformedEntryDetails, setCurrentTransformedEntryDetails) = React.useState(_ =>
    Dict.make()->processingItemToObjMapper
  )
  let (updatedTransformedEntryDetails, setUpdatedTransformedEntryDetails) = React.useState(_ =>
    Dict.make()->processingItemToObjMapper
  )
  let (allTransformedEntryDetails, setAllTransformedEntryDetails) = React.useState(_ => [
    Dict.make()->processingItemToObjMapper,
  ])

  let getTransformedEntryDetails = async _ => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let transformedEntriesList = await getProcessingEntries(
        ~queryParameters=Some(`staging_entry_id=${id}`),
      )
      transformedEntriesList->Array.sort(sortByVersion)
      let currentTransformedEntry =
        transformedEntriesList->getValueFromArray(0, Dict.make()->processingItemToObjMapper)
      setCurrentTransformedEntryDetails(_ => currentTransformedEntry)
      setUpdatedTransformedEntryDetails(_ => currentTransformedEntry)
      setAllTransformedEntryDetails(_ => transformedEntriesList)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch transformed entry details"))
    }
  }

  React.useEffect(() => {
    getTransformedEntryDetails()->ignore
    None
  }, [])

  let onReprocess = async () => {
    try {
      setReprocessButtonState(_ => Button.Loading)
      let url = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~hyperswitchReconType=#PROCESS_STAGING_ENTRY,
        ~methodType=Post,
        ~id=Some(currentTransformedEntryDetails.id),
      )
      let res = await updateDetails(url, Dict.make()->JSON.Encode.object, Post)
      switch res->getDictFromJsonObject->getOptionString("failure") {
      | Some(reason) => {
          setReprocessButtonState(_ => Button.Normal)
          showToast(~message=reason, ~toastType=ToastError)
        }
      | None => {
          showToast(~message="Transformed entry processed successfully", ~toastType=ToastSuccess)
          RescriptReactRouter.replace(
            GlobalVars.appendDashboardPath(~url="/v1/recon-engine/exceptions/transformed-entries"),
          )
        }
      }
    } catch {
    | Exn.Error(e) => {
        setReprocessButtonState(_ => Button.Normal)
        let err = Exn.message(e)->Option.getOr("")
        showToast(
          ~message=err
          ->safeParse
          ->getDictFromJsonObject
          ->getString("message", "Failed to re-process the entry. Please try again."),
          ~toastType=ToastError,
        )
      }
    }
  }

  let tabs: array<Tabs.tab> = React.useMemo(() => {
    open Tabs
    [
      {
        title: "Entry Details",
        renderContent: () =>
          <ReconEngineTransformedEntryExceptionEntry
            currentTransformedEntryDetails
            setUpdatedTransformedEntryDetails
            updatedTransformedEntryDetails
          />,
      },
      {
        title: "Audit Trail",
        renderContent: () => <AuditTrail allTransactionDetails=allTransformedEntryDetails />,
      },
    ]
  }, (allTransformedEntryDetails, currentTransformedEntryDetails, updatedTransformedEntryDetails))

  <>
    <div className="flex flex-col gap-4">
      <BreadCrumbNavigation
        path=[
          {
            title: "Transformed Entry Exceptions",
            link: `/v1/recon-engine/exceptions/transformed-entries`,
          },
        ]
        currentPageTitle=id
      />
      <div className="flex flex-row justify-between items-center mb-4">
        <PageUtils.PageHeading title="Transformed Entry Detail" customHeadingStyle="!mb-0" />
        <RenderIf condition={currentTransformedEntryDetails.status->isReprocessAvailable}>
          <ACLButton
            text="Re-process"
            buttonType=Primary
            buttonSize=Medium
            buttonState=reprocessButtonState
            authorization={userHasAccess(~groupAccess=ReconExceptionsManage)}
            onClick={_ => onReprocess()->ignore}
          />
        </RenderIf>
      </div>
    </div>
    <PageLoaderWrapper
      screenState
      customUI={<NoDataFound
        message="Payment does not exists in out record" renderType=NotFound
      />}>
      <div className="flex flex-col gap-4">
        <TransformedEntryDetailsInfo
          currentProcessingEntryDetails={currentTransformedEntryDetails}
          detailsFields=[StagingEntryId, Status, AccountName, EffectiveAt]
        />
        <Tabs tabs />
      </div>
    </PageLoaderWrapper>
  </>
}
