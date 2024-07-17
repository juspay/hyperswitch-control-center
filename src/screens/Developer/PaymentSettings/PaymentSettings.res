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

module AuthorizationInput = {
  @react.component
  let make = (~removeAuthHeaders, ~index) => {
    let (key, setKey) = React.useState(_ => "")
    let (metaValue, setValue) = React.useState(_ => "")
    let form = ReactFinalForm.useForm()
    let name = `outgoing_webhook_custom_http_headers.${key}`
    let keyInput: ReactFinalForm.fieldRenderPropsInput = {
      name: "string",
      onBlur: _ev => {
        if key->Js.String.length > 0 {
          form.change(name, metaValue->JSON.Encode.string)
        }
      },
      onChange: ev => {
        let value = ReactEvent.Form.target(ev)["value"]
        setKey(_ => value)
      },
      onFocus: _ev => {
        if key->Js.String.length > 0 {
          form.change(name, JSON.Encode.null)
        }
      },
      value: key->JSON.Encode.string,
      checked: true,
    }

    let valueInput: ReactFinalForm.fieldRenderPropsInput = {
      name: "string",
      onBlur: _ev => {
        form.change(name, metaValue->JSON.Encode.string)
      },
      onChange: ev => {
        let value = ReactEvent.Form.target(ev)["value"]
        setValue(_ => value)
      },
      onFocus: _ev => (),
      value: metaValue->JSON.Encode.string,
      checked: true,
    }

    <div className="flex gap-4">
      <FormRenderer.DesktopRow wrapperClass="flex-1">
        <div className="mt-5">
          <TextInput input={keyInput} placeholder={"Enter key"} />
        </div>
        <div className="mt-5">
          <TextInput input={valueInput} placeholder={"Enter value"} />
        </div>
      </FormRenderer.DesktopRow>
      <UIUtils.RenderIf condition={index > 0}>
        <div className="mt-6 flex gap-4">
          <ModalCloseIcon onClick={_ev => removeAuthHeaders(index, key)} />
        </div>
      </UIUtils.RenderIf>
      <UIUtils.RenderIf condition={index == 0}>
        <div className="flex bg-transparent text-white items-center mt-4">
          <p> {"text"->React.string} </p>
        </div>
      </UIUtils.RenderIf>
    </div>
  }
}
module WebHookAuthorizationHeaders = {
  @react.component
  let make = () => {
    open LogicUtils
    let form = ReactFinalForm.useForm()
    let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
      ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
    )
    let (authHeaders, setAuthHeaders) = React.useState(_ => [0])
    let formValuesRef = React.useRef(formState.values)

    React.useEffect1(() => {
      // Update the ref whenever formState.values changes
      formValuesRef.current = formState.values
      None
    }, [formState.values])

    let removeAuthHeaders = (removeIndex, name) => {
      let outGoingWebhookDict =
        formValuesRef.current
        ->getDictFromJsonObject
        ->getDictfromDict("outgoing_webhook_custom_http_headers")

      let _ = outGoingWebhookDict->Dict.delete(name)
      let modified = outGoingWebhookDict->Dict.copy->Identity.genericTypeToJson
      form.change(`outgoing_webhook_custom_http_headers`, modified)

      setAuthHeaders(prevAuthHeaders =>
        prevAuthHeaders->Array.filterWithIndex((_, index) => index != removeIndex)
      )
    }

    let addAuthHeaders = () => {
      if authHeaders->Array.length < 4 {
        let update = authHeaders->Array.concat([authHeaders->Array.length])
        setAuthHeaders(_ => update)
      }
    }

    <div className="flex-1">
      {authHeaders
      ->Array.mapWithIndex((_, index) => {
        <div className="grid grid-cols-5 flex gap-4">
          <div key={index->Int.toString} className=" col-span-4">
            <AuthorizationInput removeAuthHeaders index />
          </div>
          <UIUtils.RenderIf condition={index === authHeaders->Array.length - 1 && index != 3}>
            <div className="flex justify-start items-center mt-4">
              <Icon
                name="plus-circle"
                size=27
                customIconColor="text-gray-400"
                className="flex items-center justify-center w-fit h-fit"
                onClick={_ev => addAuthHeaders()}
              />
            </div>
          </UIUtils.RenderIf>
        </div>
      })
      ->React.array}
    </div>
  }
}

module WebHook = {
  @react.component
  let make = () => {
    let (addAuthHeaders, setAuthHeaders) = React.useState(_ => false)

    let h2RegularTextStyle = `${HSwitchUtils.getTextClass((H3, Leading_1))}`

    <>
      <div className="ml-5">
        <p className=h2RegularTextStyle> {"Webhook Setup"->React.string} </p>
      </div>
      <FormRenderer.DesktopRow>
        <FormRenderer.FieldRenderer
          field={DeveloperUtils.webhookUrl}
          labelClass="!text-base !text-grey-700 font-semibold"
          fieldWrapperClass="max-w-xl"
        />
      </FormRenderer.DesktopRow>
      <FormRenderer.DesktopRow wrapperClass="items-center">
        <p
          className={`pt-2 pb-2 text-fs-13 text-jp-gray-900 dark:text-jp-gray-text_darktheme dark:text-opacity-50 ml-1 !text-base !text-grey-700 font-semibold ml-1`}>
          {"Authorization"->React.string}
        </p>
        <BoolInput.BaseComponent
          isSelected={addAuthHeaders}
          setIsSelected={_ => setAuthHeaders(_ => !addAuthHeaders)}
          isDisabled=false
          boolCustomClass="rounded-lg"
        />
      </FormRenderer.DesktopRow>
      <UIUtils.RenderIf condition=addAuthHeaders>
        <WebHookAuthorizationHeaders />
      </UIUtils.RenderIf>
    </>
  }
}

module ReturnUrl = {
  @react.component
  let make = () => {
    let h2RegularTextStyle = `${HSwitchUtils.getTextClass((H3, Leading_1))}`
    <>
      <div className="ml-5">
        <p className=h2RegularTextStyle> {"Return URL Setup"->React.string} </p>
      </div>
      <FormRenderer.DesktopRow>
        <FormRenderer.FieldRenderer
          field={DeveloperUtils.returnUrl}
          errorClass={HSwitchUtils.errorClass}
          labelClass="!text-base !text-grey-700 font-semibold"
          fieldWrapperClass="max-w-xl"
        />
      </FormRenderer.DesktopRow>
    </>
  }
}

@react.component
let make = (~webhookOnly=false, ~showFormOnly=false, ~profileId="") => {
  open DeveloperUtils
  open APIUtils
  open HSwitchUtils
  open MerchantAccountUtils
  open HSwitchSettingTypes
  let getURL = useGetURL()
  let url = RescriptReactRouter.useUrl()
  let id = HSwitchUtils.getConnectorIDFromUrl(url.path->List.toArray, profileId)
  let businessProfileDetails = BusinessProfileHook.useGetBusinessProflile(id)
  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let showToast = ToastState.useShowToast()
  let updateDetails = useUpdateMethod()
  let (isDisabled, setIsDisabled) = React.useState(_ => false)
  let (profileInfo, setProfileInfo) = React.useState(() => businessProfileDetails)

  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)
  let bgClass = webhookOnly ? "" : "bg-white dark:bg-jp-gray-lightgray_background"
  let fetchBusinessProfiles = BusinessProfileHook.useFetchBusinessProfiles()

  let threedsConnectorList =
    HyperswitchAtom.connectorListAtom
    ->Recoil.useRecoilValueFromAtom
    ->Array.filter(item =>
      item.connector_type->ConnectorUtils.connectorTypeStringToTypeMapper ===
        AuthenticationProcessor
    )

  let isBusinessProfileHasThreeds = threedsConnectorList->Array.some(item => item.profile_id == id)

  let fieldsToValidate = () => {
    let defaultFieldsToValidate =
      [WebhookUrl, ReturnUrl]->Array.filter(urlField => urlField === WebhookUrl || !webhookOnly)
    defaultFieldsToValidate
  }

  let onSubmit = async (values, _) => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let url = getURL(~entityName=BUSINESS_PROFILE, ~methodType=Post, ~id=Some(id), ())
      let body = values->getBusinessProfilePayload->JSON.Encode.object
      let res = await updateDetails(url, body, Post, ())
      let profileTypeInfo = res->BusinessProfileMapper.businessProfileTypeMapper
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
    Nullable.null
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
            initialValues={businessProfileDetails->parseBussinessProfileJson->JSON.Encode.object}
            subscription=ReactFinalForm.subscribeToValues
            validate={values => {
              MerchantAccountUtils.validateMerchantAccountForm(
                ~values,
                ~setIsDisabled=Some(setIsDisabled),
                ~fieldsToValidate={fieldsToValidate()},
                ~initialData=profileInfo->parseBussinessProfileJson->JSON.Encode.object,
                ~isLiveMode=featureFlagDetails.isLiveMode,
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
                    subHeading={businessProfileDetails.payment_response_hash_key->Option.getOr(
                      "NA",
                    )}
                    isCopy=true
                  />
                </div>
                <FormRenderer.DesktopRow>
                  <FormRenderer.FieldRenderer
                    labelClass="!text-base !text-grey-700 font-semibold"
                    fieldWrapperClass="max-w-xl"
                    field={FormRenderer.makeFieldInfo(
                      ~name="collect_shipping_details_from_wallet_connector",
                      ~label="Collect Shipping Details",
                      ~customInput=InputFields.boolInput(
                        ~isDisabled=false,
                        ~boolCustomClass="rounded-lg",
                        ~size=Large,
                        (),
                      ),
                      (),
                    )}
                  />
                  <FormRenderer.FieldRenderer
                    labelClass="!text-base !text-grey-700 font-semibold"
                    fieldWrapperClass="max-w-xl"
                    field={FormRenderer.makeFieldInfo(
                      ~name="is_connector_agnostic_mit_enabled",
                      ~label="Connector Agnostic",
                      ~customInput=InputFields.boolInput(
                        ~isDisabled=false,
                        ~boolCustomClass="rounded-lg",
                        ~size=Large,
                        (),
                      ),
                      (),
                    )}
                  />
                </FormRenderer.DesktopRow>
                <UIUtils.RenderIf condition={isBusinessProfileHasThreeds}>
                  <FormRenderer.DesktopRow>
                    <FormRenderer.FieldRenderer
                      field={threedsConnectorList
                      ->Array.map(item => item.connector_name)
                      ->authenticationConnectors}
                      errorClass
                      labelClass="!text-base !text-grey-700 font-semibold"
                      fieldWrapperClass="max-w-xl"
                    />
                    <FormRenderer.FieldRenderer
                      field={threeDsRequestorUrl}
                      errorClass
                      labelClass="!text-base !text-grey-700 font-semibold"
                      fieldWrapperClass="max-w-xl"
                    />
                  </FormRenderer.DesktopRow>
                </UIUtils.RenderIf>
                <ReturnUrl />
                <WebHook />
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
