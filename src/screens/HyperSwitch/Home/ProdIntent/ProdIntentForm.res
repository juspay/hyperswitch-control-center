@react.component
let make = (~isFromMilestoneCard=false) => {
  open APIUtils
  open ProdVerifyModalUtils

  let fetchDetails = useGetMethod()
  let updateDetails = useUpdateMethod()

  let email = HSLocalStorage.getFromMerchantDetails("email")
  let {
    showProdIntentForm,
    setShowProdIntentForm,
    dashboardPageState,
    integrationDetails,
    setIntegrationDetails,
    setIsProdIntentCompleted,
  } = React.useContext(GlobalProvider.defaultContext)
  let (initialValues, setInitialValues) = React.useState(_ => Js.Dict.empty())

  let markAsDone = async () => {
    try {
      let url = getURL(~entityName=INTEGRATION_DETAILS, ~methodType=Post, ())
      let body = HSwitchUtils.constructOnboardingBody(
        ~dashboardPageState,
        ~integrationDetails,
        ~is_done=true,
        (),
      )
      let _ = await updateDetails(url, body, Post)
      setIntegrationDetails(_ => body->ProviderHelper.getIntegrationDetails)
    } catch {
    | _ => ()
    }
  }

  let getProdVerifyDetails = async () => {
    open LogicUtils
    try {
      let url = `${getURL(
          ~entityName=USERS,
          ~userType=#USER_DATA,
          ~methodType=Get,
          (),
        )}?keys=ProdIntent`
      let res = await fetchDetails(url)
      let firstValueFromArray = res->getArrayFromJson([])->getValueFromArray(0, Js.Json.null)
      let valueForProdIntent =
        firstValueFromArray->getDictFromJsonObject->getDictfromDict("ProdIntent")
      let hideHeader = valueForProdIntent->getBool(IsCompleted->getStringFromVariant, false)
      setIsProdIntentCompleted(_ => hideHeader)
      if !hideHeader {
        valueForProdIntent->Js.Dict.set(POCemail->getStringFromVariant, email->Js.Json.string)
      } else if !integrationDetails.account_activation.is_done {
        markAsDone()->ignore
      }
      setInitialValues(_ => valueForProdIntent)
    } catch {
    | _ => ()
    }
  }

  React.useEffect0(() => {
    getProdVerifyDetails()->ignore
    None
  })

  <ProdVerifyModal
    showModal={showProdIntentForm}
    setShowModal={setShowProdIntentForm}
    initialValues
    getProdVerifyDetails
  />
}
