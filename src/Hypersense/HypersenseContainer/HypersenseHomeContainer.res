@react.component
let make = () => {
  open APIUtils
  open LogicUtils

  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let {hypersenseUrl} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

  let onCreatingMerchant = async () => {
    let hypersenseTokenUrl = getURL(
      ~entityName=V1(HYPERSENSE),
      ~methodType=Get,
      ~hypersenseType=#TOKEN,
    )
    let res = await fetchDetails(hypersenseTokenUrl)
    let token = res->getDictFromJsonObject->getString("token", "")
    Window.Location.replace(`${hypersenseUrl}/login?auth_token=${token}`)
  }

  React.useEffect0(() => {
    onCreatingMerchant()->ignore
    None
  })

  <HypersenseHome />
}
