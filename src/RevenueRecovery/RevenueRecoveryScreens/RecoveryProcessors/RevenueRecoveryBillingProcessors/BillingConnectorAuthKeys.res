@react.component
let make = (
  ~initialValues,
  ~setConnectorName,
  ~connector,
  ~handleAuthKeySubmit,
  ~validateMandatoryField,
  ~updatedInitialVal,
  ~connectorInfoDict,
  ~screenState,
) => {
  open LogicUtils

  let input: ReactFinalForm.fieldRenderPropsInput = {
    name: "name",
    onBlur: _ => (),
    onChange: ev => {
      let value = ev->Identity.formReactEventToString
      setConnectorName(_ => value)
      RescriptReactRouter.replace(
        GlobalVars.appendDashboardPath(~url=`/v2/recovery/onboarding?name=${value}`),
      )
    },
    onFocus: _ => (),
    value: connector->JSON.Encode.string,
    checked: true,
  }

  let options =
    RevenueRecoveryOnboardingUtils.billingConnectorList->RevenueRecoveryOnboardingUtils.getOptions

  open RevenueRecoveryOnboardingUtils
  <PageWrapper
    title="Choose your Billing Platform"
    subTitle="Choose one processor for now. You can connect more processors later">
    <div className="-m-1 mb-10 flex flex-col gap-7">
      <PageLoaderWrapper screenState>
        <Form onSubmit={handleAuthKeySubmit} initialValues validate=validateMandatoryField>
          <SelectBox.BaseDropdown
            allowMultiSelect=false
            buttonText="Select Platform"
            input
            deselectDisable=true
            customButtonStyle="!rounded-xl h-[45px] pr-2"
            options
            hideMultiSelectButtons=true
            addButton=false
            searchable=true
            customStyle="!w-full"
            customDropdownOuterClass="!border-none"
            fullLength=true
            shouldDisplaySelectedOnTop=true
            searchInputPlaceHolder="Search Platform"
          />
          <RenderIf condition={connector->isNonEmptyString}>
            <div className="flex flex-col mb-5 mt-7 gap-3 w-full ">
              <ConnectorAuthKeys
                initialValues={updatedInitialVal}
                showVertically=true
                processorType=ConnectorTypes.BillingProcessor
              />
              <ConnectorLabelV2 isInEditState=true connectorInfo={connectorInfoDict} />
              <ConnectorMetadataV2
                isInEditState=true
                connectorInfo={connectorInfoDict}
                processorType=ConnectorTypes.BillingProcessor
              />
              <ConnectorWebhookDetails
                isInEditState=true
                connectorInfo={connectorInfoDict}
                processorType=ConnectorTypes.BillingProcessor
              />
              <FormRenderer.SubmitButton
                text="Next"
                buttonSize={Small}
                customSumbitButtonStyle="!w-full mt-8"
                tooltipForWidthClass="w-full"
              />
            </div>
          </RenderIf>
          <FormValuesSpy />
        </Form>
      </PageLoaderWrapper>
    </div>
  </PageWrapper>
}
