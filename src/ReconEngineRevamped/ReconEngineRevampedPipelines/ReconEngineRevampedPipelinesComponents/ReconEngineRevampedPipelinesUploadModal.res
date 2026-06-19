open Typography
open LogicUtils
open FormDataUtils

let maxFileSizeBytes = 8 * 1024 * 1024

let isSupportedFileType = (fileName: string) =>
  [".csv", ".ext", ".xlsx"]->Array.some(ext => fileName->String.toLowerCase->String.endsWith(ext))

let formatFileSize = (bytes: int) => {
  if bytes < 1024 {
    `${bytes->Int.toString} B`
  } else if bytes < 1024 * 1024 {
    `${(bytes / 1024)->Int.toString} KB`
  } else {
    let mb = bytes->Int.toFloat /. (1024.0 *. 1024.0)
    `${mb->Float.toFixedWithPrecision(~digits=1)} MB`
  }
}

type ingestionSource = {
  ingestion_id: string,
  name: string,
  account_id: string,
  account_name: string,
}

@react.component
let make = (
  ~showModal: bool,
  ~setShowModal: (bool => bool) => unit,
  ~onUploadSuccess: unit => unit,
) => {
  let showToast = ToastState.useShowToast()
  let getURL = APIUtils.useGetURL()
  let fetchDetails = APIUtils.useGetMethod()
  let updateDetails = APIUtils.useUpdateMethod()

  let (sources, setSources) = React.useState((_): array<ingestionSource> => [])
  let (loadingSources, setLoadingSources) = React.useState(_ => true)
  let (selectedSource, setSelectedSource) = React.useState(_ => None)
  let (selectedFile, setSelectedFile) = React.useState(_ => None)
  let (isDragging, setIsDragging) = React.useState(_ => false)
  let (isUploading, setIsUploading) = React.useState(_ => false)
  let dragDepthRef = React.useRef(0)
  let fileInputRef = React.useRef(Js.Nullable.null)

  let clearFileInput = () =>
    fileInputRef.current
    ->Nullable.toOption
    ->Option.forEach(elem => elem->DOMUtils.toInputElement->DOMUtils.setInputValue(""))

  let fetchSources = async () => {
    try {
      setLoadingSources(_ => true)
      let configUrl = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Get,
        ~hyperswitchReconType=#INGESTION_CONFIG,
      )
      let accountsUrl = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Get,
        ~hyperswitchReconType=#ACCOUNTS_LIST,
      )
      let configRes = await fetchDetails(configUrl)
      let accountsRes = await fetchDetails(accountsUrl)

      let accountMap: Dict.t<string> = Dict.make()
      accountsRes
      ->getArrayDataFromJson(d => (
        d->getString("account_id", ""),
        d->getString("account_name", ""),
      ))
      ->Array.forEach(((id, name)) => accountMap->Dict.set(id, name))

      let manualSources =
        configRes
        ->getArrayDataFromJson(d => {
          let data = d->getDictfromDict("data")
          let ingestionType = data->getString("ingestion_type", "")
          if ingestionType == "manual" {
            Some({
              ingestion_id: d->getString("ingestion_id", ""),
              name: d->getString("name", ""),
              account_id: d->getString("account_id", ""),
              account_name: accountMap->Dict.get(d->getString("account_id", ""))->Option.getOr(""),
            })
          } else {
            None
          }
        })
        ->Array.filterMap(x => x)

      setSources(_ => manualSources)
      setLoadingSources(_ => false)
    } catch {
    | _ =>
      setLoadingSources(_ => false)
      showToast(~message="Failed to load sources.", ~toastType=ToastError)
    }
  }

  React.useEffect(() => {
    if showModal {
      fetchSources()->ignore
    }
    None
  }, [showModal])

  let reset = () => {
    setSelectedSource(_ => None)
    setSelectedFile(_ => None)
    clearFileInput()
    setIsUploading(_ => false)
    setIsDragging(_ => false)
    dragDepthRef.current = 0
  }

  let close = () => {
    reset()
    setShowModal(_ => false)
  }

  let selectFile = file => {
    let fileName = file["name"]->String.toLowerCase
    if !isSupportedFileType(fileName) {
      showToast(~message="Please select a .csv, .ext, or .xlsx file.", ~toastType=ToastError)
    } else if file["size"] > maxFileSizeBytes {
      showToast(~message="File size must not exceed 8 MB.", ~toastType=ToastError)
    } else {
      setSelectedFile(_ => Some(file))
    }
  }

  let handleFileDrop = ev => {
    ev->ReactEvent.Mouse.preventDefault
    dragDepthRef.current = 0
    setIsDragging(_ => false)
    let droppedFiles = ev->MultipleFileUpload.dataTransfer->MultipleFileUpload.files
    switch droppedFiles[0] {
    | Some(file) => selectFile(file)
    | None => ()
    }
  }

  let handleFileInput = ev => {
    switch ReactEvent.Form.target(ev)["files"][0] {
    | Some(file) => selectFile(file)
    | None => ()
    }
  }

  let uploadFile = async () => {
    switch (selectedSource, selectedFile) {
    | (Some(source), Some(file)) =>
      try {
        setIsUploading(_ => true)
        let url = getURL(
          ~entityName=V1(HYPERSWITCH_RECON),
          ~methodType=Post,
          ~hyperswitchReconType=#FILE_UPLOAD,
          ~id=Some(source.ingestion_id),
        )
        let fd = formData()
        append(fd, "file", file)
        let _ = await updateDetails(
          ~bodyFormData=fd,
          url,
          Dict.make()->JSON.Encode.object,
          Post,
          ~contentType=AuthHooks.Unknown,
        )
        showToast(~message="File uploaded successfully.", ~toastType=ToastSuccess)
        close()
        onUploadSuccess()
      } catch {
      | _ =>
        showToast(~message="Upload failed. Please try again.", ~toastType=ToastError)
        setIsUploading(_ => false)
      }
    | _ => ()
    }
  }

  let transitionClass = showModal ? "translate-x-0" : "translate-x-full"

  let dropZoneBorderClass = isDragging
    ? "border-blue-500 bg-blue-50"
    : "border-nd_gray-300 bg-nd_gray-50 hover:border-nd_gray-400 hover:bg-white"

  let sourceOptions = sources->Array.map(s => {
    SelectBox.label: s.account_name->isNonEmptyString ? `${s.name} (${s.account_name})` : s.name,
    value: s.ingestion_id,
  })

  let selectedId = selectedSource->Option.map(s => s.ingestion_id)->Option.getOr("")

  let sourceInput = ReactFinalForm.makeInputRecord(selectedId->JSON.Encode.string, ev => {
    let v = ev->Identity.genericTypeToJson->getStringFromJson("")
    setSelectedSource(_ => sources->Array.find(s => s.ingestion_id == v))
  })

  <>
    <RenderIf condition=showModal>
      <div className="fixed inset-0 bg-black/20 z-40 transition-opacity" onClick={_ => close()} />
    </RenderIf>
    <div
      className={`fixed right-0 top-0 h-full w-[480px] bg-white shadow-2xl rounded-l-2xl overflow-hidden transform transition-all duration-300 ease-in-out flex flex-col z-50 ${transitionClass}`}>
      <div className="flex items-center justify-between px-6 py-5 border-b border-nd_gray-150">
        <div className="flex items-center gap-3">
          <Icon name="nd-upload-file" size=18 className="text-nd_gray-600" />
          <p className={`${heading.xs.semibold} text-nd_gray-800`}>
            {"Upload a File"->React.string}
          </p>
        </div>
        <div
          className="w-8 h-8 flex items-center justify-center rounded-lg hover:bg-nd_gray-100 cursor-pointer transition-colors"
          onClick={_ => close()}>
          <Icon name="nd-cross" size=14 className="text-nd_gray-500" />
        </div>
      </div>
      <div className="flex-1 overflow-y-auto px-6 py-5 flex flex-col gap-6">
        <div>
          <p className={`${body.sm.semibold} text-nd_gray-600 mb-2 uppercase tracking-wide`}>
            {"Source"->React.string}
          </p>
          {if loadingSources {
            <Shimmer styleClass="h-10 w-full rounded-lg" />
          } else if sources->Array.length == 0 {
            <p className={`${body.sm.regular} text-nd_gray-400`}>
              {"No manual upload sources configured."->React.string}
            </p>
          } else {
            <SelectBoxAdapter
              input=sourceInput
              options=sourceOptions
              allowMultiSelect=false
              isDropDown=true
              deselectDisable=false
              buttonText="Select a source"
              fullLength=true
            />
          }}
        </div>
        {switch selectedSource {
        | None => React.null
        | Some(_) =>
          <div>
            <p className={`${body.sm.semibold} text-nd_gray-600 mb-2 uppercase tracking-wide`}>
              {"File"->React.string}
            </p>
            <input
              ref={fileInputRef->ReactDOM.Ref.domRef}
              type_="file"
              accept=".csv,.ext,.xlsx"
              onChange=handleFileInput
              hidden=true
              id="pipelinesFileUploadInput"
            />
            <label
              htmlFor="pipelinesFileUploadInput"
              onDragEnter={ev => {
                ev->ReactEvent.Mouse.preventDefault
                dragDepthRef.current = dragDepthRef.current + 1
                setIsDragging(_ => true)
              }}
              onDragOver={ev => ev->ReactEvent.Mouse.preventDefault}
              onDragLeave={_ => {
                dragDepthRef.current = dragDepthRef.current > 0 ? dragDepthRef.current - 1 : 0
                if dragDepthRef.current == 0 {
                  setIsDragging(_ => false)
                }
              }}
              onDrop=handleFileDrop
              className={`flex flex-col items-center justify-center w-full border-2 border-dashed ${dropZoneBorderClass} rounded-xl cursor-pointer transition-all duration-150 min-h-[200px]`}>
              <div className="flex flex-col items-center gap-3 py-10 pointer-events-none">
                <Icon name="nd-upload" size=28 className="text-nd_gray-300" />
                <div className="flex flex-col items-center gap-1 text-center px-4">
                  <p className={`${body.md.semibold} text-nd_gray-700`}>
                    {"Drag & drop a file here"->React.string}
                  </p>
                  <p className={`${body.sm.regular} text-nd_gray-400`}>
                    {"or click to browse"->React.string}
                  </p>
                  <p className={`${body.xs.regular} text-nd_gray-400 mt-1`}>
                    {".csv · .ext · .xlsx — max 8 MB"->React.string}
                  </p>
                </div>
              </div>
            </label>
            {switch selectedFile {
            | None => React.null
            | Some(file) =>
              <div
                className="mt-3 px-3 py-2.5 border border-nd_gray-200 rounded-lg bg-white flex items-center justify-between">
                <div className="flex items-center gap-2 min-w-0">
                  <Icon name="nd-file" size=15 className="text-nd_gray-500 flex-shrink-0" />
                  <span className={`${body.sm.medium} text-nd_gray-700 truncate`}>
                    {file["name"]->React.string}
                  </span>
                  <span className={`${body.xs.regular} text-nd_gray-400 shrink-0`}>
                    {file["size"]->formatFileSize->React.string}
                  </span>
                </div>
                <Icon
                  name="nd-delete-dustbin-02"
                  size=15
                  className="text-nd_red-400 hover:text-nd_red-600 cursor-pointer ml-3 flex-shrink-0"
                  onClick={_ => {
                    setSelectedFile(_ => None)
                    clearFileInput()
                  }}
                />
              </div>
            }}
          </div>
        }}
      </div>
      <div className="px-6 py-4 border-t border-nd_gray-150 flex justify-end gap-3 bg-white">
        <Button
          text="Cancel"
          buttonType=Secondary
          buttonSize=Small
          onClick={_ => close()}
          maxButtonWidth="!w-fit"
        />
        <Button
          text={isUploading ? "Uploading..." : "Upload"}
          buttonType=Primary
          buttonSize=Small
          buttonState={selectedSource->Option.isNone || selectedFile->Option.isNone || isUploading
            ? Disabled
            : Normal}
          onClick={_ => uploadFile()->ignore}
          maxButtonWidth="!w-fit"
        />
      </div>
    </div>
  </>
}
