module ConnectorConnect = {
  @react.component
  let make = (~connector_account_reference_id, ~autoFocus=false) => {
    <FormRenderer.FieldRenderer
      labelClass="font-semibold !text-hyperswitch_black"
      field={FormRenderer.makeFieldInfo(
        ~label="",
        ~name=`feature_metadata.revenue_recovery.billing_account_reference.${connector_account_reference_id}`,
        ~toolTipPosition=Right,
        ~customInput=InputFields.textInput(~customStyle="border rounded-xl", ~autoFocus),
        ~placeholder="Enter Account ID",
      )}
    />
  }
}

module ConnectorConnectSummary = {
  @react.component
  let make = (~connector, ~connector_account_reference_id, ~autoFocus=false) => {
    let connectorName = connector->ConnectorUtils.getDisplayNameForConnector

    <div className="flex gap-7">
      <div className="flex gap-3 items-center">
        <GatewayIcon gateway={connector->String.toUpperCase} className="w-10" />
        <h1 className="text-medium font-semibold text-gray-600"> {connectorName->React.string} </h1>
      </div>
      <div className="w-full ml-5 mb-2">
        <ConnectorConnect connector_account_reference_id autoFocus />
      </div>
    </div>
  }
}

module HardDeclineRetryConfiguration = {
  open Typography
  open LocalStorage

  @react.component
  let make = () => {
    let (budgetValue, setBudgetValue) = React.useState(_ => 1600)

    React.useEffect(() => {
      setItem("hard_decline_budget", budgetValue->Int.toString)
      None
    }, [])

    let handleInputChange = (ev: ReactEvent.Form.t) => {
      let newValue = {ev->ReactEvent.Form.target}["value"]
      setBudgetValue(_ => newValue)
      setItem("hard_decline_budget", newValue)
    }

    <div className="flex flex-col gap-5">
      <div className="bg-nd_gray-50 border border-nd_br_gray-200 rounded-lg p-5">
        <div className="flex items-center gap-2 mb-3">
          <Icon name="nd_light_bulb" size=20 className="text-nd_gray-600" />
          <div className={heading.xs.semibold}> {"Hard Declines Budget"->React.string} </div>
        </div>
        <div className={`${body.md.regular} text-nd_gray-700 mb-4`}>
          {"Some card declines (e.g. lost/stolen or AVS mismatch) are still salvageable—but they need extra 'retry power' like switching gateways or using backup networks."->React.string}
        </div>
        <div className="flex flex-col gap-3">
          <div className="flex items-start gap-2">
            <Icon name="check-black" size=16 className="text-nd_green-400 mt-0.5 flex-shrink-0" />
            <div className={`${body.md.regular} text-nd_gray-700`}>
              {"Pick how much you're willing to spend each month (e.g. $500)."->React.string}
            </div>
          </div>
          <div className="flex items-start gap-2">
            <Icon name="check-black" size=16 className="text-nd_green-400 mt-0.5 flex-shrink-0" />
            <div className={`${body.md.regular} text-nd_gray-700`}>
              {"We only use it when our system sees a >50% chance of success."->React.string}
            </div>
          </div>
        </div>
      </div>
      <div className="flex flex-col gap-2">
        <div className={`${body.lg.medium} text-nd_gray-700`}>
          {"Suggested Budget"->React.string}
        </div>
        <input
          type_="text"
          value={budgetValue->Int.toString}
          onChange=handleInputChange
          placeholder="$ 1600"
          className="w-full border border-nd_br_gray-200 rounded-xl px-4 py-2 focus:outline-none focus:ring-0.5 focus:ring-nd_primary_blue-400 focus:border-nd_primary_blue-400"
        />
      </div>
    </div>
  }
}

@react.component
let make = (
  ~initialValues,
  ~validateMandatoryField,
  ~connector,
  ~billingConnector,
  ~onSubmit,
  ~connector_account_reference_id,
) => {
  open RevenueRecoveryOnboardingUtils
  open Typography
  let connectorName = connector->ConnectorUtils.getDisplayNameForConnector

  <div>
    <PageWrapper
      title="Configure Retry Logic"
      subTitle="Set how and when you'd like retries to be attempted. You can modify this later.">
      <Form onSubmit initialValues validate=validateMandatoryField>
        <div className="mb-10 flex flex-col gap-10">
          <div className="flex flex-col gap-5">
            <div className={heading.sm.semibold}>
              {"External Retry Configuration"->React.string}
            </div>
            <div>
              <div className="text-nd_gray-700 font-medium flex gap-1 w-fit align-center">
                {"Start Retry After"->React.string}
                <span className="text-red-900 mb-0.5"> {"*"->React.string} </span>
                <ToolTip
                  height="mt-0.5"
                  description="Sets the number of failed attempts that will be monitored before initiating retry scheduling"
                  toolTipFor={<div className="cursor-pointer">
                    <Icon name="info-vacent" size=13 />
                  </div>}
                  toolTipPosition=ToolTip.Top
                  newDesign=true
                />
              </div>
              <div className="-m-1 -mt-3">
                <FormRenderer.FieldRenderer
                  labelClass="font-semibold !text-hyperswitch_black"
                  field={FormRenderer.makeFieldInfo(
                    ~label="",
                    ~name="feature_metadata.revenue_recovery.billing_connector_retry_threshold",
                    ~toolTipPosition=Right,
                    ~customInput=InputFields.numericTextInput(~customStyle="border rounded-xl"),
                    ~placeholder="ex 3",
                  )}
                />
              </div>
            </div>
            <div>
              <div className="text-nd_gray-700 font-medium flex gap-1 w-fit">
                {"Max Retry Attempts"->React.string}
                <span className="text-red-900 mb-0.5"> {"*"->React.string} </span>
                <ToolTip
                  height="mt-0.5"
                  description="Defines the maximum number of retry attempts before the system stops trying."
                  toolTipFor={<div className="cursor-pointer">
                    <Icon name="info-vacent" size=13 />
                  </div>}
                  toolTipPosition=ToolTip.Top
                  newDesign=true
                />
              </div>
              <div className="-m-1 -mt-3">
                <FormRenderer.FieldRenderer
                  labelClass="font-semibold !text-hyperswitch_black"
                  field={FormRenderer.makeFieldInfo(
                    ~label="",
                    ~name="feature_metadata.revenue_recovery.max_retry_count",
                    ~toolTipPosition=Right,
                    ~customInput=InputFields.numericTextInput(~customStyle="border rounded-xl"),
                    ~placeholder="ex 15",
                  )}
                />
              </div>
            </div>
            <div className="flex flex-col gap-5 mt-3">
              <div className={heading.sm.semibold}>
                {"Hard decline retry Configuration"->React.string}
              </div>
              <HardDeclineRetryConfiguration />
            </div>
          </div>
          <RenderIf
            condition={billingConnector->ConnectorUtils.getConnectorNameTypeFromString(
              ~connectorType=BillingProcessor,
            ) != BillingProcessor(CUSTOMBILLING)}>
            <div className="border-t w-full my-2" />
            <div className="flex flex-col gap-7">
              <div>
                <div className={heading.sm.semibold}>
                  {"Set Up Payment Processor Reference"->React.string}
                </div>
                <div className={`${heading.xs.medium} font-medium leading-5 opacity-50 mt-2`}>
                  {"Enter the same processor ID used in your subscription platform."->React.string}
                </div>
              </div>
              <div className="mb-10 flex flex-col gap-6 mt-2">
                <div>
                  <div className="text-nd_gray-700 font-medium mb-3">
                    {"Selected processor"->React.string}
                  </div>
                  <div className="flex gap-4 items-center">
                    <GatewayIcon gateway={connector->String.toUpperCase} className="w-10" />
                    <h1 className={`${body.lg.semibold} text-gray-600`}>
                      {connectorName->React.string}
                    </h1>
                  </div>
                </div>
                <div>
                  <div className="text-nd_gray-700 font-medium">
                    {"Processor Reference ID"->React.string}
                    <span className="text-red-900 ml-0.5 mb-0.5"> {"*"->React.string} </span>
                  </div>
                  <div className="-m-1 -mt-3">
                    <ConnectorConnect connector_account_reference_id />
                  </div>
                </div>
              </div>
            </div>
          </RenderIf>
          <FormRenderer.SubmitButton
            text="Next"
            buttonSize={Small}
            customSumbitButtonStyle="!w-full"
            tooltipForWidthClass="w-full"
          />
        </div>
      </Form>
    </PageWrapper>
  </div>
}
