@react.component
let make = (~isFromMilestoneCard=false) => {
  open APIUtils
  open ProdVerifyModalUtils
  open CommonAuthHooks
  let fetchDetails = useGetMethod()
  let getURL = useGetURL()
  let {email} = useCommonAuthInfo()->Option.getOr(defaultAuthInfo)
  let {showProdIntentForm, setShowProdIntentForm, setIsProdIntentCompleted} = React.useContext(
    GlobalProvider.defaultContext,
  )
  let {userInfo: {merchantId}} = React.useContext(UserInfoProvider.defaultContext)
  let (initialValues, setInitialValues) = React.useState(_ => Dict.make())

  let getProdVerifyDetails = async () => {
    open LogicUtils
    try {
      let url = getURL(
        ~entityName=V1(USERS),
        ~userType=#USER_DATA,
        ~methodType=Get,
        ~queryParamerters=Some(`keys=ProdIntent`),
      )
      let res = await fetchDetails(url)
      let firstValueFromArray = res->getArrayFromJson([])->getValueFromArray(0, JSON.Encode.null)
      let valueForProdIntent =
        firstValueFromArray->getDictFromJsonObject->getDictfromDict("ProdIntent")
      let hideHeader = valueForProdIntent->getBool(IsCompleted->getStringFromVariant, false)
      if !hideHeader {
        valueForProdIntent->Dict.set(POCemail->getStringFromVariant, email->JSON.Encode.string)
      }
      setIsProdIntentCompleted(_ => Some(hideHeader))
      setInitialValues(_ => valueForProdIntent)
    } catch {
    | _ => ()
    }
  }

  React.useEffect(() => {
    getProdVerifyDetails()->ignore
    None
  }, [merchantId])

  <ProdVerifyModal
    showModal={showProdIntentForm}
    setShowModal={setShowProdIntentForm}
    initialValues
    getProdVerifyDetails
  />
}
