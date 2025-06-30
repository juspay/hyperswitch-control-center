let setupProductUrl = (
  ~productType: option<ProductTypes.productTypes>,
  ~url: RescriptReactRouter.url,
) => {
  let currentUrl = GlobalVars.extractModulePath(
    ~path=url.path,
    ~query=url.search,
    ~end=url.path->List.toArray->Array.length,
  )

  let productUrl = ProductUtils.getProductUrl(
    ~productType=productType->Option.getOr(ProductTypes.Orchestration(V1)),
    ~url=currentUrl,
  )
  RescriptReactRouter.replace(productUrl)

  switch url.path->HSwitchUtils.urlPath {
  | list{"unauthorized"} =>
    RescriptReactRouter.push(GlobalVars.appendDashboardPath(~url="/unauthorized"))
  | _ => ()
  }
}
