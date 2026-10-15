@react.component
let make = (
  ~initialValues,
  ~onSubmit,
  ~validateMandatoryField,
  ~updatedInitialVal,
  ~connectorInfoDict,
  ~screenState,
  ~isCustomBilling=false,
) => {
  open RevenueRecoveryOnboardingUtils
  open Typography
  let isLiveMode = (HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom).isLiveMode
  <PageWrapper
    title="Authenticate Platform"
    subTitle="Configure your credentials from your billing platform dashboard.">
    <div className="-m-1 mb-10 flex flex-col gap-7">
      <PageLoaderWrapper screenState>
        <Form onSubmit initialValues validate=validateMandatoryField>
          <div className="flex flex-col mb-5 mt-7 gap-3 w-full ">
            <RenderIf condition={isCustomBilling}>
              <div
                className="flex gap-2 items-start p-4 rounded-xl border border-nd_gray-200 bg-nd_gray-50">
                <Icon name="info-vacant" size=16 className="mt-0.5" />
                <p className={`${body.sm.regular} text-nd_gray-600`}>
                  {"Note: Custom Billing doesn't require any credentials. Click Next to continue."->React.string}
                </p>
              </div>
            </RenderIf>
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
