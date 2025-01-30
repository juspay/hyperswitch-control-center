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
  currentProduct: Orchestrator,
  setCurrentProductValue: _ => (),
  setDefaultProductToSessionStorage: _ => (),
}

let defaultContext = React.createContext(defaultValue)

module Provider = {
  let make = React.Context.provider(defaultContext)
}

@react.component
let make = (~children) => {
  open SessionStorage
  let (showFeedbackModal, setShowFeedbackModal) = React.useState(_ => false)
  let (showProdIntentForm, setShowProdIntentForm) = React.useState(_ => false)
  let (dashboardPageState, setDashboardPageState) = React.useState(_ => #DEFAULT)
  let (permissionInfo, setPermissionInfo) = React.useState(_ => [])
  let (isProdIntentCompleted, setIsProdIntentCompleted) = React.useState(_ => None)
  let (currentProduct, setCurrentProduct) = React.useState(_ => Orchestrator)
  let (integrationDetails, setIntegrationDetails) = React.useState(_ =>
    Dict.make()->JSON.Encode.object->ProviderHelper.getIntegrationDetails
  )

  let setCurrentProductValue = product => {
    setCurrentProduct(_ => product)
    sessionStorage.setItem("product", product->SidebarUtils.getStringFromVariant)
  }

  let setDefaultProductToSessionStorage = () => {
    open SidebarUtils
    let currentSessionData = sessionStorage.getItem("product")->Nullable.toOption
    let data = switch currentSessionData {
    | Some(sessionData) => sessionData->getVariantFromString
    | None => Orchestrator
    }

    setCurrentProductValue(data)
  }

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
      currentProduct,
      setCurrentProductValue,
      setDefaultProductToSessionStorage,
    }>
    children
  </Provider>
}
