open OrderEntity
open APIUtils
open OrderUtils
open HSwitchOrderUtils
open LogicUtils
open CurrencyUtils
@react.component
let make = (~order: PaymentInterfaceTypes.order, ~setShowModal, ~refetch) => {
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let showToast = ToastState.useShowToast()
  let (isLoading, setIsLoading) = React.useState(_ => false)

  let {merchantId, orgId} = React.useContext(
    UserInfoProvider.defaultContext,
  ).getCommonSessionDetails()
  let {devSortEnabled} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

  let conversionFactor = getCurrencyConversionFactor(order.currency)
  let precisionDigits = getAmountPrecisionDigits(order.currency)
  // Full amount available to capture, in major units, used as the pre-filled value
  let amountCapturableInMajorUnits = order.amount_capturable /. conversionFactor
  let amountToCaptureField = amountFieldWithPrecision(
    ~name="amount",
    ~precisionDigits,
    ~label="Amount to Capture",
    ~placeholder="Enter Amount to Capture",
  )

  let captureInitialValues = getCaptureInitialValues(~amountCapturableInMajorUnits)

  let capturePayment = async values => {
    try {
      setIsLoading(_ => true)
      let captureUrl = getURL(
        ~entityName=V1(PAYMENT_CAPTURE),
        ~methodType=Post,
        ~id=Some(order.payment_id),
      )

      let dict = values->getDictFromJsonObject
      let amount = dict->getFloat("amount", 0.0)
      let body =
        [
          ("amount_to_capture", Math.round(amount *. conversionFactor)->JSON.Encode.float),
        ]->getJsonFromArrayOfJson

      let _ = await updateDetails(captureUrl, body, Post)
      refetch()->ignore
      showToast(~message="Payment captured successfully", ~toastType=ToastSuccess)
      setShowModal(_ => false)
    } catch {
    | exn => {
        Console.error2("Payment capture failed:", exn)
        showToast(~message="Failed to capture payment", ~toastType=ToastError)
        setIsLoading(_ => false)
        setShowModal(_ => false)
      }
    }
  }

  let onSubmit = (values, _) => {
    open Promise
    capturePayment(values)->ignore
    Nullable.null->resolve
  }

  let validate = values =>
    validateCaptureAmount(
      ~conversionFactor,
      ~amountCapturableInMajorUnits,
      ~precisionDigits,
      values,
    )

  <div>
    <Form onSubmit validate initialValues=captureInitialValues>
      <div className="flex flex-col w-full max-w-4xl mx-auto p-6">
        <div className="border-b border-nd_gray-200 pb-4 mb-6">
          <div className="flex flex-row justify-between items-center ">
            <CardUtils.CardHeader
              heading="Confirm Capture Payment" subHeading="" customSubHeadingStyle=""
            />
            <DisplayKeyValueParams
              heading={getHeading(~devSortEnabled, Status)}
              value={getCell(order, Status, merchantId, orgId)}
              showTitle=false
              labelMargin="mt-0 py-0 "
            />
          </div>
        </div>
        <div className="grid grid-cols-2 gap-8 mb-2">
          <FormRenderer.DesktopRow>
            <DisplayKeyValueParams
              heading={Table.makeHeaderInfo(~key="amount", ~title="Amount")}
              value={getCell(order, Amount, merchantId, orgId)}
              isInHeader=true
            />
          </FormRenderer.DesktopRow>
          <FormRenderer.DesktopRow>
            <DisplayKeyValueParams
              heading={getHeading(~devSortEnabled, PaymentId)}
              value={getCell(order, PaymentId, merchantId, orgId)}
            />
          </FormRenderer.DesktopRow>
        </div>
        <div className="grid grid-cols-2 gap-8 mb-2">
          <FormRenderer.DesktopRow>
            <DisplayKeyValueParams
              heading={getHeading(~devSortEnabled, CustomerId)}
              value={getCell(order, CustomerId, merchantId, orgId)}
            />
          </FormRenderer.DesktopRow>
          <FormRenderer.DesktopRow>
            <DisplayKeyValueParams
              heading={getHeading(~devSortEnabled, Email)}
              value={getCell(order, Email, merchantId, orgId)}
            />
          </FormRenderer.DesktopRow>
        </div>
        <div className="grid grid-cols-2 gap-8 mb-2">
          <FormRenderer.DesktopRow>
            <FormRenderer.FieldRenderer field={amountToCaptureField} labelClass="text-fs-11" />
          </FormRenderer.DesktopRow>
        </div>
        <div className="flex justify-end gap-4 mt-16">
          <Button
            text="Cancel"
            onClick={_ => setShowModal(_ => false)}
            buttonState={isLoading ? Disabled : Normal}
            customButtonStyle="w-20 !h-10"
          />
          <FormRenderer.SubmitButton
            text={isLoading ? "Processing..." : "Capture"}
            customSubmitButtonStyle="w-50 !h-10"
            showToolTip=false
            disabledParameter=isLoading
          />
        </div>
      </div>
    </Form>
  </div>
}
