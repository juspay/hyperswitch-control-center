@react.component
let make = (
  ~getClientSecret,
  ~navigationPath="/sdk",
  ~onSubmitClick=_ => (),
  ~submitButtonText="Show Preview",
) => {
  open FormRenderer
  open SDKPaymentHelper
  open SDKPaymentUtils
  open Typography
  let {
    isGuestMode,
    setIsGuestMode,
    showSetupFutureUsage,
    setShowSetupFutureUsage,
    sendAuthType,
    setSendAuthType,
    initialValuesForCheckoutForm,
    setKeyForReRenderingSDK,
    setInitialValuesForCheckoutForm,
    showBillingAddress,
    setPaymentStatus,
  } = React.useContext(SDKProvider.defaultContext)
  let {userInfo: {roleId}} = React.useContext(UserInfoProvider.defaultContext)
  let isInternalUser = roleId->HyperSwitchUtils.checkIsInternalUser
  let {globalUIConfig: {font: {textColor: {primaryNormal}}}} = React.useContext(
    ThemeProvider.themeContext,
  )
  let (showModal, setShowModal) = React.useState(() => false)
  let showToast = ToastState.useShowToast()
  let paymentConnectorList = ConnectorListInterface.useFilteredConnectorList(
    ~retainInList=PaymentProcessor,
  )

  let onSubmit = async (values, _) => {
    try {
      setKeyForReRenderingSDK(_ => Date.now()->Float.toString)
      setInitialValuesForCheckoutForm(_ =>
        getTypedPaymentData(
          values,
          ~showBillingAddress,
          ~isGuestMode,
          ~showSetupFutureUsage,
          ~sendAuthType,
        )
      )
      let typedValues = getTypedPaymentData(
        values,
        ~onlyEssential=true,
        ~showBillingAddress,
        ~isGuestMode,
        ~showSetupFutureUsage,
        ~sendAuthType,
      )
      let _ = await getClientSecret(~typedValues)
      RescriptReactRouter.push(GlobalVars.appendDashboardPath(~url=navigationPath))
      onSubmitClick()
      // To re-render the SDK back again after the payment is completed
      setPaymentStatus(_ => INCOMPLETE)
    } catch {
    | _ => showToast(~message="Something went wrong. Please try again", ~toastType=ToastError)
    }
    Nullable.null
  }

  <Form
    formClass="mt-4"
    initialValues={initialValuesForCheckoutForm->Identity.genericTypeToJson}
    onSubmit>
    <FieldRenderer
      field={enterCustomerId(~isGuestMode, ~setIsGuestMode)} fieldWrapperClass="!w-full"
    />
    <RenderIf condition={!isGuestMode}>
      <FieldRenderer field=selectShowSavedCardField fieldWrapperClass="!w-full" />
    </RenderIf>
    <FieldRenderer field=selectCurrencyField fieldWrapperClass="!w-full" />
    <FieldRenderer
      field={enterAmountField(initialValuesForCheckoutForm)} fieldWrapperClass="!w-full"
    />
    <div className="mt-4">
      <span
        className={`${primaryNormal} ${body.md.medium} cursor-pointer`}
        onClick={_ => setShowModal(_ => true)}>
        {"Edit Checkout Details"->React.string}
      </span>
    </div>
    <RenderIf condition=showModal>
      <EditCheckoutDetails
        showModal
        setShowModal
        showSetupFutureUsage
        setShowSetupFutureUsage
        sendAuthType
        setSendAuthType
      />
    </RenderIf>
    <SubmitButton
      text=submitButtonText
      disabledParamter={initialValuesForCheckoutForm.profile_id->LogicUtils.isEmptyString ||
      paymentConnectorList->Array.length == 0 ||
      isInternalUser}
      customSumbitButtonStyle="!mt-5 !w-full"
    />
  </Form>
}
