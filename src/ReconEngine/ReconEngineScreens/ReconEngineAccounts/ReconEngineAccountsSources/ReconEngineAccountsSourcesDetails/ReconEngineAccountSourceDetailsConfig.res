open LogicUtils
open FormDataUtils
open Typography

@react.component
let make = (~config: ReconEngineTypes.ingestionConfigType, ~isUploading, ~setIsUploading) => {
  let dataDict = config.data->getDictFromJsonObject
  let ingestionType = dataDict->getString("ingestion_type", "")
  let allKeyValuePairs = getKeyValuePairsFromDict(dataDict)
  let keyValuePairs = allKeyValuePairs->Array.filter(((key, _)) => {
    !(key->titleToSnake == "ingestion_type")
  })
  let showToast = ToastState.useShowToast()
  let (selectedFile, setSelectedFile) = React.useState(_ => None)
  let getURL = APIUtils.useGetURL()
  let updateDetails = APIUtils.useUpdateMethod()

  let handleFileUpload = async ev => {
    try {
      let files = ReactEvent.Form.target(ev)["files"]
      switch files[0] {
      | Some(value) =>
        let fileSize = value["size"]
        if fileSize > 10 * 1024 * 1024 {
          showToast(~message="File size should be less than 10MB", ~toastType=ToastError)
          setSelectedFile(_ => None)
        } else {
          setSelectedFile(_ => Some(value))
        }
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
        setIsUploading(_ => false)
      } catch {
      | Exn.Error(_) =>
        showToast(~message="An error occurred while uploading the file.", ~toastType=ToastError)
        setIsUploading(_ => false)
      }
    }
  }

  {
    if ingestionType == "manual" {
      <div className="mt-10">
        <input
          type_="file"
          accept=".csv,.ext"
          onChange={ev => ev->handleFileUpload->ignore}
          hidden=true
          id="fileUploadInput"
        />
        <label
          htmlFor="fileUploadInput"
          className="flex flex-col items-center justify-center w-full border border-dashed border-nd_gray-300 rounded-xl cursor-pointer transition-colors hover:border-nd_gray-400">
          <div className="flex flex-col items-center justify-center py-8 gap-5">
            <Icon name="nd-upload" size=20 className="text-gray-400" />
            <div className="flex flex-col gap-1 items-center">
              <div className={`${body.lg.semibold} text-nd_gray-700`}>
                {"Choose a file or drag & drop it here"->React.string}
              </div>
              <div className={`${body.md.medium} text-nd_gray-500`}>
                {".csv only | Max size 8 MB"->React.string}
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
                <div className="flex items-center gap-2">
                  <Icon name="nd-file" size=16 />
                  <span className={`${body.sm.medium} text-nd_gray-700`}>
                    {file["name"]->React.string}
                  </span>
                  <span className={`${body.xs.light} text-nd_gray-500`}>
                    {((file["size"] / 1024)->Int.toString ++ " KB")->React.string}
                  </span>
                </div>
                <Button
                  text={isUploading ? "Uploading..." : "Upload"}
                  buttonType=Primary
                  onClick={_ => uploadFile()->ignore}
                  buttonState={isUploading ? Loading : Normal}
                  buttonSize=Small
                />
              </div>
            </div>
          </div>
        | None => React.null
        }}
      </div>
    } else {
      <div
        className={`relative p-6 grid lg:grid-cols-4 md:grid-cols-3 grid-cols-2 gap-10 border rounded-xl border-nd_gray-200 my-8 items-center`}>
        <ToolTip
          toolTipPosition=Bottom
          description="This feature is available in prod"
          justifyClass="!absolute !right-3 !top-3"
          toolTipFor={<div
            className={`${body.sm.medium} text-nd_gray-400 flex flex-row items-center cursor-not-allowed gap-2`}>
            <Icon name="nd-edit-pencil" size=16 className="text-nd_primary_blue-500 opacity-60" />
            <span className={`text-nd_primary_blue-500 opacity-60 ${body.md.medium}`}>
              {"Edit"->React.string}
            </span>
          </div>}
        />
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
        <ToolTip
          toolTipPosition=Bottom
          description="This feature is available in prod"
          contentAlign=Default
          toolTipFor={<div>
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
          </div>}
          justifyClass=""
        />
      </div>
    }
  }
}
