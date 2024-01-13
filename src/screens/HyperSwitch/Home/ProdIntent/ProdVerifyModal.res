open ProdVerifyModalUtils
open CardUtils

@react.component
let make = (~showModal, ~setShowModal, ~initialValues=Dict.make(), ~getProdVerifyDetails) => {
  open APIUtils
  let updateDetails = useUpdateMethod()
  let showToast = ToastState.useShowToast()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)
  let (isSubmitBtnDisabled, setIsSubmitBtnDisabled) = React.useState(_ => false)
  let {setShowProdIntentForm} = React.useContext(GlobalProvider.defaultContext)

  let updateProdDetails = async values => {
    try {
      let url = getURL(~entityName=USERS, ~userType=#USER_DATA, ~methodType=Post, ())
      let bodyValues = values->getBody->Js.Json.object_
      let body = [("ProdIntent", bodyValues)]->LogicUtils.getJsonFromArrayOfJson
      let _ = await updateDetails(url, body, Post)
      showToast(
        ~toastType=ToastSuccess,
        ~message="Successfully sent for verification!",
        ~autoClose=true,
        (),
      )
      setScreenState(_ => Success)
      getProdVerifyDetails()->ignore
      setShowProdIntentForm(_ => false)
    } catch {
    | _ => setShowModal(_ => false)
    }
    Js.Nullable.null
  }

  let onSubmit = (values, _) => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    updateProdDetails(values)
  }

  let modalBody = {
    <>
      <div className="p-2 m-2">
        <div className="py-5 px-3 flex justify-between align-top">
          <CardHeader
            heading="Get access to Live environment"
            subHeading="We require some details for business verification. Once verified, our team will reach out and provide live credentials within a business day "
            customSubHeadingStyle="w-full !max-w-none pr-10"
          />
          <div className="h-fit" onClick={_ => setShowModal(_ => false)}>
            <Icon
              name="close" className="border-2 p-2 rounded-2xl bg-gray-100 cursor-pointer" size=30
            />
          </div>
        </div>
        <div className="min-h-96">
          <PageLoaderWrapper screenState sectionHeight="h-30-vh">
            <Form
              key="prod-request-form"
              initialValues={initialValues->Js.Json.object_}
              validate={values =>
                values->validateForm(
                  ~fieldsToValidate=formFields,
                  ~setIsDisabled=setIsSubmitBtnDisabled,
                )}
              onSubmit>
              <div className="flex flex-col gap-12 h-full w-full">
                <FormRenderer.DesktopRow>
                  <div className="flex flex-col gap-5">
                    {formFields
                    ->Array.mapWithIndex((column, index) =>
                      <FormRenderer.FieldRenderer
                        key={index->string_of_int}
                        fieldWrapperClass="w-full"
                        field={column->getFormField}
                        errorClass
                        labelClass="!text-black font-medium !-ml-[0.5px]"
                      />
                    )
                    ->React.array}
                  </div>
                </FormRenderer.DesktopRow>
                <div className="flex justify-end w-full pr-5 pb-3">
                  <FormRenderer.SubmitButton
                    disabledParamter=isSubmitBtnDisabled text="Submit" buttonSize={Small}
                  />
                </div>
              </div>
            </Form>
          </PageLoaderWrapper>
        </div>
      </div>
    </>
  }

  <Modal
    showModal
    closeOnOutsideClick=true
    setShowModal
    childClass="p-0"
    borderBottom=true
    modalClass="w-full max-w-2xl mx-auto my-auto dark:!bg-jp-gray-lightgray_background">
    modalBody
  </Modal>
}
