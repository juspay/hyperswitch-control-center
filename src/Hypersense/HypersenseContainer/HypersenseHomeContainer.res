@react.component
let make = () => {
  open APIUtils
  open LogicUtils

  let getURL = useGetURL()
  let fetchDetails = useGetMethod()

  let onCreatingMerchant = async () => {
    let hypersenseTokenUrl = getURL(
      ~entityName=V1(HYPERSENSE),
      ~methodType=Get,
      ~hypersenseType=#TOKEN,
    )
    let res = await fetchDetails(hypersenseTokenUrl)
    let token = res->getDictFromJsonObject->getString("token", "")
    Window.Location.replace(`https://hypersense-sbx-2.netlify.app/login?auth_token=${token}`)
  }

  React.useEffect0(() => {
    onCreatingMerchant()->ignore
    None
  })

  <HypersenseHome />
}
