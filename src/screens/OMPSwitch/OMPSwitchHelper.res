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
    Js.log2("omp arrow", arrow)

    let baseCompStyle = switch isDarkBg {
    | false => "text-black hover:bg-opacity-80"
    | true => "text-white hover:bg-opacity-80 bg-sidebar-blue"
    }

    let iconName = switch isDarkBg {
    | false => "arrow-without-tail"
    | true => "arrow-without-tail-new"
    }

    let arrowDownClass = switch isDarkBg {
    | false => "rotate-180 transition duration-[250ms] opacity-70"
    | true => "rotate-0 transition duration-[250ms] opacity-70"
    }

    let arrowUpClass = switch isDarkBg {
    | false => "rotate-0 transition duration-[250ms] opacity-70"
    | true => "-rotate-180 transition duration-[250ms] opacity-70"
    }

    let textColor = switch isDarkBg {
    | false => "text-grey-900"
    | true => "text-white"
    }

    let width = switch isDarkBg {
    | true => "w-5/6"
    | false => "w-full"
    }

    <div
      className={`flex items-center justify-between text-sm text-center font-medium  cursor-pointer w-full overflow-scroll ${baseCompStyle}`}>
      <div className={`${width}`}>
        <RenderIf condition={heading->LogicUtils.isNonEmptyString}>
          <p className="text-xs text-left text-gray-400"> {heading->React.string} </p>
        </RenderIf>
        <div className="text-left flex gap-2">
          <p className={`fs-10 ${textColor} overflow-scroll`}> {subHeading->React.string} </p>
          <RenderIf condition={showEditIcon}>
            <Icon name="pencil-alt" size=10 onClick=onEditClick className="mr-1" />
          </RenderIf>
          <Icon className={arrow ? arrowDownClass : arrowUpClass} name={iconName} size=15 />
        </div>
      </div>
    </div>
  }
}

module AddNewMerchantProfileButton = {
  @react.component
  let make = (
    ~user,
    ~setShowModal,
    ~customPadding="",
    ~customStyle="",
    ~customHRTagStyle="",
    ~addItemBtnStyle="",
  ) => {
    let {userHasAccess, hasAnyGroupAccess} = GroupACLHooks.useUserGroupACLHook()
    let cursorStyles = GroupAccessUtils.cursorStyles(
      // TODO: Remove `MerchantDetailsManage` permission in future
      hasAnyGroupAccess(
        userHasAccess(~groupAccess=MerchantDetailsManage),
        userHasAccess(~groupAccess=AccountManage),
      ),
    )
    <ACLDiv
      // TODO: Remove `MerchantDetailsManage` permission in future
      authorization={hasAnyGroupAccess(
        userHasAccess(~groupAccess=MerchantDetailsManage),
        userHasAccess(~groupAccess=AccountManage),
      )}
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
          {`Add new ${user}`->React.string}
        </div>
      </>}
    </ACLDiv>
  }
}

module OMPViews = {
  @react.component
  let make = (
    ~views: OMPSwitchTypes.ompViews,
    ~selectedEntity: UserInfoTypes.entity,
    ~onChange,
  ) => {
    open OMPSwitchUtils

    let {userInfo} = React.useContext(UserInfoProvider.defaultContext)
    let merchantList = Recoil.useRecoilValueFromAtom(HyperswitchAtom.merchantListAtom)
    let orgList = Recoil.useRecoilValueFromAtom(HyperswitchAtom.orgListAtom)
    let profileList = Recoil.useRecoilValueFromAtom(HyperswitchAtom.profileListAtom)

    let cssBasedOnIndex = index => {
      if index == 0 {
        "rounded-l-md"
      } else if index == views->Array.length - 1 {
        "rounded-r-md"
      } else {
        ""
      }
    }

    let getName = entityType => {
      let name = switch entityType {
      | #Organization => currentOMPName(orgList, userInfo.orgId)
      | #Merchant => currentOMPName(merchantList, userInfo.merchantId)
      | #Profile => currentOMPName(profileList, userInfo.profileId)
      | _ => ""
      }
      name->String.length > 10
        ? name
          ->String.substring(~start=0, ~end=10)
          ->String.concat("...")
        : name
    }

    <div className="flex h-fit">
      {views
      ->Array.mapWithIndex((value, index) => {
        let selectedStyle = selectedEntity == value.entity ? `bg-blue-200` : ""
        <div
          key={index->Int.toString}
          onClick={_ => onChange(value.entity)->ignore}
          className={`text-xs py-2 px-3 ${selectedStyle} border text-blue-500 border-blue-500 ${index->cssBasedOnIndex} cursor-pointer break-all`}>
          {`${value.lable} (${value.entity->getName})`->React.string}
        </div>
      })
      ->React.array}
    </div>
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
