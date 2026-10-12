open BlocklistUtils
open FormDataUtils
open LogicUtils
open APIUtils
open Typography

@react.component
let make = (~onUploaded) => {
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod(~showErrorToast=false)
  let showToast = ToastAdapter.useShowToast()
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let (selectedFile, setSelectedFile) = React.useState(_ => None)
  let (uploadButtonState, setUploadButtonState) = React.useState(_ => Button.Normal)
  let inputRef = React.useRef(Nullable.null)
  let fileSelectionTokenRef = React.useRef(0)

  let clearFileInput = () => {
    inputRef.current
    ->getOptionalFromNullable
    ->Option.forEach(elem => elem->DOMUtils.toInputElement->DOMUtils.setInputValue(""))
  }

  let rejectFile = message => {
    clearFileInput()
    setSelectedFile(_ => None)
    showToast(~message, ~toastType=ToastError)
  }

  let validateFileContents = (~file, ~selectionToken, event) => {
    if fileSelectionTokenRef.current === selectionToken {
      let fileContents = ReactEvent.Form.target(event)["result"]
      switch fileContents->getBlocklistCsvDataRowCountError {
      | Some(errorMessage) => rejectFile(errorMessage)
      | None => setSelectedFile(_ => Some(file))
      }
    }
  }

  let readFileContents = (~file, ~selectionToken) => {
    let fileReader = FileReader.reader
    fileReader.onload = event => validateFileContents(~file, ~selectionToken, event)
    fileReader.onerror = _ => {
      if fileSelectionTokenRef.current === selectionToken {
        rejectFile("Unable to read the CSV file.")
      }
    }
    fileReader->FileReader.readFileAsText(file)
  }

  let handleFileChange = ev => {
    fileSelectionTokenRef.current = fileSelectionTokenRef.current + 1
    let selectionToken = fileSelectionTokenRef.current
    let files = ReactEvent.Form.target(ev)["files"]
    switch files[0] {
    | None => setSelectedFile(_ => None)
    | Some(file) =>
      switch file->getBlocklistCsvFileError {
      | Some(errorMessage) => rejectFile(errorMessage)
      | None => readFileContents(~file, ~selectionToken)
      }
    }
  }

  let triggerFilePicker = _ => {
    inputRef.current->getOptionalFromNullable->Option.forEach(elem => elem->DOMUtils.click())
  }

  let resetSelectedFile = _ => {
    fileSelectionTokenRef.current = fileSelectionTokenRef.current + 1
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
        onUploaded()
      } catch {
      | Exn.Error(e) =>
        let errorMessage =
          Exn.message(e)
          ->Option.getOr("Failed to upload blocklist CSV")
          ->parseBlocklistErrorMessage
        showToast(~message=errorMessage, ~toastType=ToastError)
      }
      setUploadButtonState(_ => Button.Normal)
    }
  }

  let onUploadClick = _ => {
    mixpanelEvent(~eventName="blocklist_upload_csv")
    uploadFile()->ignore
  }

  let selectedFileName = selectedFile->getFileName
  let selectedFileSize = selectedFile->getFileSize->formatFileSize

  <BlocklistHelper.Panel>
    <BlocklistHelper.PanelHeader
      title="Upload a CSV"
      description="Each row is one entry: a type (generic_card_bin or fingerprint) and its value. Start from the sample file to get the format right."
      action={<Button
        text="Download Sample File"
        buttonType=Secondary
        onClick=downloadSampleFile
        leftIcon={CustomIcon(<Icon name="nd-download-bar-down" size=15 />)}
      />}
    />
    <input
      type_="file"
      accept=".csv"
      className="hidden"
      ref={inputRef->ReactDOM.Ref.domRef}
      onChange=handleFileChange
    />
    {switch selectedFile {
    | Some(_) =>
      <>
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
            name="trash-alt" className="cursor-pointer text-nd_gray-500" onClick=resetSelectedFile
          />
        </div>
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
      </>
    | None =>
      <div
        className="border border-dashed border-nd_gray-300 rounded-lg bg-nd_gray-25 p-5 flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div className="flex items-center gap-4 min-w-0">
          <div
            className="h-11 w-11 shrink-0 rounded-lg border border-nd_gray-200 bg-white flex items-center justify-center">
            <Icon name="nd-upload" size=22 className="text-nd_gray-600" />
          </div>
          <div className="min-w-0">
            <p className={`text-nd_gray-700 ${body.md.medium}`}>
              {`Up to ${maxBlocklistCsvDataRowsLabel} rows, ${maxBlocklistCsvFileSizeLabel} max`->React.string}
            </p>
            <p className={`text-nd_gray-500 mt-1 ${body.sm.medium}`}>
              {"Only .csv files are supported. Larger files cannot be processed."->React.string}
            </p>
          </div>
        </div>
        <ACLButton
          text="Choose File"
          buttonType=Secondary
          onClick=triggerFilePicker
          authorization={userHasAccess(~groupAccess=AccountManage)}
        />
      </div>
    }}
    <BlocklistHelper.BackgroundJobNote
      description="Uploads are processed in the background. Track progress under Background jobs below."
    />
  </BlocklistHelper.Panel>
}
