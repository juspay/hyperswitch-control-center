module ConfiguratorForm = {
  @react.component
  let make = (~initialValues, ~selectedStyleId) => {
    open FormRenderer
    open LogicUtils
    open PaymentLinkThemeConfiguratorUtils
    open PaymentLinkThemeConfiguratorHelper
    let showToast = ToastState.useShowToast()
    let (wasmInitialized, setWasmInitialized) = React.useState(_ => false)
    let (initialValues, setInitialValues) = React.useState(_ => initialValues)
    let (previewLoading, setPreviewLoading) = React.useState(_ => false)
    let (previewHtml, setPreviewHtml) = React.useState(_ => "")
    let (previewError, setPreviewError) = React.useState(_ => None)
    let {paymentResult} = React.useContext(SDKProvider.defaultContext)

    let merchantDetailsTypedValue = Recoil.useRecoilValueFromAtom(
      HyperswitchAtom.merchantDetailsValueAtom,
    )
    let businessProfileRecoilVal = Recoil.useRecoilValueFromAtom(
      HyperswitchAtom.businessProfileFromIdAtom,
    )
    let updateBusinessProfile = BusinessProfileHook.useUpdateBusinessProfile()

    let initializeWasm = async () => {
      try {
        let _ = await Window.paymentLinkWasmInit()
        setWasmInitialized(_ => true)
      } catch {
      | Exn.Error(e) => {
          let errorMessage = Exn.message(e)->Option.getOr("WASM initialization failed")
          setPreviewError(_ => Some(errorMessage))
        }
      }
    }

    React.useEffect(() => {
      initializeWasm()->ignore
      None
    }, [])

    let generatePreview = (~values) => {
      let publishableKey = merchantDetailsTypedValue.publishable_key

      try {
        setPreviewLoading(_ => true)
        setPreviewError(_ => None)

        let configs = PaymentLinkThemeConfiguratorUtils.generateWasmPayload(
          ~paymentDetails=paymentResult,
          ~publishableKey,
          ~formValues=values,
        )
        // Js.log2("WASM configs", configs)

        let validationResult = Window.validatePaymentLinkConfig(
          JSON.stringify(configs->Identity.genericTypeToJson),
        )
        let validationJson = JSON.parseExn(validationResult)
        let validationDict = validationJson->LogicUtils.getDictFromJsonObject
        let isValid = validationDict->LogicUtils.getBool("valid", false)
        let errors = validationDict->LogicUtils.getArrayFromDict("errors", [])

        if !isValid {
          let errorMessages = errors->Array.map(error => {
            switch error->JSON.Decode.string {
            | Some(msg) => msg
            | None => "Unknown validation error"
            }
          })
          let combinedErrors = errorMessages->Array.joinWith(", ")
          setPreviewError(_ => Some(`Validation failed: ${combinedErrors}`))
          setPreviewLoading(_ => false)
        } else {
          let response = Window.generatePaymentLinkPreview(
            JSON.stringify(configs->Identity.genericTypeToJson),
          )

          // Js.log2("WASM response", response)
          setPreviewHtml(_ => response)
          setPreviewLoading(_ => false)
        }
      } catch {
      | Exn.Error(e) => {
          let errorMessage = Exn.message(e)->Option.getOr("WASM function failed")
          setPreviewError(_ => Some(errorMessage))
          setPreviewLoading(_ => false)
        }
      }
    }

    let debouncedGeneratePreview = ReactDebounce.useDebounced(values => {
      generatePreview(~values)
    }, ~wait=800)

    React.useEffect(() => {
      if wasmInitialized {
        generatePreview(~values=initialValues)
      }
      None
    }, (initialValues, wasmInitialized, merchantDetailsTypedValue))

    let onSubmit = async (values, isAutoSubmit) => {
      debouncedGeneratePreview(values)
      setInitialValues(_ => values)

      if !isAutoSubmit {
        let body = constructBusinessProfileBodyFromJson(
          ~json=values,
          ~paymentLinkConfig=businessProfileRecoilVal.payment_link_config,
          ~styleID=selectedStyleId,
        )
        let dict = Dict.make()
        dict->Dict.set("payment_link_config", body->Identity.genericTypeToJson)
        let _ = await updateBusinessProfile(~body=dict->JSON.Encode.object)
        showToast(
          ~toastType=ToastSuccess,
          ~message="Configuration Saved Successfully!",
          ~autoClose=true,
        )
      }

      Nullable.null
    }

    module AutoSubmitter = {
      @react.component
      let make = (~submit) => {
        let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
          ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
        )
        let form = ReactFinalForm.useForm()
        let values = formState.values
        React.useEffect(() => {
          let onKeyDown = ev => {
            let keyCode = ev->ReactEvent.Keyboard.keyCode
            if keyCode === 13 {
              form.submit()->ignore
            }
          }
          Window.addEventListener("keydown", onKeyDown)
          Some(() => Window.removeEventListener("keydown", onKeyDown))
        }, [])

        React.useEffect(() => {
          if formState.dirty {
            submit(formState.values, false)->ignore
          }
          None
        }, [values])

        React.null
      }
    }

    // Js.log2("Initial Values", initialValues)
    let defaultThemeColor = initialValues->getDictFromJsonObject->getString("theme", "#FFFFFF")

    <RenderIf condition={selectedStyleId->LogicUtils.isNonEmptyString}>
      <div className="bg-white rounded-lg">
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 w-full">
          <div className="w-full">
            <div className="space-y-4">
              <Form
                formClass="space-y-4"
                initialValues
                onSubmit={(values, _) => onSubmit(values, false)}>
                <AutoSubmitter submit={(values, _) => onSubmit(values, true)} />
                <FieldRenderer field={makeBackgroundImageField()} fieldWrapperClass="!w-full" />
                <FieldRenderer field={makeLogoField()} fieldWrapperClass="!w-full" />
                <FieldRenderer field={makeReturnUrlField()} fieldWrapperClass="!w-full" />
                <FieldRenderer field={makePaymentButtonTextField()} fieldWrapperClass="!w-full" />
                <FieldRenderer
                  field={makeCustomMessageForCardTermsField()} fieldWrapperClass="!w-full"
                />
                <FieldRenderer
                  field={makeMaxItemsVisibleAfterCollapseField()} fieldWrapperClass="!w-full"
                />
                <div className="flex flex-row">
                  <FieldRenderer field={makeDisplaySdkOnlyField()} fieldWrapperClass="!w-full" />
                  <FieldRenderer
                    field={makeEnabledSavedPaymentMethodField()} fieldWrapperClass="!w-full"
                  />
                </div>
                <div className="flex flex-row">
                  <FieldRenderer field={makeHideCardNicknameField()} fieldWrapperClass="!w-full" />
                  <FieldRenderer
                    field={makeShowCardFormByDefaultField()} fieldWrapperClass="!w-full"
                  />
                </div>
                <div className="flex flex-row">
                  <FieldRenderer
                    field={makeBrandingVisibilityField()} fieldWrapperClass="!w-full"
                  />
                  <FieldRenderer field={makeSkipStatusScreenField()} fieldWrapperClass="!w-full" />
                </div>
                <div className="flex flex-row">
                  <FieldRenderer
                    field={makeIsSetupMandateFlowField()} fieldWrapperClass="!w-full"
                  />
                  <FieldRenderer field={makeShowCardTermsField()} fieldWrapperClass="!w-full" />
                </div>
                <div className="flex flex-row gap-4">
                  <FieldRenderer
                    field={makeThemeField(
                      ~defaultValue=initialValues
                      ->getDictFromJsonObject
                      ->getString("theme", "#FFFFFF"),
                    )}
                    fieldWrapperClass="!w-full"
                  />
                  <FieldRenderer
                    field={makeBackgroundColorField(
                      ~defaultValue=initialValues
                      ->getDictFromJsonObject
                      ->getString("background_color", "#FFFFFF"),
                    )}
                    fieldWrapperClass="!w-full"
                  />
                </div>
                <div className="flex flex-row gap-4">
                  <FieldRenderer
                    field={makePaymentButtonColorField(
                      ~defaultValue=initialValues
                      ->getDictFromJsonObject
                      ->getString("payment_button_colour", defaultThemeColor),
                    )}
                    fieldWrapperClass="!w-full"
                  />
                  <FieldRenderer
                    field={makePaymentButtonTextColorField(
                      ~defaultValue=initialValues
                      ->getDictFromJsonObject
                      ->getString("payment_button_text_colour", "#FFFFFF"),
                    )}
                    fieldWrapperClass="!w-full"
                  />
                </div>
                <div className="flex flex-row gap-4">
                  <FieldRenderer field={makeSellerNameField()} fieldWrapperClass="!w-full" />
                  <FieldRenderer
                    field={makeMerchantDescriptionField()} fieldWrapperClass="!w-full"
                  />
                </div>
                <div className="flex flex-row gap-4">
                  <FieldRenderer field={makeDetailsLayoutField()} fieldWrapperClass="!w-full" />
                  <FieldRenderer field={makeSdkLayoutField()} fieldWrapperClass="!w-full" />
                </div>
                <div className="flex justify-between pt-4">
                  <SubmitButton
                    text="Save Configuration" buttonType={Primary} buttonSize={Medium}
                  />
                </div>
                // <FormValuesSpy />
              </Form>
            </div>
          </div>
          <div className="w-full">
            <div className="sticky top-4 w-full">
              <div className="bg-nd_gray-25 rounded-lg border border-nd_gray-300 p-4 h-full">
                <div className="flex items-center justify-between">
                  <h4 className="text-md font-semibold text-nd_gray-600 mb-2">
                    {"Live Preview"->React.string}
                  </h4>
                  {previewLoading
                    ? <div className="flex items-center gap-2 text-sm text-nd_gray-500">
                        <div
                          className="animate-spin h-4 w-4 border-b-2 border-nd_primary_blue-500 rounded-full"
                        />
                        {"Generating..."->React.string}
                      </div>
                    : React.null}
                </div>
                <div className=" rounded-lg w-full h-[700px] flex flex-col bg-white">
                  {switch (previewLoading, previewError, previewHtml) {
                  | (true, _, _) =>
                    <div className="flex items-center justify-center h-full w-full">
                      <div className="text-center">
                        <div className="animate-pulse space-y-4 w-full">
                          <div className="h-4 bg-nd_gray-200 rounded w-3/4 mx-auto" />
                          <div className="h-4 bg-nd_gray-200 rounded w-1/2 mx-auto" />
                          <div className="h-32 bg-nd_gray-200 rounded w-full" />
                          <div className="h-4 bg-nd_gray-200 rounded w-2/3 mx-auto" />
                        </div>
                        <p className="text-nd_gray-500 mt-4 text-sm">
                          {"Generating preview..."->React.string}
                        </p>
                      </div>
                    </div>
                  | (false, Some(error), _) =>
                    <div className="flex items-center justify-center h-full w-full">
                      <div className="text-center">
                        <div className="text-red-500 mb-4">
                          <Icon name="cross-icon" size=24 />
                        </div>
                        <p className="text-red-600 font-medium mb-2">
                          {"Preview Generation Failed"->React.string}
                        </p>
                        <p className="text-nd_gray-500 text-sm max-w-md"> {error->React.string} </p>
                      </div>
                    </div>
                  | (false, None, html) =>
                    <div
                      className="w-full h-full flex-1 overflow-hidden rounded-lg bg-white relative">
                      <iframe
                        className="w-full h-full border-0"
                        style={ReactDOM.Style.make(
                          ~transform="scale(0.75)",
                          ~transformOrigin="top left",
                          ~width="133%",
                          ~height="133%",
                          (),
                        )}
                        srcDoc={html}
                        sandbox="allow-scripts allow-same-origin"
                        title="Payment Link Preview"
                      />
                    </div>
                  }}
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </RenderIf>
  }
}

module CreateNewStyleID = {
  @react.component
  let make = (~setSelectedStyleId) => {
    open LogicUtils
    let (showModal, setShowModal) = React.useState(() => false)
    let (initialValues, _setInitialValues) = React.useState(_ => Dict.make()->JSON.Encode.object)
    let businessProfileRecoilVal = Recoil.useRecoilValueFromAtom(
      HyperswitchAtom.businessProfileFromIdAtom,
    )
    let updateBusinessProfile = BusinessProfileHook.useUpdateBusinessProfile()

    let cursorStyles = authorization =>
      authorization === CommonAuthTypes.Access ? "cursor-pointer" : "cursor-not-allowed"
    let customStyle = ""
    let customPadding = ""
    let addItemBtnStyle = ""

    let styleIdField = FormRenderer.makeFieldInfo(
      ~label="Style ID",
      ~name="style_id",
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
          ~placeholder="Eg: my-style-id",
        ),
      ~isRequired=true,
    )

    let createNewStyleID = async (values, _) => {
      let valuesDict = values->getDictFromJsonObject
      let styleId = valuesDict->getString("style_id", "")->String.trim

      if styleId->isNonEmptyString {
        setShowModal(_ => false)
        setSelectedStyleId(_ => styleId)
      }
      let config = businessProfileRecoilVal.payment_link_config
      let body = PaymentLinkThemeConfiguratorUtils.constructBusinessProfileBody(
        ~paymentLinkConfig=config,
        ~styleID=styleId,
      )

      let dict = Dict.make()
      dict->Dict.set("payment_link_config", body->Identity.genericTypeToJson)
      let _ = await updateBusinessProfile(~body=dict->JSON.Encode.object)

      Nullable.null
    }

    let modalBody = {
      <div className="">
        <div className="pt-3 m-3 flex justify-between">
          <CardUtils.CardHeader
            heading="Create a new style id"
            subHeading=""
            customSubHeadingStyle="w-full !max-w-none pr-10"
          />
          <div className="h-fit" onClick={_ => setShowModal(_ => false)}>
            <Icon name="modal-close-icon" className="cursor-pointer" size=30 />
          </div>
        </div>
        <hr />
        <Form key="new-style-id-creation" onSubmit={createNewStyleID} initialValues>
          <div className="flex flex-col h-full w-full">
            <div className="py-10">
              <FormRenderer.DesktopRow>
                <FormRenderer.FieldRenderer
                  fieldWrapperClass="w-full"
                  field={styleIdField}
                  showErrorOnChange=true
                  errorClass={ProdVerifyModalUtils.errorClass}
                  labelClass="!text-black font-medium !-ml-[0.5px]"
                />
              </FormRenderer.DesktopRow>
            </div>
            <hr className="mt-4" />
            <div className="flex justify-end w-full p-3">
              <FormRenderer.SubmitButton text="Create Style ID" buttonSize=Small />
            </div>
          </div>
        </Form>
      </div>
    }

    <>
      <ACLDiv
        authorization={Access}
        noAccessDescription="You do not have the required permissions for this action. Please contact your admin."
        onClick={_ => setShowModal(_ => true)}
        isRelative=false
        contentAlign=Default
        tooltipForWidthClass="!h-full"
        className={`${cursorStyles(Access)} ${customPadding} ${addItemBtnStyle}`}
        showTooltip=true>
        {<>
          <hr />
          <div className={`flex items-center gap-2 font-medium px-3.5 py-3 text-sm ${customStyle}`}>
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
    open LogicUtils
    let (availableStyles, setAvailableStyles) = React.useState(_ => [])
    let businessProfileRecoilVal = Recoil.useRecoilValueFromAtom(
      HyperswitchAtom.businessProfileFromIdAtom,
    )
    React.useEffect(() => {
      let defaultPaymentLinkConfigValues = switch businessProfileRecoilVal.payment_link_config {
      | Some(config) => config
      | None => BusinessProfileMapper.paymentLinkConfigMapper(Dict.make())
      }

      let stylesDict = defaultPaymentLinkConfigValues.business_specific_configs
      let styles = getDictFromJsonObject(stylesDict)->Dict.keysToArray

      setAvailableStyles(_ =>
        styles->Array.map(
          styleId => {
            let dropdownOption: SelectBox.dropdownOption = {
              label: styleId,
              value: styleId,
            }
            dropdownOption
          },
        )
      )
      None
    }, [businessProfileRecoilVal])

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
    <div>
      <div className="text-nd_gray-700 text-sm py-2"> {"Select Style ID"->React.string} </div>
      <SelectBox.BaseDropdown
        allowMultiSelect=false
        buttonText="Select Style ID"
        input
        deselectDisable=true
        options={availableStyles}
        hideMultiSelectButtons=true
        marginTop="mt-12"
        dropdownCustomWidth="w-fit"
        searchable=true
        searchInputPlaceHolder="Search Style ID"
        buttonType=SecondaryFilled
        customButtonStyle="!w-32"
        bottomComponent={<CreateNewStyleID setSelectedStyleId />}
      />
    </div>
  }
}

@react.component
let make = () => {
  open LogicUtils
  let (selectedStyleId, setSelectedStyleId) = React.useState(() => "")
  let businessProfileRecoilVal = Recoil.useRecoilValueFromAtom(
    HyperswitchAtom.businessProfileFromIdAtom,
  )

  let getSelectedStyleConfigs = {
    let paymentLinkConfig = switch businessProfileRecoilVal.payment_link_config {
    | Some(config) => config
    | None => BusinessProfileMapper.paymentLinkConfigMapper(Dict.make())
    }
    let businessSpecificConfigs = paymentLinkConfig.business_specific_configs
    let businessSpecificConfigsDict = businessSpecificConfigs->getDictFromJsonObject
    let styleConfig = businessSpecificConfigsDict->Dict.get(selectedStyleId)

    switch styleConfig {
    | Some(config) => config
    | None => Dict.make()->JSON.Encode.object
    }
  }

  <div className="flex flex-col gap-8 relative">
    <StyleIdSelection selectedStyleId setSelectedStyleId />
    <div>
      <RenderIf condition={selectedStyleId->isNonEmptyString}>
        <ConfiguratorForm
          key={`configurator-form-${selectedStyleId}`}
          initialValues={getSelectedStyleConfigs}
          selectedStyleId
        />
      </RenderIf>
      <RenderIf condition={selectedStyleId->isEmptyString}>
        <NoDataFound
          customCssClass={"my-6"}
          message="Please select a Style Id to Configure and Preview"
          renderType=Painting
        />
      </RenderIf>
    </div>
  </div>
}
