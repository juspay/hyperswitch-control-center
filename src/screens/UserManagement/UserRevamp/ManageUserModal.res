let h2OptionalStyle = HSwitchUtils.getTextClass((H2, Optional))
let p1MediumStyle = HSwitchUtils.getTextClass((P1, Medium))
let p2RegularStyle = HSwitchUtils.getTextClass((P1, Regular))

module ManageUserModal = {
  @react.component
  let make = () => {
    let (userRole, setUserRole) = React.useState(_ => "merchant_view_only")
    let input: ReactFinalForm.fieldRenderPropsInput = {
      name: "string",
      onBlur: _ev => (),
      onChange: ev => {
        let value = ev->Identity.formReactEventToString
        setUserRole(_ => value)
      },
      onFocus: _ev => (),
      value: userRole->JSON.Encode.string,
      checked: true,
    }

    <div className="flex flex-col gap-16 p-2">
      <p className="text-gray-600">
        {"Perform various user-related actions such as modifying roles, removing users, or sending a new invitation."->React.string}
      </p>
      <div className="flex flex-col gap-6 ">
        <div className="flex gap-4 justify-between items-center">
          <div className="flex flex-col">
            <p className=p1MediumStyle> {"Change user role"->React.string} </p>
            <p className={`${p2RegularStyle} text-gray-400`}>
              {"Change the role in the current scope"->React.string}
            </p>
          </div>
          <SelectBox.BaseDropdown
            options={["merchant_view_only", "merchant_customer_support"]->SelectBox.makeOptions}
            searchable=false
            input
            hideMultiSelectButtons=true
            deselectDisable=true
            allowMultiSelect=false
            buttonText="Select role"
          />
        </div>
        <hr />
        <div className="flex gap-4 justify-between items-center">
          <div className="flex flex-col">
            <p className=p1MediumStyle> {"Resend invite"->React.string} </p>
            <p className={`${p2RegularStyle} text-gray-400`}>
              {"resend invite to user"->React.string}
            </p>
          </div>
          <Button
            text="Resend"
            customButtonStyle="bg-white !p-2 "
            buttonType={Secondary}
            leftIcon={FontAwesome("paper-plane-outlined")}
          />
        </div>
        <hr />
        <div className="flex gap-4 justify-between items-center">
          <div className="flex flex-col">
            <p className=p1MediumStyle> {"Delete user role"->React.string} </p>
            <p className={`${p2RegularStyle} text-gray-400`}>
              {"User will be deleted from the current role"->React.string}
            </p>
          </div>
          <Button
            text="Delete"
            customButtonStyle="bg-white !p-2 !text-red-400 "
            buttonType={Secondary}
            leftIcon={FontAwesome("delete")}
          />
        </div>
      </div>
    </div>
  }
}

@react.component
let make = (~showModal, ~setShowModal) => {
  <Modal
    showModal
    modalHeading="Manage user"
    modalHeadingClass=h2OptionalStyle
    setShowModal
    closeOnOutsideClick=true
    modalClass="m-auto !bg-white w-1/3">
    <ManageUserModal />
  </Modal>
}
