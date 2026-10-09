@react.component
let make = (
  ~initialValues,
  ~onSubmit,
  ~validateMandatoryField,
  ~updatedInitialVal,
  ~connectorInfoDict,
  ~screenState,
) => {
  open RevenueRecoveryOnboardingUtils
  let isLiveMode = (HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom).isLiveMode
  <PageWrapper
    title="Authenticate Platform"
    subTitle="Configure your credentials from your billing platform dashboard.">
    <div className="-m-1 mb-10 flex flex-col gap-7">
      <PageLoaderWrapper screenState>
        <Form onSubmit initialValues validate=validateMandatoryField>
          <div className="flex flex-col mb-5 mt-7 gap-3 w-full ">
            <ConnectorAuthKeys
              initialValues={updatedInitialVal}
              showVertically=true
              processorType=ConnectorTypes.BillingProcessor
              updateAccountDetails=isLiveMode
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
              text="Next" buttonSize={Small} customSubmitButtonStyle="!w-full mt-8"
            />
          </div>
        </Form>
      </PageLoaderWrapper>
    </div>
  </PageWrapper>
}
