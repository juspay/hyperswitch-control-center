@react.component
let make = (~currentStep: VerticalStepIndicatorTypes.step, ~setCurrentStep) => {
  open ReconConfigurationUtils
  open VerticalStepIndicatorUtils
  open ConnectProcessorsHelper
  open OMPSwitchTypes

  let (selectedProcessor, setSelectedProcessor) = React.useState(_ => "")
  let (processorList, _) = React.useState(_ => [{id: "Stripe", name: "Stripe"}])
  let (arrow, setArrow) = React.useState(_ => false)
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let getNextStep = (currentStep: VerticalStepIndicatorTypes.step): option<
    VerticalStepIndicatorTypes.step,
  > => {
    findNextStep(sections, currentStep)
  }

  let onNextClick = () => {
    switch getNextStep(currentStep) {
    | Some(nextStep) => setCurrentStep(_ => nextStep)
    | None => ()
    }
  }

  let input: ReactFinalForm.fieldRenderPropsInput = {
    name: "name",
    onBlur: _ => (),
    onChange: ev => {
      let value = ev->Identity.formReactEventToString
      setSelectedProcessor(_ => value)
    },
    onFocus: _ => (),
    value: selectedProcessor->JSON.Encode.string,
    checked: true,
  }

  let toggleChevronState = () => {
    setArrow(prev => !prev)
  }

  let addItemBtnStyle = "border border-t-0 !w-full"
  let customScrollStyle = "max-h-72 overflow-scroll px-1 pt-1 border border-b-0"
  let dropdownContainerStyle = "rounded-md border border-1 !w-full"

  <div className="flex flex-col h-full gap-y-10">
    <div className="flex flex-col h-full gap-y-10">
      <ReconConfigurationHelper.SubHeading
        title="Where do you process your payments?"
        subTitle="Choose one processor for now. You can connect more processors later"
      />
      <div className="flex flex-col h-full gap-y-10">
        <div className="flex flex-col gap-y-4">
          <p className="text-base text-gray-700 font-semibold">
            {"Select a processor"->React.string}
          </p>
          <SelectBox.BaseDropdown
            allowMultiSelect=false
            buttonText=""
            input
            deselectDisable=true
            customButtonStyle="!rounded-lg"
            options={processorList->generateDropdownOptionsCustomComponent}
            marginTop="mt-10"
            hideMultiSelectButtons=true
            addButton=false
            searchable=true
            baseComponent={<ListBaseComp heading="Profile" subHeading=selectedProcessor arrow />}
            bottomComponent={<AddNewOMPButton user=#Profile addItemBtnStyle />}
            customDropdownOuterClass="!border-none !w-full"
            fullLength=true
            toggleChevronState
            customScrollStyle
            dropdownContainerStyle
            shouldDisplaySelectedOnTop=true
            customSelectionIcon={CustomIcon(<Icon name="nd-checkbox-base" />)}
            searchInputPlaceHolder="Search"
            showSearchIcon=true
          />
        </div>
        <RenderIf condition={selectedProcessor->String.length > 0}>
          <Form>
            <div className="flex flex-col gap-y-3">
              <p className="font-semibold leading-5 text-nd_gray-700 text-sm">
                {"Provide authentication details"->React.string}
              </p>
              <FormRenderer.FieldRenderer
                labelClass="font-semibold"
                field={FormRenderer.makeFieldInfo(
                  ~label="Secret Key",
                  ~name="secret_key",
                  ~placeholder="**************",
                  ~customInput=InputFields.textInput(~customStyle="rounded-xl bg-nd_gray-50"),
                  ~isRequired=false,
                )}
              />
              <FormRenderer.FieldRenderer
                labelClass="font-semibold"
                field={FormRenderer.makeFieldInfo(
                  ~label="Client Verification Key",
                  ~name="client_verification_key",
                  ~placeholder="**************",
                  ~customInput=InputFields.textInput(~customStyle="rounded-xl bg-nd_gray-50"),
                  ~isRequired=false,
                )}
              />
            </div>
          </Form>
        </RenderIf>
        <div className="flex justify-end items-center">
          <Button
            text="Next"
            customButtonStyle="rounded w-full"
            buttonType={Primary}
            buttonState={selectedProcessor->String.length > 0 ? Normal : Disabled}
            onClick={_ => {
              mixpanelEvent(~eventName="recon_onboarding_step2")
              onNextClick()->ignore
            }}
          />
        </div>
      </div>
    </div>
  </div>
}
