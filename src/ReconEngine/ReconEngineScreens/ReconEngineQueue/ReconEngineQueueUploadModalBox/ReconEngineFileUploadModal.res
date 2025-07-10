open Typography
open LogicUtils

type modalStep = AccountSelection | FileUpload

@react.component
let make = (~showModal, ~setShowModal) => {
  open FormDataUtils
  open APIUtils
  let (currentStep, setCurrentStep) = React.useState(_ => AccountSelection)
  let (selectedAccount, setSelectedAccount) = React.useState(_ => "")
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let showToast = ToastState.useShowToast()
  let (selectedFile, setSelectedFile) = React.useState(_ => None)

  let closeModal = () => {
    setShowModal(_ => false)
    setCurrentStep(_ => AccountSelection)
    setSelectedFile(_ => None)
  }

  let handleNext = () => {
    setCurrentStep(_ => FileUpload)
  }

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

  let onSubmit = async (_, _) => {
    if selectedFile->Option.isNone {
      showToast(~message="Please select a file to upload.", ~toastType=ToastError)
    } else {
      try {
        let file = selectedFile->Option.getExn
        let url = getURL(
          ~entityName=V1(RECON_FILE_UPLOAD),
          ~methodType=Post,
          ~id=Some(selectedAccount),
        )
        let formData = formData()
        append(formData, "file", file)
        append(formData, "file_type", "zurich_adyen")
        let _ = await updateDetails(
          ~bodyFormData=formData,
          url,
          Dict.make()->JSON.Encode.object,
          Post,
          ~contentType=AuthHooks.Unknown,
        )
        showToast(~message="File uploaded successfully.", ~toastType=ToastSuccess)
        closeModal()
      } catch {
      | Exn.Error(_) =>
        showToast(~message="An error occurred while uploading the file.", ~toastType=ToastError)
      }
    }
    Nullable.null
  }

  let customFileInput = (~input as _, ~placeholder as _) => {
    <div>
      <input
        type_="file"
        accept=".csv"
        onChange={ev => ev->handleFileUpload->ignore}
        hidden=true
        id="fileUploadInput"
      />
      <label
        htmlFor="fileUploadInput"
        className="flex flex-col items-center justify-center w-full  border-2 border-dashed border-nd_gray-300 rounded-xl cursor-pointer transition-colors">
        <div className="flex flex-col items-center justify-center py-6 gap-4">
          <Icon name="cloud-upload-alt" size=24 className="text-gray-400" />
          <div className="flex flex-col gap-2 items-center">
            <div className={`${body.lg.semibold} text-nd_gray-700`}>
              {"Choose a file or drag & drop it here"->React.string}
            </div>
            <div className={`${body.md.medium} text-nd_gray-500`}>
              {".csv only | Max size 8 MB"->React.string}
            </div>
          </div>
          <div
            className={`px-4 py-2 border text-nd_gray-600 ${body.md.semibold} rounded-xl hover:bg-nd_gray-100`}>
            {"Browse Files"->React.string}
          </div>
        </div>
      </label>
    </div>
  }

  let generateAccountDropdownOptions = (accountData: JSON.t): array<SelectBox.dropdownOption> => {
    accountData
    ->getArrayFromJson([])
    ->Array.map(item => {
      let accountDict = item->getDictFromJsonObject
      let accountName = accountDict->getString("account_name", "")
      let accountId = accountDict->getString("account_id", "")
      {
        SelectBox.label: accountName,
        value: accountId,
      }
    })
  }

  <Modal
    showModal
    closeOnOutsideClick=false
    setShowModal
    modalHeading="File Upload"
    modalHeadingClass={`${heading.sm.semibold}`}
    modalClass="w-1/3 m-auto"
    childClass="p-0"
    modalHeadingDescriptionElement={<div className={`${body.md.medium} text-nd_gray-400 mt-2`}>
      {"Select the files to Upload."->React.string}
    </div>}>
    {switch currentStep {
    | AccountSelection =>
      <div className="flex flex-col gap-6 px-8 py-4">
        <div>
          <label className={`block ${body.md.medium} text-gray-900 mb-2`}>
            {"Account"->React.string}
            <span className="text-red-500"> {"*"->React.string} </span>
          </label>
          <SelectBox
            input={{
              name: "selectedAccount",
              value: selectedAccount->JSON.Encode.string,
              onChange: ev => {
                let value = ev->Identity.formReactEventToString
                setSelectedAccount(_ => value)
              },
              onBlur: _ => (),
              onFocus: _ => (),
              checked: false,
            }}
            options={ReconEngineQueueSample.account->generateAccountDropdownOptions}
            buttonText="Select Account"
            allowMultiSelect=false
            deselectDisable=true
            fullLength=true
          />
        </div>
        <div className="flex justify-end gap-3 pt-4">
          <Button text="Cancel" buttonType=Secondary onClick={_ => closeModal()} />
          <Button
            text="Next"
            buttonType=Primary
            onClick={_ => handleNext()}
            buttonState={selectedAccount->isNonEmptyString ? Normal : Disabled}
          />
        </div>
      </div>
    | FileUpload =>
      <Form onSubmit key="reconEngineFileUploadForm">
        <div className="flex flex-col gap-6 px-8 py-4">
          <div>
            <label required=true className={`block ${body.md.medium} text-nd_gray-700 mb-6`}>
              {"Upload your file"->React.string}
              <span className="text-red-500"> {"*"->React.string} </span>
            </label>
            <FormRenderer.FieldInputRenderer
              field={FormRenderer.makeInputFieldInfo(
                ~name="file",
                ~customInput=customFileInput,
                ~isRequired=true,
              )}
            />
            {switch selectedFile {
            | Some(file) =>
              <div className="mt-4 p-3 border rounded-lg bg-nd_gray-50">
                <div className="flex items-center gap-2">
                  <Icon name="nd-file" size=20 />
                  <span className={`${body.sm.medium} text-sm text-nd_gray-700`}>
                    {file["name"]->React.string}
                  </span>
                  <span className={`${body.xs.light} text-sm text-nd_gray-500`}>
                    {((file["size"] / 1024)->Int.toString ++ " KB")->React.string}
                  </span>
                </div>
              </div>
            | None => React.null
            }}
          </div>
          <div className="flex justify-end gap-3 pt-4">
            <Button text="Cancel" buttonType=Secondary onClick={_ => closeModal()} />
            <FormRenderer.SubmitButton buttonType=Primary text="Upload" />
          </div>
        </div>
      </Form>
    }}
  </Modal>
}
