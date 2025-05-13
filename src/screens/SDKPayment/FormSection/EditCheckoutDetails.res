open FormRenderer
open SDKPaymentHelper

module AuthorizationAndCaptureSettings = {
  @react.component
  let make = () => {
    <>
      <DesktopRow itemWrapperClass="">
        <FieldRenderer field=selectCaptureMethodField />
        <FieldRenderer field=selectSetupFutureUsageField />
      </DesktopRow>
      <DesktopRow itemWrapperClass="">
        <FieldRenderer field=selectAuthenticationField />
        <FieldRenderer field=external3DSAuthToggle />
      </DesktopRow>
    </>
  }
}

@react.component
let make = (~showModal, ~setShowModal) => {
  <Modal
    setShowModal
    showModal
    closeOnOutsideClick=true
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
    />}>
    <div className="flex flex-col gap-5">
      <FieldRenderer field=enterEmailField fieldWrapperClass="!w-full" />
      <Accordion
        initialExpandedArray=[0]
        accordion={[
          {
            title: "Authorization & Capture Settings",
            renderContent: () => {
              <AuthorizationAndCaptureSettings />
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
