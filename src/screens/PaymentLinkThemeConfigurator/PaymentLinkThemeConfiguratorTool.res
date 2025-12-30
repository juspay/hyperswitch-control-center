open LogicUtils
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
    let (previewLoading, setPreviewLoading) = React.useState(_ => false)
    let (previewHtml, setPreviewHtml) = React.useState(_ => "")
    let (previewError, setPreviewError) = React.useState(_ => None)
    let {paymentResult} = React.useContext(SDKProvider.defaultContext)

    let merchantDetailsTypedValue = Recoil.useRecoilValueFromAtom(
      HyperswitchAtom.merchantDetailsValueAtom,
    )
    let businessProfileRecoilVal = Recoil.useRecoilValueFromAtom(
      HyperswitchAtom.businessProfileFromIdAtomInterface,
    )
    let updateBusinessProfile = BusinessProfileHook.useUpdateBusinessProfile()

    let generatePreview = React.useCallback((~values) => {
      let publishableKey = merchantDetailsTypedValue.publishable_key

      try {
        setPreviewLoading(_ => true)
        setPreviewError(_ => None)

        let configs = generateWasmPayload(
          ~paymentDetails=paymentResult,
          ~publishableKey,
          ~formValues=values,
        )

        let validationResult = Window.validatePaymentLinkConfig(
          JSON.stringify(configs->Identity.genericTypeToJson),
        )
        let validationDict = validationResult->JSON.parseExn->getDictFromJsonObject
        let isValid = validationDict->getBool("valid", false)
        let errors = validationDict->getArrayFromDict("errors", [])

        if !isValid {
          let errorMessages =
            errors->Array.map(error => error->getStringFromJson("Unknown validation error"))

          let combinedErrors = errorMessages->Array.joinWith(", ")
          setPreviewError(_ => Some(`Validation failed: ${combinedErrors}`))
        } else {
          let response = Window.generatePaymentLinkPreview(
            JSON.stringify(configs->Identity.genericTypeToJson),
          )
          setPreviewHtml(_ => response)
        }

        setPreviewLoading(_ => false)
      } catch {
      | Exn.Error(e) => {
          let errorMessage = Exn.message(e)->Option.getOr("WASM function failed")
          setPreviewError(_ => Some(errorMessage))
          setPreviewLoading(_ => false)
        }
      }
    }, [])

    React.useEffect(() => {
      generatePreview(~values=initialValues)
      None
    }, [initialValues])

    let onSubmit = async (values, isAutoSubmit) => {
      setInitialValues(_ => values)

      if !isAutoSubmit {
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
      }

      Nullable.null
    }

    <RenderIf condition={selectedStyleId->isNonEmptyString}>
      <div className="bg-white rounded-lg">
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 w-full">
          <div className="w-full">
            <div className="space-y-4">
              <Form
                formClass="space-y-4"
                initialValues
                onSubmit={(values, _) => onSubmit(values, false)}>
                <HelperComponents.AutoSubmitter
                  autoApply=true
                  submit={(values, _) => onSubmit(values, true)}
                  submitInputOnEnter=true
                />
                <style> {React.string(configuratorScrollbarCss)} </style>
                <div
                  className="flex flex-col gap-3 rounded-lg border border-nd_gray-300 p-4 h-650-px overflow-scroll configurator-scrollbar !m-0">
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
                    <FieldRenderer
                      field={makeHideCardNicknameField()} fieldWrapperClass="!w-full"
                    />
                    <FieldRenderer
                      field={makeShowCardFormByDefaultField()} fieldWrapperClass="!w-full"
                    />
                  </div>
                  <div className="flex flex-row">
                    <FieldRenderer
                      field={makeBrandingVisibilityField()} fieldWrapperClass="!w-full"
                    />
                    <FieldRenderer
                      field={makeSkipStatusScreenField()} fieldWrapperClass="!w-full"
                    />
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
                        ->getString("theme", ""),
                      )}
                      fieldWrapperClass="!w-full"
                    />
                    <FieldRenderer
                      field={makeBackgroundColorField(
                        ~defaultValue=initialValues
                        ->getDictFromJsonObject
                        ->getString("background_color", ""),
                      )}
                      fieldWrapperClass="!w-full"
                    />
                  </div>
                  <div className="flex flex-row gap-4">
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
                  </div>
                  <div className="flex flex-row gap-4">
                    <FieldRenderer
                      field={makeColorIconCardCvcErrorField(
                        ~defaultValue=initialValues
                        ->getDictFromJsonObject
                        ->getString("color_icon_card_cvc_error", ""),
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
                </div>
                <div className="flex justify-between pt-4">
                  <SubmitButton
                    text="Save Configuration" buttonType={Primary} buttonSize={Medium}
                  />
                </div>
              </Form>
            </div>
          </div>
          <div className="w-full">
            <div className="sticky top-4 w-full">
              <div className="bg-nd_gray-25 rounded-lg border border-nd_gray-300 p-3.5 h-650-px">
                <div className="flex items-center justify-between">
                  <h4 className={`text-nd_gray-600 mb-2 ${body.xl.medium}`}>
                    {"Live Preview"->React.string}
                  </h4>
                  {previewLoading
                    ? <div className={`flex items-center gap-2 text-nd_gray-500 ${body.md.medium}`}>
                        <div
                          className="animate-spin h-4 w-4 border-b-2 border-nd_primary_blue-500 rounded-full"
                        />
                        {"Generating..."->React.string}
                      </div>
                    : React.null}
                </div>
                <div className=" rounded-lg w-full h-590-px flex flex-col bg-white">
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
                        <p className={`text-nd_gray-500 mt-4 ${body.md.medium}`}>
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
                        <p className={`text-red-600 mb-2 ${body.md.medium}`}>
                          {"Preview Generation Failed"->React.string}
                        </p>
                        <p className={`text-nd_gray-500 max-w-md ${body.md.medium}`}>
                          {error->React.string}
                        </p>
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
                        srcDoc=html
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
    open FormRenderer
    open Typography
    let showToast = ToastState.useShowToast()
    let (showModal, setShowModal) = React.useState(() => false)
    let businessProfileRecoilVal = Recoil.useRecoilValueFromAtom(
      HyperswitchAtom.businessProfileFromIdAtomInterface,
    )
    let updateBusinessProfile = BusinessProfileHook.useUpdateBusinessProfile()

    let cursorStyles = authorization =>
      authorization === CommonAuthTypes.Access ? "cursor-pointer" : "cursor-not-allowed"

    let customStyle = "text-primary bg-white dark:bg-black hover:bg-jp-gray-100 text-nowrap w-full"
    let addItemBtnStyle = "w-full"

    let styleIdField = makeFieldInfo(
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
          ~placeholder="Eg: my_style_id",
        ),
      ~isRequired=true,
    )

    let createNewStyleID = async (values, _) => {
      try {
        let valuesDict = values->getDictFromJsonObject
        let styleId = valuesDict->getString("style_id", "")->String.trim

        if styleId->isNonEmptyString {
          setShowModal(_ => false)
          setSelectedStyleId(_ => styleId)
        }
        let config = businessProfileRecoilVal.payment_link_config
        let body = constructBusinessProfileBody(~paymentLinkConfig=config, ~styleID=styleId)
        let dict = [("payment_link_config", body->Identity.genericTypeToJson)]->Dict.fromArray
        let _ = await updateBusinessProfile(~body=dict->JSON.Encode.object)
        showToast(
          ~toastType=ToastSuccess,
          ~message="Style ID Created Successfully!",
          ~autoClose=true,
        )
      } catch {
      | Exn.Error(_) =>
        showToast(
          ~toastType=ToastError,
          ~message="Failed to create new Style ID. Please try again.",
          ~autoClose=true,
        )
      }
      Nullable.null
    }

    let modalBody = {
      <>
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
        <Form
          key="new-style-id-creation"
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
              <SubmitButton text="Create Style ID" buttonSize=Small />
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
        isRelative=false
        contentAlign=Default
        tooltipForWidthClass="!h-full"
        className={`${cursorStyles(Access)} ${addItemBtnStyle}`}
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
    open PaymentLinkThemeConfiguratorTypes
    open BusinessProfileInterfaceUtils
    open Typography
    let {profileId} = React.useContext(UserInfoProvider.defaultContext).getCommonTokenDetails()
    let (businessProfileRecoilVal, setBusinessProfileRecoilVal) = Recoil.useRecoilState(
      HyperswitchAtom.businessProfileFromIdAtomInterface,
    )
    let (availableStyles, setAvailableStyles) = React.useState(_ => [])
    let fetchBusinessProfileFromId = BusinessProfileHook.useFetchBusinessProfileFromId()
    let showToast = ToastState.useShowToast()

    let fetchBusinessProfile = async () => {
      try {
        let businessProfileResponse = await fetchBusinessProfileFromId(~profileId=Some(profileId))
        setBusinessProfileRecoilVal(_ => businessProfileResponse->mapJsontoCommonType)
      } catch {
      | _ =>
        showToast(~toastType=ToastError, ~message="Failed to update style ids", ~autoClose=true)
      }
    }

    React.useEffect(() => {
      fetchBusinessProfile()->ignore
      None
    }, [])

    React.useEffect(() => {
      let defaultPaymentLinkConfigValues =
        businessProfileRecoilVal.payment_link_config->Option.getOr(
          paymentLinkConfigMapper(Dict.make()),
        )

      let stylesDict =
        defaultPaymentLinkConfigValues.business_specific_configs->Option.getOr(JSON.Encode.null)
      let styles = getDictFromJsonObject(stylesDict)->Dict.keysToArray

      let stylesList = styles->Array.map(styleId => {
        let dropdownOption: SelectBox.dropdownOption = {
          label: styleId,
          value: styleId,
        }
        dropdownOption
      })
      stylesList->Array.unshift({
        label: (Default :> string),
        value: (Default :> string),
      })

      setAvailableStyles(_ => stylesList)
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

    let customScrollStyle = "max-h-72 overflow-scroll px-1 pt-1"

    <div>
      <div className={`text-nd_gray-700 py-2 ${body.md.medium}`}>
        {"Select Style ID"->React.string}
      </div>
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
        customDropdownOuterClass="!border-none"
        customScrollStyle
        bottomComponent={<CreateNewStyleID setSelectedStyleId />}
      />
    </div>
  }
}

@react.component
let make = () => {
  let (selectedStyleId, setSelectedStyleId) = React.useState(() => "")
  let businessProfileRecoilVal = Recoil.useRecoilValueFromAtom(
    HyperswitchAtom.businessProfileFromIdAtomInterface,
  )

  let getSelectedStyleConfigs = {
    open BusinessProfileInterfaceUtils
    let paymentLinkConfig =
      businessProfileRecoilVal.payment_link_config->Option.getOr(
        paymentLinkConfigMapper(Dict.make()),
      )

    switch selectedStyleId->selectedStyleVariant {
    | Default =>
      paymentLinkConfig
      ->getDefaultStylesValue
      ->Identity.genericTypeToJson
    | Custom => {
        let businessSpecificConfigsDict =
          paymentLinkConfig.business_specific_configs->Option.mapOr(Dict.make(), json =>
            json->getDictFromJsonObject
          )
        businessSpecificConfigsDict->getJsonFromDict(selectedStyleId)
      }
    }
  }

  <div className="flex flex-col gap-8 relative">
    <StyleIdSelection selectedStyleId setSelectedStyleId />
    <div>
      <RenderIf condition={selectedStyleId->isNonEmptyString}>
        <ConfiguratorForm
          key={`configurator-form-${selectedStyleId}`}
          initialFormValues={getSelectedStyleConfigs}
          selectedStyleId
        />
      </RenderIf>
      <RenderIf condition={selectedStyleId->isEmptyString}>
        <NoDataFound
          customCssClass="my-6"
          message="Please select a Style ID to Configure and Preview"
          renderType=Painting
        />
      </RenderIf>
    </div>
  </div>
}
