@react.component
let make = () => {
  open RevenueRecoveryOnboardingUtils

  <PageWrapper
    title="Configure Recovery Plan"
    subTitle="Choose one processor for now. You can connect more processors later">
    <div className="mb-10 flex flex-col gap-8">
      <div>
        <div className="text-nd_gray-700 font-medium"> {"Start Retry After"->React.string} </div>
        <div className="-m-1 -mt-3">
          <FormRenderer.FieldRenderer
            labelClass="font-semibold !text-hyperswitch_black"
            field={FormRenderer.makeFieldInfo(
              ~label="",
              ~name="billing_account_reference",
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
              ~name="billing_account_reference",
              ~toolTipPosition=Right,
              ~customInput=InputFields.textInput(~customStyle="border rounded-xl"),
              ~placeholder="",
            )}
          />
        </div>
      </div>
    </div>
  </PageWrapper>
}
