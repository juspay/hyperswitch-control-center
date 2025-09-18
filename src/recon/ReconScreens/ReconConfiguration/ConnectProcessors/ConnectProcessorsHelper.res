open HSwitchUtils
let p1MediumTextStyle = HSwitchUtils.getTextClass((P1, Medium))
let p1RegularText = getTextClass((P1, Regular))

let generateDropdownOptionsCustomComponent: array<OMPSwitchTypes.ompListTypes> => array<
  SelectBox.dropdownOption,
> = dropdownList => {
  let options: array<SelectBox.dropdownOption> = dropdownList->Array.map((
    item
  ): SelectBox.dropdownOption => {
    let option: SelectBox.dropdownOption = {
      label: item.name,
      value: item.id,
      icon: Button.CustomIcon(
        <GatewayIcon gateway={item.name->String.toUpperCase} className="mt-0.5 mr-2 w-4 h-4" />,
      ),
    }
    option
  })
  options
}

module ListBaseComp = {
  @react.component
  let make = (
    ~heading="",
    ~subHeading,
    ~arrow,
    ~showEditIcon=false,
    ~onEditClick=_ => (),
    ~isDarkBg=false,
    ~showDropdownArrow=true,
    ~placeHolder="Select Processor",
  ) => {
    let {globalUIConfig: {sidebarColor: {secondaryTextColor}}} = React.useContext(
      ThemeProvider.themeContext,
    )

    let arrowClassName = isDarkBg
      ? `${arrow
            ? "rotate-180"
            : "-rotate-0"} transition duration-[250ms] opacity-70 ${secondaryTextColor}`
      : `${arrow
            ? "rotate-0"
            : "rotate-180"} transition duration-[250ms] opacity-70 ${secondaryTextColor}`

    <div
      className={`flex flex-row cursor-pointer items-center py-5 px-4 gap-2 min-w-44 justify-between h-8 bg-white border rounded-lg border-nd_gray-150 shadow-sm`}>
      <div className="flex flex-row items-center gap-2">
        <RenderIf condition={subHeading->String.length > 0}>
          <GatewayIcon gateway={subHeading->String.toUpperCase} className="w-6 h-6" />
          <p
            className="overflow-scroll text-nowrap text-sm font-medium text-nd_gray-500 whitespace-pre  ">
            {subHeading->React.string}
          </p>
        </RenderIf>
        <RenderIf condition={subHeading->String.length == 0}>
          <p
            className="overflow-scroll text-nowrap text-sm font-medium text-nd_gray-500 whitespace-pre  ">
            {placeHolder->React.string}
          </p>
        </RenderIf>
      </div>
      <RenderIf condition={showDropdownArrow}>
        <Icon className={`${arrowClassName} ml-1`} name="nd-angle-down" size=12 />
      </RenderIf>
    </div>
  }
}

module AddNewOMPButton = {
  @react.component
  let make = (
    ~user: UserInfoTypes.entity,
    ~customPadding="",
    ~customHRTagStyle="",
    ~addItemBtnStyle="",
    ~prodConnectorList=ConnectorUtils.connectorListForLive,
    ~filterConnector=ConnectorTypes.Processors(STRIPE)->Some,
  ) => {
    open ConnectorUtils

    let allowedRoles = switch user {
    | #Organization => [#tenant_admin]
    | #Merchant => [#tenant_admin, #org_admin]
    | #Profile => [#tenant_admin, #org_admin, #merchant_admin]
    | _ => []
    }
    let hasOMPCreateAccess = OMPCreateAccessHook.useOMPCreateAccessHook(allowedRoles)
    let cursorStyles = GroupAccessUtils.cursorStyles(hasOMPCreateAccess)
    let connectorsList = switch filterConnector {
    | Some(connector) => prodConnectorList->Array.filter(item => item != connector)
    | _ => prodConnectorList
    }

    <ACLDiv
      authorization={hasOMPCreateAccess}
      noAccessDescription="You do not have the required permissions for this action. Please contact your admin."
      onClick={_ => ()}
      isRelative=false
      contentAlign=Default
      tooltipForWidthClass="!h-full"
      className={`${cursorStyles} ${customPadding} ${addItemBtnStyle}`}
      showTooltip={hasOMPCreateAccess == Access}>
      {<>
        <hr className={customHRTagStyle} />
        <div className="flex flex-col items-start gap-3.5 font-medium  px-3.5 py-3">
          <p
            className="uppercase text-nd_gray-400 font-semibold leading-3 text-fs-10 tracking-wider bg-white">
            {"Available for production"->React.string}
          </p>
          <div className="flex flex-col gap-2.5 h-40 overflow-scroll cursor-not-allowed w-full">
            {connectorsList
            ->Array.mapWithIndex((connector: ConnectorTypes.connectorTypes, _) => {
              let connectorName = connector->getConnectorNameString
              let size = "w-4 h-4 rounded-sm"

              <div className="flex flex-row gap-3 items-center">
                <GatewayIcon gateway={connectorName->String.toUpperCase} className=size />
                <p className="text-sm font-medium normal-case text-nd_gray-600/40">
                  {connectorName
                  ->getDisplayNameForConnector(~connectorType=ConnectorTypes.Processor)
                  ->React.string}
                </p>
              </div>
            })
            ->React.array}
          </div>
        </div>
      </>}
    </ACLDiv>
  }
}

module ConnectProcessorsFields = {
  @react.component
  let make = () => {
    open OMPSwitchTypes

    let form = ReactFinalForm.useForm()
    let (selectedProcessor, setSelectedProcessor) = React.useState(_ => "")
    let (processorList, _) = React.useState(_ => [{id: "Stripe", name: "Stripe"}])
    let (arrow, setArrow) = React.useState(_ => false)
    let toggleChevronState = () => {
      setArrow(prev => !prev)
    }

    let input: ReactFinalForm.fieldRenderPropsInput = {
      name: "name",
      onBlur: _ => (),
      onChange: ev => {
        let value = ev->Identity.formReactEventToString
        form.change("processor_type", value->JSON.Encode.string)
        setSelectedProcessor(_ => value)
      },
      onFocus: _ => (),
      value: selectedProcessor->JSON.Encode.string,
      checked: true,
    }

    let addItemBtnStyle = "border border-t-0 !w-full"
    let customScrollStyle = "max-h-72 overflow-scroll px-1 pt-1 border border-b-0"
    let dropdownContainerStyle = "rounded-md border border-1 !w-full"

    <>
      <SelectBox.BaseDropdown
        allowMultiSelect=false
        buttonText=""
        input
        deselectDisable=true
        customButtonStyle="!rounded-lg"
        options={processorList->generateDropdownOptionsCustomComponent}
        hideMultiSelectButtons=true
        addButton=false
        searchable=false
        baseComponent={<ListBaseComp heading="Profile" subHeading=selectedProcessor arrow />}
        bottomComponent={<AddNewOMPButton user=#Profile addItemBtnStyle />}
        customDropdownOuterClass="!border-none !w-full"
        fullLength=true
        toggleChevronState
        customScrollStyle
        dropdownContainerStyle
        shouldDisplaySelectedOnTop=true
        customSelectionIcon={CustomIcon(<Icon name="nd-checkbox-base" />)}
      />
      <RenderIf condition={selectedProcessor->String.length > 0}>
        <div className="flex flex-col gap-y-3 mt-10">
          <p className="font-semibold leading-5 text-nd_gray-700 text-sm">
            {"Provide authentication details"->React.string}
          </p>
          <FormRenderer.FieldRenderer
            labelClass="font-semibold"
            field={FormRenderer.makeFieldInfo(
              ~label="Secret Key",
              ~name="secret_key",
              ~placeholder="sk_test_1234AbCDeFghijtT1zdp7dc",
              ~customInput=InputFields.textInput(
                ~customStyle="rounded-xl bg-nd_gray-50",
                ~isDisabled=true,
              ),
              ~isRequired=false,
            )}
          />
          <FormRenderer.FieldRenderer
            labelClass="font-semibold"
            field={FormRenderer.makeFieldInfo(
              ~label="Client Verification Key",
              ~name="client_verification_key",
              ~placeholder="hs_1234567890abcdef1234567890abcdef",
              ~customInput=InputFields.textInput(
                ~customStyle="rounded-xl bg-nd_gray-50",
                ~isDisabled=true,
              ),
              ~isRequired=false,
            )}
          />
        </div>
      </RenderIf>
      <div className="mt-10 w-full">
        <FormRenderer.DesktopRow wrapperClass="!w-full" itemWrapperClass="!mx-0">
          <FormRenderer.SubmitButton
            text="Next"
            customSumbitButtonStyle="rounded !w-full"
            buttonType={Primary}
            tooltipForWidthClass="w-full"
          />
        </FormRenderer.DesktopRow>
      </div>
    </>
  }
}
