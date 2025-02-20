@react.component
let make = (~handleAuthKeySubmit, ~initialValues, ~validateMandatoryField) => {
  open RevenueRecoveryOnboardingUtils

  <PageWrapper
    title="Configure Recovery Plan"
    subTitle="Choose one processor for now. You can connect more processors later">
    <div className="mb-10 flex flex-col gap-8">
      <Form onSubmit={handleAuthKeySubmit} initialValues validate=validateMandatoryField>
        <div>
          <div className="text-nd_gray-700 font-medium"> {"Start Retry After"->React.string} </div>
          <div className="-m-1 -mt-3">
            <FormRenderer.FieldRenderer
              labelClass="font-semibold !text-hyperswitch_black"
              field={FormRenderer.makeFieldInfo(
                ~label="",
                ~name="feature_metadata.billing_connector_recovery_metadata.start_after_retry_count",
                ~toolTipPosition=Right,
                ~customInput=InputFields.textInput(~customStyle="border rounded-xl"),
                ~placeholder="",
              )}
            />
          </div>
        </div>
        <div>
          <div className="text-nd_gray-700 font-medium"> {"Max Retry Attempts"->React.string} </div>
          <div className="-m-1 -mt-3">
            <FormRenderer.FieldRenderer
              labelClass="font-semibold !text-hyperswitch_black"
              field={FormRenderer.makeFieldInfo(
                ~label="",
                ~name="feature_metadata.billing_connector_recovery_metadata.max_retry_count",
                ~toolTipPosition=Right,
                ~customInput=InputFields.textInput(~customStyle="border rounded-xl"),
                ~placeholder="",
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
