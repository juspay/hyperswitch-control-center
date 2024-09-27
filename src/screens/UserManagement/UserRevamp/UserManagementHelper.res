open UserUtils

module OrganisationSelection = {
  @react.component
  let make = () => {
    let showToast = ToastState.useShowToast()
    let internalSwitch = OMPSwitchHooks.useInternalSwitch()
    let orgList = Recoil.useRecoilValueFromAtom(HyperswitchAtom.orgListAtom)
    let {userInfo: {userEntity}} = React.useContext(UserInfoProvider.defaultContext)

    let disableSelect = switch userEntity {
    | #Organization | #Merchant | #Profile => true
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
    | #Organization => false
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

    let disableSelect = switch userEntity {
    | #Profile => true
    | #Organization
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
    InputFields.textTagInput(
      ~input,
      ~placeholder=showPlaceHolder ? "Eg: mehak.sam@wise.com, deepak.ven@wise.com" : "",
      ~customButtonStyle="!rounded-full !px-4",
      ~seperateByComma=true,
    )
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

module UserOmpView = {
  @react.component
  let make = (
    ~views: array<UserManagementTypes.ompViewType>,
    ~userModuleEntity: UserManagementTypes.userModuleTypes,
    ~setUserModuleEntity,
  ) => {
    let (_, getNameForId) = OMPSwitchHooks.useOMPData()

    let cssBasedOnIndex = index => {
      if views->Array.length == 1 {
        "rounded-md"
      } else if index == 0 {
        "rounded-l-md"
      } else if index == views->Array.length - 1 {
        "rounded-r-md"
      } else {
        ""
      }
    }

    let getName = entityType => {
      let name = getNameForId(entityType)
      name->String.length > 10
        ? name
          ->String.substring(~start=0, ~end=10)
          ->String.concat("...")
        : name
    }

    let onChange = entity => {
      setUserModuleEntity(_ => entity)
    }

    let labelBasedOnEntity: UserManagementTypes.ompViewType => string = value =>
      switch value.entity {
      | #Default => value.label
      | _ => `${value.label} (${value.entity->getName})`
      }

    <div className="flex">
      <div className="flex h-fit">
        {views
        ->Array.mapWithIndex((value, index) => {
          let selectedStyle = userModuleEntity == value.entity ? `bg-blue-200` : ""

          <div
            key={index->Int.toString}
            onClick={_ => onChange(value.entity)->ignore}
            className={`text-xs py-2 px-3 ${selectedStyle} border text-blue-500 border-blue-500 ${index->cssBasedOnIndex} cursor-pointer break-all`}>
            {`${value->labelBasedOnEntity}`->React.string}
          </div>
        })
        ->React.array}
      </div>
    </div>
  }
}
