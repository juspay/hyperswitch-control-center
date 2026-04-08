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
  let {activeProduct} = React.useContext(ProductSelectionProvider.defaultContext)
  
  let (selectedProducts, setSelectedProducts) = React.useState(_ => ["orchestration"])

  let stringToProductType = (productKey: string): ProductTypes.productTypes => {
    switch productKey {
    | "orchestration" => Orchestration(V1)
    | "recon" => Recon(V1)
    | "recovery" => Recovery
    | "cost_observability" => CostObservability
    | _ => Orchestration(V1)
    }
  }

  let updateProdDetails = async values => {
    try {
      let url = getURL(~entityName=V1(USERS), ~userType=#USER_DATA, ~methodType=Post)
      let productTypes = selectedProducts->Array.map(stringToProductType)
      let bodyValues = values->getBody(~selectedProducts=productTypes)->JSON.Encode.object
      
      let body = [("ProdIntent", bodyValues)]->LogicUtils.getJsonFromArrayOfJson
      let _ = await updateDetails(url, body, Post)
      
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
  
  let handleProductToggle = (productKey, isSelected) => {
    setSelectedProducts(prev => {
      if isSelected {
        if prev->Array.includes(productKey) {
          prev
        } else {
          prev->Array.concat([productKey])
        }
      } else {
        prev->Array.filter(p => p !== productKey)
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
                <div className="px-3">
                  <h3 className="text-sm font-medium text-nd_gray-700 mb-3">
                    {"Select Products"->React.string}
                  </h3>
                  <ProdIntentProductSelection selectedProducts onProductToggle={handleProductToggle} />
                </div>
                <FormRenderer.DesktopRow>
                  <div className="flex flex-col gap-5">
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
    modalClass="w-full max-w-2xl mx-auto my-auto dark:!bg-jp-gray-lightgray_background">
    modalBody
  </Modal>
}
