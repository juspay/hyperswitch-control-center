open PaymentSettingsV2Types
open PaymentSettingsV2Helper
open Typography
module CollectDetails = {
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
            <p className={`${body.lg.semibold} text-nd_gray-700`}> {title->React.string} </p>
            <p className={`${body.md.medium} text-nd_gray-400 pt-2`}> {subTitle->React.string} </p>
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
                <div className={`${body.md.medium}text-nd_gray-700`}>
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
  let make = () => {
    open FormRenderer
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
          labelClass={`!${body.lg.semibold} !text-nd-gray-700`}
          fieldWrapperClass="w-full flex justify-between items-center py-8 "
          field={makeFieldInfo(
            ~name="is_auto_retries_enabled",
            ~label="Auto Retries",
            ~customInput=InputFields.boolInput(
              ~isDisabled=false,
              ~boolCustomClass="rounded-lg",
              ~toggleEnableColor="bg-nd_primary_blue-450",
            ),
            ~description="Automatically re-attempts a failed payment using the same payment method details. Our system will continue retrying the transaction on a defined routed list until it is successful or all attempts have been exhausted.",
          )}
        />
      </DesktopRow>
      <RenderIf condition={isAutoRetryEnabledFormVal}>
        <FieldRenderer
          field={maxAutoRetries}
          errorClass
          labelClass={`!${body.lg.semibold} !text-nd-gray-700`}
          fieldWrapperClass="pb-8 "
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
    <>
      <RenderIf condition={featureFlagDetails.clickToPay && connectorView}>
        <DesktopRow itemWrapperClass="mx-1">
          <div>
            <FieldRenderer
              labelClass={`!${body.lg.semibold} !text-nd-gray-700`}
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
                labelClass={`!${body.lg.semibold} !text-nd-gray-700`}
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

module WebHook = {
  @react.component
  let make = () => {
    open FormRenderer

    <div className="ml-1 mt-4">
      <FieldRenderer
        field={webhookUrl}
        labelClass={`!${body.lg.semibold} !text-nd-gray-700`}
        fieldWrapperClass="max-w-xl  "
      />
    </div>
  }
}

module ReturnUrl = {
  @react.component
  let make = () => {
    open FormRenderer
    <div className="ml-1 mt-4">
      <FieldRenderer
        field={returnUrl}
        errorClass={HSwitchUtils.errorClass}
        labelClass={`!${body.lg.semibold} !text-nd-gray-700`}
        fieldWrapperClass="max-w-xl pt-8 border-nd_gray-200"
      />
    </div>
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

    <DesktopRow itemWrapperClass="mx-1">
      <FieldRenderer
        field={merchantCodeWithNameArray->DeveloperUtils.merchantCategoryCode}
        errorClass
        labelClass={`!${body.lg.semibold} !text-nd-gray-700`}
        fieldWrapperClass="max-w-xl py-8 "
      />
    </DesktopRow>
  }
}
module SplitTransactions = {
  @react.component
  let make = () => {
    open FormRenderer

    let customSplitTransactionInput = (
      ~input: ReactFinalForm.fieldRenderPropsInput,
      ~placeholder as _,
    ) => {
      let currentValue = switch input.value->JSON.Classify.classify {
      | String(str) => str === "enable"
      | _ => false
      }

      let handleChange = newValue => {
        let valueToSet = newValue ? "enable" : "skip"
        input.onChange(valueToSet->Identity.anyTypeToReactEvent)
      }

      <BoolInput.BaseComponent
        isSelected={currentValue}
        setIsSelected={handleChange}
        isDisabled=false
        boolCustomClass="rounded-lg"
        toggleEnableColor="bg-nd_primary_blue-450"
      />
    }

    <DesktopRow itemWrapperClass="mx-1">
      <FieldRenderer
        labelClass={`!${body.lg.semibold} !text-nd-gray-700`}
        fieldWrapperClass="w-full flex justify-between items-center py-8"
        field={makeFieldInfo(
          ~name="split_txns_enabled",
          ~label="Split Transactions",
          ~customInput=customSplitTransactionInput,
        )}
      />
    </DesktopRow>
  }
}

@react.component
let make = () => {
  open FormRenderer

  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let showToast = ToastState.useShowToast()
  let {version} = React.useContext(UserInfoProvider.defaultContext).getCommonDetails()

  let businessProfileRecoilVal = Recoil.useRecoilValueFromAtom(
    HyperswitchAtom.businessProfileFromIdAtomInterface,
  )
  let updateBusinessProfile = BusinessProfileHook.useUpdateBusinessProfile(~version)

  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)
  let onSubmit = async (values, _) => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let _ = await updateBusinessProfile(~body=values, ~shouldTransform=true)

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
      initialValues={businessProfileRecoilVal->Identity.genericTypeToJson}
      onSubmit
      validate={values => {
        PaymentSettingsV2Utils.validateMerchantAccountFormV2(
          ~values,
          ~isLiveMode=featureFlagDetails.isLiveMode,
          ~businessProfileRecoilVal,
        )
      }}>
      <RenderIfVersion visibleForVersion=V1>
        <CollectDetails
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
        <CollectDetails
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
        <AutoRetries />
        <hr />
        <DesktopRow itemWrapperClass="mx-1">
          <FieldRenderer
            labelClass={`!${body.lg.semibold} !text-nd-gray-700`}
            fieldWrapperClass="w-full flex justify-between sitems-center border-nd_gray-200 py-8"
            field={makeFieldInfo(
              ~name="is_manual_retry_enabled",
              ~label="Manual Retries",
              ~customInput=InputFields.boolInput(
                ~isDisabled=false,
                ~boolCustomClass="rounded-lg",
                ~toggleEnableColor="bg-nd_primary_blue-450",
              ),
              ~description="Allows you to manually re-attempt a failed payment using its original payment ID. You can retry with the same payment method details or provide a different payment method for the new attempt.",
            )}
          />
        </DesktopRow>
        <hr />
        <DesktopRow itemWrapperClass="mx-1">
          <FieldRenderer
            labelClass={`!${body.lg.semibold} !text-nd-gray-700`}
            fieldWrapperClass="w-full flex justify-between items-center border-nd_gray-200 py-8"
            field={makeFieldInfo(
              ~name="always_request_extended_authorization",
              ~label="Extended Authorization",
              ~customInput=InputFields.boolInput(
                ~isDisabled=false,
                ~boolCustomClass="rounded-lg",
                ~toggleEnableColor="bg-nd_primary_blue-450",
              ),
              ~description="This will enable extended authorization for all payments through connectors and payment methods that support it",
              ~toolTipPosition=Right,
            )}
          />
        </DesktopRow>
        <hr />
        <DesktopRow itemWrapperClass="mx-1">
          <FieldRenderer
            labelClass={`!${body.lg.semibold} !text-nd-gray-700`}
            fieldWrapperClass="w-full flex justify-between items-center border-nd_gray-200 py-8"
            field={makeFieldInfo(
              ~name="always_enable_overcapture",
              ~label="Always Enable Overcapture",
              ~customInput=InputFields.boolInput(
                ~isDisabled=false,
                ~boolCustomClass="rounded-lg",
                ~toggleEnableColor="bg-nd_primary_blue-450",
              ),
              ~description="Allow capturing more than the originally authorized amount within connector limits",
              ~toolTipPosition=Right,
            )}
          />
        </DesktopRow>
        <hr />
      </RenderIfVersion>
      <RenderIfVersion visibleForVersion=V2>
        <CollectDetails
          title="Collect billing details from wallets"
          subTitle="Enable automatic collection of billing information when customers connect their wallets"
          options=[
            {
              name: "only if required by connector",
              key: "collect_billing_details_from_wallet_connector_if_required",
            },
            {
              name: "always",
              key: "always_collect_billing_details_from_wallet_connector",
            },
          ]
        />
        <hr />
        <CollectDetails
          title="Collect shipping details from wallets"
          subTitle="Enable automatic collection of shipping information when customers connect their wallets"
          options=[
            {
              name: "only if required by connector",
              key: "collect_shipping_details_from_wallet_connector_if_required",
            },
            {
              name: "always",
              key: "always_collect_shipping_details_from_wallet_connector",
            },
          ]
        />
        <hr />
        <SplitTransactions />
        <hr />
      </RenderIfVersion>
      <DesktopRow itemWrapperClass="mx-1">
        <FieldRenderer
          labelClass={`!${body.lg.semibold} !text-nd-gray-700`}
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
      <DesktopRow itemWrapperClass="mx-1">
        <FieldRenderer
          labelClass={`!${body.lg.semibold} !text-nd-gray-700`}
          fieldWrapperClass="w-full flex justify-between items-center border-nd_gray-200 py-8"
          field={makeFieldInfo(
            ~name="is_network_tokenization_enabled",
            ~label="Network Tokenization",
            ~customInput=InputFields.boolInput(
              ~isDisabled=false,
              ~boolCustomClass="rounded-lg",
              ~toggleEnableColor="bg-nd_primary_blue-450",
            ),
          )}
        />
      </DesktopRow>
      <hr />
      <RenderIf condition={featureFlagDetails.debitRouting}>
        <MerchantCategoryCode />
        <hr />
      </RenderIf>
      <ClickToPaySection />
      <hr />
      <ReturnUrl />
      <WebHook />
      <DesktopRow wrapperClass="mt-8">
        <div className="flex justify-end mt-4 w-full">
          <SubmitButton text="Update" buttonType=Button.Primary buttonSize=Button.Medium />
        </div>
      </DesktopRow>
    </Form>
  </PageLoaderWrapper>
}
