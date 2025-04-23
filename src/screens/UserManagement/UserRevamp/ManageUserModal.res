let h2OptionalStyle = HSwitchUtils.getTextClass((H2, Optional))
let p1MediumStyle = HSwitchUtils.getTextClass((P1, Medium))
let p2RegularStyle = HSwitchUtils.getTextClass((P1, Regular))
let itemParentContainerCss = "flex flex-wrap gap-4 md:justify-between items-center"
let itemsContainerCss = "flex flex-col items-start w-full md:w-auto"

module ChangeRoleSection = {
  @react.component
  let make = (~defaultRole, ~options) => {
    open APIUtils
    open LogicUtils
    let getURL = useGetURL()
    let url = RescriptReactRouter.useUrl()
    let showToast = ToastState.useShowToast()
    let updateDetails = useUpdateMethod()
    let (userRole, setUserRole) = React.useState(_ => defaultRole)
    let userEmail =
      url.search
      ->getDictFromUrlSearchParams
      ->Dict.get("email")
      ->Option.getOr("")

    let input: ReactFinalForm.fieldRenderPropsInput = {
      name: "string",
      onBlur: _ => (),
      onChange: ev => {
        let value = ev->Identity.formReactEventToString
        setUserRole(_ => value)
      },
      onFocus: _ => (),
      value: userRole->JSON.Encode.string,
      checked: true,
    }

    let updateRole = async () => {
      try {
        let url = getURL(~entityName=V1(USERS), ~methodType=Post, ~userType={#UPDATE_ROLE})
        let body =
          [
            ("email", userEmail->JSON.Encode.string),
            ("role_id", userRole->JSON.Encode.string),
          ]->getJsonFromArrayOfJson
        let _ = await updateDetails(url, body, Post)
        showToast(~message="Role successfully updated!", ~toastType=ToastSuccess)
        RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url="/users"))
      } catch {
      | _ => showToast(~message="Failed to update the role", ~toastType=ToastError)
      }
    }

    <div className=itemParentContainerCss>
      <div className=itemsContainerCss>
        <p className=p1MediumStyle> {"Change user role"->React.string} </p>
        <p className={`${p2RegularStyle} text-gray-400`}>
          {"Change the role in the current scope"->React.string}
        </p>
      </div>
      <div className="flex gap-4 items-center">
        <SelectBox.BaseDropdown
          options
          searchable=false
          input
          hideMultiSelectButtons=true
          deselectDisable=true
          allowMultiSelect=false
          buttonText="Select role"
          fullLength=true
        />
        <Button
          text="Update"
          buttonType=Secondary
          buttonState=Normal
          buttonSize={Small}
          onClick={_ => updateRole()->ignore}
        />
      </div>
    </div>
  }
}

module ResendInviteSection = {
  @react.component
  let make = (~invitationStatus) => {
    open APIUtils
    open LogicUtils
    let getURL = useGetURL()
    let showToast = ToastState.useShowToast()
    let url = RescriptReactRouter.useUrl()
    let updateDetails = useUpdateMethod()
    let authId = HyperSwitchEntryUtils.getSessionData(~key="auth_id")
    let (statusValue, _) = invitationStatus->UserUtils.getLabelForStatus
    let userEmail =
      url.search
      ->getDictFromUrlSearchParams
      ->Dict.get("email")
      ->Option.getOr("")

    let resendInvite = async () => {
      try {
        let url = getURL(
          ~entityName=V1(USERS),
          ~userType=#RESEND_INVITE,
          ~methodType=Post,
          ~queryParamerters=Some(`auth_id=${authId}`),
        )
        let body = [("email", userEmail->JSON.Encode.string)]->getJsonFromArrayOfJson
        let _ = await updateDetails(url, body, Post)
        showToast(~message="Invite resend. Please check your email.", ~toastType=ToastSuccess)
      } catch {
      | _ =>
        showToast(~message="Failed to send the invite. Please try again!", ~toastType=ToastError)
      }
    }

    <div className=itemParentContainerCss>
      <div className=itemsContainerCss>
        <p className=p1MediumStyle> {"Resend invite"->React.string} </p>
        <p className={`${p2RegularStyle} text-gray-400`}>
          {"Resend invite to user"->React.string}
        </p>
      </div>
      <Button
        text="Resend"
        buttonType={Secondary}
        leftIcon={FontAwesome("paper-plane-outlined")}
        onClick={_ => resendInvite()->ignore}
        buttonState={statusValue === Active ? Button.Disabled : Button.Normal}
      />
    </div>
  }
}

module DeleteUserRole = {
  @react.component
  let make = (~setShowModal) => {
    open APIUtils
    open LogicUtils
    let getURL = useGetURL()
    let showToast = ToastState.useShowToast()
    let url = RescriptReactRouter.useUrl()
    let updateDetails = useUpdateMethod()
    let showPopUp = PopUpState.useShowPopUp()
    let userEmail =
      url.search
      ->getDictFromUrlSearchParams
      ->Dict.get("email")
      ->Option.getOr("")

    let deleteUser = async () => {
      try {
        let url = getURL(~entityName=V1(USERS), ~methodType=Post, ~userType={#USER_DELETE})
        let body = [("email", userEmail->JSON.Encode.string)]->getJsonFromArrayOfJson
        let _ = await updateDetails(url, body, Delete)
        showToast(~message=`User has been successfully deleted.`, ~toastType=ToastSuccess)
        RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url="/users"))
      } catch {
      | _ => showToast(~message=`Failed to delete the user.`, ~toastType=ToastError)
      }
    }

    let deleteConfirmation = () => {
      showPopUp({
        popUpType: (Warning, WithIcon),
        heading: `Are you sure you want to delete this user?`,
        description: React.string(`This action cannot be undone. Deleting the user will permanently remove all associated data from this account. Press Confirm to delete.`),
        handleConfirm: {text: "Confirm", onClick: _ => deleteUser()->ignore},
        handleCancel: {text: "Back"},
      })
    }

    <div className=itemParentContainerCss>
      <div className=itemsContainerCss>
        <p className=p1MediumStyle> {"Delete user role"->React.string} </p>
        <p className={`${p2RegularStyle} text-gray-400`}>
          {"User will be deleted from the current role"->React.string}
        </p>
      </div>
      <Button
        text="Delete"
        customButtonStyle="bg-white !text-red-400 "
        buttonType={Secondary}
        leftIcon={FontAwesome("delete")}
        onClick={_ => {
          setShowModal(_ => false)
          deleteConfirmation()
        }}
      />
    </div>
  }
}

module ManageUserModalBody = {
  @react.component
  let make = (~options, ~defaultRole, ~invitationStatus, ~setShowModal) => {
    <div className="flex flex-col gap-16 p-2">
      <p className="text-gray-600 text-start">
        {"Perform various user-related actions such as modifying roles, removing users, or sending a new invitation."->React.string}
      </p>
      <div className="flex flex-col gap-6 ">
        <ChangeRoleSection options defaultRole />
        <hr />
        <ResendInviteSection invitationStatus />
        <hr />
        <DeleteUserRole setShowModal />
      </div>
    </div>
  }
}

module ManageUserModal = {
  @react.component
  let make = (~showModal, ~setShowModal, ~userInfoValue: UserManagementTypes.userDetailstype) => {
    open APIUtils
    let getURL = useGetURL()
    let fetchDetails = useGetMethod()
    let (options, setOptions) = React.useState(_ => [])

    let fetchListOfRoles = async () => {
      try {
        let url = getURL(
          ~entityName=V1(USERS),
          ~userType=#LIST_ROLES_FOR_ROLE_UPDATE,
          ~methodType=Get,
          ~queryParamerters=Some(`entity_type=${userInfoValue.entityType}`),
        )
        let response = await fetchDetails(url)
        setOptions(_ => response->UserUtils.makeSelectBoxOptions)
      } catch {
      | _ => setOptions(_ => [userInfoValue.roleId]->SelectBox.makeOptions)
      }
    }

    React.useEffect(() => {
      fetchListOfRoles()->ignore
      None
    }, [])

    <Modal
      showModal
      modalHeading="Manage user"
      modalHeadingClass=h2OptionalStyle
      setShowModal
      closeOnOutsideClick=true
      modalClass="m-auto !bg-white md:w-2/5 w-full">
      <ManageUserModalBody
        options
        defaultRole={userInfoValue.roleId}
        invitationStatus={userInfoValue.status}
        setShowModal
      />
    </Modal>
  }
}

@react.component
let make = (~userInfoValue: UserManagementTypes.userDetailstype) => {
  let (showModal, setShowModal) = React.useState(_ => false)
  <>
    <Button
      text="Manage user"
      buttonType=Secondary
      buttonSize=Medium
      onClick={_ => setShowModal(_ => true)}
    />
    <RenderIf condition={showModal}>
      <ManageUserModal userInfoValue showModal setShowModal />
    </RenderIf>
  </>
}
