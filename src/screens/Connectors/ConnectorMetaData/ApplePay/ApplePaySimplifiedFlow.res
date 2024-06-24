open ApplePayIntegrationTypesV2
@react.component
let make = (
  ~applePayFields,
  ~merchantBusinessCountry,
  ~setApplePayIntegrationSteps,
  ~setVefifiedDomainList,
) => {
  open LogicUtils
  open APIUtils
  open ApplePayIntegrationHelperV2
  open ApplePayIntegrationUtilsV2
  let getURL = useGetURL()
  let updateAPIHook = useUpdateMethod(~showErrorToast=false, ())
  let fetchApi = AuthHooks.useApiFetcher()
  let showToast = ToastState.useShowToast()

  let url = RescriptReactRouter.useUrl()
  let form = ReactFinalForm.useForm()
  let connectorID = HSwitchUtils.getConnectorIDFromUrl(url.path->List.toArray, "")
  let merchantDetailsValue = HSwitchUtils.useMerchantDetailsValue()
  let merchantId = merchantDetailsValue.merchant_id
  let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
    ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
  )
  let initalFormValue =
    formState.values
    ->getDictFromJsonObject
    ->getDictfromDict("metadata")
    ->getDictfromDict("apple_pay_combined")
  let setFormData = () => {
    let value = applePayCombined(initalFormValue, #simplified)
    form.change("metadata.apple_pay_combined", value->Identity.genericTypeToJson)
  }

  React.useEffect0(() => {
    let _ = setFormData()
    None
  })
  let onSubmit = async () => {
    try {
      let body = formState.values->constructVerifyApplePayReq(connectorID)
      let verifyAppleUrl = getURL(~entityName=VERIFY_APPLE_PAY, ~methodType=Post, ())
      let _ = await updateAPIHook(`${verifyAppleUrl}/${merchantId}`, body, Post, ())

      let data =
        formState.values
        ->getDictFromJsonObject
        ->getDictfromDict("metadata")
        ->getDictfromDict("apple_pay_combined")
        ->simplified
      let domainName = data.session_token_data.initiative_context->Option.getOr("")

      setVefifiedDomainList(_ => [domainName])
      setApplePayIntegrationSteps(_ => ApplePayIntegrationTypesV2.Verify)
    } catch {
    | _ => showToast(~message="Failed to Verify", ~toastType=ToastState.ToastError, ())
    }
    Nullable.null
  }

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

  let applePaySimplifiedFields =
    applePayFields
    ->Array.filter(field => {
      let typedData = field->convertMapObjectToDict->CommonMetaDataUtils.inputFieldMapper
      !(ignoreFieldsonSimplified->Array.includes(typedData.name))
    })
    ->Array.mapWithIndex((field, index) => {
      let applePayField = field->convertMapObjectToDict->CommonMetaDataUtils.inputFieldMapper
      <div key={index->Int.toString}>
        <FormRenderer.FieldRenderer
          labelClass="font-semibold !text-hyperswitch_black"
          field={applePayValueInput(
            ~applePayField,
            ~merchantBusinessCountry,
            ~integrationType={Some(#simplified)},
            (),
          )}
        />
      </div>
    })
    ->React.array
  <>
    <SimplifiedHelper
      customElement={Some(applePaySimplifiedFields)}
      heading="Provide your sandbox domain where the verification file will be hosted"
      subText=Some(
        "Input the top-level domain (example.com) or sub-domain (checkout.example.com) where you wish to enable Apple Pay",
      )
      stepNumber="1"
    />
    <hr className="w-full" />
    <SimplifiedHelper
      heading="Download domain verification file" stepNumber="2" customElement=Some(downloadAPIKey)
    />
    <hr className="w-full" />
    <SimplifiedHelper
      heading="Host sandbox domain association file"
      subText=Some(
        "Host the downloaded verification file at your sandbox domain in the following location :-",
      )
      stepNumber="3"
      customElement=Some(
        <HostURL
          prefix={`${ApplePayIntegrationUtilsV2.applePayNameMapper(
              ~name="initiative_context",
              ~integrationType=Some(#simplified),
            )}`}
        />,
      )
    />
    <div className="w-full flex gap-2 justify-end p-6">
      <Button
        text="Go Back"
        buttonType={Secondary}
        onClick={_ev => {
          setApplePayIntegrationSteps(_ => Landing)
        }}
      />
      <Button
        text="Verify & Enable"
        buttonType={Primary}
        onClick={_ev => {
          onSubmit()->ignore
        }}
        buttonState={formState.values->validateSimplifedFlow}
      />
    </div>
    <FormValuesSpy />
  </>
}
