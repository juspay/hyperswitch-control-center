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

  let initiateValue = Dict.make()
  let initiateValueJson = initiateValue->JSON.Encode.object

  let updateRefundDetails = async body => {
    try {
      let refundsUrl = getURL(~entityName=REFUNDS, ~methodType=Post, ())
      let res = await updateDetails(refundsUrl, body, Post, ())
      let refundStatus = res->LogicUtils.getDictFromJsonObject->LogicUtils.getString("status", "")
      refetch()->ignore
      switch refundStatus->statusVariantMapper {
      | Succeeded => showToast(~message="Refund successful", ~toastType=ToastSuccess, ())
      | Failed =>
        showToast(~message="Refund failed - Please check refund details", ~toastType=ToastError, ())
      | _ =>
        showToast(
          ~message="Processing your refund. Please check refund status",
          ~toastType=ToastInfo,
          (),
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
    Dict.set(body, "refund_type", "instant"->JSON.Encode.string)
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

    switch amountValue->Option.flatMap(JSON.Decode.float) {
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
      <div className="flex flex-col mx-1 mt-2">
        <div
          className="flex border-b-2 px-2 h-24 items-center border-jp-gray-940 border-opacity-75 dark:border-jp-gray-960 dark:border-opacity-75">
          <FormRenderer.DesktopRow wrapperClass="ml-2">
            <DisplayKeyValueParams
              heading={Table.makeHeaderInfo(~key="amount", ~title="Amount", ~showSort=true, ())}
              value={getCell(order, Amount)}
              isInHeader=true
            />
          </FormRenderer.DesktopRow>
          // <CurrencyElement currency=order.currency />
          <span className="ml-5 pb-1">
            <DisplayKeyValueParams
              heading={getHeading(Status)} value={getCell(order, Status)} showTitle=false
            />
          </span>
        </div>
        <div
          className="flex items-start border border-red-500 p-3 bg-red-100/[0.5] dark:bg-jp-gray-950 rounded-lg mx-6 my-6 text-fs-14 font-medium">
          <Icon size=14 name="exclamation-circle" className="fill-red-500 mr-2 mt-1" />
          {React.string(
            "Note : Once a refund is placed, it cannot be cancelled. Please Verify before proceeding further",
          )}
        </div>
        <div className="flex flex-row mx-3">
          <div className="flex flex-col w-1/2 gap-7">
            <FormRenderer.DesktopRow>
              <DisplayKeyValueParams
                heading={getHeading(CustomerId)} value={getCell(order, CustomerId)}
              />
            </FormRenderer.DesktopRow>
            <FormRenderer.DesktopRow>
              <DisplayKeyValueParams
                heading={getHeading(PaymentId)} value={getCell(order, PaymentId)}
              />
            </FormRenderer.DesktopRow>
            <FormRenderer.DesktopRow>
              <DisplayKeyValueParams
                heading={getHeading(CustomerEmail)} value={getCell(order, CustomerEmail)}
              />
            </FormRenderer.DesktopRow>
            <FormRenderer.DesktopRow>
              <DisplayKeyValueParams
                heading={Table.makeHeaderInfo(
                  ~key="amount",
                  ~title="Amount Refunded",
                  ~showSort=true,
                  (),
                )}
                value={Currency(amountRefunded.contents /. 100.0, order.currency)}
              />
            </FormRenderer.DesktopRow>
          </div>
          <div className="flex flex-col w-1/2 gap-2">
            <FormRenderer.DesktopRow>
              <DisplayKeyValueParams
                heading={Table.makeHeaderInfo(
                  ~key="amount",
                  ~title="Pending Requested Amount",
                  ~showSort=true,
                  (),
                )}
                value={Currency(requestedRefundAmount.contents /. 100.0, order.currency)}
              />
            </FormRenderer.DesktopRow>
            <FormRenderer.DesktopRow>
              <FormRenderer.FieldRenderer field=amountField labelClass="text-fs-11" />
            </FormRenderer.DesktopRow>
            <UIUtils.RenderIf condition={showRefundReason}>
              <FormRenderer.DesktopRow>
                <FormRenderer.FieldRenderer field=reasonField labelClass="text-fs-11" />
              </FormRenderer.DesktopRow>
            </UIUtils.RenderIf>
          </div>
        </div>
        <div className="flex justify-end gap-4 pr-5 pb-2 mb-3 mt-14">
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
