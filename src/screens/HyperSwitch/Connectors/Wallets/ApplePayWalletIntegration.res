module HostURL = {
  @react.component
  let make = (~prefix="") => {
    let fieldInputVal = ReactFinalForm.useField(`${prefix}`).input
    let fieldInput = switch fieldInputVal.value->Js.Json.decodeString {
    | Some(val) => val->String.length > 0 ? val : "domain_name"
    | None => "domain_name"
    }

    <p className="mt-2">
      {`${fieldInput}/.well-known/apple-developer-merchantid-domain-association`->React.string}
    </p>
  }
}

module Simplified = {
  @react.component
  let make = (
    ~metaData,
    ~metadataInputs,
    ~update,
    ~setApplePayIntegrationSteps,
    ~setVefifiedDomainList,
  ) => {
    open LogicUtils
    open WalletHelper
    open APIUtils
    open ApplePayWalletIntegrationUtils
    let url = RescriptReactRouter.useUrl()
    let updateAPIHook = useUpdateMethod(~showErrorToast=false, ())
    let showToast = ToastState.useShowToast()
    let fetchApi = AuthHooks.useApiFetcher()
    let connectorID = url.path->Belt.List.toArray->Belt.Array.get(1)->Belt.Option.getWithDefault("")
    let merchantDetailsValue = HSwitchUtils.useMerchantDetailsValue()
    let merchantId = merchantDetailsValue->getDictFromJsonObject->getString("merchant_id", "")
    let prefix = "apple_pay_combined.simplified.session_token_data.initiative_context"
    let inputField =
      <FormRenderer.FieldRenderer
        field={FormRenderer.makeFieldInfo(
          ~label="",
          ~name={prefix},
          ~placeholder="eg. example.com",
          ~customInput=InputFields.textInput(
            ~customStyle="w-64",
            ~autoComplete="off",
            ~autoFocus=true,
            (),
          ),
          (),
        )}
      />

    let downloadApplePayCert = () => {
      open Promise
      fetchApi(HSwitchGlobalVars.urlToDownloadApplePayCertificate, ~method_=Get, ())
      ->then(Fetch.Response.blob)
      ->then(content => {
        DownloadUtils.download(
          ~fileName=`apple-developer-merchantid-domain-association`,
          ~content,
          ~fileType="text/plain",
        )
        showToast(~toastType=ToastSuccess, ~message="File download complete", ())

        resolve()
      })
      ->catch(_ => {
        showToast(
          ~toastType=ToastError,
          ~message="Oops, something went wrong with the download. Please try again.",
          (),
        )
        resolve()
      })
      ->ignore
    }

    let downloadAPIKey =
      <div className="mt-4">
        <Button
          text={"Download File"}
          buttonType={Primary}
          buttonSize={Small}
          customButtonStyle="!px-2 rounded-lg"
          onClick={_ => downloadApplePayCert()}
          buttonState={Normal}
        />
      </div>

    let onSubmit = async (values, _) => {
      try {
        let (body, domainName) = values->constructVerifyApplePayReq(connectorID)
        let verifyAppleUrl = getURL(~entityName=VERIFY_APPLE_PAY, ~methodType=Post, ())
        let _ = await updateAPIHook(`${verifyAppleUrl}/${merchantId}`, body, Post)

        let updatedValue = values->constructApplePayMetadata(metadataInputs, #simplified)
        update(updatedValue)
        setVefifiedDomainList(_ => [domainName])
        setApplePayIntegrationSteps(_ => ApplePayWalletIntegrationTypes.Verify)
      } catch {
      | _ => showToast(~message="Failed to Verify", ~toastType=ToastState.ToastError, ())
      }
      Js.Nullable.null
    }

    <Form
      validate={values => validate(values, ["initiative_context"], #simplified)}
      onSubmit
      initialValues={metaData}>
      <SimplifiedHelper
        customElement={Some(inputField)}
        heading="Provide your sandbox domain where the verification file will be hosted"
        subText=Some(
          "Input the top-level domain (example.com) or sub-domain (checkout.example.com) where you wish to enable Apple Pay",
        )
        stepNumber="1"
      />
      <hr className="w-full" />
      <SimplifiedHelper
        heading="Download domain verification file"
        stepNumber="2"
        customElement=Some(downloadAPIKey)
      />
      <hr className="w-full" />
      <SimplifiedHelper
        heading="Host sandbox domain association file"
        subText=Some(
          "Host the downloaded verification file at your sandbox domain in the following location :-",
        )
        stepNumber="3"
        customElement=Some(<HostURL prefix />)
      />
      <div className="w-full flex gap-2 justify-end p-6">
        <Button
          text="Go Back"
          buttonType={Secondary}
          onClick={_ev => {
            setApplePayIntegrationSteps(_ => ApplePayWalletIntegrationTypes.Landing)
          }}
        />
        <FormRenderer.SubmitButton text="Verify & Enable" buttonSize=Button.Medium />
      </div>
      <FormValuesSpy />
    </Form>
  }
}

module Manual = {
  @react.component
  let make = (
    ~metadataInputs,
    ~metaData,
    ~update,
    ~setApplePayIntegrationSteps,
    ~setVefifiedDomainList,
  ) => {
    open WalletHelper
    open LogicUtils
    open ApplePayWalletIntegrationUtils

    let configurationFields =
      metadataInputs->getDictfromDict("apple_pay")->getDictfromDict("session_token_data")

    let fields = {
      configurationFields
      ->Dict.keysToArray
      ->Array.mapWithIndex((field, index) => {
        let label = configurationFields->getString(field, "")
        <div key={index->Belt.Int.toString}>
          <FormRenderer.FieldRenderer
            labelClass="font-semibold !text-hyperswitch_black"
            field={FormRenderer.makeFieldInfo(
              ~label,
              ~name={`apple_pay_combined.manual.session_token_data.${field}`},
              ~placeholder={`Enter ${label->snakeToTitle}`},
              ~customInput=InputFields.textInput(),
              ~isRequired=true,
              (),
            )}
          />
        </div>
      })
      ->React.array
    }

    let onSubmit = (values, _) => {
      let domainName = values->getSessionTokenDict(#manual)->getString("initiative_context", "")
      let updatedValue = values->constructApplePayMetadata(metadataInputs, #manual)
      update(updatedValue)
      setVefifiedDomainList(_ => [domainName])
      setApplePayIntegrationSteps(_ => ApplePayWalletIntegrationTypes.Verify)
      Js.Nullable.null->Js.Promise.resolve
    }

    <div className="p-6 m-2">
      <InfoCard customInfoStyle="mb-4 mr-4">
        <p className="text-base	font-normal	">
          {"Follow our"->React.string}
          <a
            href="https://hyperswitch.io/docs/paymentMethods/wallets#apple-pay"
            target="_blank"
            className="text-base	font-normal	 text-status-blue ml-1 underline underline-offset-4">
            {" Apple Pay Setup Guide "->React.string}
          </a>
          {"to get help with filling the details below"->React.string}
        </p>
      </InfoCard>
      <Form
        validate={values =>
          validate(values, configurationFields->Dict.keysToArray->getUniqueArray, #manual)}
        onSubmit
        initialValues={metaData}>
        {fields}
        <div className="flex gap-2 justify-end mt-4">
          <Button
            text="Go Back"
            buttonType={Secondary}
            onClick={_ev => {
              setApplePayIntegrationSteps(_ => ApplePayWalletIntegrationTypes.Landing)
            }}
          />
          <FormRenderer.SubmitButton text="Enable" buttonSize=Button.Medium />
        </div>
        <FormValuesSpy />
      </Form>
    </div>
  }
}

module Landing = {
  open WalletHelper
  @react.component
  let make = (
    ~setApplePayIntegrationType,
    ~appleIntegrationType,
    ~setShowWalletConfigurationModal,
    ~setApplePayIntegrationSteps,
  ) => {
    open ApplePayWalletIntegrationTypes
    <>
      <div
        className="p-6 m-2 cursor-pointer"
        onClick={_e => setApplePayIntegrationType(_ => #simplified)}>
        <Card heading="Web Domain" isSelected={appleIntegrationType === #simplified}>
          <div
            className={`opacity-50 mt-2 text-base text-hyperswitch_black opacity-50 font-normal`}>
            {"Get Apple Pay enabled on your web domains by hosting a verification file, that’s it."->React.string}
          </div>
          <div className="flex gap-2 mt-4">
            <CustomTag tagText="Faster Configuration" tagSize=4 tagLeftIcon=Some("ellipse-green") />
            <CustomTag tagText="Recommended" tagSize=4 tagLeftIcon=Some("ellipse-green") />
          </div>
        </Card>
      </div>
      <div
        className="p-6 m-2 cursor-pointer" onClick={_e => setApplePayIntegrationType(_ => #manual)}>
        <Card heading="iOS Certificate" isSelected={appleIntegrationType === #manual}>
          <div
            className={`opacity-50 mt-2 text-base text-hyperswitch_black opacity-50 font-normal`}>
            <CustomSubText />
          </div>
          <div className="flex gap-2 mt-4">
            <CustomTag tagText="For Web & Mobile" tagSize=4 tagLeftIcon=Some("ellipse-green") />
            <CustomTag
              tagText="Additional Details Required" tagSize=4 tagLeftIcon=Some("ellipse-green")
            />
          </div>
        </Card>
      </div>
      <div className={`flex gap-2 justify-end m-2 p-6`}>
        <Button
          text="Cancel"
          buttonType={Secondary}
          onClick={_ev => {
            setShowWalletConfigurationModal(_ => false)
          }}
        />
        <Button
          onClick={_ev => setApplePayIntegrationSteps(_ => Configure)}
          text="Continue"
          buttonType={Primary}
        />
      </div>
    </>
  }
}

module Verified = {
  @react.component
  let make = (
    ~verifiedDomainList,
    ~setApplePayIntegrationType,
    ~appleIntegrationType,
    ~setApplePayIntegrationSteps,
    ~setShowWalletConfigurationModal,
  ) => {
    open WalletHelper
    open ApplePayWalletIntegrationTypes
    <>
      <div className="p-6 m-2 cursor-pointer">
        <p className="text-xs	font-medium	mt-4"> {" Web Domains"->React.string} </p>
        {verifiedDomainList
        ->Array.mapWithIndex((domainUrl, index) => {
          <div
            key={string_of_int(index)}
            className="mt-4 cursor-pointer"
            onClick={_e => setApplePayIntegrationType(_ => #manual)}>
            <div className={`relative w-full  p-6 rounded flex flex-col justify-between border `}>
              <div className="flex justify-between">
                <div className={`font-medium text-base text-hyperswitch_black `}>
                  {domainUrl->React.string}
                </div>
                <div>
                  {switch appleIntegrationType {
                  | #simplified =>
                    <CustomTag
                      tagText="Verified"
                      tagSize=4
                      tagLeftIcon=Some("ellipse-green")
                      tagCustomStyle="bg-hyperswitch_green_trans"
                    />
                  | #manual =>
                    <Icon
                      onClick={_ev => setApplePayIntegrationSteps(_ => Configure)}
                      name={"arrow-right"}
                      size={15}
                    />
                  }}
                </div>
              </div>
            </div>
          </div>
        })
        ->React.array}
        <div className={`flex gap-2 justify-end mt-4`}>
          <Button
            text="Reconfigure"
            buttonType={Secondary}
            onClick={_ev => {
              setApplePayIntegrationSteps(_ => Landing)
            }}
          />
          <Button
            onClick={_ev => {
              setShowWalletConfigurationModal(_ => false)
            }}
            text="Proceed"
            buttonType={Primary}
          />
        </div>
      </div>
    </>
  }
}

@react.component
let make = (~metadataInputs, ~update, ~metaData, ~setShowWalletConfigurationModal) => {
  open ApplePayWalletIntegrationTypes

  open WalletHelper
  let (appleIntegrationType, setApplePayIntegrationType) = React.useState(_ => #simplified)
  let (applePayIntegrationStep, setApplePayIntegrationSteps) = React.useState(_ => Landing)
  let (verifiedDomainList, setVefifiedDomainList) = React.useState(_ => [])
  <div>
    <Heading />
    {switch applePayIntegrationStep {
    | Landing =>
      <Landing
        setApplePayIntegrationType
        setShowWalletConfigurationModal
        setApplePayIntegrationSteps
        appleIntegrationType
      />
    | Configure =>
      switch appleIntegrationType {
      | #simplified =>
        <Simplified
          metadataInputs metaData update setApplePayIntegrationSteps setVefifiedDomainList
        />
      | #manual =>
        <Manual metadataInputs metaData update setApplePayIntegrationSteps setVefifiedDomainList />
      }
    | Verify =>
      <Verified
        verifiedDomainList
        setApplePayIntegrationType
        setShowWalletConfigurationModal
        setApplePayIntegrationSteps
        appleIntegrationType
      />
    }}
  </div>
}
