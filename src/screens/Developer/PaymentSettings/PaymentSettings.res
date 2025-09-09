module InfoViewForWebhooks = {
  @react.component
  let make = (~heading, ~subHeading, ~isCopy=false) => {
    let showToast = ToastState.useShowToast()
    let onCopyClick = ev => {
      ev->ReactEvent.Mouse.stopPropagation
      Clipboard.writeText(subHeading)
      showToast(~message="Copied to Clipboard!", ~toastType=ToastSuccess)
    }

    <div className={`flex flex-col gap-2 m-2 md:m-4 w-1/2`}>
      <p className="font-semibold text-fs-15"> {heading->React.string} </p>
      <div className="flex gap-2 break-all w-full items-start">
        <p className="font-medium text-fs-14 text-black opacity-50"> {subHeading->React.string} </p>
        <RenderIf condition={isCopy}>
          <Icon
            name="nd-copy"
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

module AuthenticationInput = {
  @react.component
  let make = (~index, ~allowEdit, ~isDisabled) => {
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

    React.useEffect(() => {
      if allowEdit {
        setValue(_ => "")
      }
      None
    }, [allowEdit])
    let form = ReactFinalForm.useForm()
    let keyInput: ReactFinalForm.fieldRenderPropsInput = {
      name: "string",
      onBlur: _ => (),
      onChange: ev => {
        let value = ReactEvent.Form.target(ev)["value"]
        let regexForProfileName = "^([a-z]|[A-Z]|[0-9]|_|-)+$"
        let isValid = if value->String.length <= 2 {
          true
        } else if (
          value->isEmptyString ||
          value->String.length > 64 ||
          !RegExp.test(RegExp.fromString(regexForProfileName), value)
        ) {
          false
        } else {
          true
        }
        if value->String.length <= 0 {
          let name = `outgoing_webhook_custom_http_headers.${key}`
          form.change(name, JSON.Encode.null)
        }
        //Not allow users to enter just integers
        switch (value->getOptionIntFromString->Option.isNone, isValid) {
        | (true, true) => setKey(_ => value)
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
        <TextInput
          input={keyInput} placeholder={"Enter key"} isDisabled={isDisabled && !allowEdit}
        />
      </div>
      <div className="mt-5">
        <TextInput
          input={valueInput} placeholder={"Enter value"} isDisabled={isDisabled && !allowEdit}
        />
      </div>
    </DesktopRow>
  }
}
module WebHookAuthenticationHeaders = {
  @react.component
  let make = (~setAllowEdit, ~allowEdit) => {
    open LogicUtils
    let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
      ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
    )
    let form = ReactFinalForm.useForm()
    let outGoingWebhookDict =
      formState.values
      ->getDictFromJsonObject
      ->getDictfromDict("outgoing_webhook_custom_http_headers")
    let (showModal, setShowModal) = React.useState(_ => false)
    let (isDisabled, setDisabled) = React.useState(_ => true)

    let allowEditConfiguration = () => {
      form.change(`outgoing_webhook_custom_http_headers`, JSON.Encode.null)
      setAllowEdit(_ => true)
      setShowModal(_ => false)
    }
    React.useEffect(() => {
      let isEmpty = outGoingWebhookDict->LogicUtils.isEmptyDict
      setDisabled(_ => !isEmpty)
      setAllowEdit(_ => isEmpty)
      None
    }, [])
    <div className="flex-1">
      <div className="flex flex-row justify-between items-center gap-4 ">
        <p
          className={`text-xl dark:text-jp-gray-text_darktheme dark:text-opacity-50  !text-grey-700 font-semibold ml-4`}>
          {"Custom Headers"->React.string}
        </p>
        <RenderIf
          condition={!(outGoingWebhookDict->LogicUtils.isEmptyDict) && isDisabled && !allowEdit}>
          <div
            className="flex gap-2 items-center cursor-pointer"
            onClick={_ => setShowModal(_ => true)}>
            <Icon name="nd-edit" size=14 />
            <a className="text-primary cursor-pointer"> {"Edit"->React.string} </a>
          </div>
        </RenderIf>
      </div>
      <div className="grid grid-cols-5 gap-2">
        {Array.fromInitializer(~length=4, i => i)
        ->Array.mapWithIndex((_, index) =>
          <div key={index->Int.toString} className="col-span-4">
            <AuthenticationInput index={index} allowEdit isDisabled />
          </div>
        )
        ->React.array}
      </div>
      <Modal
        showModal
        setShowModal
        modalClass="w-full md:w-4/12 mx-auto my-40 border-t-8 border-t-orange-960 rounded-xl">
        <div className="relative flex items-start px-4 pb-10 pt-8 gap-4">
          <Icon
            name="warning-outlined" size=25 className="w-8" onClick={_ => setShowModal(_ => false)}
          />
          <div className="flex flex-col gap-5">
            <p className="font-bold text-2xl"> {"Edit the Current Configuration"->React.string} </p>
            <p className=" text-hyperswitch_black opacity-50 font-medium">
              {"Editing the current configuration will override the current active configuration."->React.string}
            </p>
          </div>
          <Icon
            className="absolute top-2 right-2"
            name="hswitch-close"
            size=22
            onClick={_ => setShowModal(_ => false)}
          />
        </div>
        <div className="flex items-end justify-end gap-4">
          <Button
            buttonType=Button.Primary onClick={_ => allowEditConfiguration()} text="Proceed"
          />
          <Button
            buttonType=Button.Secondary onClick={_ => setShowModal(_ => false)} text="Cancel"
          />
        </div>
      </Modal>
    </div>
  }
}

module WebHookSection = {
  @react.component
  let make = (~businessProfileDetails, ~setBusinessProfile, ~setScreenState, ~profileId="") => {
    open APIUtils
    open LogicUtils
    open FormRenderer
    open MerchantAccountUtils
    let getURL = useGetURL()
    let updateDetails = useUpdateMethod()
    let showToast = ToastState.useShowToast()
    let (allowEdit, setAllowEdit) = React.useState(_ => false)
    let {userInfo: {profileId}} = React.useContext(UserInfoProvider.defaultContext)
    let fetchBusinessProfileFromId = BusinessProfileHook.useFetchBusinessProfileFromId()

    let onSubmit = async (values, _) => {
      try {
        setScreenState(_ => PageLoaderWrapper.Loading)
        let valuesDict = values->getDictFromJsonObject
        let url = getURL(~entityName=V1(BUSINESS_PROFILE), ~methodType=Post, ~id=Some(profileId))
        let body = valuesDict->JSON.Encode.object->getCustomHeadersPayload->JSON.Encode.object
        let res = await updateDetails(url, body, Post)
        setBusinessProfile(_ => res->BusinessProfileMapper.businessProfileTypeMapper)
        fetchBusinessProfileFromId(~profileId=Some(profileId))->ignore
        showToast(~message=`Details updated`, ~toastType=ToastState.ToastSuccess)
        setAllowEdit(_ => false)
        setScreenState(_ => PageLoaderWrapper.Success)
      } catch {
      | _ => {
          setScreenState(_ => PageLoaderWrapper.Success)
          showToast(~message=`Failed to updated`, ~toastType=ToastState.ToastError)
        }
      }
      Nullable.null
    }

    <ReactFinalForm.Form
      key="auth"
      initialValues={businessProfileDetails->parseBussinessProfileJson->JSON.Encode.object}
      subscription=ReactFinalForm.subscribeToValues
      onSubmit
      render={({handleSubmit}) => {
        <form onSubmit={handleSubmit} className="flex flex-col gap-8 h-full w-full py-6 px-4">
          <WebHookAuthenticationHeaders setAllowEdit allowEdit />
          <DesktopRow>
            <div className="flex justify-end w-full gap-2">
              <RenderIf condition=allowEdit>
                <SubmitButton
                  text="Update"
                  buttonType=Button.Primary
                  buttonSize=Button.Medium
                  disabledParamter={!allowEdit}
                />
                <Button
                  buttonType=Button.Secondary
                  onClick={_ =>
                    RescriptReactRouter.push(
                      GlobalVars.appendDashboardPath(~url="/payment-settings"),
                    )}
                  text="Cancel"
                />
              </RenderIf>
            </div>
          </DesktopRow>
        </form>
      }}
    />
  }
}

module WebHook = {
  @react.component
  let make = () => {
    open FormRenderer

    <div className="ml-4 mt-4">
      <FieldRenderer
        field={DeveloperUtils.webhookUrl}
        labelClass="!text-fs-15 !text-grey-700 font-semibold"
        fieldWrapperClass="max-w-xl"
      />
    </div>
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
          labelClass="!text-fs-15 !text-grey-700 font-semibold"
          fieldWrapperClass="max-w-xl"
        />
      </DesktopRow>
    </>
  }
}

type options = {
  name: string,
  key: string,
}

module CollectDetails = {
  @react.component
  let make = (~title, ~subTitle, ~options: array<options>) => {
    open LogicUtils
    open FormRenderer
    let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
      ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
    )
    let valuesDict = formState.values->getDictFromJsonObject
    let initValue = options->Array.some(option => valuesDict->getBool(option.key, false))
    let (isSelected, setIsSelected) = React.useState(_ => initValue)
    let form = ReactFinalForm.useForm()

    let onClick = key => {
      options->Array.forEach(option => {
        form.change(option.key, (option.key === key)->JSON.Encode.bool)
      })
    }

    let p2RegularTextStyle = `${HSwitchUtils.getTextClass((P1, Medium))} text-grey-700 opacity-50`

    React.useEffect(() => {
      if isSelected {
        let value = options->Array.some(option => valuesDict->getBool(option.key, false))
        if !value {
          switch options->Array.get(0) {
          | Some(name) => form.change(name.key, true->JSON.Encode.bool)
          | _ => ()
          }
        }
      } else {
        options->Array.forEach(option => form.change(option.key, false->JSON.Encode.bool))
      }
      None
    }, [isSelected])
    <DesktopRow>
      <div className="w-full border-t border-gray-200 pt-8">
        <div className="flex justify-between items-center">
          <div className="flex-1 ">
            <p className="font-semibold text-fs-15"> {title->React.string} </p>
            <p className="font-medium text-fs-14 text-black opacity-50 pt-2">
              {subTitle->React.string}
            </p>
          </div>
          <BoolInput.BaseComponent
            isSelected
            setIsSelected={_ => setIsSelected(val => !val)}
            isDisabled=false
            boolCustomClass="rounded-lg"
          />
        </div>
        <RenderIf condition={isSelected}>
          <div className="mt-4">
            {options
            ->Array.mapWithIndex((option, index) =>
              <div
                key={index->Int.toString}
                className="flex gap-2 mb-3 items-center cursor-pointer"
                onClick={_ => onClick(option.key)}>
                <RadioIcon
                  isSelected={valuesDict->getBool(option.key, false)} fill="text-green-700"
                />
                <div className=p2RegularTextStyle>
                  {option.name->LogicUtils.snakeToTitle->React.string}
                </div>
              </div>
            )
            ->React.array}
          </div>
        </RenderIf>
      </div>
    </DesktopRow>
  }
}

module AutoRetries = {
  @react.component
  let make = (~setCheckMaxAutoRetry) => {
    open FormRenderer
    open DeveloperUtils
    open LogicUtils
    let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
      ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
    )
    let form = ReactFinalForm.useForm()
    let errorClass = "text-sm leading-4 font-medium text-start ml-1 mt-2"

    let isAutoRetryEnabled =
      formState.values->getDictFromJsonObject->getBool("is_auto_retries_enabled", false)

    React.useEffect(() => {
      if !isAutoRetryEnabled {
        form.change("max_auto_retries_enabled", JSON.Encode.null->Identity.genericTypeToJson)
        setCheckMaxAutoRetry(_ => false)
      } else {
        setCheckMaxAutoRetry(_ => true)
      }
      None
    }, [isAutoRetryEnabled])

    <>
      <DesktopRow>
        <FieldRenderer
          labelClass="!text-fs-15 !text-grey-700 font-semibold"
          fieldWrapperClass="w-full flex justify-between items-center border-t  border-gray-200 pt-8 "
          field={makeFieldInfo(
            ~name="is_auto_retries_enabled",
            ~label="Auto Retries",
            ~customInput=InputFields.boolInput(~isDisabled=false, ~boolCustomClass="rounded-lg"),
            ~description="Automatically re-attempts a failed payment using the same payment method details. Our system will continue retrying the transaction on a defined routed list until it is successful or all attempts have been exhausted.",
          )}
        />
      </DesktopRow>
      <RenderIf condition={isAutoRetryEnabled}>
        <FieldRenderer
          field={maxAutoRetries}
          errorClass
          labelClass="!text-fs-15 !text-grey-700 font-semibold"
          fieldWrapperClass="max-w-xl mx-4"
        />
      </RenderIf>
    </>
  }
}

module ClickToPaySection = {
  @react.component
  let make = () => {
    open FormRenderer
    open LogicUtils

    let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
    let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
      ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
    )
    let connectorListAtom = ConnectorListInterface.useFilteredConnectorList(
      ~retainInList=AuthenticationProcessor,
    )
    let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
    let connectorView = userHasAccess(~groupAccess=ConnectorsView) === Access
    let isClickToPayEnabled =
      formState.values->getDictFromJsonObject->getBool("is_click_to_pay_enabled", false)
    let dropDownOptions = connectorListAtom->Array.map((item): SelectBox.dropdownOption => {
      {
        label: `${item.connector_label} - ${item.id}`,
        value: item.id,
      }
    })

    <RenderIf condition={featureFlagDetails.clickToPay && connectorView}>
      <DesktopRow>
        <FieldRenderer
          labelClass="!text-fs-15 !text-grey-700 font-semibold"
          fieldWrapperClass="w-full flex justify-between items-center border-t border-gray-200 pt-8 "
          field={makeFieldInfo(
            ~name="is_click_to_pay_enabled",
            ~label="Click to Pay",
            ~customInput=InputFields.boolInput(~isDisabled=false, ~boolCustomClass="rounded-lg"),
            ~description="Click to Pay is a secure, seamless digital payment solution that lets customers checkout quickly using saved cards without entering details",
            ~toolTipPosition=Right,
          )}
        />
      </DesktopRow>
      <RenderIf condition={isClickToPayEnabled}>
        <DesktopRow>
          <FormRenderer.FieldRenderer
            labelClass="!text-fs-15 !text-grey-700 font-semibold"
            field={FormRenderer.makeFieldInfo(
              ~label="Click to Pay - Connector ID",
              ~name="authentication_product_ids.click_to_pay",
              ~placeholder="",
              ~customInput=InputFields.selectInput(
                ~options=dropDownOptions,
                ~buttonText="Select Click to Pay - Connector ID",
                ~deselectDisable=true,
              ),
            )}
          />
        </DesktopRow>
      </RenderIf>
    </RenderIf>
  }
}
module MerchantCategoryCode = {
  @react.component
  let make = () => {
    open FormRenderer

    let merchantCodeWithNameArray = React.useMemo(() => {
      try {
        Window.getMerchantCategoryCodeWithName()
      } catch {
      | Exn.Error(e) =>
        let _ = Exn.message(e)->Option.getOr("Error fetching merchant category codes")
        []
      }
    }, [])

    let errorClass = "text-sm leading-4 font-medium text-start ml-1"

    <DesktopRow>
      <FieldRenderer
        field={merchantCodeWithNameArray->DeveloperUtils.merchantCategoryCode}
        errorClass
        labelClass="!text-fs-15 !text-grey-700 font-semibold"
        fieldWrapperClass="max-w-xl  "
      />
    </DesktopRow>
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
  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let showToast = ToastState.useShowToast()
  let updateDetails = useUpdateMethod()
  let businessProfileRecoilVal =
    HyperswitchAtom.businessProfileFromIdAtom->Recoil.useRecoilValueFromAtom
  let (businessProfileDetails, setBusinessProfile) = React.useState(_ => businessProfileRecoilVal)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (checkMaxAutoRetry, setCheckMaxAutoRetry) = React.useState(_ => true)
  let {userInfo: {profileId}} = React.useContext(UserInfoProvider.defaultContext)
  let bgClass = webhookOnly ? "" : "bg-white dark:bg-jp-gray-lightgray_background"

  let threedsConnectorList = ConnectorListInterface.useFilteredConnectorList(
    ~retainInList=AuthenticationProcessor,
  )
  let isBusinessProfileHasThreeds =
    threedsConnectorList->Array.some(item => item.profile_id == profileId)
  let fetchBusinessProfileFromId = BusinessProfileHook.useFetchBusinessProfileFromId()

  let fieldsToValidate = () => {
    let defaultFieldsToValidate =
      [WebhookUrl, ReturnUrl]->Array.filter(urlField => urlField === WebhookUrl || !webhookOnly)
    if checkMaxAutoRetry {
      defaultFieldsToValidate->Array.push(MaxAutoRetries)
    }
    defaultFieldsToValidate
  }

  let onSubmit = async (values, _) => {
    try {
      open LogicUtils
      setScreenState(_ => PageLoaderWrapper.Loading)
      let valuesDict = values->getDictFromJsonObject
      let url = getURL(~entityName=V1(BUSINESS_PROFILE), ~methodType=Post, ~id=Some(profileId))
      let body = valuesDict->JSON.Encode.object->getBusinessProfilePayload->JSON.Encode.object
      let res = await updateDetails(url, body, Post)
      fetchBusinessProfileFromId(~profileId=Some(profileId))->ignore
      setBusinessProfile(_ => res->BusinessProfileMapper.businessProfileTypeMapper)
      showToast(~message=`Details updated`, ~toastType=ToastState.ToastSuccess)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => {
        setScreenState(_ => PageLoaderWrapper.Success)
        showToast(~message=`Failed to updated`, ~toastType=ToastState.ToastError)
      }
    }
    Nullable.null
  }

  React.useEffect(() => {
    if businessProfileRecoilVal.profile_id->LogicUtils.isNonEmptyString {
      setScreenState(_ => PageLoaderWrapper.Loading)
      setBusinessProfile(_ => businessProfileRecoilVal)
      setScreenState(_ => PageLoaderWrapper.Success)
    }
    None
  }, [businessProfileRecoilVal.profile_id, businessProfileRecoilVal.profile_name])

  <PageLoaderWrapper screenState>
    <PageUtils.PageHeading
      title="Payment settings"
      subTitle="Set up and monitor transaction webhooks for real-time notifications."
    />
    <div className={`${showFormOnly ? "" : "py-4 md:py-2"} h-full flex flex-col`}>
      <div className={`${showFormOnly ? "" : "mt-1"} flex flex-col gap-6`}>
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
                    heading="Profile Name" subHeading=businessProfileDetails.profile_name
                  />
                  <InfoViewForWebhooks
                    heading="Profile ID" subHeading=businessProfileDetails.profile_id isCopy=true
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
                <CollectDetails
                  title={"Collect billing details from wallets"}
                  subTitle={"Enable automatic collection of billing information when customers connect their wallets"}
                  options=[
                    {
                      name: "only if required by connector",
                      key: "collect_billing_details_from_wallet_connector",
                    },
                    {
                      name: "always",
                      key: "always_collect_billing_details_from_wallet_connector",
                    },
                  ]
                />
                <CollectDetails
                  title={"Collect shipping details from wallets"}
                  subTitle={"Enable automatic collection of shipping information when customers connect their wallets"}
                  options=[
                    {
                      name: "only if required by connector",
                      key: "collect_shipping_details_from_wallet_connector",
                    },
                    {
                      name: "always",
                      key: "always_collect_shipping_details_from_wallet_connector",
                    },
                  ]
                />
                <DesktopRow>
                  <FieldRenderer
                    labelClass="!text-fs-15 !text-grey-700 font-semibold"
                    fieldWrapperClass="w-full flex justify-between items-center border-t border-gray-200 pt-8 "
                    field={makeFieldInfo(
                      ~name="is_connector_agnostic_mit_enabled",
                      ~label="Connector Agnostic",
                      ~customInput=InputFields.boolInput(
                        ~isDisabled=false,
                        ~boolCustomClass="rounded-lg ",
                      ),
                    )}
                  />
                </DesktopRow>
                <DesktopRow>
                  <FieldRenderer
                    labelClass="!text-fs-15 !text-grey-700 font-semibold"
                    fieldWrapperClass="w-full flex justify-between items-center border-t border-gray-200 pt-8 "
                    field={makeFieldInfo(
                      ~name="force_3ds_challenge",
                      ~label="Force 3DS Challenge",
                      ~customInput=InputFields.boolInput(
                        ~isDisabled=false,
                        ~boolCustomClass="rounded-lg ",
                      ),
                    )}
                  />
                </DesktopRow>
                <DesktopRow>
                  <FieldRenderer
                    labelClass="!text-fs-15 !text-grey-700 font-semibold"
                    fieldWrapperClass="w-full flex justify-between items-center border-t border-gray-200 pt-8"
                    field={makeFieldInfo(
                      ~name="is_network_tokenization_enabled",
                      ~label="Network Tokenization",
                      ~customInput=InputFields.boolInput(
                        ~isDisabled=false,
                        ~boolCustomClass="rounded-lg",
                      ),
                    )}
                  />
                </DesktopRow>
                <DesktopRow>
                  <FieldRenderer
                    labelClass="!text-fs-15 !text-grey-700 font-semibold"
                    fieldWrapperClass="w-full flex justify-between items-center border-t border-gray-200 pt-8"
                    field={makeFieldInfo(
                      ~name="always_request_extended_authorization",
                      ~label="Extended Authorization",
                      ~customInput=InputFields.boolInput(
                        ~isDisabled=false,
                        ~boolCustomClass="rounded-lg",
                      ),
                      ~description="This will enable extended authorization for all payments through connectors and payment methods that support it",
                      ~toolTipPosition=Right,
                    )}
                  />
                </DesktopRow>
                <ClickToPaySection />
                <AutoRetries setCheckMaxAutoRetry />
                <DesktopRow>
                  <FieldRenderer
                    labelClass="!text-fs-15 !text-grey-700 font-semibold"
                    fieldWrapperClass="w-full flex justify-between items-center border-t border-gray-200 pt-8"
                    field={makeFieldInfo(
                      ~name="is_manual_retry_enabled",
                      ~label="Manual Retries",
                      ~customInput=InputFields.boolInput(
                        ~isDisabled=false,
                        ~boolCustomClass="rounded-lg",
                      ),
                      ~description="Allows you to manually re-attempt a failed payment using its original payment ID. You can retry with the same payment method details or provide a different payment method for the new attempt.",
                    )}
                  />
                </DesktopRow>
                <RenderIf condition={featureFlagDetails.debitRouting}>
                  <MerchantCategoryCode />
                </RenderIf>
                <RenderIf condition={isBusinessProfileHasThreeds}>
                  <DesktopRow wrapperClass="pt-4 flex !flex-col gap-4">
                    <FieldRenderer
                      field={threedsConnectorList
                      ->Array.map(item => item.connector_name)
                      ->authenticationConnectors}
                      errorClass
                      labelClass="!text-fs-15 !text-grey-700 font-semibold "
                      fieldWrapperClass="max-w-xl"
                    />
                    <FieldRenderer
                      field={threeDsRequestorUrl}
                      errorClass
                      labelClass="!text-fs-15 !text-grey-700 font-semibold"
                      fieldWrapperClass="max-w-xl"
                    />
                    <FieldRenderer
                      field={threeDsRequestoApprUrl}
                      errorClass
                      labelClass="!text-fs-15 !text-grey-700 font-semibold"
                      fieldWrapperClass="max-w-xl"
                    />
                  </DesktopRow>
                </RenderIf>
                <ReturnUrl />
                <WebHook />
                <DesktopRow>
                  <div className="flex justify-end w-full gap-2">
                    <SubmitButton
                      text="Update" buttonType=Button.Primary buttonSize=Button.Medium
                    />
                    <Button
                      buttonType=Button.Secondary
                      onClick={_ =>
                        RescriptReactRouter.push(
                          GlobalVars.appendDashboardPath(~url="/payment-settings"),
                        )}
                      text="Cancel"
                    />
                  </div>
                </DesktopRow>
                <FormValuesSpy />
              </form>
            }}
          />
        </div>
        <div className={` py-4 md:py-10 h-full flex flex-col `}>
          <div
            className={`border border-jp-gray-500 rounded-md dark:border-jp-gray-960"} ${bgClass}`}>
            <WebHookSection businessProfileDetails setBusinessProfile setScreenState profileId />
          </div>
        </div>
        <div className="py-4 md:py-10 h-full flex flex-col">
          <div
            className={`border border-jp-gray-500 rounded-md dark:border-jp-gray-960"} ${bgClass}`}>
            <PaymentSettingsMetadata
              businessProfileDetails setBusinessProfile setScreenState profileId
            />
          </div>
        </div>
        <RenderIf condition={featureFlagDetails.acquirerConfigSettings}>
          <AcquirerConfigSettings />
        </RenderIf>
      </div>
    </div>
  </PageLoaderWrapper>
}
