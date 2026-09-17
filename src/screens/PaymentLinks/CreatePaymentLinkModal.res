open Typography

@react.component
let make = (~refetchList) => {
  open APIUtils
  open PaymentLinksUtils

  let updateDetails = useUpdateMethod(~showErrorToast=false)
  let getURL = useGetURL()
  let showToast = ToastAdapter.useShowToast()
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let fetchProfileList = ProfileListHook.useFetchProfileList()
  let profileList = Recoil.useRecoilValueFromAtom(HyperswitchAtom.profileListAtom)
  let {profileId} = React.useContext(UserInfoProvider.defaultContext).getCommonSessionDetails()
  let (showModal, setShowModal) = React.useState(_ => false)

  let profileOptions = getProfileOptions(profileList)

  let openModal = _ => {
    fetchProfileList()->ignore
    setShowModal(_ => true)
  }

  let onSubmit = async (values, _) => {
    try {
      let url = getURL(~entityName=V1(PAYMENT_LINK_CREATE), ~methodType=Post)
      let body = getCreatePaymentLinkPayload(values)
      let _ = await updateDetails(url, body, Post)
      setShowModal(_ => false)
      showToast(~message="Payment link created successfully.", ~toastType=ToastSuccess)
      refetchList()
      Nullable.null
    } catch {
    | Exn.Error(e) =>
      let err = Exn.message(e)->Option.getOr("Failed to create payment link")
      showToast(~message=err, ~toastType=ToastError)
      Nullable.null
    }
  }

  let profileIdField = getProfileIdField(profileOptions)
  let fieldWrapperClass = "flex flex-col gap-2"
  let labelTextStyleClass = `${body.sm.semibold} text-nd_gray-700`

  <>
    <ACLButton
      text="Create Payment Link"
      authorization={userHasAccess(~groupAccess=OperationsManage)}
      buttonType=Primary
      buttonSize=Medium
      leftIcon={CustomIcon(<Icon name="nd-plus" size=16 />)}
      customButtonStyle="!w-fit !rounded-lg"
      onClick={openModal}
    />
    <RenderIf condition={showModal}>
      <Modal
        modalHeading="Create Payment Link"
        modalHeadingDescription="Generate a hosted payment page to share with the customer."
        showModal
        setShowModal
        modalClass="w-full max-w-2xl mx-auto my-auto dark:!bg-jp-gray-lightgray_background"
        childClass="p-6"
        borderBottom=true>
        <Form
          key="create-payment-link"
          onSubmit
          validate={validateForm}
          initialValues={Dict.fromArray([
            ("profile_id", profileId->JSON.Encode.string),
          ])->JSON.Encode.object}>
          <div className="flex flex-col gap-5 max-h-[70vh] overflow-y-auto">
            <div className="grid grid-cols-2 gap-4">
              <FormRenderer.FieldRenderer field=amountField fieldWrapperClass labelTextStyleClass />
              <FormRenderer.FieldRenderer
                field=currencyField fieldWrapperClass labelTextStyleClass
              />
            </div>
            <FormRenderer.FieldRenderer
              field=customerIdField fieldWrapperClass labelTextStyleClass
            />
            <FormRenderer.FieldRenderer
              field=customerEmailField fieldWrapperClass labelTextStyleClass
            />
            <FormRenderer.FieldRenderer
              field=customerPhoneField fieldWrapperClass labelTextStyleClass
            />
            <FormRenderer.FieldRenderer
              field=profileIdField fieldWrapperClass labelTextStyleClass
            />
            <FormRenderer.FieldRenderer
              field=returnUrlField fieldWrapperClass labelTextStyleClass
            />
            <FormRenderer.FieldRenderer
              field=descriptionField fieldWrapperClass labelTextStyleClass
            />
            <div className="grid grid-cols-2 gap-4">
              <FormRenderer.FieldRenderer
                field=setupFutureUsageField fieldWrapperClass labelTextStyleClass
              />
              <FormRenderer.FieldRenderer
                field=authenticationTypeField fieldWrapperClass labelTextStyleClass
              />
            </div>
            <div className="flex justify-end gap-3">
              <Button
                text="Cancel"
                buttonType=Secondary
                buttonSize=Medium
                customButtonStyle="!w-fit"
                onClick={_ => setShowModal(_ => false)}
              />
              <FormRenderer.SubmitButton
                text="Create Payment Link"
                buttonType=Primary
                buttonSize=Medium
                customSubmitButtonStyle="!w-fit"
              />
            </div>
          </div>
        </Form>
      </Modal>
    </RenderIf>
  </>
}
