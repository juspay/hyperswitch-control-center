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
  open ConnectProcessorsHelper
  let isLiveMode = (HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom).isLiveMode
  let (arrow, setArrow) = React.useState(_ => false)

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

  let toggleChevronState = () => {
    setArrow(prev => !prev)
  }

  let options = {
    open RevenueRecoveryOnboardingUtils
    isLiveMode ? prodBillingConnectorList : billingConnectorList
  }->RevenueRecoveryOnboardingUtils.getOptions

  let customScrollStyle = "max-h-72 overflow-scroll px-1 pt-1 border border-b-0"
  let dropdownContainerStyle = "rounded-md border border-1 !w-full"

  let gatewaysBottomComponent = {
    open BillingProcessorsUtils
    <RenderIf condition={!isLiveMode}>
      <p
        className="text-nd_gray-500 font-semibold leading-3 text-fs-12 tracking-wider bg-white border-t px-5 pt-4">
        {"Available for Production"->React.string}
      </p>
      <div className="p-2">
        <ReadOnlyOptionsList
          list=RevenueRecoveryOnboardingUtils.billingConnectorProdList
          headerText="Billing Platforms"
        />
        <ReadOnlyOptionsList
          list=RevenueRecoveryOnboardingUtils.billingConnectorInHouseList headerText="In House"
        />
      </div>
    </RenderIf>
  }

  open RevenueRecoveryOnboardingUtils
  <PageWrapper
    title="Choose your Billing Platform"
    subTitle="Select your subscription management platform to get started.">
    <div className="-m-1 mb-10 flex flex-col gap-7">
      <PageLoaderWrapper screenState>
        <Form onSubmit={handleAuthKeySubmit} initialValues validate=validateMandatoryField>
          <p className="text-sm text-gray-700 font-semibold mb-1">
            {"Select a Platform"->React.string}
          </p>
          <SelectBox.BaseDropdown
            allowMultiSelect=false
            buttonText="Choose a platform"
            input
            deselectDisable=true
            customButtonStyle="!rounded-xl h-[45px] pr-2"
            options
            hideMultiSelectButtons=true
            baseComponent={<ListBaseComp
              placeHolder="Choose a platform" heading="platform" subHeading=connector arrow
            />}
            bottomComponent=gatewaysBottomComponent
            addButton=false
            customScrollStyle
            dropdownContainerStyle
            toggleChevronState
            searchable=false
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
                updateAccountDetails=false
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
        </Form>
      </PageLoaderWrapper>
    </div>
  </PageWrapper>
}
