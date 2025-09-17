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
  }
}

@react.component
let make = () => {
  open LogicUtils
  let (selectedStyleId, setSelectedStyleId) = React.useState(() => "")

  let getSelectedStyleConfigs = {
    let businessProfileRecoilVal = Recoil.useRecoilValueFromAtom(
      HyperswitchAtom.businessProfileFromIdAtom,
    )
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

  Js.log2("getSelectedStyleConfigs", getSelectedStyleConfigs)

  <div className="flex flex-col gap-8 relative">
    <div className="absolute right-0 top-0">
      <StyleIdSelection selectedStyleId setSelectedStyleId />
    </div>
    <div>
      <RenderIf condition={selectedStyleId == ""}>
        <div className="text-md text-gray-500">
          {"Please select a style ID to view and update its configuration."->React.string}
        </div>
      </RenderIf>
    </div>
  </div>
}
