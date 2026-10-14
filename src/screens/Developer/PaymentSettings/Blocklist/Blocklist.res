open BlocklistUtils
open BlocklistTypes
open LogicUtils
open APIUtils
open Typography
open BlocklistHelper

@react.component
let make = () => {
  let getURL = useGetURL()
  let fetchDetails = useGetMethod(~showErrorToast=false)
  let updateDetails = useUpdateMethod(~showErrorToast=false)
  let {profileId} = React.useContext(UserInfoProvider.defaultContext).getCommonSessionDetails()
  let showToast = ToastAdapter.useShowToast()
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let resultsPerPage = 10
  let defaultValue: LoadedTable.pageDetails = {offset: 0, resultsPerPage}
  let pageDetailDict = Recoil.useRecoilValueFromAtom(LoadedTable.table_pageDetails)
  let pageDetail = pageDetailDict->getValueFromDict("Blocklist", defaultValue)
  let (jobs, setJobs) = React.useState(_ => [])
  let (totalCount, setTotalCount) = React.useState(_ => 0)
  let (offset, setOffset) = React.useState(_ => pageDetail.offset)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (exportButtonState, setExportButtonState) = React.useState(_ => Button.Normal)
  let (isBlockingGuardEnabled, setIsBlockingGuardEnabled) = React.useState(_ => false)
  let (blockingGuardDraft, setBlockingGuardDraft) = React.useState(_ => false)

  let fetchJobs = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let queryParameters = `limit=${resultsPerPage->Int.toString}&offset=${offset->Int.toString}`
      let url = getURL(
        ~entityName=V1(BLOCKLIST_BATCH),
        ~methodType=Get,
        ~queryParameters=Some(queryParameters),
      )
      let response = await fetchDetails(url)
      let mappedJobs = response->getJobsFromResponse
      let total = response->getTotalCountFromResponse(mappedJobs->Array.length)
      let offsetRows = Array.make(~length=offset, Dict.make())->Array.map(itemToObjMapper)
      let jobs = offsetRows->Array.concat(mappedJobs)
      if total <= offset {
        setOffset(_ => 0)
      }
      setJobs(_ => jobs)
      setTotalCount(_ => total)
      setScreenState(_ => total > 0 ? PageLoaderWrapper.Success : PageLoaderWrapper.Custom)
    } catch {
    | Exn.Error(e) =>
      let errorMessage = Exn.message(e)->Option.getOr("Failed to fetch blocklist jobs")
      setJobs(_ => [])
      setTotalCount(_ => 0)
      setScreenState(_ => PageLoaderWrapper.Error(errorMessage))
    }
  }

  let refreshJob = async jobId => {
    try {
      let url = getURL(~entityName=V1(BLOCKLIST_BATCH), ~methodType=Get, ~id=Some(jobId))
      let response = await fetchDetails(url)
      let updatedJob = response->getDictFromJsonObject->itemToObjMapper
      setJobs(prev =>
        prev->Array.map(job => {
          job.job_id === jobId ? updatedJob : job
        })
      )
      showToast(~message=`Refreshed ${jobId}`, ~toastType=ToastSuccess)
    } catch {
    | Exn.Error(e) =>
      let errorMessage = Exn.message(e)->Option.getOr("Failed to refresh job status")
      showToast(~message=errorMessage, ~toastType=ToastError)
    }
  }

  let downloadExport = async jobId => {
    try {
      let url = getURL(~entityName=V1(BLOCKLIST_BATCH), ~methodType=Get, ~id=Some(jobId))
      let response = await fetchDetails(url)
      switch response->getDictFromJsonObject->getString("download_url", "")->getNonEmptyString {
      | Some(downloadUrl) => downloadUrl->DownloadUtils.downloadFromUrl
      | None =>
        showToast(~message="Download link unavailable. Please try again.", ~toastType=ToastError)
      }
    } catch {
    | Exn.Error(e) =>
      let errorMessage = Exn.message(e)->Option.getOr("Failed to download blocklist export")
      showToast(~message=errorMessage, ~toastType=ToastError)
    }
  }

  React.useEffect(() => {
    if featureFlagDetails.devBlocklist {
      fetchJobs()->ignore
    }
    None
  }, (offset, profileId))

  let generateExport = async transactionType => {
    try {
      setExportButtonState(_ => Button.Loading)
      let url = getURL(
        ~entityName=V1(BLOCKLIST_EXPORT),
        ~methodType=Post,
        ~queryParameters=Some(transactionType->blocklistTransactionTypeQueryParam),
      )
      let response = await updateDetails(url, Dict.make()->JSON.Encode.object, Post)
      let fileName = response->getDictFromJsonObject->getString("file_name", "")
      let message =
        fileName->isNonEmptyString
          ? `Blocklist export started. File: ${fileName}`
          : "Blocklist export started."
      showToast(~message, ~toastType=ToastSuccess)
      offset === 0 ? await fetchJobs() : setOffset(_ => 0)
    } catch {
    | Exn.Error(e) =>
      let errorMessage =
        Exn.message(e)
        ->Option.getOr("Failed to generate blocklist export")
        ->parseBlocklistErrorMessage
      showToast(~message=errorMessage, ~toastType=ToastError)
    }
    setExportButtonState(_ => Button.Normal)
  }

  let onGenerateExportClick = transactionType => {
    mixpanelEvent(
      ~eventName="blocklist_generate_export",
      ~metadata=[
        ("transaction_type", transactionType->blocklistTransactionTypeToString->JSON.Encode.string),
      ]->getJsonFromArrayOfJson,
    )
    generateExport(transactionType)->ignore
  }

  let onBlockingGuardUpdate = _ => {
    setIsBlockingGuardEnabled(_ => blockingGuardDraft)
  }

  let showLatestJobs = () => {
    offset === 0 ? fetchJobs()->ignore : setOffset(_ => 0)
  }

  let checkOrUnblockTabs = transactionType => {
    let tabs: array<Tabs.tab> = [
      {
        title: "Check",
        renderContent: () =>
          <div className="pt-4">
            <BlocklistLookupCard transactionType />
          </div>,
      },
      {
        title: "Unblock",
        renderContent: () =>
          <div className="pt-4">
            <BlocklistEntryCard
              operation=DeleteBlocklistEntry
              transactionType
              title="Unblock a single entry"
              description="Transactions using this card BIN or fingerprint will no longer be declined by this blocklist."
              buttonText="Unblock"
              eventName="blocklist_delete_entry"
            />
          </div>,
      },
    ]
    tabs
  }

  let paymentBlocklistGuard =
    <div className="flex flex-col gap-4">
      <Panel>
        <PanelHeader
          title="Payment blocklist"
          description="When on, payments that match an entry in this list are declined."
          action={<div className="flex items-center gap-4">
            <SwitchAdapter
              isSelected=blockingGuardDraft
              setIsSelected={value => setBlockingGuardDraft(_ => value)}
              boolCustomClass="rounded-lg"
            />
            <ACLButton
              text="Update"
              buttonType=Primary
              buttonSize=Small
              buttonState={blockingGuardDraft === isBlockingGuardEnabled
                ? Button.Disabled
                : Button.Normal}
              onClick=onBlockingGuardUpdate
              authorization={userHasAccess(~groupAccess=AccountManage)}
            />
          </div>}
        />
      </Panel>
      <RenderIf condition={!isBlockingGuardEnabled}>
        <AlertV2Binding
          alertType=Neutral
          slot={{
            slot: <Icon name="nd-toast-info" size=20 className="text-nd_primary_blue-450" />,
          }}
          heading="Payment blocklist is off"
          description="Entries are saved but not applied to payments until you turn it on."
        />
      </RenderIf>
    </div>

  let blocklistSection = (transactionType: blocklistTransactionType) => {
    let transactionLabel = transactionType->blocklistTransactionTypeToLabel->String.toLowerCase
    <div className="flex flex-col gap-8 mt-6">
      <RenderIf condition={transactionType === Payment}>
        <div className="max-w-3xl"> {paymentBlocklistGuard} </div>
      </RenderIf>
      <BlocklistCountSummary transactionType />
      <div className="max-w-3xl flex flex-col">
        <Step
          stepNumber=1
          title="Add an entry"
          description={`Blocks a single card BIN or fingerprint for ${transactionLabel}. To add many at once, use Bulk upload below.`}>
          <BlocklistEntryCard
            operation=AddBlocklistEntry
            transactionType
            title="Block a single entry"
            description="Best for a few entries. Blocked immediately."
            buttonText="Block"
            eventName="blocklist_add_entry"
          />
        </Step>
        <Step
          stepNumber=2
          title="Check or unblock"
          description="Confirm whether a value is blocked, or remove an entry you no longer want to block.">
          <Tabs tabs={checkOrUnblockTabs(transactionType)} variant=Boxed size=Md fitContent=true />
        </Step>
        <Step
          stepNumber=3
          title="Export"
          description={`Download this profile's ${transactionLabel} blocklist.`}
          isLast=true>
          <Panel>
            <PanelHeader
              title="Export as CSV"
              description={`Generates a CSV of every ${transactionLabel} entry on this profile. Download it from Background jobs once it completes.`}
              action={<ACLButton
                text="Generate Export"
                buttonType=Secondary
                onClick={_ => onGenerateExportClick(transactionType)}
                buttonState=exportButtonState
                authorization={userHasAccess(~groupAccess=AccountManage)}
              />}
            />
          </Panel>
        </Step>
      </div>
    </div>
  }

  let sharedBlocklistSection =
    <div className="max-w-3xl flex flex-col gap-4">
      <div>
        <h2 className={`text-nd_gray-700 ${body.lg.semibold}`}>
          {"Bulk upload and copy"->React.string}
        </h2>
        <p className={`text-nd_gray-500 mt-1 ${body.md.medium}`}>
          {"These apply to both payment and payout blocklists."->React.string}
        </p>
      </div>
      <BlocklistBulkUpload onUploaded=showLatestJobs />
      <Panel>
        <BlocklistCloneCard onCloneStarted=showLatestJobs />
        <BackgroundJobNote
          description="Clones run in the background. Track them under Background jobs below."
        />
      </Panel>
    </div>

  let backgroundJobsSection =
    <div className="flex flex-col gap-4">
      <div>
        <h2 className={`text-nd_gray-700 ${body.lg.semibold}`}>
          {"Background jobs"->React.string}
        </h2>
        <p className={`text-nd_gray-500 mt-1 ${body.md.medium}`}>
          {"CSV uploads, exports and clones appear here. Refresh a job to see its latest status, and download exports once they complete."->React.string}
        </p>
      </div>
      <PageLoaderWrapper
        screenState
        sectionHeight="h-40"
        customUI={<NewAnalyticsHelper.NoData
          height="h-40"
          message="No background jobs yet. Bulk uploads, exports and clones will show up here."
        />}>
        <LoadedTable
          title="Blocklist"
          hideTitle=true
          actualData={jobs->Array.map(Nullable.make)}
          totalResults=totalCount
          resultsPerPage
          offset
          setOffset
          currentFetchCount={jobs->Array.length}
          entity={BlocklistTableEntity.blocklistEntity(
            ~onRefreshJob=refreshJob,
            ~onDownloadExport=downloadExport,
          )}
          showSerialNumber=true
          showAutoScroll=true
          showResultsPerPageSelector=false
        />
      </PageLoaderWrapper>
    </div>

  let blockingTabs: array<Tabs.tab> = [Payment, Payout]->Array.map((transactionType): Tabs.tab => {
    title: transactionType->blocklistTransactionTypeToLabel,
    renderContent: () => blocklistSection(transactionType),
  })

  <>
    <PaymentMethodBlocking />
    <RenderIf condition={featureFlagDetails.devBlocklist}>
      <hr className="my-8 border-nd_gray-150" />
      <div className="mb-4">
        <h2 className={`text-nd_gray-700 ${body.lg.semibold}`}> {"Blocklist"->React.string} </h2>
        <p className={`text-nd_gray-500 mt-1 ${body.md.medium}`}>
          {"Block card BINs and card fingerprints for this profile. Payments and payouts keep separate lists."->React.string}
        </p>
      </div>
      <Tabs tabs=blockingTabs size=Md />
      <hr className="my-8 border-nd_gray-150" />
      {sharedBlocklistSection}
      <hr className="my-8 border-nd_gray-150" />
      {backgroundJobsSection}
    </RenderIf>
  </>
}
