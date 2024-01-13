open ProviderTypes

let defaultIntegrationValue = Dict.make()->Js.Json.object_->ProviderHelper.getIntegrationDetails
let defaultValue = {
  showFeedbackModal: false,
  setShowFeedbackModal: _ => (),
  showProdIntentForm: false,
  setShowProdIntentForm: _ => (),
  integrationDetails: defaultIntegrationValue,
  setIntegrationDetails: _ => (),
  dashboardPageState: #DEFAULT,
  setDashboardPageState: _ => (),
  permissionInfo: [],
  setPermissionInfo: _ => (),
  isProdIntentCompleted: false,
  setIsProdIntentCompleted: _ => (),
  quickStartPageState: QuickStartTypes.ConnectProcessor(LANDING),
  setQuickStartPageState: _ => (),
}

let defaultContext = React.createContext(defaultValue)

module Provider = {
  let make = React.Context.provider(defaultContext)
}

@react.component
let make = (~children) => {
  let (showFeedbackModal, setShowFeedbackModal) = React.useState(_ => false)
  let (showProdIntentForm, setShowProdIntentForm) = React.useState(_ => false)
  let (dashboardPageState, setDashboardPageState) = React.useState(_ => #DEFAULT)
  let (permissionInfo, setPermissionInfo) = React.useState(_ => [])
  let (isProdIntentCompleted, setIsProdIntentCompleted) = React.useState(_ => false)
  let (
    quickStartPageState,
    setQuickStartPageState,
  ) = React.useState(_ => QuickStartTypes.ConnectProcessor(LANDING))

  let (integrationDetails, setIntegrationDetails) = React.useState(_ =>
    Dict.make()->Js.Json.object_->ProviderHelper.getIntegrationDetails
  )

  <Provider
    value={
      showFeedbackModal,
      setShowFeedbackModal,
      setIntegrationDetails,
      integrationDetails,
      showProdIntentForm,
      setShowProdIntentForm,
      dashboardPageState,
      setDashboardPageState,
      permissionInfo,
      setPermissionInfo,
      isProdIntentCompleted,
      setIsProdIntentCompleted,
      quickStartPageState,
      setQuickStartPageState,
    }>
    children
  </Provider>
}
