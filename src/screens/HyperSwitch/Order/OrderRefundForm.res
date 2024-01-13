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
  let updateDetails = useUpdateMethod()
  let showToast = ToastState.useShowToast()
  let notShowRefundReasonList = ["adyen"]
  let showRefundReason = !(
    notShowRefundReasonList->Array.includes(order.connector->String.toLowerCase)
  )

  let initiateValue = Dict.make()
  let initiateValueJson = initiateValue->Js.Json.object_

  let updateRefundDetails = async body => {
    try {
      let refundsUrl = getURL(~entityName=REFUNDS, ~methodType=Post, ())
      let res = await updateDetails(refundsUrl, body, Post)
      let refundStatus = res->LogicUtils.getDictFromJsonObject->LogicUtils.getString("status", "")
      refetch()
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
    Dict.set(dict, "amount", Js.Math.round(amount *. 100.0)->Js.Json.number)
    let body = dict
    Dict.set(body, "payment_id", order.payment_id->Js.Json.string)
    Dict.set(body, "refund_type", "instant"->Js.Json.string)
    if !showRefundReason {
      Dict.set(body, "reason", "RETURN"->Js.Json.string)
    }
    updateRefundDetails(body->Js.Json.object_)->ignore
    Js.Nullable.null->resolve
  }

  let validate = values => {
    let errors = Dict.make()
    let valuesDict =
      values
      ->Js.Json.decodeObject
      ->Belt.Option.map(Dict.toArray)
      ->Belt.Option.getWithDefault([])
      ->Belt.Array.keepMap(entry => {
        let (key, value) = entry
        switch value->Js.Json.classify {
        | JSONString(strVal) => Some((key, Js.Json.string(strVal)))
        | JSONNumber(int) => Some((key, int->Js.Json.number))
        | _ => None
        }
      })
      ->Dict.fromArray
    ["amount"]->Array.forEach(key => {
      if Dict.get(valuesDict, key)->Js.Option.isNone {
        Dict.set(errors, key, "Required"->Js.Json.string)
      }
    })
    let amountValue = Dict.get(valuesDict, "amount")

    switch amountValue->Belt.Option.flatMap(Js.Json.decodeNumber) {
    | Some(floatVal) =>
      if floatVal > amoutAvailableToRefund {
        let amountSplitArr =
          Js.Float.toFixedWithPrecision(amoutAvailableToRefund, ~digits=2)->String.split(".")
        let decimal = if amountSplitArr->Array.length > 1 {
          amountSplitArr[1]->Belt.Option.getWithDefault("")
        } else {
          "00"
        }
        let receivedValue = amoutAvailableToRefund->Js.Math.floor_float->Belt.Float.toString
        let formatted_amount = `${receivedValue}.${decimal}`
        Dict.set(
          errors,
          "amount",
          `Refund amount should not exceed ${formatted_amount}`->Js.Json.string,
        )
      } else if floatVal == 0.0 {
        Dict.set(errors, "amount", "Please enter refund amount greater than zero"->Js.Json.string)
      }
    | None => ()
    }
    errors->Js.Json.object_
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
