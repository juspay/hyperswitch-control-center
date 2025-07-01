let getOptions: array<BillingProcessorsUtils.optionType> => array<
  SelectBox.dropdownOption,
> = dropdownList => {
  let options: array<SelectBox.dropdownOption> = dropdownList->Array.map((
    option
  ): SelectBox.dropdownOption => {
    {
      label: option.name,
      value: option.value,
      icon: Button.CustomIcon(<img alt="image" src=option.icon className="mr-2 w-5 h-5" />),
    }
  })
  options
}

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
  ~onNextClick,
  ~currentStep,
  ~setNextStep,
) => {
  open LogicUtils
  open ConnectProcessorsHelper
  let getURL = APIUtils.useGetURL()
  let updateDetails = APIUtils.useUpdateMethod()
  let (arrow, setArrow) = React.useState(_ => false)
  let showToast = ToastState.useShowToast()
  let (apiKey, setApiKey) = React.useState(_ => "")
  let (showModal, setShowModal) = React.useState(_ => false)

  let customInitialValues =
    [
      ("name", "default"->JSON.Encode.string),
      ("description", "default api key"->JSON.Encode.string),
      ("expiration", "never"->JSON.Encode.string),
    ]->Dict.fromArray

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

  let options = RevenueRecoveryOnboardingUtils.billingConnectorList->getOptions

  let customScrollStyle = "max-h-72 overflow-scroll px-1 pt-1 border border-b-0"
  let dropdownContainerStyle = "rounded-md border border-1 !w-full"

  let gatewaysBottomComponent = {
    open BillingProcessorsUtils
    <>
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
    </>
  }

  let onSubmit = async (values, _) => {
    try {
      let valuesDict = values->LogicUtils.getDictFromJsonObject

      let body = Dict.make()
      Dict.set(body, "name", valuesDict->LogicUtils.getString("name", "")->JSON.Encode.string)
      let description = valuesDict->LogicUtils.getString("description", "")
      Dict.set(body, "description", description->JSON.Encode.string)

      let url = getURL(~entityName=V2(API_KEYS), ~methodType=Post)

      // let json = await updateDetails(url, body->JSON.Encode.object, Post, ~version=V2)
      // let keyDict = json->LogicUtils.getDictFromJsonObject

      // setApiKey(_ => keyDict->LogicUtils.getString("api_key", ""))

      // Clipboard.writeText(keyDict->LogicUtils.getString("api_key", ""))
      onNextClick(currentStep, setNextStep)
    } catch {
    | Exn.Error(e) =>
      switch Exn.message(e) {
      | Some(_error) =>
        showToast(~message="Api Key Generation Failed", ~toastType=ToastState.ToastError)
      | None => ()
      }
    }
    Nullable.null
  }

  let downloadKey = _ => {
    DownloadUtils.downloadOld(~fileName=`apiKey.txt`, ~content=apiKey)
  }

  open RevenueRecoveryOnboardingUtils
  <PageWrapper
    title="Choose your Billing Platform"
    subTitle="Select your subscription management platform to get started.">
    <div className="-m-1 mb-10 flex flex-col gap-2">
      <PageLoaderWrapper screenState>
        <p className="text-sm text-gray-700 font-semibold"> {"Select a Platform"->React.string} </p>
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
        <RenderIf condition={connector->isNonEmptyString && connector != "custom"}>
          <Form onSubmit={handleAuthKeySubmit} initialValues validate=validateMandatoryField>
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
          </Form>
        </RenderIf>
        <RenderIf condition={connector == "custom"}>
          <Form
            onSubmit
            initialValues={customInitialValues->JSON.Encode.object}
            validate={values =>
              DeveloperUtils.validateAPIKeyForm(
                values,
                ["name", "expiration", "description"],
                ~setShowCustomDate=_ => (),
              )}>
            <div className="flex gap-2 flex-col">
              <FormRenderer.FieldRenderer
                labelClass="font-semibold !text-hyperswitch_black"
                field={FormRenderer.makeFieldInfo(
                  ~label="Name",
                  ~name=`name`,
                  ~isRequired=true,
                  ~toolTipPosition=Right,
                  ~customInput=InputFields.textInput(
                    ~customStyle="border rounded-xl",
                    ~autoFocus=false,
                  ),
                  ~placeholder="Enter Api key name",
                )}
              />
              <FormRenderer.FieldRenderer
                labelClass="font-semibold !text-hyperswitch_black"
                field={FormRenderer.makeFieldInfo(
                  ~label="Description",
                  ~isRequired=true,
                  ~name="description",
                  ~toolTipPosition=Right,
                  ~customInput=InputFields.textInput(
                    ~customStyle="border rounded-xl",
                    ~autoFocus=false,
                  ),
                  ~placeholder="Enter api description",
                )}
              />
            </div>
            <FormRenderer.SubmitButton
              text="Next"
              buttonSize={Small}
              customSumbitButtonStyle="!w-full mt-8"
              tooltipForWidthClass="w-full"
            />
          </Form>
        </RenderIf>
        <Modal
          showModal
          modalHeading="Api Key"
          setShowModal
          closeOnOutsideClick=true
          modalClass="w-full max-w-2xl m-auto !bg-white dark:!bg-jp-gray-lightgray_background">
          <DeveloperUtils.SuccessUI apiKey downloadFun=downloadKey />
        </Modal>
      </PageLoaderWrapper>
    </div>
  </PageWrapper>
}
