@react.component
let make = (~showModal, ~setShowModal, ~onSuccess) => {
  open APIUtils
  open LogicUtils
  open HierarchicalConfigTypes
  open HierarchicalConfigUtils
  open Typography
  open AddCertificateModalUtils

  let getURL = useGetURL()
  let updateDetails = useUpdateMethod(~showErrorToast=false)
  let showToast = ToastAdapter.useShowToast()

  let (step, setStep) = React.useState(_ => Download)
  let (csrState, setCsrState) = React.useState(_ => NotGenerated)
  let (selectedFile, setSelectedFile) = React.useState(_ => None)
  let (submitState, setSubmitState) = React.useState(_ => Button.Disabled)
  let (errorMessage, setErrorMessage) = React.useState(_ => None)
  let inputRef = React.useRef(Nullable.null)

  let resourceId = getResourceId(csrState)

  let generateAndDownload = async () => {
    try {
      setErrorMessage(_ => None)
      setCsrState(_ => Generating)
      let url = getURL(~entityName=V1(RESOURCES), ~methodType=Post)
      let payload = [("type", applePayCertificateResourceType->JSON.Encode.string)]->Dict.fromArray
      let response = await updateDetails(url, payload->JSON.Encode.object, Post)
      let dict = response->getDictFromJsonObject
      let generatedCsr =
        dict
        ->getDictfromDict("data")
        ->getDictfromDict(applePayCertificateResourceType)
        ->getString("csr", "")
      setCsrState(_ => Generated({resourceId: dict->getString("id", ""), csr: generatedCsr}))
      DownloadUtils.download(~fileName=csrFileName, ~content=generatedCsr, ~fileType=csrFileType)
    } catch {
    | Exn.Error(e) =>
      setErrorMessage(_ => Some(
        getFormattedErrorMessage(
          ~error=e,
          ~fallback="Failed to generate certificate request.",
          ~retryHint="Please try again.",
        ),
      ))
      setCsrState(_ => NotGenerated)
    }
  }

  let downloadCsr = _ => {
    switch resourceId {
    | Some(_) =>
      DownloadUtils.download(
        ~fileName=csrFileName,
        ~content=getCsr(csrState),
        ~fileType=csrFileType,
      )
    | None => generateAndDownload()->ignore
    }
  }

  let clearFileInput = () =>
    inputRef.current
    ->getOptionalFromNullable
    ->Option.forEach(elem => elem->DOMUtils.toInputElement->DOMUtils.setInputValue(""))

  let handleFileChange = ev => {
    let target = ReactEvent.Form.target(ev)
    switch target["files"][0] {
    | Some(file) =>
      let fileReader = FileReader.reader
      fileReader.onload = event => {
        let dataUrl = ReactEvent.Form.target(event)["result"]
        let base64Certificate = dataUrl->String.split(",")->Array.get(1)->Option.getOr("")
        setSelectedFile(_ => Some({name: file["name"], base64: base64Certificate}))
        setSubmitState(_ => Normal)
        setErrorMessage(_ => None)
      }
      fileReader.onerror = _ => {
        showToast(
          ~message="Unable to read the selected file. Please try again.",
          ~toastType=ToastError,
        )
      }
      fileReader.readAsDataURL(file)
    | None => ()
    }
    clearFileInput()
  }

  let triggerFilePicker = _ =>
    inputRef.current->getOptionalFromNullable->Option.forEach(elem => elem->DOMUtils.click())

  let removeSelectedFile = _ => {
    setSelectedFile(_ => None)
    setSubmitState(_ => Disabled)
  }

  let submitCertificate = async () => {
    switch (resourceId, selectedFile) {
    | (Some(id), Some({base64: certificate})) =>
      try {
        setErrorMessage(_ => None)
        setSubmitState(_ => Loading)
        let url = getURL(
          ~entityName=V1(RESOURCES),
          ~methodType=Put,
          ~id=Some(id),
          ~idType=Some(applePayCertificateResourceType),
        )
        let payload = [("certificate", certificate->JSON.Encode.string)]->Dict.fromArray
        let _ = await updateDetails(url, payload->JSON.Encode.object, Put)
        showToast(~message="Certificate uploaded successfully", ~toastType=ToastSuccess)
        onSuccess()
      } catch {
      | Exn.Error(e) =>
        setErrorMessage(_ => Some(
          getFormattedErrorMessage(
            ~error=e,
            ~fallback="Failed to upload certificate.",
            ~retryHint="Try uploading again.",
          ),
        ))
        setSelectedFile(_ => None)
        setSubmitState(_ => Disabled)
      }
    | _ => ()
    }
  }

  let errorBanner = switch errorMessage {
  | Some(message) =>
    <AlertV2Binding
      alertType=Error
      slot={{slot: <Icon name="nd-cross" size=20 className="text-nd_red-500" />}}
      heading="Something went wrong"
      description=message
    />
  | None => React.null
  }

  let downloadContent =
    <div className="flex flex-col gap-4">
      {errorBanner}
      <p className={`${body.md.regular} text-nd_gray-700`}>
        {"Use this Certificate Signing Request to obtain a secure certificate from Apple, which enables you to accept Apple Pay."->React.string}
      </p>
      <p className={`${body.md.regular} text-nd_gray-700`}>
        {"Once the CSR file is saved, we'll guide you through exchanging it for a certificate on Apple's developer portal."->React.string}
      </p>
      <Button
        text="Download File"
        buttonType=Primary
        buttonSize=Small
        onClick=downloadCsr
        buttonState={getGenerateState(csrState)}
        customButtonStyle="w-fit"
      />
    </div>

  let uploadContent =
    <div className="flex flex-col gap-4">
      {errorBanner}
      <ol
        className={`${body.md.regular} text-nd_gray-700 list-decimal list-inside flex flex-col gap-2`}>
        <li> {"Upload your new certificate file below and click Submit."->React.string} </li>
        <li>
          {"Return to this page in Apple's Developer Center, select the Merchant ID, and activate the Apple Pay Payment Processing Certificate you just created."->React.string}
        </li>
      </ol>
      <p className={`${body.md.regular} text-nd_gray-700`}>
        {"Continue with the guide to finish integrating Apple Pay into your app."->React.string}
      </p>
      <input
        ref={inputRef->ReactDOM.Ref.domRef}
        type_="file"
        accept=".cer"
        className="hidden"
        onChange=handleFileChange
      />
      {switch selectedFile {
      | Some({name}) =>
        <div
          className="border border-nd_gray-200 rounded-lg bg-nd_gray-25 p-4 flex items-center justify-between gap-4">
          <span className={`${body.md.regular} text-nd_gray-700`}> {name->React.string} </span>
          <Icon
            name="trash-alt" className="cursor-pointer text-nd_gray-500" onClick=removeSelectedFile
          />
        </div>
      | None =>
        <Button
          text="Choose File"
          buttonType=Secondary
          onClick=triggerFilePicker
          customButtonStyle="w-fit"
        />
      }}
    </div>

  <Modal
    showModal
    setShowModal
    modalHeading="Add New Apple Pay Certificate"
    modalHeadingDescription={getStepSubHeading(step)}
    modalDescriptionClass={`${body.md.regular} text-nd_gray-500 mt-1`}
    childClass="p-6"
    borderBottom=true
    modalClass="w-full max-w-xl mx-auto my-auto dark:!bg-nd_gray-800"
    alignModal="items-center justify-center"
    closeOnOutsideClick=true>
    <div className="flex flex-col gap-6">
      {switch step {
      | Download => downloadContent
      | Upload => uploadContent
      }}
      <div className="flex justify-end gap-2 w-full">
        {switch step {
        | Download =>
          <Button
            text="Continue"
            buttonType=Primary
            onClick={_ => setStep(_ => Upload)}
            buttonState={resourceId->Option.isSome ? Normal : Disabled}
          />
        | Upload =>
          <Button
            text="Submit"
            buttonType=Primary
            onClick={_ => submitCertificate()->ignore}
            buttonState=submitState
          />
        }}
      </div>
    </div>
  </Modal>
}
