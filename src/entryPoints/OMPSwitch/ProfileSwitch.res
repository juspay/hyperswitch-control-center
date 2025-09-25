module NewProfileCreationModal = {
  @react.component
  let make = (~setShowModal, ~showModal, ~getProfileList) => {
    open APIUtils
    let getURL = useGetURL()
    let mixpanelEvent = MixpanelHook.useSendEvent()
    let updateDetails = useUpdateMethod()
    let showToast = ToastState.useShowToast()

    let createNewProfile = async values => {
      try {
        let url = getURL(~entityName=V1(BUSINESS_PROFILE), ~methodType=Post)
        let body = values
        mixpanelEvent(~eventName="create_new_profile", ~metadata=values)
        let _ = await updateDetails(url, body, Post)
        getProfileList()->ignore
        showToast(
          ~toastType=ToastSuccess,
          ~message="Profile Created Successfully!",
          ~autoClose=true,
        )
      } catch {
      | _ => showToast(~toastType=ToastError, ~message="Profile Creation Failed", ~autoClose=true)
      }

      setShowModal(_ => false)
      Nullable.null
    }

    let onSubmit = (values, _) => {
      open LogicUtils
      let dict = values->getDictFromJsonObject
      let trimmedData = dict->getString("profile_name", "")->String.trim
      Dict.set(dict, "profile_name", trimmedData->JSON.Encode.string)
      createNewProfile(dict->JSON.Encode.object)
    }

    let profileName = FormRenderer.makeFieldInfo(
      ~label="Profile Name",
      ~name="profile_name",
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
          ~placeholder="Eg: My New Profile",
        ),
      ~isRequired=true,
    )

    let validateForm = (values: JSON.t) => {
      open LogicUtils
      let errors = Dict.make()
      let profileName = values->getDictFromJsonObject->getString("profile_name", "")->String.trim
      let regexForProfileName = "^([a-z]|[A-Z]|[0-9]|_|\\s)+$"

      let errorMessage = if profileName->isEmptyString {
        "Profile name cannot be empty"
      } else if profileName->String.length > 64 {
        "Profile name cannot exceed 64 characters"
      } else if !RegExp.test(RegExp.fromString(regexForProfileName), profileName) {
        "Profile name should not contain special characters"
      } else {
        ""
      }

      if errorMessage->isNonEmptyString {
        Dict.set(errors, "profile_name", errorMessage->JSON.Encode.string)
      }

      errors->JSON.Encode.object
    }

    let modalBody =
      <div className="">
        <div className="pt-3 m-3 flex justify-between">
          <CardUtils.CardHeader
            heading="Add a new profile"
            subHeading=""
            customSubHeadingStyle="w-full !max-w-none pr-10"
          />
          <div className="h-fit" onClick={_ => setShowModal(_ => false)}>
            <Icon name="modal-close-icon" className="cursor-pointer" size=30 />
          </div>
        </div>
        <hr />
        <Form key="new-profile-creation" onSubmit validate={validateForm}>
          <div className="flex flex-col h-full w-full">
            <div className="py-10">
              <FormRenderer.DesktopRow>
                <FormRenderer.FieldRenderer
                  fieldWrapperClass="w-full"
                  field={profileName}
                  errorClass={ProdVerifyModalUtils.errorClass}
                  labelClass="!text-black font-medium !-ml-[0.5px]"
                />
              </FormRenderer.DesktopRow>
            </div>
            <hr className="mt-4" />
            <div className="flex justify-end w-full p-3">
              <FormRenderer.SubmitButton text="Add Profile" buttonSize=Small />
            </div>
          </div>
        </Form>
      </div>

    <Modal
      showModal
      closeOnOutsideClick=true
      setShowModal
      childClass="p-0"
      borderBottom=true
      modalClass="w-full max-w-xl mx-auto my-auto dark:!bg-jp-gray-lightgray_background">
      {modalBody}
    </Modal>
  }
}

@react.component
let make = () => {
  open APIUtils
  open LogicUtils
  open OMPSwitchUtils
  open OMPSwitchHelper
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let showToast = ToastState.useShowToast()
  let internalSwitch = OMPSwitchHooks.useInternalSwitch()
  let (showModal, setShowModal) = React.useState(_ => false)
  let {userInfo: {profileId, version}} = React.useContext(UserInfoProvider.defaultContext)
  let (profileList, setProfileList) = Recoil.useRecoilState(HyperswitchAtom.profileListAtom)
  let (showSwitchingProfile, setShowSwitchingProfile) = React.useState(_ => false)
  let (arrow, setArrow) = React.useState(_ => false)
  let businessProfileRecoilVal =
    HyperswitchAtom.businessProfileFromIdAtom->Recoil.useRecoilValueFromAtom
  let isMobileView = MatchMedia.useMobileChecker()

  let widthClass = isMobileView ? "w-full" : "md:w-[14rem] md:max-w-[20rem]"
  let roundedClass = isMobileView ? "rounded-none" : "rounded-md"

  let getProfileList = async () => {
    try {
      let response = switch version {
      | V1 => {
          let url = getURL(~entityName=V1(USERS), ~userType=#LIST_PROFILE, ~methodType=Get)
          await fetchDetails(url)
        }
      | V2 => {
          let url = getURL(~entityName=V2(USERS), ~userType=#LIST_PROFILE, ~methodType=Get)
          await fetchDetails(url, ~version=V2)
        }
      }

      setProfileList(_ => response->getArrayDataFromJson(profileItemToObjMapper))
    } catch {
    | _ => {
        setProfileList(_ => [ompDefaultValue(profileId, "")])
        showToast(~message="Failed to fetch profile list", ~toastType=ToastError)
      }
    }
  }
  let customStyle = "text-primary bg-white dark:bg-black hover:bg-jp-gray-100 text-nowrap w-full"
  let addItemBtnStyle = "w-full"
  let customScrollStyle = "max-h-72 overflow-scroll px-1 pt-1"
  let dropdownContainerStyle = `${roundedClass} border border-1 ${widthClass}`
  let profileSwitch = async value => {
    try {
      setShowSwitchingProfile(_ => true)
      let _ = await internalSwitch(~expectedProfileId=Some(value), ~changePath=true)
      setShowSwitchingProfile(_ => false)
    } catch {
    | _ => {
        showToast(~message="Failed to switch profile", ~toastType=ToastError)
        setShowSwitchingProfile(_ => false)
      }
    }
  }

  let input: ReactFinalForm.fieldRenderPropsInput = {
    name: "name",
    onBlur: _ => (),
    onChange: ev => {
      let value = ev->Identity.formReactEventToString
      profileSwitch(value)->ignore
    },
    onFocus: _ => (),
    value: profileId->JSON.Encode.string,
    checked: true,
  }

  // TODO : remove businessProfiles as dependancy in remove-business-profile-add-as-a-section pr
  React.useEffect(() => {
    getProfileList()->ignore
    None
  }, [businessProfileRecoilVal])

  let toggleChevronState = () => {
    setArrow(prev => !prev)
  }

  let updatedProfileList: array<
    OMPSwitchTypes.ompListTypesCustom,
  > = profileList->Array.mapWithIndex((item, i) => {
    let customComponent =
      <ProfileDropdownItem
        key={Int.toString(i)} profileName=item.name index=i currentId=item.id profileSwitch
      />
    let listItem: OMPSwitchTypes.ompListTypesCustom = {
      id: item.id,
      name: item.name,
      customComponent,
    }
    listItem
  })

  let bottomComponent = switch version {
  | V1 => <AddNewOMPButton user=#Profile setShowModal customStyle addItemBtnStyle />
  | V2 => React.null
  }

  <>
    <SelectBox.BaseDropdown
      allowMultiSelect=false
      buttonText=""
      input
      deselectDisable=true
      customButtonStyle="!rounded-md"
      options={updatedProfileList->generateDropdownOptionsCustomComponent(~isPlatformOrg=false)}
      marginTop="mt-10"
      hideMultiSelectButtons=true
      addButton=false
      searchable=true
      customStyle="w-fit "
      baseComponent={<ListBaseComp
        user={#Profile} heading="Profile" subHeading={currentOMPName(profileList, profileId)} arrow
      />}
      bottomComponent
      customDropdownOuterClass="!border-none "
      fullLength=true
      toggleChevronState
      customScrollStyle
      dropdownContainerStyle
      shouldDisplaySelectedOnTop=true
      placeholderCss="text-fs-13"
    />
    <RenderIf condition={showModal}>
      <NewProfileCreationModal setShowModal showModal getProfileList />
    </RenderIf>
    <LoaderModal
      showModal={showSwitchingProfile}
      setShowModal={setShowSwitchingProfile}
      text="Switching profile..."
    />
  </>
}
