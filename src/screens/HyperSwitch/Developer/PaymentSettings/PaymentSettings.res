module InfoViewForWebhooks = {
  @react.component
  let make = (~heading, ~subHeading, ~isCopy=false) => {
    let showToast = ToastState.useShowToast()
    let onCopyClick = ev => {
      ev->ReactEvent.Mouse.stopPropagation
      Clipboard.writeText(subHeading)
      showToast(~message="Copied to Clipboard!", ~toastType=ToastSuccess, ())
    }

    <div className={`flex flex-col gap-2 m-2 md:m-4 w-1/2`}>
      <p className="font-semibold text-fs-15"> {heading->React.string} </p>
      <div className="flex gap-2 break-all w-full items-start">
        <p className="font-medium text-fs-14 text-black opacity-50"> {subHeading->React.string} </p>
        <UIUtils.RenderIf condition={isCopy}>
          <img
            src={`/assets/CopyToClipboard.svg`}
            className="cursor-pointer"
            onClick={ev => {
              onCopyClick(ev)
            }}
          />
        </UIUtils.RenderIf>
      </div>
    </div>
  }
}

@react.component
let make = (~webhookOnly=false, ~showFormOnly=false, ~profileId="") => {
  open DeveloperUtils
  open APIUtils
  open HSwitchUtils
  open MerchantAccountUtils
  let url = RescriptReactRouter.useUrl()
  let id = url.path->Belt.List.toArray->Belt.Array.get(1)->Belt.Option.getWithDefault(profileId)
  let businessProfileDetails = useGetBusinessProflile(id)

  let showToast = ToastState.useShowToast()
  let updateDetails = useUpdateMethod()
  let (isDisabled, setIsDisabled) = React.useState(_ => false)
  let (profileInfo, setProfileInfo) = React.useState(() => businessProfileDetails)

  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)
  let bgClass = webhookOnly ? "" : "bg-white dark:bg-jp-gray-lightgray_background"
  let fetchBusinessProfiles = MerchantAccountUtils.useFetchBusinessProfiles()

  let onSubmit = async (values, _) => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let url = getURL(~entityName=BUSINESS_PROFILE, ~methodType=Post, ~id=Some(id), ())
      let body = values->getBusinessProfilePayload->Js.Json.object_
      let res = await updateDetails(url, body, Post)
      let profileTypeInfo = res->businessProfileTypeMapper
      setProfileInfo(_ => profileTypeInfo)
      showToast(~message=`Details updated`, ~toastType=ToastState.ToastSuccess, ())
      setScreenState(_ => PageLoaderWrapper.Success)
      fetchBusinessProfiles()->ignore
    } catch {
    | _ => {
        setScreenState(_ => PageLoaderWrapper.Success)
        showToast(~message=`Failed to updated`, ~toastType=ToastState.ToastError, ())
      }
    }
    Js.Nullable.null
  }

  <PageLoaderWrapper screenState>
    <div className={`${showFormOnly ? "" : "py-4 md:py-10"} h-full flex flex-col`}>
      <UIUtils.RenderIf condition={!showFormOnly}>
        <BreadCrumbNavigation
          path=[
            {
              title: "Payment Settings",
              link: "/payment-settings",
            },
          ]
          currentPageTitle={businessProfileDetails.profile_name}
          cursorStyle="cursor-pointer"
        />
      </UIUtils.RenderIf>
      <div className={`${showFormOnly ? "" : "mt-4"}`}>
        <div
          className={`w-full ${showFormOnly
              ? ""
              : "border border-jp-gray-500 rounded-md dark:border-jp-gray-960"} ${bgClass} `}>
          <ReactFinalForm.Form
            key="merchantAccount"
            initialValues={businessProfileDetails->parseBussinessProfileJson->Js.Json.object_}
            subscription=ReactFinalForm.subscribeToValues
            validate={values => {
              open HSwitchSettingTypes
              MerchantAccountUtils.validateMerchantAccountForm(
                ~values,
                ~setIsDisabled=Some(setIsDisabled),
                ~fieldsToValidate={
                  [WebhookUrl, ReturnUrl]->Array.filter(urlField =>
                    urlField === WebhookUrl || !webhookOnly
                  )
                },
                ~initialData=profileInfo->parseBussinessProfileJson->Js.Json.object_,
              )
            }}
            onSubmit
            render={({handleSubmit}) => {
              <form
                onSubmit={handleSubmit}
                className={`${showFormOnly
                    ? ""
                    : "px-2 py-4"} flex flex-col gap-7 overflow-hidden`}>
                <div className="flex items-center">
                  <InfoViewForWebhooks
                    heading="Profile ID" subHeading=businessProfileDetails.profile_id isCopy=true
                  />
                  <InfoViewForWebhooks
                    heading="Profile Name" subHeading=businessProfileDetails.profile_name
                  />
                </div>
                <div className="flex items-center">
                  <InfoViewForWebhooks
                    heading="Merchant ID" subHeading={businessProfileDetails.merchant_id}
                  />
                  <InfoViewForWebhooks
                    heading="Payment Response Hash Key"
                    subHeading={businessProfileDetails.payment_response_hash_key->Belt.Option.getWithDefault(
                      "NA",
                    )}
                    isCopy=true
                  />
                </div>
                <FormRenderer.DesktopRow>
                  {[webhookUrl, returnUrl]
                  ->Array.filter(urlField => urlField.label === "Webhook URL" || !webhookOnly)
                  ->Array.mapWithIndex((field, index) =>
                    <FormRenderer.FieldRenderer
                      key={index->Belt.Int.toString}
                      field
                      errorClass
                      labelClass="!text-base !text-grey-700 font-semibold"
                      fieldWrapperClass="max-w-xl"
                    />
                  )
                  ->React.array}
                </FormRenderer.DesktopRow>
                <FormRenderer.DesktopRow>
                  <div className="flex justify-start w-full">
                    <FormRenderer.SubmitButton
                      customSumbitButtonStyle="justify-start"
                      text="Update"
                      buttonType=Button.Primary
                      disabledParamter=isDisabled
                      buttonSize=Button.Small
                    />
                  </div>
                </FormRenderer.DesktopRow>
                <FormValuesSpy />
              </form>
            }}
          />
        </div>
      </div>
    </div>
  </PageLoaderWrapper>
}
