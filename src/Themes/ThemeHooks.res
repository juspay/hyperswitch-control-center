let useProcessAssets = () => {
  open GlobalVars
  open ThemeTypes

  let showToast = ToastState.useShowToast()
  let updateDetails = APIUtils.useUpdateMethod(~showErrorToast=false)
  let getURL = APIUtils.useGetURL()
  let uploadAsset = async (asset, fileName, themeId, assetUploadUrl) =>
    switch asset {
    | Some(Url(url)) => Some(url)
    | Some(File(file)) => {
        let formData = FormDataUtils.formData()
        FormDataUtils.append(formData, "asset_name", fileName)
        FormDataUtils.append(formData, "asset_data", Some(file))
        let _ = await updateDetails(
          assetUploadUrl,
          Dict.make()->JSON.Encode.object,
          Post,
          ~bodyFormData=formData,
          ~headers=Dict.make(),
          ~contentType=AuthHooks.Unknown,
        )
        Some(`${getHostUrl}/themes/${themeId}/${fileName}`)
      }
    | None => None
    }

  let resolve = (result, label) =>
    switch result {
    | Ok(url) => url
    | Error(_) =>
      showToast(~message=`Failed to upload ${label}`, ~toastType=ToastError)
      None
    }

  async (~assets: ThemeTypes.assets, ~themeId): HyperSwitchConfigTypes.urlThemeConfig => {
    let assetUploadUrl = getURL(
      ~entityName=V1(USERS),
      ~methodType=Post,
      ~id=Some(themeId),
      ~userType=#THEME_UPLOAD_ASSET,
    )

    let results = await PromiseUtils.allSettledResultPolyfill([
      uploadAsset(assets.logo, "logo.png", themeId, assetUploadUrl),
      uploadAsset(assets.favicon, "favicon.png", themeId, assetUploadUrl),
    ])

    let logoResult = results->Array.get(0)->Option.getOr(Error("logo"))
    let faviconResult = results->Array.get(1)->Option.getOr(Error("favicon"))

    let logoUrl = resolve(logoResult, "logo")
    let faviconUrl = resolve(faviconResult, "favicon")

    if results->Array.every(Result.isError) {
      Exn.raiseError("Asset upload failed")
    }

    {logoUrl, faviconUrl}
  }
}
