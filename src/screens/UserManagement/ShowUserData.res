open UserManagementUtils
open UIUtils

external typeConversion: array<Nullable.t<UserRoleEntity.userTableTypes>> => array<
  UserRoleEntity.userTableTypes,
> = "%identity"

module UserUtilsPopover = {
  @react.component
  let make = (~infoValue: UserRoleEntity.userTableTypes, ~setIsUpdateRoleSelected) => {
    open HeadlessUI
    open APIUtils
    open CommonAuthHooks
    let getURL = useGetURL()
    let updateDetails = useUpdateMethod()
    let showToast = ToastState.useShowToast()
    let {email: merchantEmail} = useCommonAuthInfo()->Option.getOr(defaultAuthInfo)
    let showPopUp = PopUpState.useShowPopUp()

    let deleteUser = async () => {
      try {
        let url = getURL(~entityName=USERS, ~methodType=Post, ~userType={#USER_DELETE}, ())
        let body =
          [("email", infoValue.email->JSON.Encode.string)]->LogicUtils.getJsonFromArrayOfJson
        let _ = await updateDetails(url, body, Delete, ())
        showToast(~message=`User has been successfully deleted.`, ~toastType=ToastSuccess, ())
        RescriptReactRouter.replace(HSwitchGlobalVars.appendDashboardPath(~url="/users"))
      } catch {
      | _ => ()
      }
    }

    <RenderIf condition={infoValue.email !== merchantEmail}>
      <Popover className="relative inline-block text-left">
        {popoverProps => <>
          <Popover.Button
            className={
              let openClasses = if popoverProps["open"] {
                `group border py-2 rounded-md inline-flex items-center text-base font-medium hover:text-opacity-100 focus:outline-none`
              } else {
                `text-opacity-90 group border py-2 rounded-md inline-flex items-center text-base font-medium hover:text-opacity-100 focus:outline-none`
              }
              `${openClasses} border-none`
            }>
            {buttonProps => <Icon name="menu-option" size=28 />}
          </Popover.Button>
          <Transition
            \"as"="span"
            enter={"transition ease-out duration-200"}
            enterFrom="opacity-0 translate-y-1"
            enterTo="opacity-100 translate-y-0"
            leave={"transition ease-in duration-150"}
            leaveFrom="opacity-100 translate-y-0"
            leaveTo="opacity-0 translate-y-1">
            <Popover.Panel className={`absolute !z-30 right-2`}>
              {panelProps => {
                <div
                  className="relative flex flex-col py-3 rounded-lg shadow-lg ring-1 ring-black ring-opacity-5 w-40">
                  <Navbar.MenuOption
                    text="Update role"
                    onClick={_ => {
                      panelProps["close"]()
                      setIsUpdateRoleSelected(_ => true)
                    }}
                  />
                  <RenderIf condition={infoValue.role_id !== "org_admin"}>
                    <Navbar.MenuOption
                      text="Delete user"
                      onClick={_ => {
                        panelProps["close"]()
                        showPopUp({
                          popUpType: (Warning, WithIcon),
                          heading: `Are you sure you want to delete this user?`,
                          description: React.string(`This action cannot be undone. Deleting the user will permanently remove all associated data from this account. Press Confirm to delete.`),
                          handleConfirm: {text: "Confirm", onClick: _ => deleteUser()->ignore},
                          handleCancel: {text: "Back"},
                        })
                      }}
                    />
                  </RenderIf>
                </div>
              }}
            </Popover.Panel>
          </Transition>
        </>}
      </Popover>
    </RenderIf>
  }
}

module UserHeading = {
  @react.component
  let make = (
    ~infoValue: UserRoleEntity.userTableTypes,
    ~isUpdateRoleSelected,
    ~setIsUpdateRoleSelected,
    ~newRoleSelected,
  ) => {
    open APIUtils
    let getURL = useGetURL()
    let fetchDetails = useGetMethod()
    let showToast = ToastState.useShowToast()
    let updateDetails = useUpdateMethod()
    let status = infoValue.status->UserRoleEntity.statusToVariantMapper
    let (buttonState, setButtonState) = React.useState(_ => Button.Normal)
    let {permissionInfo, setPermissionInfo} = React.useContext(GlobalProvider.defaultContext)
    let userPermissionJson = HyperswitchAtom.userPermissionAtom->Recoil.useRecoilValueFromAtom

    let resendInvite = async () => {
      try {
        setButtonState(_ => Button.Loading)
        let url = getURL(~entityName=USERS, ~userType=#RESEND_INVITE, ~methodType=Post, ())
        let body =
          [("email", infoValue.email->JSON.Encode.string)]->Dict.fromArray->JSON.Encode.object
        let _ = await updateDetails(url, body, Post, ())
        showToast(~message=`Invite resend. Please check your email.`, ~toastType=ToastSuccess, ())
        setButtonState(_ => Button.Normal)
      } catch {
      | _ => setButtonState(_ => Button.Normal)
      }
    }

    let updatePermissionInfoOnBack = async () => {
      try {
        let url = getURL(
          ~entityName=USER_MANAGEMENT,
          ~userRoleTypes=ROLE_ID,
          ~id=Some(infoValue.role_id),
          ~methodType=Get,
          (),
        )
        let res = await fetchDetails(url)

        let defaultList = defaultPresentInInfoList(permissionInfo)
        setPermissionInfo(_ => defaultList)
        let updatedPermissionListForGivenRole = updatePresentInInfoList(
          defaultList,
          res->getArrayOfPermissionData,
        )
        setPermissionInfo(_ => updatedPermissionListForGivenRole)
        setIsUpdateRoleSelected(_ => false)
      } catch {
      | _ => RescriptReactRouter.replace(HSwitchGlobalVars.appendDashboardPath(~url="/users"))
      }
    }

    let updateRole = async () => {
      try {
        let url = getURL(~entityName=USERS, ~methodType=Post, ~userType={#UPDATE_ROLE}, ())
        let body =
          [
            ("email", infoValue.email->JSON.Encode.string),
            ("role_id", newRoleSelected->JSON.Encode.string),
          ]->LogicUtils.getJsonFromArrayOfJson
        let _ = await updateDetails(url, body, Post, ())
        showToast(~message=`Role successfully updated!`, ~toastType=ToastSuccess, ())
        RescriptReactRouter.replace(HSwitchGlobalVars.appendDashboardPath(~url="/users"))
      } catch {
      | _ => ()
      }
    }

    let onClickHandler = () => {
      if newRoleSelected === infoValue.role_id {
        setIsUpdateRoleSelected(_ => false)
      } else {
        updatePermissionInfoOnBack()->ignore
      }
    }

    <div className="flex justify-between flex-wrap">
      <PageUtils.PageHeading
        title=infoValue.name
        subTitle=infoValue.email
        customTitleStyle="!p-0"
        isTag=true
        tagText={infoValue.role_name->String.toUpperCase}
      />
      <RenderIf condition={isUpdateRoleSelected}>
        <div className="flex items-center gap-2">
          <Button
            buttonType={Secondary}
            text="Back"
            onClick={_ => onClickHandler()}
            customButtonStyle="!p-3"
          />
          <Button
            buttonType={Primary}
            text="Update role"
            onClick={_ => updateRole()->ignore}
            customButtonStyle="!p-3"
          />
        </div>
      </RenderIf>
      <RenderIf condition={!isUpdateRoleSelected}>
        <div className="flex items-center gap-4">
          <div className={`font-semibold text-green-700`}>
            {switch status {
            | InviteSent => "INVITE SENT"->String.toUpperCase->React.string
            | _ => infoValue.status->String.toUpperCase->React.string
            }}
          </div>
          <RenderIf condition={userPermissionJson.usersManage === Access}>
            <div className="flex items-center gap-2">
              <RenderIf condition={status !== Active}>
                <Button
                  text="Resend Invite"
                  buttonState
                  buttonType={Primary}
                  customButtonStyle="!px-2"
                  onClick={_ => resendInvite()->ignore}
                />
              </RenderIf>
              <UserUtilsPopover infoValue setIsUpdateRoleSelected />
            </div>
          </RenderIf>
        </div>
      </RenderIf>
    </div>
  }
}

@react.component
let make = () => {
  open APIUtils
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let url = RescriptReactRouter.useUrl()
  let (roleData, setRoleData) = React.useState(_ => JSON.Encode.null)
  let {permissionInfo, setPermissionInfo} = React.useContext(GlobalProvider.defaultContext)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (isUpdateRoleSelected, setIsUpdateRoleSelected) = React.useState(_ => false)
  let (newRoleSelected, setNewRoleSelected) = React.useState(_ => "")
  let (currentSelectedUser, setCurrentSelectedUser) = React.useState(_ =>
    Dict.make()->UserRoleEntity.itemToObjMapperForUser
  )

  let getRoleForUser = async (~role_id) => {
    try {
      let url = getURL(
        ~entityName=USER_MANAGEMENT,
        ~userRoleTypes=ROLE_ID,
        ~id={
          Some(role_id)
        },
        ~methodType=Get,
        (),
      )
      let res = await fetchDetails(`${url}?groups=true`)
      setRoleData(_ => res)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | Exn.Error(e) =>
      let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
      setScreenState(_ => PageLoaderWrapper.Error(err))
    }
  }

  let getPermissionInfo = async () => {
    try {
      let url = getURL(~entityName=USERS, ~userType=#PERMISSION_INFO, ~methodType=Get, ())
      let res = await fetchDetails(`${url}?groups=true`)
      let permissionInfoValue =
        res->LogicUtils.getArrayDataFromJson(ProviderHelper.itemToObjMapperForGetInfo)

      setPermissionInfo(_ => permissionInfoValue)
    } catch {
    | _ => ()
    }
  }

  let getUserData = async () => {
    try {
      let userDataURL = getURL(
        ~entityName=USER_MANAGEMENT,
        ~methodType=Get,
        ~userRoleTypes=USER_LIST,
        (),
      )
      let res = await fetchDetails(userDataURL)
      let userData = res->LogicUtils.getArrayDataFromJson(UserRoleEntity.itemToObjMapperForUser)
      let localCurrentSelectedUser =
        userData
        ->Array.map(Nullable.make)
        ->typeConversion
        ->Array.reduce(Dict.make()->UserRoleEntity.itemToObjMapperForUser, (acc, ele) => {
          url.search
          ->LogicUtils.getDictFromUrlSearchParams
          ->Dict.get("email")
          ->Option.getOr("")
          ->String.includes(ele.email)
            ? ele
            : acc
        })
      setCurrentSelectedUser(_ => localCurrentSelectedUser)
      if localCurrentSelectedUser.role_id->LogicUtils.isNonEmptyString {
        getRoleForUser(~role_id=localCurrentSelectedUser.role_id)->ignore
      } else {
        setScreenState(_ => PageLoaderWrapper.Custom)
      }
    } catch {
    | _ => ()
    }
  }

  React.useEffect0(() => {
    getUserData()->ignore
    if permissionInfo->Array.length === 0 {
      getPermissionInfo()->ignore
    }
    None
  })

  React.useEffect1(() => {
    let defaultList = defaultPresentInInfoList(permissionInfo)
    setPermissionInfo(_ => defaultList)
    let updatedPermissionListForGivenRole = updatePresentInInfoList(
      defaultList,
      roleData->getArrayOfPermissionData,
    )
    setPermissionInfo(_ => updatedPermissionListForGivenRole)

    None
  }, [roleData])

  let customUrlErrorScreen =
    <DefaultLandingPage
      title="Oops, we hit a little bump on the road!"
      customStyle={`py-16 !m-0 h-80-vh`}
      overriddingStylesTitle="text-2xl font-semibold"
      buttonText="Back"
      overriddingStylesSubtitle="!text-sm text-grey-700 opacity-50 !w-3/4"
      subtitle="We apologize for the inconvenience, but it seems like we encountered a hiccup while processing your request."
      onClickHandler={_ =>
        RescriptReactRouter.replace(HSwitchGlobalVars.appendDashboardPath(~url="/users"))}
      isButton=true
    />

  <PageLoaderWrapper screenState customUI={customUrlErrorScreen}>
    <div className="h-full">
      <BreadCrumbNavigation
        path=[{title: "Users", link: "/users"}] currentPageTitle=currentSelectedUser.name
      />
      <div className="h-4/5 bg-white mt-5 p-10 relative flex flex-col gap-8">
        <UserHeading
          infoValue={currentSelectedUser}
          isUpdateRoleSelected
          setIsUpdateRoleSelected
          newRoleSelected
        />
        <RenderIf condition={!isUpdateRoleSelected}>
          <div className="flex flex-col justify-between gap-12 show-scrollbar overflow-scroll">
            {permissionInfo
            ->Array.mapWithIndex((ele, index) => {
              <RolePermissionValueRenderer
                key={index->string_of_int}
                heading={`${ele.module_->LogicUtils.snakeToTitle} module`}
                description={ele.description}
                isPermissionAllowed={ele.isPermissionAllowed}
              />
            })
            ->React.array}
          </div>
        </RenderIf>
        <RenderIf condition={isUpdateRoleSelected}>
          <InviteUsers
            isInviteUserFlow=false setNewRoleSelected currentRole={currentSelectedUser.role_id}
          />
        </RenderIf>
      </div>
    </div>
  </PageLoaderWrapper>
}
