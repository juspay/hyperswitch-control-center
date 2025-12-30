open OrderEntity
open APIUtils
open OrderUtils
open HSwitchOrderUtils
open LogicUtils
open CurrencyUtils
@react.component
let make = (
  ~order: PaymentInterfaceTypes.order,
  ~setShowModal,
  ~requestedRefundAmount,
  ~amountRefunded,
  ~amoutAvailableToRefund,
  ~refetch,
) => {
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let showToast = ToastState.useShowToast()
  let showRefundAddressEmailList = ["coingate"]
  let showRefundAddressEmail =
    showRefundAddressEmailList->Array.includes(order.connector->String.toLowerCase)

  let {merchantId, orgId} = React.useContext(UserInfoProvider.defaultContext).getCommonDetails()
  let isSplitPayment =
    order.connector->String.toLowerCase->isSplitPaymentConnector &&
      !(order.split_payments->isEmptyDict)
  let initiateValue = initialValuesDict(~isSplitPayment, ~order)
  let initiateValueJson = initiateValue->JSON.Encode.object

  let updateRefundDetails = async body => {
    try {
      let refundsUrl = getURL(~entityName=V1(REFUNDS), ~methodType=Post)
      let res = await updateDetails(refundsUrl, body, Post)
      let refundStatus = res->LogicUtils.getDictFromJsonObject->LogicUtils.getString("status", "")
      refetch()->ignore
      switch refundStatus->statusVariantMapper {
      | Succeeded =>
        showToast(~message="Refund successful", ~toastType=ToastSuccess)
        setShowModal(_ => false)
      | Failed =>
        showToast(~message="Refund failed - Please check refund details", ~toastType=ToastError)
        setShowModal(_ => false)
      | _ =>
        showToast(
          ~message="Processing your refund. Please check refund status",
          ~toastType=ToastInfo,
        )
        setShowModal(_ => false)
      }
    } catch {
    | _ => {
        showToast(~message="Refund failed", ~toastType=ToastError)
        setShowModal(_ => false)
      }
    }
  }

  let conversionFactor = getCurrencyConversionFactor(order.currency)
  let precisionDigits = getAmountPrecisionDigits(order.currency)
  let amountFieldWithPrecision = HSwitchOrderUtils.amountFieldWithPrecision(~precisionDigits)

  let onSubmit = (values, _) => {
    open Promise
    setShowModal(_ => false)
    let dict = values->LogicUtils.getDictFromJsonObject
    let amount = dict->LogicUtils.getFloat("amount", 0.0)
    Dict.set(dict, "amount", Math.round(amount *. conversionFactor)->JSON.Encode.float)
    let body = dict
    Dict.set(body, "payment_id", order.payment_id->JSON.Encode.string)
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
    if showRefundAddressEmail {
      let metadata = getDictFromJsonObject(values)->getDictfromDict("metadata")
      let emailValue = metadata->LogicUtils.getString("email", "")
      let cryptoAddress = metadata->Dict.get("address")
      let metadataErrors = Dict.make()
      if (
        cryptoAddress->Option.isNone ||
          cryptoAddress
          ->Option.getOr(JSON.Encode.null)
          ->LogicUtils.getStringFromJson("")
          ->String.trim
          ->LogicUtils.isEmptyString
      ) {
        Dict.set(metadataErrors, "address", `Required`->JSON.Encode.string)
      }
      if emailValue->CommonAuthUtils.isValidEmail {
        Dict.set(metadataErrors, "email", `Please Enter Valid Email`->JSON.Encode.string)
      }
      if !(metadataErrors->isEmptyDict) {
        Dict.set(errors, "metadata", metadataErrors->JSON.Encode.object)
      }
    }
    let amountValue = Dict.get(valuesDict, "amount")
    switch amountValue->Option.flatMap(obj => obj->JSON.Decode.float) {
    | Some(floatVal) =>
      let enteredAmountInMinorUnits = Math.round(floatVal *. conversionFactor)
      let remainingAmountInMinorUnits = Math.round(amoutAvailableToRefund *. conversionFactor)
      if enteredAmountInMinorUnits > remainingAmountInMinorUnits {
        let formatted_amount = Float.toFixedWithPrecision(
          amoutAvailableToRefund,
          ~digits=precisionDigits,
        )
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
              value={Currency(amountRefunded.contents /. conversionFactor, order.currency)}
            />
          </FormRenderer.DesktopRow>
          <FormRenderer.DesktopRow>
            <DisplayKeyValueParams
              heading={Table.makeHeaderInfo(~key="amount", ~title="Pending Requested Amount")}
              value={Currency(requestedRefundAmount.contents /. conversionFactor, order.currency)}
            />
          </FormRenderer.DesktopRow>
        </div>
        <div className="grid grid-cols-2 gap-8 mb-2">
          <FormRenderer.DesktopRow>
            <FormRenderer.FieldRenderer field={amountFieldWithPrecision} labelClass="text-fs-11" />
          </FormRenderer.DesktopRow>
          {switch order.connector
          ->String.toLowerCase
          ->ConnectorUtils.getConnectorNameTypeFromString {
          | Processors(ADYEN) =>
            <FormRenderer.DesktopRow>
              <FormRenderer.FieldRenderer
                field={adyenReasonDropdownField} labelClass="text-fs-11"
              />
            </FormRenderer.DesktopRow>
          | _ =>
            <FormRenderer.DesktopRow>
              <FormRenderer.FieldRenderer field={reasonField} labelClass="text-fs-11" />
            </FormRenderer.DesktopRow>
          }}
          <RenderIf condition={showRefundAddressEmail}>
            <FormRenderer.DesktopRow>
              <FormRenderer.FieldRenderer field={refundAddressField} labelClass="text-fs-11" />
            </FormRenderer.DesktopRow>
            <FormRenderer.DesktopRow>
              <FormRenderer.FieldRenderer field={refundEmailField} labelClass="text-fs-11" />
            </FormRenderer.DesktopRow>
          </RenderIf>
        </div>
        <RenderIf condition={isSplitPayment}>
          {switch order.connector
          ->String.toLowerCase
          ->ConnectorUtils.getConnectorNameTypeFromString {
          | Processors(STRIPE) =>
            let chargeType = order.split_payments->getStripeChargeType
            <div className="grid grid-cols-2 gap-8 mb-2 mx-4">
              <FormRenderer.FieldRenderer
                field={FormRenderer.makeFieldInfo(
                  ~name="split_refunds.stripe_split_refund.revert_platform_fee",
                  ~label="Revert Platform Fee",
                  ~customInput=InputFields.boolInput(
                    ~isDisabled=false,
                    ~boolCustomClass="rounded-lg mx-1",
                  ),
                  ~placeholder="",
                )}
              />
              <RenderIf condition={chargeType == Destination}>
                <FormRenderer.FieldRenderer
                  field={FormRenderer.makeFieldInfo(
                    ~name="split_refunds.stripe_split_refund.revert_transfer",
                    ~label="Revert Transfer Fee",
                    ~customInput=InputFields.boolInput(
                      ~isDisabled=false,
                      ~boolCustomClass="rounded-lg mx-1",
                    ),
                    ~placeholder="",
                  )}
                />
              </RenderIf>
            </div>
          | _ => React.null
          }}
        </RenderIf>
        <div className="flex justify-end gap-4 mt-16">
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
