open Typography
open LogicUtils
open ReconEngineApiKeysTypes
open ReconEngineApiKeysUtils

@react.component
let make = (~onClose: unit => unit, ~onCreated: unit => unit) => {
  let getURL = APIUtils.useGetURL()
  let updateDetails = APIUtils.useUpdateMethod(~showErrorToast=false)
  let (apiKey, setApiKey) = React.useState(_ => "")
  let (isCreating, setIsCreating) = React.useState(_ => false)
  let (error, setError) = React.useState(_ => "")
  let closeModal = () => {
    if !isCreating {
      onClose()
    }
  }

  let onSubmit = async (values, _) => {
    setIsCreating(_ => true)
    setError(_ => "")
    try {
      let url = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~hyperswitchReconType=#API_KEYS,
        ~methodType=Post,
      )
      let response = await updateDetails(url, makeCreateBody(values), Post)
      let key = response->getDictFromJsonObject->getString("api_key", "")
      if key->isEmptyString {
        setError(_ =>
          "The key was created, but the response did not include its value. Refresh the list before trying again."
        )
      } else {
        setApiKey(_ => key)
      }
      onCreated()
    } catch {
    | _ => setError(_ => "Could not create the API key. Check your details and try again.")
    }
    setIsCreating(_ => false)
    Nullable.null
  }

  <Modal
    showModal=true
    setShowModal={_ => closeModal()}
    modalHeading={apiKey->isNonEmptyString ? "API key created" : "Create API key"}
    headerTextClass={heading.sm.semibold}
    modalClass="w-full max-w-2xl m-auto !bg-white"
    childClass="p-6"
    showCloseIcon={!isCreating}
    closeOnOutsideClick=false>
    <RenderIf condition={apiKey->isNonEmptyString}>
      <ReconEngineApiKeysHelper.CreatedKey apiKey onDone=closeModal />
    </RenderIf>
    <RenderIf condition={apiKey->isEmptyString}>
      <Form
        initialValues={[("expiration", (NeverExpires :> string)->JSON.Encode.string)]
        ->Dict.fromArray
        ->JSON.Encode.object}
        validate
        onSubmit>
        <div className="flex flex-col gap-5">
          <p className={`${body.md.regular} text-nd_gray-600`}>
            {"Create a key for your reconciliation integration. The full key will be shown only once."->React.string}
          </p>
          <div className="flex flex-col gap-4 min-w-0">
            <FormRenderer.FieldRenderer
              field={nameField(~isDisabled=isCreating)} fieldWrapperClass="w-full" errorClass
            />
            <FormRenderer.FieldRenderer
              field={descriptionField(~isDisabled=isCreating)} fieldWrapperClass="w-full" errorClass
            />
            <FormRenderer.FieldRenderer
              field={expirationField(~isDisabled=isCreating)} fieldWrapperClass="w-full" errorClass
            />
            <ReconEngineApiKeysHelper.ExpirationDateField isDisabled=isCreating />
            <p className={`${body.sm.regular} text-nd_gray-500`}>
              {"Expiration cannot be changed after creation."->React.string}
            </p>
          </div>
          <RenderIf condition={error->isNonEmptyString}>
            <p role="alert" className={`${body.sm.medium} text-nd_red-600`}>
              {error->React.string}
            </p>
          </RenderIf>
          <div className="flex justify-end gap-3 pt-2">
            <Button
              text="Cancel"
              buttonType=Secondary
              buttonSize=Small
              buttonState={isCreating ? Disabled : Normal}
              onClick={_ => closeModal()}
            />
            <FormRenderer.SubmitButton
              text="Create API key" loadingText="Creating API key" buttonSize=Small
            />
          </div>
        </div>
      </Form>
    </RenderIf>
  </Modal>
}
