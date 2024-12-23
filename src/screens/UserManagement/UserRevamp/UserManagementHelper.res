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

let generateDropdownOptionsUserOMPViews = (
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

module UserOmpView = {
  @react.component
  let make = (
    ~views: array<UserManagementTypes.usersOmpViewType>,
    ~selectedEntity: UserManagementTypes.userModuleTypes,
    ~onChange,
  ) => {
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
        onChange(selection)->ignore
      },
      onFocus: _ => (),
      value: (selectedEntity :> string)->JSON.Encode.string,
      checked: true,
    }

    let options = views->generateDropdownOptionsUserOMPViews(getNameForId)

    let displayName = switch selectedEntity {
    | #Default => "My Team"
    | _ => selectedEntity->getNameForId
    }

    <OMPSwitchHelper.OMPViewsComp input options displayName />
  }
}
