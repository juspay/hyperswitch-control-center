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
  let {profileId} = React.useContext(UserInfoProvider.defaultContext).getCommonSessionDetails()
  let showToast = ToastAdapter.useShowToast()
  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let resultsPerPage = 10
  let defaultValue: LoadedTable.pageDetails = {offset: 0, resultsPerPage}
  let pageDetailDict = Recoil.useRecoilValueFromAtom(LoadedTable.table_pageDetails)
  let pageDetail = pageDetailDict->getValueFromDict("Blocklist", defaultValue)
  let (jobs, setJobs) = React.useState(_ => [])
  let (totalCount, setTotalCount) = React.useState(_ => 0)
  let (offset, setOffset) = React.useState(_ => pageDetail.offset)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)

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

  let showLatestJobs = () => {
    offset === 0 ? fetchJobs()->ignore : setOffset(_ => 0)
  }

  let blockingTabs: array<Tabs.tab> = [Payment, Payout]->Array.map((transactionType): Tabs.tab => {
    title: (transactionType :> string)->capitalizeString,
    renderContent: () =>
      <BlocklistTransactionSection transactionType onExportStarted=showLatestJobs />,
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
      <hr className="my-8 border-nd_gray-150" />
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
    </RenderIf>
  </>
}
