open PaymentSettingsV2Types
module CollectDetailsV2 = {
  @react.component
  let make = (~title, ~subTitle, ~options: array<options>) => {
    open LogicUtils
    open FormRenderer
    let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
      ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
    )
    let defaultOption = {
      name: "",
      key: "",
    }
    let valuesDict = formState.values->getDictFromJsonObject
    let initValue = options->Array.some(option => valuesDict->getBool(option.key, false))
    let form = ReactFinalForm.useForm()

    let onClick = key => {
      options->Array.forEach(option => {
        form.change(option.key, (option.key === key)->JSON.Encode.bool)
      })
    }
    let handleToggle = newValue => {
      if newValue {
        let value = options->Array.some(option => valuesDict->getBool(option.key, false))
        let firstOption = options->getValueFromArray(0, defaultOption)
        if !value {
          if firstOption.key->isNonEmptyString {
            form.change(firstOption.key, true->JSON.Encode.bool)
          }
        }
      } else {
        options->Array.forEach(option => form.change(option.key, false->JSON.Encode.bool))
      }
    }

    <DesktopRow itemWrapperClass="mx-1">
      <div className="w-full py-8 ">
        <div className="flex justify-between items-center">
          <div className="flex-1 ">
            <p className="font-bold text-fs-16 text-nd_gray-600"> {title->React.string} </p>
            <p className="font-medium text-fs-14 text-nd_gray-400 pt-2">
              {subTitle->React.string}
            </p>
          </div>
          <BoolInput.BaseComponent
            isSelected={initValue}
            setIsSelected={handleToggle}
            isDisabled=false
            boolCustomClass="rounded-lg  "
            toggleEnableColor="bg-nd_primary_blue-450"
          />
        </div>
        <RenderIf condition={initValue}>
          <div className="mt-4">
            {options
            ->Array.mapWithIndex((option, index) =>
              <div
                key={index->Int.toString}
                className="flex gap-2  items-center cursor-pointer"
                onClick={_ => onClick(option.key)}>
                <RadioIcon
                  isSelected={valuesDict->getBool(option.key, false)}
                  fill="text-nd_primary_blue-450"
                />
                <div className="text-fs-14 font-medium text-nd_gray-600">
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

module AutoRetriesV2 = {
  @react.component
  let make = () => {
    open FormRenderer
    open DeveloperUtils
    open LogicUtils
    let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
      ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
    )
    let errorClass = "text-sm leading-4 font-medium text-start ml-1 mt-2"
    let isAutoRetryEnabledFormVal =
      formState.values->getDictFromJsonObject->getBool("is_auto_retries_enabled", false)
    <>
      <DesktopRow itemWrapperClass="mx-1">
        <FieldRenderer
          labelClass="!text-fs-15 !text-grey-700 font-semibold"
          fieldWrapperClass="w-full flex justify-between items-center py-8 "
          field={makeFieldInfo(
            ~name="is_auto_retries_enabled",
            ~label="Auto Retries",
            ~customInput=InputFields.boolInput(
              ~isDisabled=false,
              ~boolCustomClass="rounded-lg",
              ~toggleEnableColor="bg-nd_primary_blue-450",
            ),
          )}
        />
      </DesktopRow>
      <RenderIf condition={isAutoRetryEnabledFormVal}>
        <FieldRenderer
          field={maxAutoRetriesV2}
          errorClass
          labelClass="!text-fs-15 !text-grey-700 font-semibold"
          fieldWrapperClass="pb-8 "
        />
      </RenderIf>
    </>
  }
}

module ClickToPaySectionV2 = {
  @react.component
  let make = () => {
    open FormRenderer
    open LogicUtils

    let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
    let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
      ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
    )
    let connectorListAtom = ConnectorInterface.useConnectorArrayMapper(
      ~interface=ConnectorInterface.connectorInterfaceV1,
      ~retainInList=AuthenticationProcessor,
    )
    let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
    let connectorView = userHasAccess(~groupAccess=ConnectorsView) === Access
    let isClickToPayEnabled =
      formState.values->getDictFromJsonObject->getBool("is_click_to_pay_enabled", false)
    let dropDownOptions = connectorListAtom->Array.map((item): SelectBox.dropdownOption => {
      {
        label: `${item.connector_label} - ${item.merchant_connector_id}`,
        value: item.merchant_connector_id,
      }
    })
    <>
      <RenderIf condition={featureFlagDetails.clickToPay && connectorView}>
        <DesktopRow itemWrapperClass="mx-1">
          <div>
            <FieldRenderer
              labelClass="!text-fs-15 !text-grey-700 font-semibold"
              fieldWrapperClass="w-full flex justify-between items-center pt-8 pb-8  "
              field={makeFieldInfo(
                ~name="is_click_to_pay_enabled",
                ~label="Click to Pay",
                ~customInput=InputFields.boolInput(
                  ~isDisabled=false,
                  ~boolCustomClass="rounded-lg",
                  ~toggleEnableColor="bg-nd_primary_blue-450",
                ),
                ~description="Click to Pay is a secure, seamless digital payment solution that lets customers checkout quickly using saved cards without entering details",
                ~toolTipPosition=Right,
              )}
            />
          </div>
        </DesktopRow>
        <RenderIf condition={isClickToPayEnabled}>
          <DesktopRow itemWrapperClass="mx-1">
            <div>
              <FormRenderer.FieldRenderer
                labelClass="!text-fs-15 !text-grey-700 font-semibold"
                fieldWrapperClass="pb-4"
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
            </div>
          </DesktopRow>
        </RenderIf>
      </RenderIf>
    </>
  }
}

module WebHookV2 = {
  @react.component
  let make = () => {
    open FormRenderer

    <div className="ml-1 mt-4">
      <FieldRenderer
        field={DeveloperUtils.webhookUrlV2}
        labelClass="!text-fs-15 !text-grey-700 font-semibold"
        fieldWrapperClass="max-w-xl  "
      />
    </div>
  }
}

module ReturnUrlV2 = {
  @react.component
  let make = () => {
    open FormRenderer
    <div className="ml-1 mt-4">
      <FieldRenderer
        field={DeveloperUtils.returnUrlV2}
        errorClass={HSwitchUtils.errorClass}
        labelClass="!text-fs-15 !text-grey-700 font-semibold"
        fieldWrapperClass="max-w-xl pt-8 border-gray-200 "
      />
    </div>
  }
}

@react.component
let make = () => {
  open APIUtils
  open FormRenderer

  let getURL = useGetURL()
  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let showToast = ToastState.useShowToast()
  let updateDetails = useUpdateMethod()
  let fetchBusinessProfileFromId = BusinessProfileHook.useFetchBusinessProfileFromId()
  let {userInfo: {profileId}} = React.useContext(UserInfoProvider.defaultContext)
  let businessProfileRecoilVal =
    HyperswitchAtom.businessProfileFromIdAtom->Recoil.useRecoilValueFromAtom
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)

  let onSubmit = async (values, _) => {
    try {
      open LogicUtils
      setScreenState(_ => PageLoaderWrapper.Loading)
      let valuesDict = values->getDictFromJsonObject
      let url = getURL(~entityName=V1(BUSINESS_PROFILE), ~methodType=Post, ~id=Some(profileId))
      let body = valuesDict->JSON.Encode.object
      let _ = await updateDetails(url, body, Post)
      let _ = await fetchBusinessProfileFromId(~profileId=Some(profileId))

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
  <PageLoaderWrapper screenState>
    <Form
      initialValues={businessProfileRecoilVal
      ->PaymentSettingsUtils.parseBusinessProfileForPaymentBehaviour
      ->Identity.genericTypeToJson}
      onSubmit
      validate={values => {
        PaymentSettingsUtils.validateMerchantAccountFormV2(
          ~values,
          ~isLiveMode=featureFlagDetails.isLiveMode,
        )
      }}>
      <CollectDetailsV2
        title="Collect billing details from wallets"
        subTitle="Enable automatic collection of billing information when customers connect their wallets"
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
      <hr />
      <CollectDetailsV2
        title="Collect shipping details from wallets"
        subTitle="Enable automatic collection of shipping information when customers connect their wallets"
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
      <hr />
      <DesktopRow itemWrapperClass="mx-1">
        <FieldRenderer
          labelClass="!text-fs-15 !text-grey-700 font-semibold"
          fieldWrapperClass="w-full flex justify-between items-center py-8"
          field={makeFieldInfo(
            ~name="is_connector_agnostic_mit_enabled",
            ~label="Connector Agnostic",
            ~customInput=InputFields.boolInput(
              ~isDisabled=false,
              ~boolCustomClass="rounded-lg ",
              ~toggleEnableColor="bg-nd_primary_blue-450",
            ),
          )}
        />
      </DesktopRow>
      <hr />
      <ClickToPaySectionV2 />
      <hr />
      <AutoRetriesV2 />
      <hr />
      <ReturnUrlV2 />
      <WebHookV2 />
      <DesktopRow wrapperClass="mt-8">
        <div className="flex justify-end mt-4 w-full">
          <SubmitButton text="Update" buttonType=Button.Primary buttonSize=Button.Medium />
        </div>
      </DesktopRow>
    </Form>
  </PageLoaderWrapper>
}
