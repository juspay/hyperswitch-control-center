module ListBaseCompForProfile = {
  @react.component
  let make = (~currProfile, ~arrow) => {
    <div
      className="flex items-center justify-end text-sm text-center text-black font-medium rounded hover:bg-opacity-80 bg-white cursor-pointer">
      <div className="flex flex-row gap-2 p-2 fs-10">
        <p className="text-grey-900"> {"Profile"->React.string} </p>
        <p className="text-gray-400"> {"|"->React.string} </p>
        <p className="text-nowrap text-semibold"> {currProfile->React.string} </p>
      </div>
      <div className="px-2 py-2">
        <Icon
          className={arrow
            ? "rotate-180 transition duration-[250ms] opacity-70"
            : "rotate-0 transition duration-[250ms] opacity-70"}
          name="arrow-without-tail"
          size=15
        />
      </div>
    </div>
  }
}

module NewAccountCreationModal = {
  @react.component
  let make = (~setShowModal, ~showModal, ~getProfileList) => {
    open APIUtils
    let getURL = useGetURL()
    let updateDetails = useUpdateMethod()
    let showToast = ToastState.useShowToast()

    let createNewAccount = async values => {
      try {
        let url = getURL(~entityName=BUSINESS_PROFILE, ~methodType=Post)
        let body = values
        let _ = await updateDetails(url, body, Post)
        getProfileList()->ignore
        showToast(
          ~toastType=ToastSuccess,
          ~message="Account Created Successfully!",
          ~autoClose=true,
        )
      } catch {
      | _ => showToast(~toastType=ToastError, ~message="Account Creation Failed", ~autoClose=true)
      }

      setShowModal(_ => false)
      Nullable.null
    }

    let onSubmit = (values, _) => {
      createNewAccount(values)
    }

    let profileName = FormRenderer.makeFieldInfo(
      ~label="Profile Name",
      ~name="profile_name",
      ~placeholder="Eg: My New Profile",
      ~customInput=InputFields.textInput(),
      ~isRequired=true,
    )

    let modalBody =
      <div className="p-2 m-2">
        <div className="py-5 px-3 flex justify-between align-top">
          <CardUtils.CardHeader
            heading="Add a new profile"
            subHeading=""
            customSubHeadingStyle="w-full !max-w-none pr-10"
          />
          <div className="h-fit" onClick={_ => setShowModal(_ => false)}>
            <Icon
              name="close" className="border-2 p-2 rounded-2xl bg-gray-100 cursor-pointer" size=30
            />
          </div>
        </div>
        <Form key="new-account-creation" onSubmit>
          <div className="flex flex-col gap-12 h-full w-full">
            <FormRenderer.DesktopRow>
              <div className="flex flex-col gap-5">
                <FormRenderer.FieldRenderer
                  fieldWrapperClass="w-full"
                  field={profileName}
                  errorClass={ProdVerifyModalUtils.errorClass}
                  labelClass="!text-black font-medium !-ml-[0.5px]"
                />
              </div>
            </FormRenderer.DesktopRow>
            <div className="flex justify-end w-full pr-5 pb-3">
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
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let showToast = ToastState.useShowToast()
  let profileSwitch = OMPSwitchHooks.useProfileSwitch()
  let (showModal, setShowModal) = React.useState(_ => false)
  let {userInfo: {profileId}} = React.useContext(UserInfoProvider.defaultContext)
  let (profileList, setProfileList) = Recoil.useRecoilState(HyperswitchAtom.profileListAtom)
  let (showSwitchingProfile, setShowSwitchingProfile) = React.useState(_ => false)
  let (arrow, setArrow) = React.useState(_ => false)
  let businessProfiles = Recoil.useRecoilValueFromAtom(HyperswitchAtom.businessProfilesAtom)

  let getProfileList = async () => {
    try {
      let url = getURL(~entityName=USERS, ~userType=#LIST_PROFILE, ~methodType=Get)
      let response = await fetchDetails(url)
      setProfileList(_ => response->getArrayDataFromJson(profileItemToObjMapper))
    } catch {
    | _ => {
        setProfileList(_ => ompDefaultValue(profileId, ""))
        showToast(~message="Failed to fetch profile list", ~toastType=ToastError)
      }
    }
  }
  let customStyle = "text-blue-500 bg-white dark:bg-black hover:bg-jp-gray-100 text-nowrap w-full"
  let addItemBtnStyle = "border border-t-0 w-full"
  let customScrollStyle = "max-h-72 overflow-scroll px-1 pt-1 border border-b-0"
  let dropdownContainerStyle = "min-w-[15rem] rounded-md border border-1"
  let profileSwitch = async value => {
    try {
      setShowSwitchingProfile(_ => true)
      let _ = await profileSwitch(~expectedProfileId=value, ~currentProfileId=profileId)
      RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url="/home"))
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

  React.useEffect(() => {
    getProfileList()->ignore
    None
  }, [businessProfiles])

  let toggleChevronState = () => {
    setArrow(prev => !prev)
  }

  <div className="border border-gray-200 rounded-md">
    <SelectBox.BaseDropdown
      allowMultiSelect=false
      buttonText=""
      input
      deselectDisable=true
      customButtonStyle="!rounded-md"
      options={profileList->generateDropdownOptions}
      hideMultiSelectButtons=true
      addButton=false
      searchable=false
      customStyle="absolute w-fit right-0"
      baseComponent={<ListBaseCompForProfile
        currProfile={currentOMPName(profileList, profileId)} arrow
      />}
      baseComponentCustomStyle="bg-white"
      bottomComponent={<OMPSwitchHelper.AddNewMerchantProfileButton
        user="profile" setShowModal customStyle addItemBtnStyle
      />}
      optionClass="text-gray-600 text-fs-14"
      selectClass="text-gray-600 text-fs-14"
      customDropdownOuterClass="!border-none !w-full"
      fullLength=true
      toggleChevronState
      customScrollStyle
      dropdownContainerStyle
    />
    <RenderIf condition={showModal}>
      <NewAccountCreationModal setShowModal showModal getProfileList />
    </RenderIf>
    <LoaderModal
      showModal={showSwitchingProfile}
      setShowModal={setShowSwitchingProfile}
      text="Switching profile..."
    />
  </div>
}
