open LogicUtils
open PaymentLinkThemeConfiguratorTypes
open PaymentLinkThemeConfiguratorUtils

module ConfiguratorForm = {
  @react.component
  let make = (~initialFormValues, ~selectedStyleId) => {
    open Typography
    open FormRenderer
    open PaymentLinkThemeConfiguratorHelper
    let configuratorScrollbarCss = `
      .configurator-scrollbar {
        scrollbar-width: thin;
        scrollbar-color: #9CA3AF #F3F4F6;
      }
      .configurator-scrollbar::-webkit-scrollbar {
        width: 6px;
        height: 6px;
      }
      .configurator-scrollbar::-webkit-scrollbar-thumb {
        background-color: #9CA3AF;
        border-radius: 10px;
      }
      .configurator-scrollbar::-webkit-scrollbar-track {
        background-color: #F3F4F6;
        border-radius: 10px;
      }
    `

    let showToast = ToastState.useShowToast()
    let (initialValues, setInitialValues) = React.useState(_ => initialFormValues)

    React.useEffect(() => {
      setInitialValues(_ => initialFormValues)
      None
    }, [initialFormValues])

    let (previewState, setPreviewState) = React.useState(_ => PreviewLoading)
    let {paymentResult, initialValuesForCheckoutForm} = React.useContext(SDKProvider.defaultContext)

    let isOffSession = Option.equal(
      initialValuesForCheckoutForm.setup_future_usage,
      Some((OffSession :> string)),
      (a, b) => a == b,
    )

    let merchantDetailsTypedValue = Recoil.useRecoilValueFromAtom(
      HyperswitchAtom.merchantDetailsValueAtom,
    )
    let businessProfileRecoilVal = Recoil.useRecoilValueFromAtom(
      HyperswitchAtom.businessProfileFromIdAtomInterface,
    )
    let updateBusinessProfile = BusinessProfileHook.useUpdateBusinessProfile()

    let generatePreview = (~values) => {
      let publishableKey = merchantDetailsTypedValue.publishable_key

      try {
        setPreviewState(_ => PreviewLoading)

        let configs = generateWasmPayload(
          ~paymentDetails=paymentResult,
          ~publishableKey,
          ~formValues=values,
        )

        let validationResult = Window.validatePaymentLinkConfig(
          JSON.stringify(configs->Identity.genericTypeToJson),
        )
        switch validationResult->safeParseOpt {
        | Some(validationJson) =>
          let validationDict = validationJson->getDictFromJsonObject
          let isValid = validationDict->getBool("valid", false)
          let errors = validationDict->getArrayFromDict("errors", [])

          if !isValid {
            let errorMessages =
              errors->Array.map(error => error->getStringFromJson("Unknown validation error"))

            let combinedErrors = errorMessages->Array.joinWith(", ")
            setPreviewState(_ => PreviewError(`Validation failed: ${combinedErrors}`))
          } else {
            let response = Window.generatePaymentLinkPreview(
              JSON.stringify(configs->Identity.genericTypeToJson),
            )
            setPreviewState(_ => PreviewSuccess(response))
          }
        | None => setPreviewState(_ => PreviewError("Invalid preview validation response"))
        }
      } catch {
      | Exn.Error(e) => {
          let errorMessage = Exn.message(e)->Option.getOr("WASM function failed")
          setPreviewState(_ => PreviewError(errorMessage))
        }
      }
    }

    let debouncedGeneratePreview = ReactDebounce.useDebounced(
      values => generatePreview(~values),
      ~wait=400,
    )

    React.useEffect(() => {
      debouncedGeneratePreview(initialValues)
      None
    }, [initialValues])

    let onSubmit = async (values, isAutoSubmit) => {
      setInitialValues(_ => values)

      if !isAutoSubmit {
        try {
          let body = constructBusinessProfileBodyFromJson(
            ~json=values,
            ~paymentLinkConfig=businessProfileRecoilVal.payment_link_config,
            ~styleID=selectedStyleId,
          )
          let dict = [("payment_link_config", body->Identity.genericTypeToJson)]->Dict.fromArray
          let _ = await updateBusinessProfile(~body=dict->JSON.Encode.object)
          showToast(
            ~toastType=ToastSuccess,
            ~message="Configuration Saved Successfully!",
            ~autoClose=true,
          )
        } catch {
        | Exn.Error(e) =>
          let errorMessage =
            Exn.message(e)->Option.getOr("Failed to save payment link configuration")
          showToast(~toastType=ToastError, ~message=errorMessage, ~autoClose=true)
        }
      }

      Nullable.null
    }

    <RenderIf condition={selectedStyleId->isNonEmptyString}>
      <div className="grid grid-cols-1 lg:grid-cols-[1fr_2fr] gap-8 w-full bg-white rounded-lg">
        <div className="space-y-4">
          <h4 className={`text-nd_gray-700 mb-3 ${body.xl.semibold}`}>
            {"Payment Link Settings"->React.string}
          </h4>
          <Form
            formClass="space-y-4" initialValues onSubmit={(values, _) => onSubmit(values, false)}>
            <HelperComponents.AutoSubmitter
              autoApply=true submit={(values, _) => onSubmit(values, true)} submitInputOnEnter=true
            />
            <style> {React.string(configuratorScrollbarCss)} </style>
            <div
              className="flex flex-col gap-3 rounded-lg border border-nd_gray-150 p-4 h-650-px overflow-scroll configurator-scrollbar !m-0">
              <FieldRenderer field={makeLogoField()} fieldWrapperClass="!w-full" />
              <FieldRenderer field={makeSellerNameField()} fieldWrapperClass="!w-full" />
              <FieldRenderer field={makeMerchantDescriptionField()} fieldWrapperClass="!w-full" />
              <FieldRenderer field={makePaymentButtonTextField()} fieldWrapperClass="!w-full" />
              <RenderIf condition={isOffSession}>
                <FieldRenderer
                  field={makeCustomMessageForCardTermsField()} fieldWrapperClass="!w-full"
                />
                <FieldRenderer field={makeShowCardTermsField()} fieldWrapperClass="!w-full" />
              </RenderIf>
              <FieldRenderer
                field={makeHideCardNicknameField()}
                fieldWrapperClass="!w-full flex flex-row items-center justify-between py-2"
                labelPadding="py-0"
              />
              <FieldRenderer
                field={makeDisplaySdkOnlyField()}
                fieldWrapperClass="!w-full flex flex-row items-center justify-between py-2"
                labelPadding="py-0"
              />
              <FieldRenderer
                field={makeBrandingVisibilityField()}
                fieldWrapperClass="!w-full flex flex-row items-center justify-between py-2"
                labelPadding="py-0"
              />
              <FieldRenderer
                field={makeThemeField(
                  ~defaultValue=initialValues
                  ->getDictFromJsonObject
                  ->getString("theme", ""),
                )}
                fieldWrapperClass="!w-full"
              />
              <FieldRenderer
                field={makeBackgroundColorField(
                  ~defaultValue=initialValues
                  ->getDictFromJsonObject
                  ->getString("background_colour", ""),
                )}
                fieldWrapperClass="!w-full"
              />
              <FieldRenderer
                field={makePaymentButtonColorField(
                  ~defaultValue=initialValues
                  ->getDictFromJsonObject
                  ->getString("payment_button_colour", ""),
                )}
                fieldWrapperClass="!w-full"
              />
              <FieldRenderer
                field={makePaymentButtonTextColorField(
                  ~defaultValue=initialValues
                  ->getDictFromJsonObject
                  ->getString("payment_button_text_colour", ""),
                )}
                fieldWrapperClass="!w-full"
              />
              <FieldRenderer
                field={makeColorIconCardCvcErrorField(
                  ~defaultValue=initialValues
                  ->getDictFromJsonObject
                  ->getString("color_icon_card_cvc_error", ""),
                )}
                fieldWrapperClass="!w-full"
              />
              <FieldRenderer field={makeDetailsLayoutField()} fieldWrapperClass="!w-full" />
              <FieldRenderer field={makeSdkLayoutField()} fieldWrapperClass="!w-full" />
            </div>
            <div className="flex justify-between pt-4">
              <SubmitButton
                text="Save Payment Link Theme" buttonType={Primary} buttonSize={Medium}
              />
            </div>
          </Form>
        </div>
        <div className="sticky top-4">
          <div className="flex items-center justify-between mb-3">
            <h4 className={`text-nd_gray-700 ${body.xl.semibold}`}>
              {"Theme Preview"->React.string}
            </h4>
          </div>
          <div className="bg-nd_gray-25 rounded-lg border border-nd_gray-150 h-650-px">
            <MobilePreviewFrame>
              <div className="rounded-lg w-full h-590-px flex flex-col bg-white">
                {switch previewState {
                | PreviewLoading =>
                  <div className="flex items-center justify-center h-full w-full">
                    <div className="text-center">
                      <div className="animate-pulse space-y-4 w-full">
                        <div className="h-32 bg-nd_gray-200 rounded w-full" />
                        <div className="h-4 bg-nd_gray-200 rounded w-1/2 mx-auto" />
                        <div className="h-4 bg-nd_gray-200 rounded w-2/3 mx-auto" />
                        <div className="h-4 bg-nd_gray-200 rounded w-3/4 mx-auto" />
                      </div>
                      <p className={`text-nd_gray-500 mt-4 ${body.md.medium}`}>
                        {"Generating preview..."->React.string}
                      </p>
                    </div>
                  </div>
                | PreviewError(error) =>
                  <div className="flex items-center justify-center h-full w-full">
                    <div className="text-center">
                      <div className="text-nd_red-500 mb-4">
                        <Icon name="cross-icon" size=24 />
                      </div>
                      <p className={`text-nd_red-600 mb-2 ${body.md.medium}`}>
                        {"Preview Generation Failed"->React.string}
                      </p>
                      <p className={`text-nd_gray-500 max-w-md ${body.md.medium}`}>
                        {error->React.string}
                      </p>
                    </div>
                  </div>
                | PreviewSuccess(html) =>
                  <div className="h-full flex-1 overflow-hidden rounded-lg bg-white relative">
                    <iframe
                      className="w-full h-full border-0"
                      style={ReactDOM.Style.make(
                        ~transform="scale(0.75)",
                        ~transformOrigin="top left",
                        ~width="133%",
                        ~height="133%",
                        (),
                      )}
                      srcDoc=html
                      sandbox="allow-scripts allow-same-origin"
                      title="Payment Link Preview"
                    />
                  </div>
                }}
              </div>
            </MobilePreviewFrame>
          </div>
        </div>
      </div>
    </RenderIf>
  }
}

module CreateNewStyleID = {
  @react.component
  let make = (~setSelectedStyleId) => {
    open FormRenderer
    open Typography
    let showToast = ToastState.useShowToast()
    let (showModal, setShowModal) = React.useState(() => false)
    let businessProfileRecoilVal = Recoil.useRecoilValueFromAtom(
      HyperswitchAtom.businessProfileFromIdAtomInterface,
    )
    let updateBusinessProfile = BusinessProfileHook.useUpdateBusinessProfile()
    let customStyle = "text-primary bg-white dark:bg-black hover:bg-jp-gray-100 text-nowrap w-full"

    let styleIdField = makeFieldInfo(
      ~label="Payment Link Config ID",
      ~name="payment_link_config_id",
      ~customInput=(~input, ~placeholder as _) =>
        InputFields.textInput()(
          ~input={
            ...input,
            onChange: event =>
              ReactEvent.Form.target(event)["value"]
              ->String.trimStart
              ->Identity.stringToFormReactEvent
              ->input.onChange,
          },
          ~placeholder="Eg: my_payment_link_config_id",
        ),
      ~isRequired=true,
    )

    let createNewStyleID = async (values, _) => {
      try {
        let valuesDict = values->getDictFromJsonObject
        let styleId = valuesDict->getString("payment_link_config_id", "")->String.trim
        setShowModal(_ => false)
        let config = businessProfileRecoilVal.payment_link_config
        let body = constructBusinessProfileBody(~paymentLinkConfig=config, ~styleID=styleId)
        let dict = [("payment_link_config", body->Identity.genericTypeToJson)]->Dict.fromArray
        let _ = await updateBusinessProfile(~body=dict->JSON.Encode.object)
        styleId->isNonEmptyString ? setSelectedStyleId(_ => styleId) : ()
        showToast(
          ~toastType=ToastSuccess,
          ~message="Payment Link Config ID Created Successfully!",
          ~autoClose=true,
        )
      } catch {
      | Exn.Error(_) =>
        showToast(
          ~toastType=ToastError,
          ~message="Failed to create new Payment Link Config ID. Please try again.",
          ~autoClose=true,
        )
      }
      Nullable.null
    }

    let modalBody = {
      <>
        <div className="pt-3 m-3 flex justify-between">
          <CardUtils.CardHeader
            heading="Create a new Payment Link Config ID"
            subHeading=""
            customSubHeadingStyle="w-full !max-w-none pr-10"
            customHeadingStyle="text-black"
          />
          <div className="h-fit" onClick={_ => setShowModal(_ => false)}>
            <Icon name="modal-close-icon" className="cursor-pointer" size=30 />
          </div>
        </div>
        <hr />
        <Form
          key="new-payment-link-config-id-creation"
          onSubmit=createNewStyleID
          initialValues={JSON.Encode.object(Dict.make())}
          validate=validateStyleIdForm>
          <div className="flex flex-col h-full w-full">
            <div className="py-10">
              <DesktopRow>
                <FieldRenderer
                  fieldWrapperClass="w-full"
                  field=styleIdField
                  showErrorOnChange=true
                  errorClass=ProdVerifyModalUtils.errorClass
                  labelClass={`!text-black !-ml-[0.5px] ${body.md.medium}`}
                />
              </DesktopRow>
            </div>
            <hr className="mt-4" />
            <div className="flex justify-end w-full p-3">
              <SubmitButton text="Create Payment Link Config ID" buttonSize=Small />
            </div>
          </div>
        </Form>
      </>
    }

    <>
      <ACLDiv
        authorization=Access
        noAccessDescription="You do not have the required permissions for this action. Please contact your admin."
        onClick={_ => setShowModal(_ => true)}
        className="cursor-pointer w-full"
        showTooltip=true>
        {<>
          <hr />
          <div className={`flex items-center gap-2 px-3.5 py-3 ${body.md.medium} ${customStyle}`}>
            <Icon name="nd-plus" size=15 />
            {`Create new`->React.string}
          </div>
        </>}
      </ACLDiv>
      <Modal
        showModal
        closeOnOutsideClick=true
        setShowModal
        childClass="p-0"
        borderBottom=true
        modalClass="w-full max-w-xl mx-auto my-auto dark:!bg-jp-gray-lightgray_background">
        modalBody
      </Modal>
    </>
  }
}

module StyleIdSelection = {
  @react.component
  let make = (~selectedStyleId, ~setSelectedStyleId) => {
    open Typography
    let businessProfileRecoilVal = Recoil.useRecoilValueFromAtom(
      HyperswitchAtom.businessProfileFromIdAtomInterface,
    )
    let (availableStyles, setAvailableStyles) = React.useState(_ => [])
    React.useEffect(() => {
      let defaultOption: SelectBox.dropdownOption = {
        label: defaultStyleId,
        value: defaultStyleId,
      }

      switch businessProfileRecoilVal.payment_link_config {
      | Some(paymentLinkConfig) => {
          let stylesDict =
            paymentLinkConfig.business_specific_configs->Option.getOr(JSON.Encode.null)
          let styles = getDictFromJsonObject(stylesDict)->Dict.keysToArray

          let stylesList = styles->Array.map(styleId => {
            let dropdownOption: SelectBox.dropdownOption = {
              label: styleId,
              value: styleId,
            }
            dropdownOption
          })

          let finalStylesList = stylesList->Array.length == 0 ? [defaultOption] : stylesList

          setAvailableStyles(_ => finalStylesList)
          let isValid =
            selectedStyleId->isNonEmptyString &&
              finalStylesList->Array.some(opt => opt.value == selectedStyleId)
          if !isValid {
            let hasDefault = finalStylesList->Array.some(opt => opt.value == defaultStyleId)
            let autoSelect = hasDefault
              ? defaultStyleId
              : finalStylesList->Array.get(0)->Option.mapOr("", opt => opt.value)
            autoSelect->isNonEmptyString ? setSelectedStyleId(_ => autoSelect) : ()
          }
        }
      | None => {
          setSelectedStyleId(_ => defaultStyleId)
          setAvailableStyles(_ => [defaultOption])
        }
      }

      None
    }, [businessProfileRecoilVal.payment_link_config])

    let input: ReactFinalForm.fieldRenderPropsInput = {
      name: "styleId",
      onBlur: _ => (),
      onChange: ev => {
        let value = ev->Identity.formReactEventToString
        setSelectedStyleId(_ => value)
      },
      onFocus: _ => (),
      value: selectedStyleId->JSON.Encode.string,
      checked: true,
    }

    let customScrollStyle = "max-h-72 overflow-scroll px-1 pt-1"
    let dropdownContainerStyle = "rounded-md border border-1 max-w-18-rem"

    <div>
      <div className={`text-nd_gray-700 py-2 ${body.md.medium}`}>
        {"Select Payment Link Config ID"->React.string}
      </div>
      <SelectBoxAdapter.BaseDropdown
        allowMultiSelect=false
        buttonText="Select Payment Link Config ID"
        input
        deselectDisable=true
        options={availableStyles}
        hideMultiSelectButtons=true
        marginTop="mt-12"
        searchable=true
        searchInputPlaceHolder="Search Payment Link Config ID"
        buttonType=SecondaryFilled
        customButtonStyle="!w-40"
        customDropdownOuterClass="!border-none"
        customScrollStyle
        dropdownContainerStyle
        bottomComponent={<CreateNewStyleID setSelectedStyleId />}
      />
    </div>
  }
}

@react.component
let make = () => {
  let (selectedStyleId, setSelectedStyleId) = React.useState(() => "")
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let businessProfileRecoilVal = Recoil.useRecoilValueFromAtom(
    HyperswitchAtom.businessProfileFromIdAtomInterface,
  )

  let initPaymentLinkWasm = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let _ = await Window.paymentLinkWasmInit()
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | Exn.Error(e) =>
      let errorMessage = Exn.message(e)->Option.getOr("Failed to initialize payment link preview")
      setScreenState(_ => PageLoaderWrapper.Error(errorMessage))
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to initialize payment link preview"))
    }
  }

  React.useEffect(() => {
    initPaymentLinkWasm()->ignore
    None
  }, [])

  let selectedStyleConfigs = React.useMemo(() => {
    open BusinessProfileInterfaceUtils
    let paymentLinkConfig =
      businessProfileRecoilVal.payment_link_config->Option.getOr(
        paymentLinkConfigMapper(Dict.make()),
      )

    let businessSpecificConfigsDict =
      paymentLinkConfig.business_specific_configs->Option.mapOr(Dict.make(), json =>
        json->getDictFromJsonObject
      )
    businessSpecificConfigsDict->getJsonFromDict(selectedStyleId)
  }, (selectedStyleId, businessProfileRecoilVal.payment_link_config))

  <PageLoaderWrapper screenState>
    <div className="flex flex-col gap-8 relative">
      <StyleIdSelection selectedStyleId setSelectedStyleId />
      <div>
        <RenderIf condition={selectedStyleId->isNonEmptyString}>
          <ConfiguratorForm
            key={selectedStyleId} initialFormValues={selectedStyleConfigs} selectedStyleId
          />
        </RenderIf>
        <RenderIf condition={selectedStyleId->isEmptyString}>
          <NoDataFound
            customCssClass="my-6"
            message="Please select a Payment Link Config ID to Configure and Preview"
            renderType=Painting
          />
        </RenderIf>
      </div>
    </div>
  </PageLoaderWrapper>
}
