@react.component
let make = (~isFromMilestoneCard=false) => {
  open APIUtils
  open ProdVerifyModalUtils

  let fetchDetails = useGetMethod()

  let email = HSLocalStorage.getFromMerchantDetails("email")
  let {showProdIntentForm, setShowProdIntentForm, setIsProdIntentCompleted} = React.useContext(
    GlobalProvider.defaultContext,
  )
  let (initialValues, setInitialValues) = React.useState(_ => Dict.make())

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
        valueForProdIntent->Dict.set(POCemail->getStringFromVariant, email->Js.Json.string)
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
