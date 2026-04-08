open ProdVerifyModalUtils
open CardUtils

@react.component
let make = (~showModal, ~setShowModal, ~initialValues=Dict.make(), ~getProdVerifyDetails) => {
  open APIUtils
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let showToast = ToastState.useShowToast()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)
  let {setShowProdIntentForm} = React.useContext(GlobalProvider.defaultContext)
  let mixpanelEvent = MixpanelHook.useSendEvent()

  let (selectedProducts, setSelectedProducts) = React.useState(_ => [ProductTypes.Orchestration(V1)])

  let updateProdDetails = async values => {
    try {
      let url = getURL(~entityName=V1(USERS), ~userType=#USER_DATA, ~methodType=Post)
      let selectedProductStrings = selectedProducts->Array.map(ProductUtils.getProductStringName)
      let bodyValues = values->getBody(~selectedProducts=selectedProductStrings)->JSON.Encode.object
      let body = [("ProdIntent", bodyValues)]->LogicUtils.getJsonFromArrayOfJson
      let _ = await updateDetails(url, body, Post)

      let emailUrl = getURL(~entityName=V1(USERS), ~userType=#SEND_PROD_INTENT_EMAIL, ~methodType=Post)
      let emailBody = [
        ("requested_products", selectedProducts->Array.map(ProductUtils.getProductStringName)->JSON.Encode.array),
        ("poc_email", values->LogicUtils.getDictFromJsonObject->LogicUtils.getString("poc_email", "")->JSON.Encode.string),
        ("poc_name", values->LogicUtils.getDictFromJsonObject->LogicUtils.getString("poc_name", "")->JSON.Encode.string),
      ]->LogicUtils.getJsonFromArrayOfJson
      let _ = await updateDetails(emailUrl, emailBody, Post)->catch(err => {
        Console.error("Failed to send production intent email notification:")
        Console.error(err)
        showToast(
          ~toastType=ToastWarning,
          ~message="Request submitted, but email notification failed. Our team will still process your request.",
          ~autoClose=true,
        )
        Promise.resolve(JSON.Encode.null)
      })

      showToast(
        ~toastType=ToastSuccess,
        ~message="Successfully sent for verification!",
        ~autoClose=true,
      )
      setScreenState(_ => Success)
      getProdVerifyDetails()->ignore
      setShowProdIntentForm(_ => false)
    } catch {
    | _ => setShowModal(_ => false)
    }
    Nullable.null
  }

  let onSubmit = (values, _) => {
    mixpanelEvent(~eventName="create_get_production_access_request", ~metadata=values)
    setScreenState(_ => PageLoaderWrapper.Loading)
    updateProdDetails(values)
  }

  let handleProductToggle = (product: ProductTypes.productTypes) => {
    setSelectedProducts(prev => {
      let exists = prev->Array.some(p => p == product)
      if exists {
        prev->Array.filter(p => p != product)
      } else {
        prev->Array.concat([product])
      }
    })
  }

  let modalBody = {
    <>
      <div className="p-2 m-2">
        <div className="py-5 px-3 flex justify-between align-top">
          <CardHeader
            heading="Get access to Live environment"
            subHeading="We require some details for business verification. Once verified, our team will reach out and provide live credentials within a business day"
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
              initialValues={initialValues->JSON.Encode.object}
              validate={values => values->validateForm(~fieldsToValidate=formFields)}
              onSubmit>
              <div className="flex flex-col gap-8 w-full">
                <FormRenderer.DesktopRow>
                  <div className="flex flex-col gap-6">
                    <ProdIntentProductSelection
                      selectedProducts
                      onProductToggle=handleProductToggle
                    />
                    <div className="grid grid-cols-2 gap-5">
                      {formFields
                      ->Array.mapWithIndex((column, index) =>
                        <FormRenderer.FieldRenderer
                          key={index->Int.toString}
                          fieldWrapperClass="w-full"
                          field={column->getFormField}
                          errorClass
                          labelClass="!text-black font-medium !-ml-[0.5px]"
                        />
                      )
                      ->React.array}
                    </div>
                  </div>
                </FormRenderer.DesktopRow>
                <div className="flex justify-end w-full pr-5 pb-3">
                  <FormRenderer.SubmitButton text="Get Production Access" buttonSize={Small} />
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
    modalClass="w-full max-w-3xl mx-auto my-auto dark:!bg-jp-gray-lightgray_background">
    modalBody
  </Modal>
}
