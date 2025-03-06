open ProviderTypes

let defaultIntegrationValue = Dict.make()->JSON.Encode.object->ProviderHelper.getIntegrationDetails

let defaultValue = {
  showFeedbackModal: false,
  setShowFeedbackModal: _ => (),
  showProdIntentForm: false,
  setShowProdIntentForm: _ => (),
  integrationDetails: defaultIntegrationValue,
  setIntegrationDetails: _ => (),
  dashboardPageState: #DEFAULT,
  setDashboardPageState: _ => (),
  // TODO: change this when custom role for user-management revamp is picked
  permissionInfo: [],
  setPermissionInfo: _ => (),
  isProdIntentCompleted: None,
  setIsProdIntentCompleted: _ => (),
  showSideBar: true,
  setShowSideBar: _ => (),
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
  let (isProdIntentCompleted, setIsProdIntentCompleted) = React.useState(_ => None)
  let (showSideBar, setShowSideBar) = React.useState(_ => true)
  let (integrationDetails, setIntegrationDetails) = React.useState(_ =>
    Dict.make()->JSON.Encode.object->ProviderHelper.getIntegrationDetails
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
      showSideBar,
      setShowSideBar,
    }>
    children
  </Provider>
}
