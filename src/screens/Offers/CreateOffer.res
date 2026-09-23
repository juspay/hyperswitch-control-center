open APIUtils
open LogicUtils
open OffersFormFields
open OffersFormUtils
open OffersHelpers

@react.component
let make = () => {
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod(~showErrorToast=false)
  let {merchantId} = React.useContext(UserInfoProvider.defaultContext).getCommonSessionDetails()
  let showToast = ToastState.useShowToast()

  let onSubmit = async (values, _) => {
    try {
      let url = getURL(~entityName=V1(OFFERS), ~methodType=Post, ~offersType=#OFFER_CREATE)
      let body = buildCreateBody(~merchantId, values->getDictFromJsonObject->offerFormValuesMapper)
      let _ = await updateDetails(url, body, Post)
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

  <AccessControl authorization={userHasAccess(~groupAccess=OffersManage)}>
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
  </AccessControl>
}
