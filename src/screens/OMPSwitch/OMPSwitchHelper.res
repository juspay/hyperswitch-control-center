module ListBaseComp = {
  @react.component
  let make = (
    ~heading,
    ~subHeading,
    ~arrow,
    ~showEditIcon=false,
    ~onEditClick=_ => (),
    ~isDarkBg=false,
  ) => {
    let baseCompStyle = isDarkBg
      ? "text-white hover:bg-opacity-80 bg-sidebar-blue"
      : "text-black hover:bg-opacity-80"

    let iconName = isDarkBg ? "arrow-without-tail-new" : "arrow-without-tail"

    let arrowDownClass = isDarkBg
      ? "rotate-0 transition duration-[250ms] opacity-70"
      : "rotate-180 transition duration-[250ms] opacity-70"

    let arrowUpClass = isDarkBg
      ? "-rotate-180 transition duration-[250ms] opacity-70"
      : "rotate-0 transition duration-[250ms] opacity-70"

    let textColor = isDarkBg ? "text-grey-300" : "text-grey-900"
    let width = isDarkBg ? "w-[12rem]" : "min-w-[5rem] w-fit max-w-[10rem]"
    let paddingSubheading = isDarkBg ? "pl-2" : ""
    let paddingHeading = isDarkBg ? "pl-2" : ""

    let endValue = isDarkBg ? 23 : 15

    let subHeadingElement = if subHeading->String.length > 15 {
      <HelperComponents.EllipsisText
        displayValue=subHeading
        endValue
        showCopy=false
        customTextStyle={`${textColor} font-extrabold`}
      />
    } else {
      {subHeading->React.string}
    }

    <div className={`text-sm font-medium cursor-pointer ${baseCompStyle}`}>
      <div className={`flex flex-col items-start`}>
        <RenderIf condition={heading->LogicUtils.isNonEmptyString}>
          <p className={`text-xs text-left text-gray-400 ${paddingHeading}`}>
            {heading->React.string}
          </p>
        </RenderIf>
        <div className="text-left flex gap-2">
          <p
            className={`fs-10 ${textColor} ${width} ${paddingSubheading} overflow-scroll text-nowrap`}>
            {subHeadingElement}
          </p>
          <RenderIf condition={showEditIcon}>
            <Icon name="pencil-edit" size=15 onClick=onEditClick className="mx-2" />
          </RenderIf>
          <Icon
            className={`${arrow ? arrowDownClass : arrowUpClass} ml-1`} name={iconName} size=15
          />
        </div>
      </div>
    </div>
  }
}

module AddNewOMPButton = {
  @react.component
  let make = (
    ~user: UserInfoTypes.entity,
    ~setShowModal,
    ~customPadding="",
    ~customStyle="",
    ~customHRTagStyle="",
    ~addItemBtnStyle="",
  ) => {
    let allowedRoles = switch user {
    | #Organization => [#tenant_admin]
    | #Merchant => [#tenant_admin, #org_admin]
    | #Profile => [#tenant_admin, #org_admin, #merchant_admin]
    | _ => []
    }
    let hasOMPCreateAccess = OMPCreateAccessHook.useOMPCreateAccessHook(allowedRoles)
    let cursorStyles = GroupAccessUtils.cursorStyles(hasOMPCreateAccess)

    <ACLDiv
      authorization={hasOMPCreateAccess}
      noAccessDescription="You do not have the required permissions for this action. Please contact your admin."
      onClick={_ => setShowModal(_ => true)}
      isRelative=false
      contentAlign=Default
      tooltipForWidthClass="!h-full"
      className={`${cursorStyles} ${customPadding} ${addItemBtnStyle}`}>
      {<>
        <hr className={customHRTagStyle} />
        <div
          className={`group flex  items-center gap-2 font-medium px-2 py-2 text-sm ${customStyle}`}>
          <Icon name="plus-circle" size=15 />
          {`Add new ${(user :> string)->String.toLowerCase}`->React.string}
        </div>
      </>}
    </ACLDiv>
  }
}

module OMPViewBaseComp = {
  @react.component
  let make = (~displayName, ~arrow) => {
    let arrowUpClass = "rotate-0 transition duration-[250ms] opacity-70"
    let arrowDownClass = "rotate-180 transition duration-[250ms] opacity-70"

    let truncatedDisplayName = if displayName->String.length > 15 {
      <HelperComponents.EllipsisText
        displayValue=displayName endValue=15 showCopy=false expandText=false
      />
    } else {
      {displayName->React.string}
    }

    <div className={`text-sm font-medium cursor-pointer px-4`}>
      <div className={`flex flex-col items-start`}>
        <div className="text-left flex items-center gap-1">
          <Icon name="settings-new" size=18 />
          <p className={`text-jp-gray-900 fs-10 overflow-scroll text-nowrap`}>
            {`View data for:`->React.string}
          </p>
          <span className="text-blue-500 text-nowrap"> {truncatedDisplayName} </span>
          <Icon
            className={`${arrow ? arrowDownClass : arrowUpClass} ml-1`}
            name="arrow-without-tail"
            size=15
          />
        </div>
      </div>
    </div>
  }
}

let generateDropdownOptionsOMPViews = (dropdownList: OMPSwitchTypes.ompViews, getNameForId) => {
  let options: array<SelectBox.dropdownOption> = dropdownList->Array.map((
    item
  ): SelectBox.dropdownOption => {
    {
      label: `${item.entity->getNameForId}`,
      value: `${(item.entity :> string)}`,
      labelDescription: `(${item.lable})`,
      description: `${item.entity->getNameForId}`,
    }
  })
  options
}

module OMPViewsComp = {
  @react.component
  let make = (~input, ~options, ~displayName, ~entityMapper=UserInfoUtils.entityMapper) => {
    let (arrow, setArrow) = React.useState(_ => false)

    let toggleChevronState = () => {
      setArrow(prev => !prev)
    }

    let customScrollStyle = "max-h-72 overflow-scroll px-1 pt-1"
    let dropdownContainerStyle = "rounded-lg border w-full shadow-md"

    <div className="flex h-fit border border-grey-100 bg-white rounded-lg py-2 hover:bg-opacity-80">
      <SelectBox.BaseDropdown
        allowMultiSelect=false
        buttonText=""
        input
        deselectDisable=true
        customButtonStyle="!rounded-md"
        options
        marginTop="mt-8"
        hideMultiSelectButtons=true
        addButton=false
        customStyle="rounded w-fit absolute left-0"
        searchable=false
        baseComponent={<OMPViewBaseComp displayName arrow />}
        baseComponentCustomStyle="bg-white rounded"
        optionClass="font-inter text-fs-14 font-normal leading-5"
        selectClass="font-inter text-fs-14 font-normal leading-5 font-semibold"
        labelDescriptionClass="font-inter text-fs-12 font-normal leading-4"
        customDropdownOuterClass="!border-none !w-full"
        toggleChevronState
        customScrollStyle
        dropdownContainerStyle
        shouldDisplaySelectedOnTop=true
        descriptionOnHover=true
        textEllipsisForDropDownOptions=true
      />
    </div>
  }
}

module OMPViews = {
  @react.component
  let make = (
    ~views: OMPSwitchTypes.ompViews,
    ~selectedEntity: UserInfoTypes.entity,
    ~onChange,
    ~entityMapper=UserInfoUtils.entityMapper,
  ) => {
    let (_, getNameForId) = OMPSwitchHooks.useOMPData()

    let input: ReactFinalForm.fieldRenderPropsInput = {
      name: "name",
      onBlur: _ => (),
      onChange: ev => {
        let value = ev->Identity.formReactEventToString
        onChange(value->UserInfoUtils.entityMapper)->ignore
      },
      onFocus: _ => (),
      value: (selectedEntity :> string)->JSON.Encode.string,
      checked: true,
    }

    let options = views->generateDropdownOptionsOMPViews(getNameForId)

    let displayName = selectedEntity->getNameForId

    <OMPViewsComp input options displayName />
  }
}

module OMPCopyTextCustomComp = {
  @react.component
  let make = (
    ~displayValue,
    ~copyValue=None,
    ~customTextCss="",
    ~customParentClass="flex items-center",
    ~customOnCopyClick=() => (),
  ) => {
    let showToast = ToastState.useShowToast()
    let copyVal = switch copyValue {
    | Some(val) => val
    | None => displayValue
    }
    let onCopyClick = ev => {
      ev->ReactEvent.Mouse.stopPropagation
      Clipboard.writeText(copyVal)
      customOnCopyClick()
      showToast(~message="Copied to Clipboard!", ~toastType=ToastSuccess)
    }

    if displayValue->LogicUtils.isNonEmptyString {
      <div className=customParentClass>
        <div className=customTextCss> {displayValue->React.string} </div>
        <img
          alt="cursor"
          src={`/assets/copyid.svg`}
          className="cursor-pointer"
          onClick={ev => {
            onCopyClick(ev)
          }}
        />
      </div>
    } else {
      "NA"->React.string
    }
  }
}

let generateDropdownOptions: array<OMPSwitchTypes.ompListTypes> => array<
  SelectBox.dropdownOption,
> = dropdownList => {
  let options: array<SelectBox.dropdownOption> = dropdownList->Array.map((
    item
  ): SelectBox.dropdownOption => {
    label: item.name,
    value: item.id,
    icon: Button.CustomRightIcon(
      <ToolTip
        description={item.id}
        customStyle="!whitespace-nowrap"
        toolTipFor={<div className="cursor-pointer">
          <OMPCopyTextCustomComp displayValue=" " copyValue=Some({item.id}) />
        </div>}
        toolTipPosition=ToolTip.TopRight
      />,
    ),
  })
  options
}

module EditOrgName = {
  @react.component
  let make = (~showModal, ~setShowModal, ~orgList, ~orgId, ~getOrgList) => {
    open LogicUtils
    open APIUtils
    let getURL = useGetURL()
    let updateDetails = useUpdateMethod()
    let showToast = ToastState.useShowToast()
    let initialValues =
      [
        ("organization_name", OMPSwitchUtils.currentOMPName(orgList, orgId)->JSON.Encode.string),
      ]->Dict.fromArray

    let validateForm = (values: JSON.t) => {
      let errors = Dict.make()
      let organizationName =
        values->getDictFromJsonObject->getString("organization_name", "")->String.trim
      let regexForOrganizationName = "^([a-z]|[A-Z]|[0-9]|_|\\s)+$"

      let errorMessage = if organizationName->isEmptyString {
        "Organization name cannot be empty"
      } else if organizationName->String.length > 64 {
        "Organization name cannot exceed 64 characters"
      } else if !RegExp.test(RegExp.fromString(regexForOrganizationName), organizationName) {
        "Organization name should not contain special characters"
      } else {
        ""
      }

      if errorMessage->isNonEmptyString {
        Dict.set(errors, "organization_name", errorMessage->JSON.Encode.string)
      }

      errors->JSON.Encode.object
    }

    let orgName = FormRenderer.makeFieldInfo(
      ~label="Org Name",
      ~name="organization_name",
      ~placeholder=`Eg: Hyperswitch`,
      ~customInput=InputFields.textInput(),
      ~isRequired=true,
    )

    let onSubmit = async (values, _) => {
      try {
        let url = getURL(~entityName=UPDATE_ORGANIZATION, ~methodType=Put, ~id=Some(orgId))
        let _ = await updateDetails(url, values, Put)
        let _ = await getOrgList()
        showToast(~message="Updated organization name!", ~toastType=ToastSuccess)
      } catch {
      | _ => showToast(~message="Failed to update organization name!", ~toastType=ToastError)
      }
      setShowModal(_ => false)
      Nullable.null
    }

    <>
      <Modal modalHeading="Edit Org name" showModal setShowModal modalClass="w-1/4 m-auto">
        <Form initialValues={initialValues->JSON.Encode.object} onSubmit validate={validateForm}>
          <div className="flex flex-col gap-12 h-full w-full">
            <FormRenderer.DesktopRow>
              <FormRenderer.FieldRenderer
                fieldWrapperClass="w-full"
                field={orgName}
                labelClass="!text-black font-medium !-ml-[0.5px]"
              />
            </FormRenderer.DesktopRow>
            <div className="flex justify-end w-full pr-5 pb-3">
              <FormRenderer.SubmitButton
                text="Submit changes" buttonSize={Small} loadingText="Processing..."
              />
            </div>
          </div>
        </Form>
      </Modal>
    </>
  }
}
