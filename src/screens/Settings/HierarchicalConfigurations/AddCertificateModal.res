@react.component
let make = (~showModal, ~setShowModal, ~onSuccess, ~onResourceCreated) => {
  open APIUtils
  open LogicUtils
  open HierarchicalConfigTypes
  open HierarchicalConfigUtils
  open Typography
  open AddCertificateModalUtils

  let getURL = useGetURL()
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let updateDetails = useUpdateMethod(~showErrorToast=false)
  let showToast = ToastAdapter.useShowToast()

  let (step, setStep) = React.useState(_ => ChooseType)
  let (selectedResourceType, setSelectedResourceType) = React.useState(_ => ApplePay)
  let (csrState, setCsrState) = React.useState(_ => NotGenerated)
  let (selectedFile, setSelectedFile) = React.useState(_ => None)
  let (submitState, setSubmitState) = React.useState(_ => Button.Disabled)
  let (googleMerchantId, setGoogleMerchantId) = React.useState(_ => "")
  let (googlePayKeyState, setGooglePayKeyState) = React.useState(_ => KeyNotGenerated)
  let (errorMessage, setErrorMessage) = React.useState(_ => None)
  let inputRef = React.useRef(Nullable.null)

  let resourceId = getResourceId(csrState)

  React.useEffect(() => {
    if !showModal {
      setStep(_ => ChooseType)
      setSelectedResourceType(_ => ApplePay)
      setCsrState(_ => NotGenerated)
      setSelectedFile(_ => None)
      setSubmitState(_ => Disabled)
      setGoogleMerchantId(_ => "")
      setGooglePayKeyState(_ => KeyNotGenerated)
      setErrorMessage(_ => None)
    }
    None
  }, [showModal])

  let continueWithResourceType = () => {
    setErrorMessage(_ => None)
    mixpanelEvent(~eventName=`hierarchical_config_${(selectedResourceType :> string)}_selected`)
    setStep(_ =>
      switch selectedResourceType {
      | ApplePay => ApplePayDownload
      | GooglePay => GooglePayGenerate
      }
    )
  }

  let goBackToChooseType = () => {
    setErrorMessage(_ => None)
    setStep(_ => ChooseType)
  }

  let generateAndDownload = async () => {
    try {
      setErrorMessage(_ => None)
      setCsrState(_ => Generating)
      let url = getURL(~entityName=V1(RESOURCES), ~methodType=Post)
      let payload =
        [("type", applePayCertificateResourceType->JSON.Encode.string)]->getJsonFromArrayOfJson
      let response = await updateDetails(url, payload, Post)
      let dict = response->getDictFromJsonObject
      let generatedCsr =
        dict
        ->getDictFromNestedDict("data", applePayCertificateResourceType)
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
    mixpanelEvent(~eventName="hierarchical_config_csr_download_clicked")
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
        let payload = [("certificate", certificate->JSON.Encode.string)]->getJsonFromArrayOfJson
        let _ = await updateDetails(url, payload, Put)
        mixpanelEvent(~eventName="hierarchical_config_certificate_upload_success")
        showToast(~message="Certificate uploaded successfully", ~toastType=ToastSuccess)
        onSuccess(ApplePay)
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

  let generateGooglePayKey = async () => {
    let trimmedMerchantId = googleMerchantId->String.trim

    if trimmedMerchantId->isNonEmptyString && googlePayKeyState == KeyNotGenerated {
      try {
        setErrorMessage(_ => None)
        setGooglePayKeyState(_ => KeyGenerating)
        let url = getURL(~entityName=V1(RESOURCES), ~methodType=Post)
        let payload = getGooglePayGeneratePayload(~googleMerchantId=trimmedMerchantId)
        let response = await updateDetails(url, payload, Post)
        setGooglePayKeyState(_ => KeyGenerated({publicKey: response->getGooglePayPublicKey}))
        mixpanelEvent(~eventName="hierarchical_config_google_pay_key_generate_success")
        showToast(~message="Google Pay key generated successfully", ~toastType=ToastSuccess)
        onResourceCreated(GooglePay)
      } catch {
      | Exn.Error(e) =>
        setErrorMessage(_ => Some(
          getFormattedErrorMessage(
            ~error=e,
            ~fallback="Failed to generate Google Pay key.",
            ~retryHint="Please try again.",
          ),
        ))
        setGooglePayKeyState(_ => KeyNotGenerated)
      }
    }
  }

  let googleMerchantIdInput: ReactFinalForm.fieldRenderPropsInput = {
    name: "google_merchant_id",
    onBlur: _ => (),
    onFocus: _ => (),
    onChange: ev => {
      let value = ReactEvent.Form.target(ev)["value"]
      setGoogleMerchantId(_ => value)
    },
    value: googleMerchantId->JSON.Encode.string,
    checked: false,
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

  let chooseTypeContent =
    <div className="flex flex-col gap-3">
      {resourceTypes
      ->Array.map(resourceType =>
        <HierarchicalConfigHelper.RadioCard
          key={(resourceType :> string)}
          title={resourceType->getResourceTypeLabel}
          description={resourceType->getResourceTypeDescription}
          isSelected={resourceType == selectedResourceType}
          onClick={() => setSelectedResourceType(_ => resourceType)}
        />
      )
      ->React.array}
    </div>

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

  let googlePayContent =
    <div className="flex flex-col gap-4">
      {errorBanner}
      {switch googlePayKeyState {
      | KeyGenerated({publicKey}) =>
        <div className="flex flex-col gap-4">
          <p className={`${body.md.regular} text-nd_gray-700`}>
            {"Download the public key and use it in your Google Pay tokenizationSpecification with type DIRECT. The private key is generated and stored securely by Hyperswitch and is never shown."->React.string}
          </p>
          <Button
            text="Download Public Key"
            buttonType=Primary
            buttonSize=Small
            customButtonStyle="w-fit"
            onClick={_ => {
              mixpanelEvent(~eventName="hierarchical_config_google_pay_public_key_download_clicked")
              DownloadUtils.download(
                ~fileName=googlePayPublicKeyFileName,
                ~content=publicKey,
                ~fileType=googlePayPublicKeyFileType,
              )
            }}
          />
          <p className={`${body.sm.regular} text-nd_gray-500`}>
            {"Link this key to your merchant or a profile from the Hierarchical Resources list."->React.string}
          </p>
        </div>
      | KeyNotGenerated | KeyGenerating =>
        <div className="flex flex-col gap-4">
          <p className={`${body.md.regular} text-nd_gray-700`}>
            {"Enter the Google Merchant ID from your Google Pay & Wallet Console. Hyperswitch will generate a key pair for DIRECT tokenization and return the public key for your checkout."->React.string}
          </p>
          <div className="flex flex-col gap-1">
            <span className={`${body.sm.medium} text-nd_gray-600`}>
              {"Google Merchant ID"->React.string}
            </span>
            <TextInput
              input=googleMerchantIdInput
              placeholder="Enter Google Merchant ID"
              isDisabled={googlePayKeyState == KeyGenerating}
              autoFocus=true
            />
          </div>
        </div>
      }}
    </div>

  let footer = switch step {
  | ChooseType =>
    <Button
      text="Continue"
      buttonType=Primary
      onClick={_ => continueWithResourceType()}
      buttonState=Normal
    />
  | ApplePayDownload =>
    <>
      <RenderIf condition={resourceId->Option.isNone}>
        <Button
          text="Back"
          buttonType=Secondary
          onClick={_ => goBackToChooseType()}
          buttonState={csrState == Generating ? Disabled : Normal}
        />
      </RenderIf>
      <Button
        text="Continue"
        buttonType=Primary
        onClick={_ => {
          mixpanelEvent(~eventName="hierarchical_config_continue_to_upload_clicked")
          setStep(_ => ApplePayUpload)
        }}
        buttonState={resourceId->Option.isSome ? Normal : Disabled}
      />
    </>
  | ApplePayUpload =>
    <Button
      text="Submit"
      buttonType=Primary
      onClick={_ => {
        mixpanelEvent(~eventName="hierarchical_config_certificate_submit_clicked")
        submitCertificate()->ignore
      }}
      buttonState=submitState
    />
  | GooglePayGenerate =>
    switch googlePayKeyState {
    | KeyGenerated(_) =>
      <Button text="Done" buttonType=Primary onClick={_ => setShowModal(_ => false)} />
    | KeyNotGenerated | KeyGenerating =>
      <>
        <Button
          text="Back"
          buttonType=Secondary
          onClick={_ => goBackToChooseType()}
          buttonState={googlePayKeyState == KeyGenerating ? Disabled : Normal}
        />
        <Button
          text="Generate Key"
          buttonType=Primary
          onClick={_ => {
            mixpanelEvent(~eventName="hierarchical_config_google_pay_key_generate_clicked")
            generateGooglePayKey()->ignore
          }}
          buttonState={getGooglePayGenerateState(~keyState=googlePayKeyState, ~googleMerchantId)}
        />
      </>
    }
  }

  <Modal
    showModal
    setShowModal
    modalHeading={getModalHeading(step)}
    modalHeadingDescription={getStepSubHeading(step)}
    modalDescriptionClass={`${body.md.regular} text-nd_gray-500 mt-1`}
    childClass="p-6"
    borderBottom=true
    modalClass="w-full max-w-xl mx-auto my-auto dark:!bg-nd_gray-800"
    alignModal="items-center justify-center"
    closeOnOutsideClick=false>
    <div className="flex flex-col gap-6">
      {switch step {
      | ChooseType => chooseTypeContent
      | ApplePayDownload => downloadContent
      | ApplePayUpload => uploadContent
      | GooglePayGenerate => googlePayContent
      }}
      <div className="flex justify-end gap-2 w-full"> {footer} </div>
    </div>
  </Modal>
}
