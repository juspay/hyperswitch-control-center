open ProviderTypes
open SessionStorage

let defaultIntegrationValue = Dict.make()->JSON.Encode.object->ProviderHelper.getIntegrationDetails
let currentProductValue =
  sessionStorage.getItem("product")
  ->Nullable.toOption
  ->Option.getOr("Orchestrator")

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
  activeProduct: currentProductValue->ProductUtils.getVariantFromString,
  setActiveProductValue: _ => (),
  setDefaultProductToSessionStorage: _ => (),
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
  let (activeProduct, setActiveProduct) = React.useState(_ =>
    currentProductValue->ProductUtils.getVariantFromString
  )
  let (showSideBar, setShowSideBar) = React.useState(_ => true)
  let (integrationDetails, setIntegrationDetails) = React.useState(_ =>
    Dict.make()->JSON.Encode.object->ProviderHelper.getIntegrationDetails
  )

  let setActiveProductValue = product => {
    setActiveProduct(_ => product)
    sessionStorage.setItem("product", product->ProductUtils.getStringFromVariant)
  }

  let setDefaultProductToSessionStorage = productType => {
    open ProductUtils
    let currentSessionData = sessionStorage.getItem("product")->Nullable.toOption
    let data = switch currentSessionData {
    | Some(sessionData) => sessionData->getVariantFromString
    | None => productType
    }
    setActiveProductValue(data)
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
      activeProduct,
      setActiveProductValue,
      setDefaultProductToSessionStorage,
      showSideBar,
      setShowSideBar,
    }>
    children
  </Provider>
}
