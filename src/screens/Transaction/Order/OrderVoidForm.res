open OrderEntity
open APIUtils
open OrderUtils
open HSwitchOrderUtils

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

  let amountToDisplay = CurrencyUtils.convertCurrencyFromLowestDenomination(
    ~amount=order.amount,
    ~currency=order.currency,
  )

  let updateVoidDetails = async values => {
    setIsLoading(_ => true)
    try {
      let cancelUrl = getURL(
        ~entityName=V1(PAYMENT_CANCEL),
        ~methodType=Post,
        ~id=Some(order.payment_id),
      )
      let _ = await updateDetails(cancelUrl, values, Post)
      refetch()->ignore
      showToast(~message="Payment voided successfully", ~toastType=ToastSuccess)
    } catch {
    | _ => showToast(~message="Failed to void payment", ~toastType=ToastError)
    }

    setShowModal(_ => false)
    setIsLoading(_ => false)
  }

  let onSubmit = (values, _) => {
    open Promise
    updateVoidDetails(values)->ignore
    Nullable.null->resolve
  }

  <Form onSubmit initialValues={Dict.make()->JSON.Encode.object}>
    <div className="flex flex-col w-full p-6">
      <div className="border-b border-nd_gray-200 pb-4 mb-5">
        <div className="flex flex-row justify-between items-center">
          <div className={Typography.body.lg.semibold}>
            {React.string("Confirm Void Payment")}
          </div>
          <DisplayKeyValueParams
            heading={getHeading(~devSortEnabled, Status)}
            value={getCell(order, Status, merchantId, orgId)}
            showTitle=false
            labelMargin="mt-0 py-0"
          />
        </div>
        <div className="mt-3">
          <AlertV2Binding
            alertType=Warning
            description="This action is irreversible and cannot be undone."
          />
        </div>
      </div>
      <div className="grid grid-cols-2 gap-x-6 gap-y-4 mb-5">
        <DisplayKeyValueParams
          heading={Table.makeHeaderInfo(~key="amount", ~title="Amount")}
          value={Currency(amountToDisplay, order.currency)}
          isInHeader=true
        />
        <DisplayKeyValueParams
          heading={getHeading(~devSortEnabled, PaymentId)}
          value={getCell(order, PaymentId, merchantId, orgId)}
        />
        <DisplayKeyValueParams
          heading={getHeading(~devSortEnabled, CustomerId)}
          value={getCell(order, CustomerId, merchantId, orgId)}
        />
        <DisplayKeyValueParams
          heading={getHeading(~devSortEnabled, Email)}
          value={getCell(order, Email, merchantId, orgId)}
        />
      </div>
      <div className="mb-2">
        <FormRenderer.FieldRenderer
          field={cancellationReasonField}
          labelClass="text-fs-11 !ml-0"
          fieldWrapperClass="flex flex-col"
        />
      </div>
      <div className="flex justify-end gap-4 mt-16">
        <Button
          text="Cancel"
          onClick={_ => {
            setShowModal(_ => false)
          }}
          buttonState={isLoading ? Disabled : Normal}
        />
        <FormRenderer.SubmitButton
          text={isLoading ? "Processing..." : "Confirm Void"}
          showToolTip=false
          disabledParameter=isLoading
        />
      </div>
    </div>
  </Form>
}
