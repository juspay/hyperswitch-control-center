@react.component
let make = (
  ~modalHeading,
  ~setShowModal,
  ~showModal,
  ~feedbackVia="user",
  ~modalType: HSwitchFeedBackModalUtils.modalType=FeedBackModal,
) => {
  open HSwitchFeedBackModalUtils
  open APIUtils
  let {email} = CommonAuthHooks.useCommonAuthInfo()->Option.getOr(CommonAuthHooks.defaultAuthInfo)
  let showToast = ToastState.useShowToast()
  let updateDetails = useUpdateMethod()
  let getURL = useGetURL()
  let onSubmit = async (values, _) => {
    try {
      let url = getURL(~entityName=V1(USERS), ~userType=#USER_DATA, ~methodType=Post)
      let body =
        [
          (
            "Feedback",
            HSwitchUtils.getBodyForFeedBack(~email, ~values, ~modalType)->JSON.Encode.object,
          ),
        ]->LogicUtils.getJsonFromArrayOfJson
      let _ = await updateDetails(url, body, Post)
      let successMessage = switch modalType {
      | FeedBackModal => "Thanks for feedback"
      | RequestConnectorModal => "Request submitted succesfully"
      }
      showToast(~toastType=ToastSuccess, ~message=successMessage, ~autoClose=false)
    } catch {
    | _ => ()
    }
    setShowModal(_ => false)
    Nullable.null
  }

  let showLabel = switch modalType {
  | FeedBackModal => false
  | RequestConnectorModal => true
  }

  let modalFormFields = switch modalType {
  | FeedBackModal =>
    <>
      <RatingOptions icons=["angry", "frown", "smile", "smile-beam", "grin-hearts"] size=30 />
      <div className="text-md w-full font-medium mt-7 -mb-1 text-dark_black opacity-80 my-5">
        {"Type of feedback"->React.string}
      </div>
      <div className="mb-5 mt-1">
        <FormRenderer.FieldRenderer field=selectFeedbackType />
      </div>
      <div className="text-md w-full font-medium mt-3 ml-2 -mb-1 text-dark_black opacity-80 my-5">
        {"How can we improve your hyperswitch experience?"->React.string}
      </div>
      <div className="mt-2">
        <FormRenderer.FieldRenderer field={feedbackTextBox} />
      </div>
    </>
  | RequestConnectorModal =>
    <div className="flex flex-col gap-1">
      <FormRenderer.FieldRenderer field=connectorNameField />
      <FormRenderer.FieldRenderer field=connectorDescription />
    </div>
  }

  let submitBtnText = switch modalType {
  | FeedBackModal => "Send"
  | RequestConnectorModal => "Submit Request"
  }

  <Modal
    modalHeading
    headingClass="!bg-transparent dark:!bg-jp-gray-lightgray_background"
    showModal
    setShowModal
    borderBottom=true
    closeOnOutsideClick=true
    modalClass="w-full max-w-xl m-auto dark:!bg-jp-gray-lightgray_background pb-3">
    <Form onSubmit validate={values => values->validateFields(~modalType)}>
      <LabelVisibilityContext showLabel>
        <div className="flex flex-col justify-center">
          {modalFormFields}
          <div className="flex justify-end gap-3 p-1 mt-4">
            <Button
              buttonType=Button.Secondary onClick={_ => setShowModal(_ => false)} text="Cancel"
            />
            <FormRenderer.SubmitButton text=submitBtnText />
          </div>
        </div>
      </LabelVisibilityContext>
    </Form>
  </Modal>
}
