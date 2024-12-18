open UserUtils

module OrganisationSelection = {
  @react.component
  let make = () => {
    let showToast = ToastState.useShowToast()
    let internalSwitch = OMPSwitchHooks.useInternalSwitch()
    let orgList = Recoil.useRecoilValueFromAtom(HyperswitchAtom.orgListAtom)
    let {userInfo: {userEntity}} = React.useContext(UserInfoProvider.defaultContext)

    let disableSelect = switch userEntity {
    | #Tenant | #Organization | #Merchant | #Profile => true
    }

    let handleOnChange = async (event, input: ReactFinalForm.fieldRenderPropsInput) => {
      try {
        let _ = await internalSwitch(~expectedOrgId=Some(event->Identity.formReactEventToString))
        input.onChange(event)
      } catch {
      | _ => showToast(~message="Something went wrong. Please try again", ~toastType=ToastError)
      }
    }

    let field = FormRenderer.makeFieldInfo(
      ~label="Select an organization",
      ~name="org_value",
      ~customInput=(~input, ~placeholder as _) =>
        InputFields.selectInput(
          ~options=getMerchantSelectBoxOption(
            ~label="All organizations",
            ~value="all_organizations",
            ~dropdownList=orgList,
          ),
          ~deselectDisable=true,
          ~buttonText="Select an organization",
          ~fullLength=true,
          ~customButtonStyle="!rounded-lg",
          ~dropdownCustomWidth="!w-full",
          ~textStyle="!text-gray-500",
          ~disableSelect,
        )(
          ~input={
            ...input,
            onChange: event => handleOnChange(event, input)->ignore,
          },
          ~placeholder="Select an organization",
        ),
      ~isRequired=true,
    )
    <FormRenderer.FieldRenderer field labelClass="font-semibold" />
  }
}

module MerchantSelection = {
  @react.component
  let make = () => {
    let showToast = ToastState.useShowToast()
    let internalSwitch = OMPSwitchHooks.useInternalSwitch()
    let merchList = Recoil.useRecoilValueFromAtom(HyperswitchAtom.merchantListAtom)
    let {userInfo: {userEntity}} = React.useContext(UserInfoProvider.defaultContext)

    let disableSelect = switch userEntity {
    | #Merchant | #Profile => true
    | #Tenant | #Organization => false
    }

    let handleOnChange = async (event, input: ReactFinalForm.fieldRenderPropsInput) => {
      try {
        let selectedMerchantValue = event->Identity.formReactEventToString
        if selectedMerchantValue->stringToVariantForAllSelection->Option.isNone {
          let _ = await internalSwitch(~expectedMerchantId=Some(selectedMerchantValue))
        }
        input.onChange(event)
      } catch {
      | _ => showToast(~message="Something went wrong. Please try again", ~toastType=ToastError)
      }
    }

    let field = FormRenderer.makeFieldInfo(
      ~label="Merchants for access",
      ~name="merchant_value",
      ~customInput=(~input, ~placeholder as _) =>
        InputFields.selectInput(
          ~options=getMerchantSelectBoxOption(
            ~label="All merchants",
            ~value="all_merchants",
            ~dropdownList=merchList,
            ~showAllSelection=true,
          ),
          ~deselectDisable=true,
          ~buttonText="Select a Merchant",
          ~fullLength=true,
          ~customButtonStyle="!rounded-lg",
          ~dropdownCustomWidth="!w-full",
          ~textStyle="!text-gray-500",
          ~disableSelect,
        )(
          ~input={
            ...input,
            onChange: event => handleOnChange(event, input)->ignore,
          },
          ~placeholder="Select a merchant",
        ),
    )
    <FormRenderer.FieldRenderer field labelClass="font-semibold" />
  }
}

module ProfileSelection = {
  @react.component
  let make = () => {
    let showToast = ToastState.useShowToast()
    let internalSwitch = OMPSwitchHooks.useInternalSwitch()
    let profileList = Recoil.useRecoilValueFromAtom(HyperswitchAtom.profileListAtom)
    let {userInfo: {userEntity}} = React.useContext(UserInfoProvider.defaultContext)
    let form = ReactFinalForm.useForm()
    let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
      ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
    )

    let disableSelect = switch userEntity {
    | #Profile => true
    | #Tenant
    | #Organization => {
        let selected_merchant =
          formState.values
          ->LogicUtils.getDictFromJsonObject
          ->LogicUtils.getString("merchant_value", "")
        switch selected_merchant->stringToVariantForAllSelection {
        | Some(#All_Merchants) => {
            form.change(
              "profile_value",
              (#All_Profiles: UserManagementTypes.allSelectionType :> string)
              ->String.toLowerCase
              ->JSON.Encode.string,
            )
            true
          }
        | _ => false
        }
      }
    | #Merchant => false
    }

    let handleOnChange = async (event, input: ReactFinalForm.fieldRenderPropsInput) => {
      try {
        let selectedProfileValue = event->Identity.formReactEventToString

        if selectedProfileValue->stringToVariantForAllSelection->Option.isNone {
          let _ = await internalSwitch(~expectedProfileId=Some(selectedProfileValue))
        }
        input.onChange(event)
      } catch {
      | _ => showToast(~message="Something went wrong. Please try again", ~toastType=ToastError)
      }
    }

    let field = FormRenderer.makeFieldInfo(
      ~label="Profiles for access",
      ~name="profile_value",
      ~customInput=(~input, ~placeholder as _) =>
        InputFields.selectInput(
          ~options=getMerchantSelectBoxOption(
            ~label="All profiles",
            ~value="all_profiles",
            ~dropdownList=profileList,
            ~showAllSelection=true,
          ),
          ~deselectDisable=true,
          ~buttonText="Select a Profile",
          ~fullLength=true,
          ~customButtonStyle="!rounded-lg",
          ~dropdownCustomWidth="!w-full",
          ~textStyle="!text-gray-500",
          ~disableSelect,
        )(
          ~input={
            ...input,
            onChange: event => handleOnChange(event, input)->ignore,
          },
          ~placeholder="Select a merchant",
        ),
    )

    <FormRenderer.FieldRenderer field labelClass="font-semibold" />
  }
}

let inviteEmail = FormRenderer.makeFieldInfo(
  ~label="Enter email(s) ",
  ~name="email_list",
  ~customInput=(~input, ~placeholder as _) => {
    let showPlaceHolder = input.value->LogicUtils.getArrayFromJson([])->Array.length === 0
    <PillInput name="email_list" placeholder={showPlaceHolder ? "Eg: abc.sa@wise.com" : ""} />
  },
  ~isRequired=true,
)
module SwitchMerchantForUserAction = {
  @react.component
  let make = (~userInfoValue: UserManagementTypes.userDetailstype) => {
    let showToast = ToastState.useShowToast()
    let internalSwitch = OMPSwitchHooks.useInternalSwitch()

    let onSwitchForUserAction = async () => {
      try {
        let _ = await internalSwitch(
          ~expectedOrgId=userInfoValue.org.id,
          ~expectedMerchantId=userInfoValue.merchant.id,
          ~expectedProfileId=userInfoValue.profile.id,
        )
      } catch {
      | _ => showToast(~message="Failed to perform operation!", ~toastType=ToastError)
      }
    }

    <Button
      text="Switch to update"
      customButtonStyle="!p-2"
      buttonType={PrimaryOutline}
      onClick={_ => onSwitchForUserAction()->ignore}
    />
  }
}

module UserOmpViewBaseComp = {
  @react.component
  let make = (~userModuleEntity: UserManagementTypes.userModuleTypes, ~arrow) => {
    let (_, getNameForId) = OMPSwitchHooks.useOMPData()

    let arrowUpClass = "rotate-0 transition duration-[250ms] opacity-70"
    let arrowDownClass = "rotate-180 transition duration-[250ms] opacity-70"

    let displayName = switch userModuleEntity {
    | #Default => "My Team"
    | _ => userModuleEntity->getNameForId
    }

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

let generateDropdownOptionsOMPViews = (
  dropdownList: array<UserManagementTypes.usersOmpViewType>,
  getNameForId,
) => {
  let options: array<SelectBox.dropdownOption> = dropdownList->Array.map((
    item
  ): SelectBox.dropdownOption => {
    switch item.entity {
    | #Default => {
        label: `${item.label}`,
        value: `${(item.entity :> string)}`,
        labelDescription: `(${(item.entity :> string)})`,
        description: `${item.label}`,
      }
    | _ => {
        label: `${item.entity->getNameForId} (${(item.entity :> string)})`,
        value: `${(item.entity :> string)}`,
        labelDescription: `(${(item.entity :> string)})`,
        description: `${item.entity->getNameForId}`,
      }
    }
  })
  options
}

// Separate module is created for Users OMP Views because we need to
// handle the #Default view case which is specific to Users Module.
// To use OMPViews Component from OMPSwitchHelper we need to declare #Default entity
// in UserInfoTypes entity type as well and handle it at all places unneccesarily

module UserOmpView = {
  @react.component
  let make = (
    ~views: array<UserManagementTypes.usersOmpViewType>,
    ~userModuleEntity: UserManagementTypes.userModuleTypes,
    ~setUserModuleEntity,
  ) => {
    let (arrow, setArrow) = React.useState(_ => false)
    let (_, getNameForId) = OMPSwitchHooks.useOMPData()

    let input: ReactFinalForm.fieldRenderPropsInput = {
      name: "name",
      onBlur: _ => (),
      onChange: ev => {
        let value = ev->Identity.formReactEventToString
        let selection = switch value {
        | "Default" => #Default
        | _ => value->UserInfoUtils.entityMapper
        }
        setUserModuleEntity(_ => selection)
      },
      onFocus: _ => (),
      value: (userModuleEntity :> string)->JSON.Encode.string,
      checked: true,
    }

    let toggleChevronState = () => {
      setArrow(prev => !prev)
    }

    let customScrollStyle = "max-h-72 overflow-scroll px-1 pt-1"
    let dropdownContainerStyle = "rounded-ls border w-full shadow-md"

    <div className="flex">
      <div
        className="flex h-fit border border-grey-100 bg-white rounded-lg py-2 hover:bg-opacity-80">
        <SelectBox.BaseDropdown
          allowMultiSelect=false
          buttonText=""
          input
          deselectDisable=true
          customButtonStyle="!rounded-md"
          options={views->generateDropdownOptionsOMPViews(getNameForId)}
          marginTop="mt-8"
          hideMultiSelectButtons=true
          addButton=false
          customStyle="rounded absolute w-fit left-0"
          searchable=false
          baseComponent={<UserOmpViewBaseComp userModuleEntity arrow />}
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
    </div>
  }
}
