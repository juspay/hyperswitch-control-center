@react.component
let make = (~handleAuthKeySubmit, ~initialValues, ~validateMandatoryField) => {
  open RevenueRecoveryOnboardingUtils

  <PageWrapper
    title="Configure Recovery Plan"
    subTitle="Set up how invoices should be selected and processed for recovery.">
    <div className="mb-10 flex flex-col gap-8">
      <Form onSubmit={handleAuthKeySubmit} initialValues validate=validateMandatoryField>
        <div>
          <div className="text-nd_gray-700 font-medium flex gap-2 w-fit align-center">
            {"Start Retry After"->React.string}
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
        <div className="mt-5">
          <div className="text-nd_gray-700 font-medium flex gap-2 w-fit">
            {"Max Retry Attempts"->React.string}
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
            <FormRenderer.SubmitButton
              text="Next"
              buttonSize={Small}
              customSumbitButtonStyle="!w-full mt-8"
              tooltipForWidthClass="w-full"
            />
          </div>
        </div>
        <FormValuesSpy />
      </Form>
    </div>
  </PageWrapper>
}
