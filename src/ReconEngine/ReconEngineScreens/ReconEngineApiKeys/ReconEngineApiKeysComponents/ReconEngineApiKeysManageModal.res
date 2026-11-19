open Typography
open LogicUtils
open ReconEngineApiKeysTypes
open ReconEngineApiKeysUtils

@react.component
let make = (~apiKey: apiKey, ~action: action, ~onClose: unit => unit, ~onUpdated: unit => unit) => {
  let getURL = APIUtils.useGetURL()
  let updateDetails = APIUtils.useUpdateMethod(~showErrorToast=false)
  let showToast = ToastAdapter.useShowToast()
  let (isSaving, setIsSaving) = React.useState(_ => false)
  let (error, setError) = React.useState(_ => "")
  let isRevoke = action === Revoke

  let closeModal = () => {
    if !isSaving {
      onClose()
    }
  }

  let submit = async values => {
    setIsSaving(_ => true)
    setError(_ => "")
    try {
      let url = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~hyperswitchReconType=#API_KEYS,
        ~methodType=Put,
        ~id=Some(apiKey.id),
      )
      let _ = await updateDetails(url, makeUpdateBody(~action, ~values), Put)
      showToast(~message=isRevoke ? "API key revoked" : "API key updated", ~toastType=ToastSuccess)
      onUpdated()
    } catch {
    | _ =>
      setError(_ =>
        isRevoke
          ? "Could not revoke the API key. Please try again."
          : "Could not update the API key. Check your details and try again."
      )
    }
    setIsSaving(_ => false)
    Nullable.null
  }

  let errorMessage =
    <RenderIf condition={error->isNonEmptyString}>
      <p role="alert" className={`${body.sm.medium} text-nd_red-600`}> {error->React.string} </p>
    </RenderIf>

  <Modal
    showModal=true
    setShowModal={_ => closeModal()}
    modalHeading={isRevoke ? "Revoke API key" : "Edit API key"}
    headerTextClass={heading.sm.semibold}
    modalClass="w-full max-w-2xl m-auto !bg-white"
    childClass="p-6"
    showCloseIcon={!isSaving}
    closeOnOutsideClick=false>
    <RenderIf condition=isRevoke>
      <div className="flex flex-col gap-5">
        <p className={`${body.md.regular} text-nd_gray-700 break-words`}>
          {`Revoke the API key "${apiKey.name}"? Integrations using it will lose access. This cannot be undone.`->React.string}
        </p>
        <div className="rounded-lg border border-nd_gray-200 bg-nd_gray-50 p-4">
          <p className={`${body.sm.medium} text-nd_gray-600 mb-1`}>
            {"Key prefix"->React.string}
          </p>
          <code className={`${body.md.regular} text-nd_gray-800 break-all`}>
            {apiKey.prefix->getMaskedPrefix->React.string}
          </code>
        </div>
        errorMessage
        <div className="flex justify-end gap-3">
          <Button
            text="Cancel"
            buttonType=Secondary
            buttonSize=Small
            buttonState={isSaving ? Disabled : Normal}
            onClick={_ => closeModal()}
          />
          <Button
            text="Revoke API key"
            buttonType=Delete
            buttonSize=Small
            buttonState={isSaving ? Loading : Normal}
            onClick={_ => submit(JSON.Encode.null)->ignore}
          />
        </div>
      </div>
    </RenderIf>
    <RenderIf condition={!isRevoke}>
      <Form
        initialValues={[
          ("name", apiKey.name->JSON.Encode.string),
          ("description", apiKey.description->JSON.Encode.string),
        ]
        ->Dict.fromArray
        ->JSON.Encode.object}
        validate=validateDetails
        onSubmit={(values, _) => submit(values)}>
        <div className="flex flex-col gap-5">
          <div className="flex flex-col gap-4 min-w-0">
            <FormRenderer.FieldRenderer
              field={nameField(~isDisabled=isSaving)} fieldWrapperClass="w-full" errorClass
            />
            <FormRenderer.FieldRenderer
              field={descriptionField(~isDisabled=isSaving)} fieldWrapperClass="w-full" errorClass
            />
            <p className={`${body.sm.regular} text-nd_gray-600`}>
              {"Only the name and description can be changed. The key value and expiration stay the same."->React.string}
            </p>
          </div>
          errorMessage
          <div className="flex justify-end gap-3">
            <Button
              text="Cancel"
              buttonType=Secondary
              buttonSize=Small
              buttonState={isSaving ? Disabled : Normal}
              onClick={_ => closeModal()}
            />
            <FormRenderer.SubmitButton
              text="Save changes" loadingText="Saving changes" buttonSize=Small
            />
          </div>
        </div>
      </Form>
    </RenderIf>
  </Modal>
}
