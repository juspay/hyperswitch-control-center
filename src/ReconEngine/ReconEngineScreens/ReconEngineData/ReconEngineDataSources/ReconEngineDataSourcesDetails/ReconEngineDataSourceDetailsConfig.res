open LogicUtils
open FormDataUtils
open Typography
open ReconEngineDataSourcesUtils

@react.component
let make = (~config: ReconEngineTypes.ingestionConfigType, ~isUploading, ~setIsUploading) => {
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let dataDict = config.data->getDictFromJsonObject
  let ingestionType = dataDict->getString("ingestion_type", "")
  let allKeyValuePairs = getKeyValuePairsFromDict(dataDict)
  let keyValuePairs = allKeyValuePairs->Array.filter(((key, _)) => {
    !(key->titleToSnake == "ingestion_type")
  })
  let showToast = ToastAdapter.useShowToast()
  let (selectedFile, setSelectedFile) = React.useState(_ => None)
  let (isDraggingFile, setIsDraggingFile) = React.useState(_ => false)
  let dragDepthRef = React.useRef(0)
  let fileInputRef = React.useRef(Js.Nullable.null)
  let getURL = APIUtils.useGetURL()
  let updateDetails = APIUtils.useUpdateMethod()

  let clearFileInput = () => {
    fileInputRef.current
    ->Nullable.toOption
    ->Option.forEach(elem => elem->DOMUtils.toInputElement->DOMUtils.setInputValue(""))
  }

  let selectFile = file => {
    let fileName = file["name"]->String.toLowerCase
    let fileSize = file["size"]
    let hasSupportedExtension = isSupportedFileType(fileName)
    if !hasSupportedExtension {
      showToast(~message="Please select a .csv, .ext, or .xlsx file.", ~toastType=ToastError)
      setSelectedFile(_ => None)
      clearFileInput()
    } else if fileSize > maxFileSizeBytes {
      showToast(~message="File size should not exceed 8 MB", ~toastType=ToastError)
      setSelectedFile(_ => None)
      clearFileInput()
    } else {
      setSelectedFile(_ => Some(file))
    }
  }

  let handleFileUpload = ev => {
    try {
      let files = ReactEvent.Form.target(ev)["files"]
      switch files[0] {
      | Some(value) => selectFile(value)
      | None =>
        showToast(~message="No file selected. Please choose a file.", ~toastType=ToastError)
        setSelectedFile(_ => None)
      }
    } catch {
    | _ =>
      showToast(~message="An unexpected error occurred. Please try again.", ~toastType=ToastError)
      setSelectedFile(_ => None)
    }
  }

  let handleFileDrop = (ev, hasManageAccess) => {
    open MultipleFileUpload

    ev->ReactEvent.Mouse.preventDefault
    dragDepthRef.current = 0
    setIsDraggingFile(_ => false)
    if hasManageAccess {
      let droppedFiles = ev->dataTransfer->files
      switch droppedFiles[0] {
      | Some(file) => selectFile(file)
      | None => showToast(~message="No file selected. Please choose a file.", ~toastType=ToastError)
      }
    }
  }

  let uploadFile = async () => {
    switch selectedFile {
    | None => showToast(~message="Please select a file to upload.", ~toastType=ToastError)
    | Some(file) =>
      try {
        setIsUploading(_ => true)
        let url = getURL(
          ~entityName=V1(HYPERSWITCH_RECON),
          ~methodType=Post,
          ~hyperswitchReconType=#FILE_UPLOAD,
          ~id=Some(config.ingestion_id),
        )
        let formData = formData()
        append(formData, "file", file)
        let _ = await updateDetails(
          ~bodyFormData=formData,
          url,
          Dict.make()->JSON.Encode.object,
          Post,
          ~contentType=AuthHooks.Unknown,
        )
        showToast(~message="File uploaded successfully.", ~toastType=ToastSuccess)
        setSelectedFile(_ => None)
        clearFileInput()
        setIsUploading(_ => false)
      } catch {
      | Exn.Error(_) =>
        showToast(~message="An error occurred while uploading the file.", ~toastType=ToastError)
        clearFileInput()
        setIsUploading(_ => false)
      }
    }
  }

  let removeSelectedFile = () => {
    if !isUploading {
      setSelectedFile(_ => None)
      clearFileInput()
    }
  }

  let handleUploadKeyDown = ev => {
    if ReactEvent.Keyboard.key(ev) == "Enter" && !isUploading {
      ev->ReactEvent.Keyboard.preventDefault
      uploadFile()->ignore
    }
  }

  React.useEffect(() => {
    switch selectedFile {
    | Some(_) =>
      Window.addEventListener("keydown", handleUploadKeyDown)
      Some(() => Window.removeEventListener("keydown", handleUploadKeyDown))
    | None => None
    }
  }, (selectedFile, isUploading))

  {
    if ingestionType == "manual" {
      let hasManageAccess =
        userHasAccess(~groupAccess=UserManagementTypes.ReconSourcesManage) === Access
      let cursorPointerClass = hasManageAccess ? "cursor-pointer" : "cursor-not-allowed"
      let dropZoneBorderClass =
        isDraggingFile && hasManageAccess
          ? "border-nd_primary_blue-500 bg-blue-50 shadow-sm scale-[1.002]"
          : "border-nd_gray-300 bg-white shadow-none scale-100"
      <div className="mt-10">
        <input
          ref={fileInputRef->ReactDOM.Ref.domRef}
          type_="file"
          accept=".csv,.ext,.xlsx"
          disabled={!hasManageAccess}
          onChange=handleFileUpload
          hidden=true
          id="fileUploadInput"
        />
        <label
          htmlFor="fileUploadInput"
          onDragEnter={ev => {
            ev->ReactEvent.Mouse.preventDefault
            if hasManageAccess {
              dragDepthRef.current = dragDepthRef.current + 1
              setIsDraggingFile(_ => true)
            }
          }}
          onDragOver={ev => ev->ReactEvent.Mouse.preventDefault}
          onDragLeave={_ => {
            if hasManageAccess {
              dragDepthRef.current = dragDepthRef.current > 0 ? dragDepthRef.current - 1 : 0
              if dragDepthRef.current == 0 {
                setIsDraggingFile(_ => false)
              }
            }
          }}
          onDrop={ev => handleFileDrop(ev, hasManageAccess)}
          className={`flex flex-col items-center justify-center w-full border border-dashed ${dropZoneBorderClass} rounded-xl ${cursorPointerClass} transform-gpu transition-all duration-200 ease-out hover:border-nd_gray-400`}>
          <div className="flex flex-col items-center justify-center py-8 gap-5">
            <Icon name="nd-upload" size=20 className="text-gray-400" />
            <div className="flex flex-col gap-1 items-center">
              <div className={`${body.lg.semibold} text-nd_gray-700`}>
                {"Choose a file or drag & drop it here"->React.string}
              </div>
              <div className={`${body.md.medium} text-nd_gray-500`}>
                {".csv,.ext,.xlsx only | Max size 8 MB"->React.string}
              </div>
            </div>
            <div
              className={`px-3 py-2 border text-nd_gray-600 ${body.sm.semibold} rounded-lg hover:bg-nd_gray-100`}>
              {"Browse Files"->React.string}
            </div>
          </div>
        </label>
        {switch selectedFile {
        | Some(file) =>
          <div className="mt-4 space-y-3">
            <div className="p-3 border rounded-lg bg-nd_gray-50">
              <div className="flex items-center justify-between">
                <div className="flex min-w-0 items-center gap-2">
                  <Icon name="nd-file" size=16 />
                  <span className={`${body.sm.medium} text-nd_gray-700 truncate`}>
                    {file["name"]->React.string}
                  </span>
                  <span className={`${body.xs.light} text-nd_gray-500 shrink-0`}>
                    {file["size"]->formatFileSize->React.string}
                  </span>
                </div>
                <div
                  className="flex items-center gap-3 ml-3"
                  onKeyDown={ev => ev->ReactEvent.Keyboard.stopPropagation}>
                  <Icon
                    onClick={_ => removeSelectedFile()}
                    className={`text-nd_red-500 hover:text-nd_red-700 ${!isUploading
                        ? "cursor-pointer"
                        : "cursor-not-allowed"}`}
                    name="nd-delete-dustbin-02"
                    size=16
                  />
                  <ACLButton
                    authorization={userHasAccess(
                      ~groupAccess=UserManagementTypes.ReconSourcesManage,
                    )}
                    text={isUploading ? "Uploading..." : "Upload"}
                    buttonType=Primary
                    onClick={_ => uploadFile()->ignore}
                    buttonState={isUploading ? Loading : Normal}
                    buttonSize=Small
                  />
                </div>
              </div>
            </div>
          </div>
        | None => React.null
        }}
      </div>
    } else {
      <div
        className={`relative p-6 grid lg:grid-cols-4 md:grid-cols-3 grid-cols-2 gap-10 border rounded-xl border-nd_gray-200 my-8 items-center`}>
        <div
          className={`${body.sm.medium} text-nd_gray-400 flex flex-row items-center cursor-not-allowed gap-2 absolute right-3 top-3`}>
          <Icon name="nd-edit-pencil" size=16 className="text-nd_primary_blue-500 opacity-60" />
          <span className={`text-nd_primary_blue-500 opacity-60 ${body.md.medium}`}>
            {"Edit"->React.string}
          </span>
        </div>
        <div>
          <p className={`${body.md.medium} text-nd_gray-400`}>
            {"Configuration Type"->React.string}
          </p>
          <div className="flex items-center gap-2 mt-2">
            <p className={`${body.lg.medium} text-nd_gray-600`}>
              {ingestionType->String.toUpperCase->React.string}
            </p>
            <TableUtils.LabelCell
              labelColor={config.is_active ? LabelGreen : LabelRed}
              text={config.is_active ? "Active" : "Inactive"}
            />
          </div>
        </div>
        {keyValuePairs
        ->Array.map(((key, value)) => {
          <div key={key}>
            <p className={`${body.md.medium} text-nd_gray-400`}> {key->React.string} </p>
            <p className={`${body.lg.medium} text-nd_gray-600 mt-2 truncate`}>
              {value->React.string}
            </p>
          </div>
        })
        ->React.array}
        <div>
          <p className={`${body.md.medium} text-nd_gray-400`}> {"Last Sync"->React.string} </p>
          {if config.last_synced_at->LogicUtils.isNonEmptyString {
            <p className={`${body.lg.medium} text-nd_gray-600 mt-2`}>
              <TableUtils.DateCell timestamp={config.last_synced_at} textAlign=Left />
            </p>
          } else {
            <span className={`${body.md.medium} text-nd_gray-600 mt-2`}> {"-"->React.string} </span>
          }}
        </div>
        <div>
          <p className={`${body.md.medium} text-nd_gray-400`}> {"File Upload"->React.string} </p>
          <div className="mt-2">
            <input
              disabled=true
              type_="file"
              accept=".csv,.ext"
              onChange={ev => ev->handleFileUpload->ignore}
              hidden=true
              id="fileUploadInput"
            />
            <label htmlFor="fileUploadInput" className="cursor-not-allowed">
              <div className="flex flex-row items-center gap-2 cursor-not-allowed">
                <Icon name="nd-upload" size=16 className="text-nd_primary_blue-500 opacity-60" />
                <div className={`${body.lg.medium} text-nd_primary_blue-500 opacity-60`}>
                  {"Upload File"->React.string}
                </div>
              </div>
            </label>
          </div>
        </div>
      </div>
    }
  }
}
