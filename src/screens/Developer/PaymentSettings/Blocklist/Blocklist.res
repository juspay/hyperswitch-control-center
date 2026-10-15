open BlocklistUtils
open LogicUtils
open APIUtils
open Typography

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
      setScreenState(_ => PageLoaderWrapper.Success)
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

  let generateExport = async () => {
    try {
      setExportButtonState(_ => Button.Loading)
      let url = getURL(~entityName=V1(BLOCKLIST_EXPORT), ~methodType=Post)
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

  let onGenerateExportClick = _ => {
    mixpanelEvent(~eventName="blocklist_generate_export")
    generateExport()->ignore
  }

  let showLatestJobs = () => {
    offset === 0 ? fetchJobs()->ignore : setOffset(_ => 0)
  }

  <>
    <PaymentMethodBlocking />
    <RenderIf condition={featureFlagDetails.devBlocklist}>
      <hr className="my-8 border-nd_gray-150" />
      <PageUtils.PageHeading
        title="Blocklist"
        subTitle="Block card BINs and card fingerprints for this profile. Payments that match a blocked entry are declined."
        customTitleStyle={`!${body.lg.semibold} text-nd_gray-700`}
        customSubTitleStyle={`${body.md.medium} text-nd_gray-500`}
        showPermLink=false
      />
      <div className="flex flex-col gap-8">
        <BlocklistCountSummary />
        <div className="max-w-3xl flex flex-col">
          <BlocklistHelper.Step
            stepNumber=1
            title="Add entries"
            description="Choose how you want to add entries. Both options add to the same blocklist.">
            <TabsBinding defaultValue="individual" variant=Boxed size=Md>
              <TabsBinding.List variant=Boxed size=Md fitContent=true>
                <TabsBinding.Trigger value="individual" variant=Boxed size=Md>
                  {"Individual"->React.string}
                </TabsBinding.Trigger>
                <TabsBinding.Trigger value="bulk" variant=Boxed size=Md>
                  {"Bulk upload (CSV)"->React.string}
                </TabsBinding.Trigger>
              </TabsBinding.List>
              <TabsBinding.Content value="individual" className="pt-4">
                <BlocklistEntryCard
                  operation=AddBlocklistEntry
                  title="Block a single entry"
                  description="Best for a few entries. Blocked immediately."
                  buttonText="Block"
                  eventName="blocklist_add_entry"
                />
              </TabsBinding.Content>
              <TabsBinding.Content value="bulk" className="pt-4">
                <BlocklistBulkUpload onUploaded=showLatestJobs />
              </TabsBinding.Content>
            </TabsBinding>
          </BlocklistHelper.Step>
          <BlocklistHelper.Step
            stepNumber=2
            title="Check or unblock"
            description="Confirm whether a value is blocked, or remove an entry you no longer want to block.">
            <TabsBinding defaultValue="check" variant=Boxed size=Md>
              <TabsBinding.List variant=Boxed size=Md fitContent=true>
                <TabsBinding.Trigger value="check" variant=Boxed size=Md>
                  {"Check"->React.string}
                </TabsBinding.Trigger>
                <TabsBinding.Trigger value="unblock" variant=Boxed size=Md>
                  {"Unblock"->React.string}
                </TabsBinding.Trigger>
              </TabsBinding.List>
              <TabsBinding.Content value="check" className="pt-4">
                <BlocklistLookupCard />
              </TabsBinding.Content>
              <TabsBinding.Content value="unblock" className="pt-4">
                <BlocklistEntryCard
                  operation=DeleteBlocklistEntry
                  title="Unblock a single entry"
                  description="Payments using this card BIN or fingerprint will no longer be declined by the blocklist."
                  buttonText="Unblock"
                  eventName="blocklist_delete_entry"
                />
              </TabsBinding.Content>
            </TabsBinding>
          </BlocklistHelper.Step>
          <BlocklistHelper.Step
            stepNumber=3
            title="Export or reuse"
            description="Download this profile's blocklist, or apply it to other profiles."
            isLast=true>
            <BlocklistHelper.Panel>
              <BlocklistHelper.PanelHeader
                title="Export as CSV"
                description="Generates a CSV of every entry on this profile. Download it from Background jobs once it completes."
                action={<ACLButton
                  text="Generate Export"
                  buttonType=Secondary
                  onClick=onGenerateExportClick
                  buttonState=exportButtonState
                  authorization={userHasAccess(~groupAccess=AccountManage)}
                />}
              />
              <hr className="border-nd_gray-150" />
              <BlocklistCloneCard onCloneStarted=showLatestJobs />
              <BlocklistHelper.BackgroundJobNote
                description="Exports and clones run in the background. Track them under Background jobs below."
              />
            </BlocklistHelper.Panel>
          </BlocklistHelper.Step>
        </div>
        <div className="flex flex-col gap-4">
          <div>
            <h2 className={`text-nd_gray-700 ${body.lg.semibold}`}>
              {"Background jobs"->React.string}
            </h2>
            <p className={`text-nd_gray-500 mt-1 ${body.md.medium}`}>
              {"CSV uploads, exports and clones appear here. Refresh a job to see its latest status, and download exports once they complete."->React.string}
            </p>
          </div>
          <PageLoaderWrapper screenState sectionHeight="h-40">
            {jobs->isNonEmptyArray
              ? <LoadedTable
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
              : <div
                  className={`max-w-3xl border border-dashed border-nd_gray-300 rounded-lg bg-nd_gray-25 p-6 text-center text-nd_gray-500 ${body.md.medium}`}>
                  {"No background jobs yet. Bulk uploads, exports and clones will show up here."->React.string}
                </div>}
          </PageLoaderWrapper>
        </div>
      </div>
    </RenderIf>
  </>
}
