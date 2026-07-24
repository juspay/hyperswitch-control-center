open BlocklistTypes
open BlocklistUtils
open FormDataUtils
open LogicUtils
open APIUtils
open Typography

@react.component
let make = () => {
  let getURL = useGetURL()
  let fetchDetails = useGetMethod(~showErrorToast=false)
  let updateDetails = useUpdateMethod(~showErrorToast=false)
  let showToast = ToastAdapter.useShowToast()
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let resultsPerPage = 20
  let defaultValue: LoadedTable.pageDetails = {offset: 0, resultsPerPage}
  let pageDetailDict = Recoil.useRecoilValueFromAtom(LoadedTable.table_pageDetails)
  let pageDetail = pageDetailDict->Dict.get("Blocklist")->Option.getOr(defaultValue)
  let (jobs, setJobs) = React.useState(_ => [])
  let (totalCount, setTotalCount) = React.useState(_ => 0)
  let (offset, setOffset) = React.useState(_ => pageDetail.offset)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (selectedFile, setSelectedFile) = React.useState(_ => None)
  let (uploadButtonState, setUploadButtonState) = React.useState(_ => Button.Normal)
  let inputRef = React.useRef(Nullable.null)

  let clearFileInput = () => {
    inputRef.current
    ->Nullable.toOption
    ->Option.forEach(elem => elem->DOMUtils.toInputElement->DOMUtils.setInputValue(""))
  }

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
      setJobs(_ => mappedJobs)
      setTotalCount(_ => response->getTotalCountFromResponse(mappedJobs->Array.length))
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

  React.useEffect(() => {
    fetchJobs()->ignore
    None
  }, [offset])

  let handleFileChange = ev => {
    let files = ReactEvent.Form.target(ev)["files"]
    switch files[0] {
    | Some(file) =>
      if file->isValidBlocklistCsvFile {
        if file->isBlocklistCsvFileSizeAllowed {
          setSelectedFile(_ => Some(file))
        } else {
          clearFileInput()
          setSelectedFile(_ => None)
          showToast(~message="CSV file size should be less than 5 MB.", ~toastType=ToastError)
        }
      } else {
        clearFileInput()
        setSelectedFile(_ => None)
        showToast(~message="Please upload a valid CSV file.", ~toastType=ToastError)
      }
    | None => setSelectedFile(_ => None)
    }
  }

  let triggerFilePicker = _ => {
    inputRef.current->Nullable.toOption->Option.forEach(elem => elem->DOMUtils.click())
  }

  let resetSelectedFile = _ => {
    setSelectedFile(_ => None)
    clearFileInput()
  }

  let downloadSampleFile = _ => {
    DownloadUtils.download(
      ~fileName="blocklist_sample.csv",
      ~content=sampleCsv,
      ~fileType="text/csv",
    )
  }

  let uploadFile = async () => {
    switch selectedFile {
    | None => showToast(~message="Please select a CSV file to upload.", ~toastType=ToastError)
    | Some(file) =>
      try {
        setUploadButtonState(_ => Button.Loading)
        let formData = formData()
        append(formData, "file", file)
        let url = getURL(~entityName=V1(BLOCKLIST_BATCH), ~methodType=Post)
        let response = await updateDetails(
          ~bodyFormData=formData,
          url,
          Dict.make()->JSON.Encode.object,
          Post,
          ~contentType=AuthHooks.Unknown,
        )
        let responseDict = response->getDictFromJsonObject
        let jobId = responseDict->getString("job_id", "")
        let message =
          jobId->isNonEmptyString
            ? `Blocklist CSV uploaded. Job ID: ${jobId}`
            : "Blocklist CSV uploaded."
        showToast(~message, ~toastType=ToastSuccess)
        setSelectedFile(_ => None)
        clearFileInput()
        if offset === 0 {
          await fetchJobs()
        } else {
          setOffset(_ => 0)
        }
      } catch {
      | Exn.Error(e) =>
        let errorMessage = Exn.message(e)->Option.getOr("Failed to upload blocklist CSV")
        showToast(~message=errorMessage, ~toastType=ToastError)
      }
      setUploadButtonState(_ => Button.Normal)
    }
  }

  let selectedFileName = selectedFile->getFileName
  let selectedFileSize = selectedFile->getFileSize->formatFileSize

  let onUploadClick = _ => {
    mixpanelEvent(~eventName="blocklist_upload_csv")
    uploadFile()->ignore
  }

  let emptyState = <NoDataFound message="No blocklist batch uploads found" renderType=Painting />

  <>
    <PageUtils.PageHeading
      title="Blocklist" subTitle="Upload blocklist CSV files and track batch processing status."
    />
    <div className="flex flex-col gap-6">
      <div className="max-w-3xl">
        <section className="border border-nd_gray-200 rounded-lg bg-white p-5 flex flex-col gap-4">
          <div className="flex items-start justify-between gap-4">
            <div>
              <h2 className={`text-nd_gray-700 ${body.lg.semibold}`}>
                {"Upload CSV"->React.string}
              </h2>
              <p className={`text-nd_gray-500 mt-1 ${body.md.medium}`}>
                {"Upload a CSV file to create an asynchronous blocklist batch job."->React.string}
              </p>
            </div>
            <Button
              text="Download Sample File"
              buttonType=Secondary
              onClick=downloadSampleFile
              leftIcon={CustomIcon(<Icon name="nd-download-bar-down" size=15 />)}
            />
          </div>
          <input
            type_="file"
            accept=".csv"
            className="hidden"
            ref={inputRef->ReactDOM.Ref.domRef}
            onChange=handleFileChange
          />
          <RenderIf condition={selectedFile->Option.isSome}>
            <div
              className="border border-nd_gray-200 rounded-lg bg-nd_gray-25 p-4 flex items-center justify-between gap-4">
              <div className="flex items-center gap-3 min-w-0">
                <Icon name="nd-file" size=28 className="text-nd_gray-600" />
                <div className="min-w-0">
                  <p className={`text-nd_gray-700 truncate ${body.md.medium}`}>
                    {selectedFileName->React.string}
                  </p>
                  <p className={`text-nd_gray-400 ${body.sm.medium}`}>
                    {selectedFileSize->React.string}
                  </p>
                </div>
              </div>
              <Icon
                name="trash-alt"
                className="cursor-pointer text-nd_gray-500"
                onClick=resetSelectedFile
              />
            </div>
          </RenderIf>
          <RenderIf condition={selectedFile->Option.isNone}>
            <div
              className="border border-dashed border-nd_gray-300 rounded-lg bg-nd_gray-25 p-5 flex flex-col sm:flex-row sm:items-center justify-between gap-4">
              <div className="flex items-center gap-4 min-w-0">
                <div
                  className="h-11 w-11 shrink-0 rounded-lg border border-nd_gray-200 bg-white flex items-center justify-center">
                  <Icon name="nd-upload" size=22 className="text-nd_gray-600" />
                </div>
                <div className="min-w-0">
                  <p className={`text-nd_gray-700 ${body.md.medium}`}>
                    {"Upload a CSV file up to 5 MB"->React.string}
                  </p>
                  <p className={`text-nd_gray-500 mt-1 ${body.sm.medium}`}>
                    {"Only .csv files are supported for blocklist batch uploads."->React.string}
                  </p>
                </div>
              </div>
              <Button text="Choose File" buttonType=Secondary onClick=triggerFilePicker />
            </div>
          </RenderIf>
          <RenderIf condition={selectedFile->Option.isSome}>
            <div className="flex justify-end">
              <ACLButton
                text="Upload"
                buttonType=Primary
                onClick=onUploadClick
                buttonState=uploadButtonState
                authorization={userHasAccess(~groupAccess=AccountManage)}
                leftIcon={CustomIcon(<Icon name="nd-upload" size=15 className="text-white" />)}
              />
            </div>
          </RenderIf>
        </section>
      </div>
      <PageLoaderWrapper screenState sectionHeight="h-60-vh">
        <LoadedTable
          title="Blocklist"
          hideTitle=true
          actualData={jobs->Array.map(Nullable.make)}
          totalResults=totalCount
          resultsPerPage
          offset
          setOffset
          currentFetchCount={jobs->Array.length}
          entity={BlocklistTableEntity.blocklistEntity(~onRefreshJob=refreshJob)}
          showSerialNumber=true
          showAutoScroll=true
          dataNotFoundComponent=emptyState
        />
      </PageLoaderWrapper>
    </div>
  </>
}
