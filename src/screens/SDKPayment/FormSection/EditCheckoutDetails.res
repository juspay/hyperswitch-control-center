open FormRenderer
open SDKPaymentHelper

module AuthorizationAndCaptureSettings = {
  @react.component
  let make = (
    ~showSetupFutureUsage,
    ~setShowSetupFutureUsage,
    ~setInitialValuesForCheckoutForm,
    ~sendAuthType,
    ~setSendAuthType,
  ) => {
    let {state: {commonInfo: {profileId}}} = React.useContext(UserInfoProvider.defaultContext)
    let handleIsSelectedForFuture = (val, setFunc) => {
      setInitialValuesForCheckoutForm(_ => {
        SDKPaymentUtils.initialValueForForm(~showSetupFutureUsage=val, ~sendAuthType, ~profileId)
      })
      setFunc(_ => val)
    }
    let handleIsSelectedForThreeDs = (val, setFunc) => {
      setInitialValuesForCheckoutForm(_ => {
        SDKPaymentUtils.initialValueForForm(~sendAuthType=val, ~showSetupFutureUsage, ~profileId)
      })
      setFunc(_ => val)
    }

    <>
      <DesktopRow itemWrapperClass="mx-0">
        <FieldRenderer field=selectCaptureMethodField />
        <div className="flex justify-between mr-2">
          <FieldRenderer field={selectSetupFutureUsageField(showSetupFutureUsage)} />
          <BoolInput.BaseComponent
            isSelected=showSetupFutureUsage
            setIsSelected={val => handleIsSelectedForFuture(val, setShowSetupFutureUsage)}
            boolCustomClass="rounded-xl mt-5"
            toggleEnableColor="bg-primary"
            toggleBorder="border-primary"
          />
        </div>
      </DesktopRow>
      <DesktopRow itemWrapperClass="mx-0">
        <FieldRenderer field=external3DSAuthToggle />
        <div className="flex justify-between mr-2">
          <FieldRenderer field={selectAuthenticationField(sendAuthType)} labelClass="mr-4" />
          <BoolInput.BaseComponent
            boolCustomClass="rounded-xl mt-5"
            toggleEnableColor="bg-primary"
            isSelected=sendAuthType
            setIsSelected={val => handleIsSelectedForThreeDs(val, setSendAuthType)}
          />
        </div>
      </DesktopRow>
    </>
  }
}

@react.component
let make = (
  ~showModal,
  ~setShowModal,
  ~showSetupFutureUsage,
  ~setShowSetupFutureUsage,
  ~sendAuthType,
  ~setSendAuthType,
) => {
  let {setInitialValuesForCheckoutForm} = React.useContext(SDKProvider.defaultContext)
  <Modal
    setShowModal
    showModal
    modalClass="w-full max-w-xl max-h-[90vh] mx-auto my-auto overflow-hidden rounded-lg bg-white"
    childClass="m-4 overflow-y-auto max-h-[80vh]"
    customModalHeading={<PageUtils.PageHeading
      title="Edit Checkout Details"
      customHeadingStyle="p-4 border-b-2"
      customTitleStyle="!font-semibold !text-xl !text-nd_gray-700"
      customTitleSectionStyles="!justify-between"
      customTagComponent={<Icon
        name="modal-close-icon"
        className="cursor-pointer"
        size=30
        onClick={_ => setShowModal(_ => false)}
      />}
      showPermLink={false}
    />}>
    <div className="flex flex-col gap-5">
      <FieldRenderer field=enterEmailField fieldWrapperClass="!w-full" />
      <Accordion
        initialExpandedArray=[0]
        accordion={[
          {
            title: "Authorization & Capture Settings",
            renderContent: (~currentAccordianState as _, ~closeAccordionFn as _) => {
              <AuthorizationAndCaptureSettings
                showSetupFutureUsage
                setShowSetupFutureUsage
                setInitialValuesForCheckoutForm
                sendAuthType
                setSendAuthType
              />
            },
            renderContentOnTop: None,
          },
        ]}
        accordianTopContainerCss="!overflow-visible"
        accordianBottomContainerCss="p-5"
        contentExpandCss="p-2"
        titleStyle="font-semibold text-bold text-md hover:!bg-white"
      />
      <ToggleFormSection />
    </div>
    <div className="flex justify-end p-2">
      <Button text="Save" buttonType={Primary} onClick={_ => setShowModal(_ => false)} />
    </div>
  </Modal>
}
