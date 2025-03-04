open OrderEntity
open APIUtils
open OrderUtils
open HSwitchOrderUtils
open OrderTypes

@react.component
let make = (
  ~order,
  ~setShowModal,
  ~requestedRefundAmount,
  ~amountRefunded,
  ~amoutAvailableToRefund,
  ~refetch,
) => {
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let showToast = ToastState.useShowToast()
  let notShowRefundReasonList = ["adyen"]
  let showRefundReason = !(
    notShowRefundReasonList->Array.includes(order.connector->String.toLowerCase)
  )
  let {userInfo: {merchantId, orgId}} = React.useContext(UserInfoProvider.defaultContext)
  let initiateValue = Dict.make()
  let initiateValueJson = initiateValue->JSON.Encode.object

  let updateRefundDetails = async body => {
    try {
      let refundsUrl = getURL(~entityName=V1(REFUNDS), ~methodType=Post)
      let res = await updateDetails(refundsUrl, body, Post)
      let refundStatus = res->LogicUtils.getDictFromJsonObject->LogicUtils.getString("status", "")
      refetch()->ignore
      switch refundStatus->statusVariantMapper {
      | Succeeded => showToast(~message="Refund successful", ~toastType=ToastSuccess)
      | Failed =>
        showToast(~message="Refund failed - Please check refund details", ~toastType=ToastError)
      | _ =>
        showToast(
          ~message="Processing your refund. Please check refund status",
          ~toastType=ToastInfo,
        )
      }
    } catch {
    | _ => setShowModal(_ => true)
    }
  }

  let onSubmit = (values, _) => {
    open Promise
    setShowModal(_ => false)
    let dict = values->LogicUtils.getDictFromJsonObject
    let amount = dict->LogicUtils.getFloat("amount", 0.0)
    Dict.set(dict, "amount", Math.round(amount *. 100.0)->JSON.Encode.float)
    let body = dict
    Dict.set(body, "payment_id", order.payment_id->JSON.Encode.string)

    // NOTE: Backend might change later , but for now removed as backend will have default value as scheduled
    // Dict.set(body, "refund_type", "instant"->JSON.Encode.string)

    if !showRefundReason {
      Dict.set(body, "reason", "RETURN"->JSON.Encode.string)
    }
    updateRefundDetails(body->JSON.Encode.object)->ignore
    Nullable.null->resolve
  }

  let validate = values => {
    let errors = Dict.make()
    let valuesDict =
      values
      ->JSON.Decode.object
      ->Option.map(Dict.toArray)
      ->Option.getOr([])
      ->Belt.Array.keepMap(entry => {
        let (key, value) = entry
        switch value->JSON.Classify.classify {
        | String(strVal) => Some((key, JSON.Encode.string(strVal)))
        | Number(int) => Some((key, int->JSON.Encode.float))
        | _ => None
        }
      })
      ->Dict.fromArray
    ["amount"]->Array.forEach(key => {
      if Dict.get(valuesDict, key)->Option.isNone {
        Dict.set(errors, key, "Required"->JSON.Encode.string)
      }
    })
    let amountValue = Dict.get(valuesDict, "amount")

    switch amountValue->Option.flatMap(obj => obj->JSON.Decode.float) {
    | Some(floatVal) =>
      if floatVal > amoutAvailableToRefund {
        let amountSplitArr =
          Float.toFixedWithPrecision(amoutAvailableToRefund, ~digits=2)->String.split(".")
        let decimal = if amountSplitArr->Array.length > 1 {
          amountSplitArr[1]->Option.getOr("")
        } else {
          "00"
        }
        let receivedValue = amoutAvailableToRefund->Math.floor->Float.toString
        let formatted_amount = `${receivedValue}.${decimal}`
        Dict.set(
          errors,
          "amount",
          `Refund amount should not exceed ${formatted_amount}`->JSON.Encode.string,
        )
      } else if floatVal == 0.0 {
        Dict.set(
          errors,
          "amount",
          "Please enter refund amount greater than zero"->JSON.Encode.string,
        )
      }
    | None => ()
    }
    errors->JSON.Encode.object
  }

  <div>
    <Form onSubmit validate initialValues=initiateValueJson>
      <div className="flex flex-col w-full max-w-4xl mx-auto p-6">
        <div
          className="border-b border-jp-gray-940 border-opacity-75 dark:border-jp-gray-960 dark:border-opacity-75 pb-4 mb-6">
          <div className="flex flex-row justify-between items-center ">
            <CardUtils.CardHeader
              heading="Initiate Refund" subHeading="" customSubHeadingStyle=""
            />
            <DisplayKeyValueParams
              heading={getHeading(Status)}
              value={getCell(order, Status, merchantId, orgId)}
              showTitle=false
              labelMargin="mt-0 py-0 "
            />
          </div>
          <div className="flex text-fs-13 ">
            <Icon size={14} name="exclamation-circle" className="text-red-600 mr-2 mt-1" />
            <span className="font-medium text-jp-gray-700 mt-2">
              {React.string(
                "Note: Refunds cannot be canceled once placed. Please verify before proceeding.",
              )}
            </span>
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
              heading={getHeading(PaymentId)} value={getCell(order, PaymentId, merchantId, orgId)}
            />
          </FormRenderer.DesktopRow>
        </div>
        <div className="grid grid-cols-2 gap-8 mb-2">
          <FormRenderer.DesktopRow>
            <DisplayKeyValueParams
              heading={getHeading(CustomerId)} value={getCell(order, CustomerId, merchantId, orgId)}
            />
          </FormRenderer.DesktopRow>
          <FormRenderer.DesktopRow>
            <DisplayKeyValueParams
              heading={getHeading(Email)} value={getCell(order, Email, merchantId, orgId)}
            />
          </FormRenderer.DesktopRow>
        </div>
        <div className="grid grid-cols-2 gap-8 mb-2">
          <FormRenderer.DesktopRow>
            <DisplayKeyValueParams
              heading={Table.makeHeaderInfo(~key="amount", ~title="Amount Refunded")}
              value={Currency(amountRefunded.contents /. 100.0, order.currency)}
            />
          </FormRenderer.DesktopRow>
          <FormRenderer.DesktopRow>
            <DisplayKeyValueParams
              heading={Table.makeHeaderInfo(~key="amount", ~title="Pending Requested Amount")}
              value={Currency(requestedRefundAmount.contents /. 100.0, order.currency)}
            />
          </FormRenderer.DesktopRow>
        </div>
        <div className="grid grid-cols-2 gap-8 mb-16">
          <FormRenderer.DesktopRow>
            <FormRenderer.FieldRenderer field={amountField} labelClass="text-fs-11" />
          </FormRenderer.DesktopRow>
          <RenderIf condition={showRefundReason}>
            <FormRenderer.DesktopRow>
              <FormRenderer.FieldRenderer field={reasonField} labelClass="text-fs-11" />
            </FormRenderer.DesktopRow>
          </RenderIf>
        </div>
        <div className="flex justify-end gap-4">
          <Button
            text="Cancel"
            onClick={_ => {
              setShowModal(_ => false)
            }}
            customButtonStyle="w-20 !h-10"
          />
          <FormRenderer.SubmitButton
            text={"Initiate Refund"} customSumbitButtonStyle="w-50 !h-10" showToolTip=false
          />
        </div>
      </div>
    </Form>
  </div>
}
