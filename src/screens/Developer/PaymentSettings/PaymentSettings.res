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
        <RenderIf condition={isCopy}>
          <img
            src={`/assets/CopyToClipboard.svg`}
            className="cursor-pointer"
            onClick={ev => {
              onCopyClick(ev)
            }}
          />
        </RenderIf>
      </div>
    </div>
  }
}

module DynamicWebHookAuthHeader = {
  module AuthenticationInput = {
    @react.component
    let make = (~index, ~removeInput, ~webHookAuthInputs) => {
      open LogicUtils
      open FormRenderer
      let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
        ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
      )
      let outGoingWebhookDict =
        formState.values
        ->getDictFromJsonObject
        ->getDictfromDict("outgoing_webhook_custom_http_headers")

      let (key, setKey) = React.useState(_ => "")
      let (metaValue, setValue) = React.useState(_ => "")
      let getOutGoingWebhook = () => {
        let key = outGoingWebhookDict->Dict.keysToArray->LogicUtils.getValueFromArray(index, "")
        let outGoingWebHookVal = outGoingWebhookDict->getOptionString(key)
        switch outGoingWebHookVal {
        | Some(value) => (key, value)
        | _ => ("", "")
        }
      }
      React.useEffect(() => {
        let (outGoingWebhookKey, outGoingWebHookValue) = getOutGoingWebhook()
        setValue(_ => outGoingWebHookValue)
        setKey(_ => outGoingWebhookKey)

        None
      }, [webHookAuthInputs])
      let form = ReactFinalForm.useForm()
      let keyInput: ReactFinalForm.fieldRenderPropsInput = {
        name: "string",
        onBlur: _ => {
          if key->String.length > 0 {
            let name = `outgoing_webhook_custom_http_headers.${key}`
            form.change(name, metaValue->JSON.Encode.string)
          }
        },
        onChange: ev => {
          let value = ReactEvent.Form.target(ev)["value"]
          if value->String.length <= 0 {
            let details =
              formState.values
              ->getDictFromJsonObject
              ->getDictfromDict("outgoing_webhook_custom_http_headers")
              ->Dict.toArray
              ->Array.filter(((formKey, _)) => formKey != key)
              ->Dict.fromArray
            form.change("outgoing_webhook_custom_http_headers", details->Identity.genericTypeToJson)
            setKey(_ => value)
          }
          switch value->getOptionIntFromString->Option.isNone {
          | true => setKey(_ => value)
          | _ => ()
          }
        },
        onFocus: _ => (),
        value: key->JSON.Encode.string,
        checked: true,
      }
      let valueInput: ReactFinalForm.fieldRenderPropsInput = {
        name: "string",
        onBlur: _ => (),
        onChange: ev => {
          let value = ReactEvent.Form.target(ev)["value"]
          if key->String.length > 0 {
            let name = `outgoing_webhook_custom_http_headers.${key}`
            form.change(name, value->JSON.Encode.string)
          }
          setValue(_ => value)
        },
        onFocus: _ => (),
        value: metaValue->JSON.Encode.string,
        checked: true,
      }
      let showCloseIcon = () => {
        outGoingWebhookDict->Dict.keysToArray->Array.length >= 1 &&
          webHookAuthInputs->Array.length > 1
      }
      <div className="flex gap-4">
        <DesktopRow wrapperClass="flex-1">
          <div className="mt-5">
            <TextInput input={keyInput} placeholder={"Enter key"} />
          </div>
          <div className="mt-5">
            <TextInput input={valueInput} placeholder={"Enter value"} />
          </div>
        </DesktopRow>
        <RenderIf condition={showCloseIcon()}>
          <div className="mt-6 flex gap-4">
            <ModalCloseIcon onClick={_ev => removeInput(index, key)} />
          </div>
        </RenderIf>
      </div>
    }
  }
  module WebHookAuthenticationHeaders = {
    @react.component
    let make = () => {
      open LogicUtils
      let form = ReactFinalForm.useForm()
      let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
        ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
      )
      let (webHookAuthInputs, setWebHookAuthInputs) = React.useState(_ =>
        Array.fromInitializer(~length=1, i => i)
      )
      React.useEffect(() => {
        let length =
          formState.values
          ->getDictFromJsonObject
          ->getDictfromDict("outgoing_webhook_custom_http_headers")
          ->Dict.toArray
          ->Array.length
        let arr = Array.fromInitializer(~length=length > 0 ? length : 1, i => i)
        setWebHookAuthInputs(_ => arr)
        None
      }, [])
      let removeInput = (removeIndex, removeKey) => {
        let details =
          formState.values
          ->getDictFromJsonObject
          ->getDictfromDict("outgoing_webhook_custom_http_headers")
          ->Dict.toArray
          ->Array.filter(((key, _)) => key != removeKey)
          ->Dict.fromArray
        form.change("outgoing_webhook_custom_http_headers", details->Identity.genericTypeToJson)
        setWebHookAuthInputs(_ =>
          webHookAuthInputs->Array.filterWithIndex((_, index) => index != removeIndex)
        )
      }
      let addInput = () => {
        setWebHookAuthInputs(_ =>
          Array.fromInitializer(~length=webHookAuthInputs->Array.length + 1, i => i)
        )
      }

      let checkForEmpty = () => {
        let arr =
          formState.values
          ->getDictFromJsonObject
          ->getDictfromDict("outgoing_webhook_custom_http_headers")
          ->Dict.toArray
          ->Array.filter(((key, value)) =>
            key->String.length != 0 && value->getStringFromJson("")->String.length != 0
          )

        arr->Array.length == webHookAuthInputs->Array.length ? true : false
      }
      <div className="flex-1">
        <p
          className={`ml-4 text-fs-13 text-jp-gray-900 dark:text-jp-gray-text_darktheme dark:text-opacity-50 ml-1 !text-base !text-grey-700 font-semibold ml-1`}>
          {"Custom HTTP Headers"->React.string}
        </p>
        {webHookAuthInputs
        ->Array.mapWithIndex((_, index) =>
          <div key={index->Int.toString} className="grid grid-cols-5 flex gap-4">
            <div key={index->Int.toString} className="col-span-4">
              <AuthenticationInput index={index} removeInput webHookAuthInputs />
            </div>
            <RenderIf
              condition={index === webHookAuthInputs->Array.length - 1 &&
              index != 3 &&
              checkForEmpty()}>
              <div className="flex justify-start items-center mt-4">
                <Icon
                  name="plus"
                  size=16
                  className="flex items-center justify-center w-fit h-fit p-1 border-2 rounded-full bg-gray-100"
                  onClick={_ => addInput()}
                />
              </div>
            </RenderIf>
          </div>
        )
        ->React.array}
      </div>
    }
  }
}

module WebHookAuthHeader = {
  module AuthenticationInput = {
    @react.component
    let make = (~index) => {
      open LogicUtils
      open FormRenderer
      let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
        ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
      )
      let (key, setKey) = React.useState(_ => "")
      let (metaValue, setValue) = React.useState(_ => "")
      let getOutGoingWebhook = () => {
        let outGoingWebhookDict =
          formState.values
          ->getDictFromJsonObject
          ->getDictfromDict("outgoing_webhook_custom_http_headers")
        let key = outGoingWebhookDict->Dict.keysToArray->LogicUtils.getValueFromArray(index, "")
        let outGoingWebHookVal = outGoingWebhookDict->getOptionString(key)
        switch outGoingWebHookVal {
        | Some(value) => (key, value)
        | _ => ("", "")
        }
      }
      React.useEffect(() => {
        let (outGoingWebhookKey, outGoingWebHookValue) = getOutGoingWebhook()
        setValue(_ => outGoingWebHookValue)
        setKey(_ => outGoingWebhookKey)

        None
      }, [])
      let form = ReactFinalForm.useForm()
      let keyInput: ReactFinalForm.fieldRenderPropsInput = {
        name: "string",
        onBlur: _ => (),
        onChange: ev => {
          let value = ReactEvent.Form.target(ev)["value"]
          if value->String.length <= 0 {
            let name = `outgoing_webhook_custom_http_headers.${key}`
            form.change(name, JSON.Encode.null)
          }
          switch value->getOptionIntFromString->Option.isNone {
          | true => setKey(_ => value)
          | _ => ()
          }
        },
        onFocus: _ => (),
        value: key->JSON.Encode.string,
        checked: true,
      }
      let valueInput: ReactFinalForm.fieldRenderPropsInput = {
        name: "string",
        onBlur: _ => {
          if key->String.length > 0 {
            let name = `outgoing_webhook_custom_http_headers.${key}`
            form.change(name, metaValue->JSON.Encode.string)
          }
        },
        onChange: ev => {
          let value = ReactEvent.Form.target(ev)["value"]
          setValue(_ => value)
        },
        onFocus: _ => (),
        value: metaValue->JSON.Encode.string,
        checked: true,
      }

      <DesktopRow wrapperClass="flex-1">
        <div className="mt-5">
          <TextInput input={keyInput} placeholder={"Enter key"} />
        </div>
        <div className="mt-5">
          <TextInput input={valueInput} placeholder={"Enter value"} />
        </div>
      </DesktopRow>
    }
  }
  module WebHookAuthenticationHeaders = {
    @react.component
    let make = () => {
      <div className="flex-1">
        <p
          className={`ml-4 text-fs-13 text-jp-gray-900 dark:text-jp-gray-text_darktheme dark:text-opacity-50 ml-1 !text-base !text-grey-700 font-semibold ml-1`}>
          {"Custom HTTP Headers"->React.string}
        </p>
        <div className="grid grid-cols-5 flex gap-2">
          {Array.fromInitializer(~length=4, i => i)
          ->Array.mapWithIndex((_, index) =>
            <div key={index->Int.toString} className="col-span-4">
              <AuthenticationInput index={index} />
            </div>
          )
          ->React.array}
        </div>
      </div>
    }
  }
}

module WebHook = {
  @react.component
  let make = (~setCustomHttpHeaders, ~enableCustomHttpHeaders) => {
    open FormRenderer
    open LogicUtils
    let {customWebhookHeaders, dynamicCustomWebhookHeaders} =
      HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
    let form = ReactFinalForm.useForm()
    let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
      ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
    )
    let h2RegularTextStyle = `${HSwitchUtils.getTextClass((H3, Leading_1))}`
    let webHookURL =
      formState.values
      ->getDictFromJsonObject
      ->getOptionString("webhook_url")
      ->Option.isSome
    let outGoingHeaders =
      formState.values
      ->getDictFromJsonObject
      ->getDictfromDict("outgoing_webhook_custom_http_headers")
      ->isEmptyDict

    React.useEffect(() => {
      if !webHookURL {
        setCustomHttpHeaders(_ => false)
        form.change("outgoing_webhook_custom_http_headers", JSON.Encode.null)
      }
      None
    }, [webHookURL])

    let updateCustomHttpHeaders = () => {
      setCustomHttpHeaders(_ => !enableCustomHttpHeaders)
    }
    React.useEffect(() => {
      if webHookURL && !outGoingHeaders {
        setCustomHttpHeaders(_ => true)
      }
      None
    }, [])
    <>
      <div>
        <div className="ml-4">
          <p className=h2RegularTextStyle> {"Webhook Setup"->React.string} </p>
        </div>
        <div className="ml-4 mt-4">
          <FieldRenderer
            field={DeveloperUtils.webhookUrl}
            labelClass="!text-base !text-grey-700 font-semibold"
            fieldWrapperClass="max-w-xl"
          />
        </div>
        <RenderIf condition={dynamicCustomWebhookHeaders || customWebhookHeaders}>
          <div className="ml-4">
            <div className={"mt-4 flex items-center text-jp-gray-700 font-bold self-start"}>
              <div className="font-semibold text-base text-black dark:text-white">
                {"Enable Custom HTTP Headers"->React.string}
              </div>
              <ToolTip description="Enter Webhook url to enable" toolTipPosition=ToolTip.Right />
            </div>
            <div className="mt-4">
              <BoolInput.BaseComponent
                boolCustomClass="rounded-lg"
                isSelected=enableCustomHttpHeaders
                size={Large}
                setIsSelected={_ => webHookURL ? updateCustomHttpHeaders() : ()}
              />
            </div>
          </div>
        </RenderIf>
      </div>
      <RenderIf condition={enableCustomHttpHeaders && dynamicCustomWebhookHeaders}>
        <DynamicWebHookAuthHeader.WebHookAuthenticationHeaders />
      </RenderIf>
      <RenderIf condition={enableCustomHttpHeaders && customWebhookHeaders}>
        <WebHookAuthHeader.WebHookAuthenticationHeaders />
      </RenderIf>
    </>
  }
}

module ReturnUrl = {
  @react.component
  let make = () => {
    open FormRenderer
    <>
      <DesktopRow>
        <FieldRenderer
          field={DeveloperUtils.returnUrl}
          errorClass={HSwitchUtils.errorClass}
          labelClass="!text-base !text-grey-700 font-semibold"
          fieldWrapperClass="max-w-xl"
        />
      </DesktopRow>
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
  open FormRenderer
  let getURL = useGetURL()
  let url = RescriptReactRouter.useUrl()
  let id = HSwitchUtils.getConnectorIDFromUrl(url.path->List.toArray, profileId)
  let businessProfileDetails = BusinessProfileHook.useGetBusinessProflile(id)
  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let showToast = ToastState.useShowToast()
  let updateDetails = useUpdateMethod()

  let (busiProfieDetails, setBusiProfie) = React.useState(_ => businessProfileDetails)

  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)
  let (enableCustomHttpHeaders, setCustomHttpHeaders) = React.useState(_ => false)
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
      open LogicUtils
      setScreenState(_ => PageLoaderWrapper.Loading)
      let valuesDict = values->getDictFromJsonObject
      if !enableCustomHttpHeaders {
        valuesDict->Dict.set("outgoing_webhook_custom_http_headers", JSON.Encode.null)
      }
      let url = getURL(~entityName=BUSINESS_PROFILE, ~methodType=Post, ~id=Some(id), ())
      let body = valuesDict->JSON.Encode.object->getBusinessProfilePayload->JSON.Encode.object
      let res = await updateDetails(url, body, Post, ())
      setBusiProfie(_ => res->BusinessProfileMapper.businessProfileTypeMapper)
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
      <RenderIf condition={!showFormOnly}>
        <BreadCrumbNavigation
          path=[
            {
              title: "Payment Settings",
              link: "/payment-settings",
            },
          ]
          currentPageTitle={busiProfieDetails.profile_name}
          cursorStyle="cursor-pointer"
        />
      </RenderIf>
      <div className={`${showFormOnly ? "" : "mt-4"}`}>
        <div
          className={`w-full ${showFormOnly
              ? ""
              : "border border-jp-gray-500 rounded-md dark:border-jp-gray-960"} ${bgClass} `}>
          <ReactFinalForm.Form
            key="merchantAccount"
            initialValues={busiProfieDetails->parseBussinessProfileJson->JSON.Encode.object}
            subscription=ReactFinalForm.subscribeToValues
            validate={values => {
              MerchantAccountUtils.validateMerchantAccountForm(
                ~values,
                ~fieldsToValidate={fieldsToValidate()},
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
                    heading="Profile ID" subHeading=busiProfieDetails.profile_id isCopy=true
                  />
                  <InfoViewForWebhooks
                    heading="Profile Name" subHeading=busiProfieDetails.profile_name
                  />
                </div>
                <div className="flex items-center">
                  <InfoViewForWebhooks
                    heading="Merchant ID" subHeading={busiProfieDetails.merchant_id}
                  />
                  <InfoViewForWebhooks
                    heading="Payment Response Hash Key"
                    subHeading={busiProfieDetails.payment_response_hash_key->Option.getOr("NA")}
                    isCopy=true
                  />
                </div>
                <DesktopRow>
                  <FieldRenderer
                    labelClass="!text-base !text-grey-700 font-semibold"
                    fieldWrapperClass="max-w-xl"
                    field={makeFieldInfo(
                      ~name="collect_shipping_details_from_wallet_connector",
                      ~label="Collect Shipping Details",
                      ~customInput=InputFields.boolInput(
                        ~isDisabled=false,
                        ~boolCustomClass="rounded-lg",
                        (),
                      ),
                      (),
                    )}
                  />
                  <FieldRenderer
                    labelClass="!text-base !text-grey-700 font-semibold"
                    fieldWrapperClass="max-w-xl"
                    field={makeFieldInfo(
                      ~name="is_connector_agnostic_mit_enabled",
                      ~label="Connector Agnostic",
                      ~customInput=InputFields.boolInput(
                        ~isDisabled=false,
                        ~boolCustomClass="rounded-lg",
                        (),
                      ),
                      (),
                    )}
                  />
                </DesktopRow>
                <RenderIf condition={isBusinessProfileHasThreeds}>
                  <DesktopRow>
                    <FieldRenderer
                      field={threedsConnectorList
                      ->Array.map(item => item.connector_name)
                      ->authenticationConnectors}
                      errorClass
                      labelClass="!text-base !text-grey-700 font-semibold"
                      fieldWrapperClass="max-w-xl"
                    />
                    <FieldRenderer
                      field={threeDsRequestorUrl}
                      errorClass
                      labelClass="!text-base !text-grey-700 font-semibold"
                      fieldWrapperClass="max-w-xl"
                    />
                  </DesktopRow>
                </RenderIf>
                <ReturnUrl />
                <WebHook enableCustomHttpHeaders setCustomHttpHeaders />
                <DesktopRow>
                  <div className="flex justify-start w-full">
                    <SubmitButton
                      customSumbitButtonStyle="justify-start"
                      text="Update"
                      buttonType=Button.Primary
                      buttonSize=Button.Small
                    />
                  </div>
                </DesktopRow>
                <FormValuesSpy />
              </form>
            }}
          />
        </div>
      </div>
    </div>
  </PageLoaderWrapper>
}
