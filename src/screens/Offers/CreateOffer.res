open LogicUtils
open OffersFormFields
open OffersFormUtils
open Typography

module FormSection = {
  @react.component
  let make = (~title, ~children) => {
    <div className="flex flex-col gap-4">
      <div className={`${heading.sm.semibold} text-nd_gray-700`}> {title->React.string} </div>
      <div className="flex flex-col gap-4 border border-nd_gray-150 bg-white rounded-xl p-5">
        children
      </div>
    </div>
  }
}

module FieldRow = {
  @react.component
  let make = (~fields) => {
    <div className="grid grid-cols-1 md:grid-cols-2 gap-x-8 gap-y-2">
      {fields
      ->Array.mapWithIndex((field, index) =>
        <FormRenderer.FieldRenderer key={index->Int.toString} field fieldWrapperClass="w-full" />
      )
      ->React.array}
    </div>
  }
}

@react.component
let make = () => {
  let createOffer = OffersHooks.useCreateOffer()
  let showToast = ToastState.useShowToast()

  let onSubmit = async (values, _) => {
    try {
      let _ = await createOffer(values->getDictFromJsonObject->offerFormValuesMapper)
      showToast(~message="Offer created", ~toastType=ToastSuccess)
      RescriptReactRouter.push(GlobalVars.appendDashboardPath(~url="/offers"))
    } catch {
    | Exn.Error(e) =>
      showToast(
        ~message=Exn.message(e)->Option.getOr("Failed to create the offer"),
        ~toastType=ToastError,
      )
    }
    Nullable.null
  }

  let initialValues =
    [
      ("language", (OffersTypes.English :> string)->JSON.Encode.string),
      ("calculation_rule", (OffersTypes.Percentage :> string)->JSON.Encode.string),
    ]->getJsonFromArrayOfJson

  <div className="flex flex-col gap-6">
    <div>
      <PageUtils.PageHeading title="Create a New Offer" />
      <BreadCrumbNavigation
        path=[{title: "Offers", link: "/offers"}] currentPageTitle="Create a New Offer"
      />
    </div>
    <Form onSubmit validate=validateOfferForm initialValues>
      <div className="flex flex-col gap-6">
        <FormSection title="Offer Details">
          <FieldRow fields=[offerCodeField, titleField] />
          <FieldRow fields=[displayTitleField, languageField] />
          <FieldRow fields=[descriptionField, logoField] />
          <FieldRow fields=[validityField] />
          <FieldRow fields=[calculationRuleField, benefitValueField] />
          <FieldRow fields=[maxAmountField] />
          <FieldRow fields=[campaignAmountField, campaignCountField] />
        </FormSection>
        <FormSection title="Transaction Level Details">
          <FieldRow fields=[currencyField] />
          <FieldRow fields=[minOrderAmountField, maxOrderAmountField] />
        </FormSection>
        <FormSection title="Payment Details">
          <FieldRow fields=[amountPerCardField, countPerCardField] />
          <BinListUpload />
        </FormSection>
        <FormRenderer.SubmitButton
          text="Create Offer" buttonType=Primary customSubmitButtonStyle="!w-fit"
        />
      </div>
    </Form>
  </div>
}
