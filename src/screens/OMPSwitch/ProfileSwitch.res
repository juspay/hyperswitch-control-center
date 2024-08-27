module ListBaseComp = {
  @react.component
  let make = () => {
    let (arrow, setArrow) = React.useState(_ => false)
    // let {profileId} = React.useContext(UserInfoProvider.defaultContext)

    <div className="flex flex-col items-end gap-2 mr-2" onClick={_ => setArrow(prev => !prev)}>
      <div
        className="flex items-center justify-end text-sm text-center text-black font-medium rounded hover:bg-opacity-80 bg-white w-fit">
        <div className="flex flex-col items-start px-2 py-2  ">
          // <p className="text-xs text-gray-400"> {"Profile"->React.string} </p>
          <p className="fs-10 text-nowrap"> {"current_profile_id"->React.string} </p>
        </div>
        <div className="px-2 py-2">
          <Icon
            className={arrow
              ? `rotate-0 transition duration-[250ms] opacity-70`
              : `rotate-180 transition duration-[250ms] opacity-70`}
            name="arrow-without-tail"
            size=15
          />
        </div>
      </div>
    </div>
  }
}

module AddNewProfileButton = {
  @react.component
  let make = (~setShowModal) => {
    let userPermissionJson = Recoil.useRecoilValueFromAtom(HyperswitchAtom.userPermissionAtom)
    let cursorStyles = PermissionUtils.cursorStyles(userPermissionJson.merchantDetailsManage)
    // let {globalUIConfig: {font: {textColor}}} = React.useContext(ThemeProvider.themeContext)
    <>
      <ACLDiv
        permission={userPermissionJson.merchantDetailsManage}
        onClick={_ => setShowModal(_ => true)}
        isRelative=false
        contentAlign=Default
        tooltipForWidthClass="!h-full"
        className={`${cursorStyles} px-1 py-1`}>
        {<>
          <hr />
          <div
            className="group flex gap-2 font-medium w-56 items-center px-2 py-2 text-sm text-blue-500 bg-white dark:bg-black hover:bg-jp-gray-100">
            <Icon name="plus-circle" size=15 />
            {"Add new profile"->React.string}
          </div>
        </>}
      </ACLDiv>
    </>
  }
}

module NewAccountCreationModal = {
  @react.component
  let make = (~setShowModal, ~showModal, ~setFetchUpdatedProfileList) => {
    open APIUtils
    let getURL = useGetURL()
    let updateDetails = useUpdateMethod()
    let showToast = ToastState.useShowToast()
    // let fetchSwitchMerchantList = SwitchMerchantListHook.useFetchSwitchMerchantList()

    let createNewAccount = async values => {
      try {
        let url = getURL(~entityName=BUSINESS_PROFILE, ~methodType=Post)
        let body = values
        let _ = await updateDetails(url, body, Post)
        // let _ = await fetchSwitchMerchantList()
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
      setFetchUpdatedProfileList(prev => !prev)
      createNewAccount(values)
    }

    let profileName = FormRenderer.makeFieldInfo(
      ~label="Profile Name",
      ~name="profile_name",
      ~placeholder="Eg: My New Profile",
      ~customInput=InputFields.textInput(),
      ~isRequired=true,
    )

    let modalBody = {
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
              <FormRenderer.SubmitButton text="Add Profile" buttonSize={Small} />
            </div>
          </div>
        </Form>
      </div>
    }

    <Modal
      showModal
      closeOnOutsideClick=true
      setShowModal
      childClass="p-0"
      borderBottom=true
      modalClass="w-full max-w-xl mx-auto my-auto dark:!bg-jp-gray-lightgray_background">
      modalBody
    </Modal>
  }
}

@react.component
let make = () => {
  open APIUtils
  open LogicUtils
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let (profileList, setProfileList) = React.useState(_ => Dict.make()->JSON.Encode.object)
  let (showModal, setShowModal) = React.useState(_ => false)
  let (fetchUpdatedProfileList, setFetchUpdatedProfileList) = React.useState(_ => true)
  //   let {profileId} = React.useContext(UserInfoProvider.defaultContext)

  let getProfileList = async () => {
    try {
      let url = getURL(~entityName=USERS, ~userType=#LIST_PROFILE, ~methodType=Get)
      let response = await fetchDetails(url)
      setProfileList(_ => response)
    } catch {
    | _ => ()
    }
  }

  React.useEffect(() => {
    getProfileList()->ignore
    None
  }, [fetchUpdatedProfileList])

  let profileListArray =
    profileList
    ->getArrayFromJson([])
    ->Array.map(item => {
      let dict = item->getDictFromJsonObject
      let profileId = dict->getString("profile_id", "")
      profileId
    })

  let options = profileListArray->SelectBox.makeOptions

  let input: ReactFinalForm.fieldRenderPropsInput = {
    name: "name",
    onBlur: _ => (),
    onChange: _ => (),
    onFocus: _ => (),
    value: "current_profile_id"->JSON.Encode.string,
    checked: true,
  }

  <div className="">
    <SelectBox.BaseDropdown
      allowMultiSelect=false
      buttonText=""
      input
      deselectDisable=true
      customButtonStyle="!rounded-md"
      options
      hideMultiSelectButtons=true
      addButton=false
      // dropdownCustomWidth="!w-fit"
      searchable=false
      fullLength=true
      baseComponent={<ListBaseComp />}
      baseComponentCustomStyle="bg-white !w-fit"
      bottomComponent={<AddNewProfileButton setShowModal />}
      optionClass="text-gray-600 text-fs-14"
      selectClass="text-gray-600 text-fs-14"
      customDropdownOuterClass="!border-none"
    />
    <RenderIf condition={showModal}>
      <NewAccountCreationModal setShowModal showModal setFetchUpdatedProfileList />
    </RenderIf>
  </div>
}
