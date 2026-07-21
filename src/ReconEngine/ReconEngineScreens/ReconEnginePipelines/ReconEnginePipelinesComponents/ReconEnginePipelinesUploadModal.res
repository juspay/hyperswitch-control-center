open Typography
open LogicUtils
open FormDataUtils
open ReconEnginePipelinesUploadUtils

module StepField = {
  @react.component
  let make = (~step: int, ~label: string, ~isComplete: bool, ~children) => {
    let circleClass = isComplete
      ? "bg-nd_primary_blue-500 text-white"
      : "bg-nd_gray-100 text-nd_gray-500"

    <div className="flex-1 min-w-0">
      <div className="flex items-center gap-2 mb-2">
        <span
          className={`flex items-center justify-center w-6 h-6 shrink-0 rounded-full ${body.xs.semibold} ${circleClass}`}>
          {isComplete
            ? <Icon name="nd-check" size=12 className="text-white" />
            : step->Int.toString->React.string}
        </span>
        <label className={`block ${body.md.medium} text-nd_gray-700`}>
          {label->React.string}
        </label>
      </div>
      {children}
    </div>
  }
}

module UploadDropzone = {
  @react.component
  let make = (~ingestionId: string, ~disabled: bool, ~onUploadSuccess) => {
    open ReconEnginePipelinesTypes

    let showToast = ToastAdapter.useShowToast()
    let (selectedFiles, setSelectedFiles) = React.useState(_ => [])
    let (isUploading, setIsUploading) = React.useState(_ => false)
    let (isDraggingFile, setIsDraggingFile) = React.useState(_ => false)
    let dragDepthRef = React.useRef(0)
    let fileInputRef = React.useRef(Js.Nullable.null)
    let getURL = APIUtils.useGetURL()
    let updateDetails = APIUtils.useUpdateMethod()
    let canSelectFiles = !disabled && !isUploading

    let clearFileInput = () => {
      fileInputRef.current
      ->Nullable.toOption
      ->Option.forEach(elem => elem->DOMUtils.toInputElement->DOMUtils.setInputValue(""))
    }

    let validateAndAddFiles = files => {
      let existingKeys = selectedFiles->Array.map(item => item.fileId)
      let (accepted, rejected, _) = files->Array.reduce(([], [], existingKeys), (
        (accAccepted, accRejected, seenKeys),
        file,
      ) => {
        let existingCount = selectedFiles->Array.length + accAccepted->Array.length
        switch file->classifyFile(~existingCount, ~seenKeys) {
        | Ok(fileName) => (
            accAccepted->Array.concat([{fileId: fileName, file, status: Idle}]),
            accRejected,
            seenKeys->Array.concat([fileName]),
          )
        | Error(reason) => (accAccepted, accRejected->Array.concat([reason]), seenKeys)
        }
      })

      if accepted->isNonEmptyArray {
        setSelectedFiles(prev => prev->Array.concat(accepted))
      }
      if rejected->isNonEmptyArray {
        showToast(~message=rejected->Array.joinWith("; "), ~toastType=ToastError)
      }
    }

    let handleFileUpload = ev => {
      try {
        let files = ReactEvent.Form.target(ev)["files"]->fileListToArray
        if files->isEmptyArray {
          showToast(~message="No file selected. Please choose a file.", ~toastType=ToastError)
        } else {
          validateAndAddFiles(files)
        }
        clearFileInput()
      } catch {
      | _ =>
        showToast(~message="An unexpected error occurred. Please try again.", ~toastType=ToastError)
      }
    }

    let handleFileDrop = ev => {
      open MultipleFileUpload
      ev->ReactEvent.Mouse.preventDefault
      dragDepthRef.current = 0
      setIsDraggingFile(_ => false)
      if canSelectFiles {
        let droppedFiles = ev->dataTransfer->files->fileListToArray
        if droppedFiles->isEmptyArray {
          showToast(~message="No file selected. Please choose a file.", ~toastType=ToastError)
        } else {
          validateAndAddFiles(droppedFiles)
        }
      }
    }

    let uploadOneFile = item => {
      let url = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Post,
        ~hyperswitchReconType=#FILE_UPLOAD,
        ~id=Some(ingestionId),
      )
      let formData = formData()
      append(formData, "file", item.file)
      updateDetails(
        ~bodyFormData=formData,
        url,
        Dict.make()->JSON.Encode.object,
        Post,
        ~contentType=AuthHooks.Unknown,
      )
    }

    let uploadFiles = async () => {
      if selectedFiles->isEmptyArray {
        showToast(~message="Please select a file to upload.", ~toastType=ToastError)
      } else {
        setIsUploading(_ => true)
        let results = await PromiseUtils.allSettledResultPolyfill(
          selectedFiles->Array.map(item => uploadOneFile(item)),
        )
        let failedItems =
          selectedFiles
          ->Array.mapWithIndex((item, index) =>
            switch results[index] {
            | Some(Error(msg)) => Some({...item, status: Failed(msg)})
            | _ => None
            }
          )
          ->Array.filterMap(x => x)
        let failCount = failedItems->Array.length
        let successCount = selectedFiles->Array.length - failCount

        setSelectedFiles(_ => failedItems)
        clearFileInput()
        setIsUploading(_ => false)

        let message = if failCount == 0 {
          `${successCount->Int.toString} file${successCount > 1 ? "s" : ""} uploaded successfully.`
        } else if successCount == 0 {
          `${failCount->Int.toString} file${failCount > 1 ? "s" : ""} failed to upload.`
        } else {
          `${successCount->Int.toString} uploaded, ${failCount->Int.toString} failed.`
        }
        showToast(~message, ~toastType={failCount == 0 ? ToastSuccess : ToastError})

        if failCount == 0 {
          onUploadSuccess()
        }
      }
    }

    let removeSelectedFile = fileId => {
      if !isUploading {
        setSelectedFiles(prev => prev->Array.filter(item => item.fileId !== fileId))
        clearFileInput()
      }
    }

    let dropZoneBorderClass = if disabled || isUploading {
      "border-nd_gray-200 bg-nd_gray-50 shadow-none scale-100"
    } else if isDraggingFile {
      "border-nd_primary_blue-500 bg-blue-50 shadow-sm scale-[1.002]"
    } else {
      "border-nd_gray-300 bg-white shadow-none scale-100"
    }
    let cursorClass = canSelectFiles ? "cursor-pointer" : "cursor-not-allowed"

    <div>
      <input
        ref={fileInputRef->ReactDOM.Ref.domRef}
        type_="file"
        accept=".csv,.ext,.xlsx,.txt"
        multiple=true
        disabled={!canSelectFiles}
        onChange=handleFileUpload
        hidden=true
        id="pipelinesFileUploadInput"
      />
      <label
        htmlFor="pipelinesFileUploadInput"
        onDragEnter={ev => {
          ev->ReactEvent.Mouse.preventDefault
          if canSelectFiles {
            dragDepthRef.current = dragDepthRef.current + 1
            setIsDraggingFile(_ => true)
          }
        }}
        onDragOver={ev => ev->ReactEvent.Mouse.preventDefault}
        onDragLeave={_ => {
          dragDepthRef.current = dragDepthRef.current > 0 ? dragDepthRef.current - 1 : 0
          if dragDepthRef.current == 0 {
            setIsDraggingFile(_ => false)
          }
        }}
        onDrop=handleFileDrop
        className={`flex flex-col items-center justify-center w-full h-full min-h-96 border border-dashed ${dropZoneBorderClass} rounded-xl ${cursorClass} transform-gpu transition-all duration-200 ease-out ${disabled
            ? ""
            : "hover:border-nd_gray-400"}`}>
        <div
          className={`flex flex-col items-center justify-center py-8 gap-5 px-4 text-center ${disabled
              ? "opacity-60"
              : ""}`}>
          <Icon
            name={disabled ? "lock-icon" : "nd-upload"}
            size={disabled ? 24 : 28}
            className="text-nd_gray-400"
          />
          <div className="flex flex-col gap-1 items-center">
            <div
              className={`${body.lg.semibold} ${disabled
                  ? "text-nd_gray-400"
                  : "text-nd_gray-700"}`}>
              {"Choose files or drag & drop them here"->React.string}
            </div>
            <div className={`${body.md.medium} text-nd_gray-500`}>
              {`.csv,.ext,.xlsx,.txt only | Max size 8 MB | Up to ${maxFilesCount->Int.toString} files`->React.string}
            </div>
          </div>
          <div
            className={`px-3 py-2 border text-nd_gray-600 ${body.sm.semibold} rounded-lg ${disabled
                ? ""
                : "hover:bg-nd_gray-100"}`}>
            {"Browse Files"->React.string}
          </div>
        </div>
      </label>
      <RenderIf condition={selectedFiles->isNonEmptyArray}>
        <div className="mt-4 space-y-3">
          {selectedFiles
          ->Array.map(item => {
            <div key={item.fileId} className="p-3 border rounded-lg bg-nd_gray-50">
              <div className="flex items-center justify-between">
                <div className="flex min-w-0 items-center gap-2">
                  <Icon name="nd-file" size=16 />
                  <span className={`${body.sm.medium} text-nd_gray-700 truncate`}>
                    {item.file["name"]->React.string}
                  </span>
                  <span className={`${body.xs.light} text-nd_gray-500 shrink-0`}>
                    {item.file["size"]->formatFileSize->React.string}
                  </span>
                  {switch item.status {
                  | Failed(msg) =>
                    <span className={`${body.xs.light} text-nd_red-500 shrink-0`}>
                      {`Failed: ${msg}`->React.string}
                    </span>
                  | Idle => React.null
                  }}
                </div>
                <Icon
                  onClick={_ => removeSelectedFile(item.fileId)}
                  className={`text-nd_red-500 hover:text-nd_red-700 ml-3 ${!isUploading
                      ? "cursor-pointer"
                      : "cursor-not-allowed"}`}
                  name="nd-delete-dustbin-02"
                  size=16
                />
              </div>
            </div>
          })
          ->React.array}
          <div className="flex justify-end">
            <ACLButton
              text={isUploading
                ? "Uploading..."
                : `Upload (${selectedFiles->Array.length->Int.toString})`}
              buttonType=Primary
              onClick={_ => uploadFiles()->ignore}
              buttonState={isUploading ? Loading : Normal}
              buttonSize=Small
            />
          </div>
        </div>
      </RenderIf>
    </div>
  }
}

module UploadModalBody = {
  @react.component
  let make = (~accountData: array<ReconEngineTypes.accountType>, ~onUploadSuccess) => {
    let getIngestionConfigs = ReconEngineHooks.useGetIngestionConfigs()
    let (selectedAccountId, setSelectedAccountId) = React.useState(_ => "")
    let (selectedIngestionId, setSelectedIngestionId) = React.useState(_ => "")
    let (ingestionConfigs, setIngestionConfigs) = React.useState(_ => [])
    let (configsLoading, setConfigsLoading) = React.useState(_ => false)

    let fetchIngestionConfigs = async accountId => {
      try {
        setConfigsLoading(_ => true)
        let configs = await getIngestionConfigs(~queryParameters=Some(`account_id=${accountId}`))
        setIngestionConfigs(_ => configs)
      } catch {
      | _ => setIngestionConfigs(_ => [])
      }
      setConfigsLoading(_ => false)
    }

    let accountOptions = React.useMemo(() => {
      accountData->getAccountDropdownOptions
    }, [accountData])

    let configOptions = React.useMemo(() => {
      ingestionConfigs->getIngestionConfigDropdownOptions
    }, [ingestionConfigs])

    let getAccountName = accountId =>
      accountData
      ->Array.find(account => account.account_id == accountId)
      ->Option.map(account => account.account_name)
      ->Option.getOr("Select Account")

    let getConfigName = ingestionId =>
      ingestionConfigs
      ->Array.find(config => config.ingestion_id == ingestionId)
      ->Option.map(config => config.name)
      ->Option.getOr("Select Ingestion Config")

    let accountInput: ReactFinalForm.fieldRenderPropsInput = {
      name: "account_id",
      onBlur: _ => (),
      onChange: ev => {
        let accountId = ev->Identity.formReactEventToString
        setSelectedAccountId(_ => accountId)
        setSelectedIngestionId(_ => "")
        setIngestionConfigs(_ => [])
        if accountId->isNonEmptyString {
          fetchIngestionConfigs(accountId)->ignore
        }
      },
      onFocus: _ => (),
      value: selectedAccountId->JSON.Encode.string,
      checked: true,
    }

    let configInput: ReactFinalForm.fieldRenderPropsInput = {
      name: "ingestion_id",
      onBlur: _ => (),
      onChange: ev => setSelectedIngestionId(_ => ev->Identity.formReactEventToString),
      onFocus: _ => (),
      value: selectedIngestionId->JSON.Encode.string,
      checked: true,
    }

    let canUpload = selectedAccountId->isNonEmptyString && selectedIngestionId->isNonEmptyString

    <div className="flex flex-col gap-6">
      <div className="flex gap-6">
        <StepField step=1 label="Account" isComplete={selectedAccountId->isNonEmptyString}>
          <SelectBoxAdapter.BaseDropdown
            allowMultiSelect=false
            buttonText={getAccountName(selectedAccountId)}
            input=accountInput
            options=accountOptions
            hideMultiSelectButtons=true
            deselectDisable=true
            searchable=true
            fullLength=true
          />
        </StepField>
        <StepField
          step=2 label="Ingestion Config" isComplete={selectedIngestionId->isNonEmptyString}>
          {if configsLoading {
            <div className="flex items-center gap-2 h-10 px-3 border border-nd_gray-150 rounded-lg">
              <Icon name="nd-loading" size=14 className="text-nd_gray-400 animate-spin" />
              <span className={`${body.sm.regular} text-nd_gray-500`}>
                {"Loading configs..."->React.string}
              </span>
            </div>
          } else {
            <SelectBoxAdapter.BaseDropdown
              allowMultiSelect=false
              buttonText={selectedAccountId->isEmptyString
                ? "Select an account first"
                : getConfigName(selectedIngestionId)}
              input=configInput
              options=configOptions
              hideMultiSelectButtons=true
              deselectDisable=true
              searchable=true
              fullLength=true
              disableSelect={selectedAccountId->isEmptyString}
            />
          }}
          <RenderIf
            condition={selectedAccountId->isNonEmptyString &&
            !configsLoading &&
            configOptions->isEmptyArray}>
            <p className={`${body.sm.regular} text-nd_gray-500 mt-2`}>
              {"No manual ingestion configs found for this account."->React.string}
            </p>
          </RenderIf>
        </StepField>
      </div>
      <div className="flex flex-col border-t border-nd_gray-150 pt-6">
        <label className={`block ${body.md.medium} text-nd_gray-700 mb-2`}>
          {"File"->React.string}
        </label>
        <UploadDropzone ingestionId=selectedIngestionId disabled={!canUpload} onUploadSuccess />
      </div>
    </div>
  }
}

@react.component
let make = (~accountData: array<ReconEngineTypes.accountType>, ~onClose: unit => unit) => {
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let (showModal, setShowModal) = React.useState(_ => false)
  let authorization = userHasAccess(~groupAccess=UserManagementTypes.ReconSourcesManage)

  let handleSetShowModal = (updater: bool => bool) => {
    let next = updater(showModal)
    setShowModal(_ => next)
    if !next {
      onClose()
    }
  }

  <>
    <ACLButton
      text="Upload"
      leftIcon={CustomIcon(<Icon name="nd-upload" size=16 />)}
      buttonType=Primary
      buttonSize=Small
      authorization
      onClick={_ => setShowModal(_ => true)}
    />
    <RenderIf condition=showModal>
      <Modal
        showModal
        setShowModal=handleSetShowModal
        closeOnOutsideClick=true
        modalHeading="Upload File"
        modalHeadingDescription="Select an account and ingestion config, then upload a file."
        modalClass="w-full max-w-4xl mx-auto my-auto"
        childClass="p-6">
        <UploadModalBody accountData onUploadSuccess={() => handleSetShowModal(_ => false)} />
      </Modal>
    </RenderIf>
  </>
}
