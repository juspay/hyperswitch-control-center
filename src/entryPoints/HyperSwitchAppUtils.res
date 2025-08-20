let setupProductUrl = (
  ~productType: option<ProductTypes.productTypes>,
  ~url: RescriptReactRouter.url,
) => {
  let {isLiveMode} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

  let productUrl = ProductUtils.getProductUrl(
    ~productType=productType->Option.getOr(ProductTypes.Orchestration(V1)),
    ~isLiveMode,
  )
  RescriptReactRouter.replace(productUrl)

  switch url.path->HSwitchUtils.urlPath {
  | list{"unauthorized"} =>
    RescriptReactRouter.push(GlobalVars.appendDashboardPath(~url="/unauthorized"))
  | _ => ()
  }
}
