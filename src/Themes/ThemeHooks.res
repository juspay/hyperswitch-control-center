let useProcessAssets = () => {
  open GlobalVars
  open ThemeTypes

  let showToast = ToastState.useShowToast()
  let updateDetails = APIUtils.useUpdateMethod(~showErrorToast=false)
  let getURL = APIUtils.useGetURL()
  let processAsset = async (~asset: assetValue, ~fileName, ~assetUploadUrl, ~themeId): string =>
    switch asset {
    | Url(url) => url
    | File(file) => {
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
        `${getHostUrl}/themes/${themeId}/${fileName}`
      }
    }

  let toOptPromise = async (asset, fileName, assetUploadUrl, themeId) =>
    switch asset {
    | Some(a) => Some(await processAsset(~asset=a, ~fileName, ~assetUploadUrl, ~themeId))
    | None => None
    }

  let resolveUrl = (result, label) =>
    switch result {
    | Some(Ok(url)) => url
    | Some(Error(_)) =>
      showToast(~message=`Failed to upload ${label}`, ~toastType=ToastError)
      None
    | None => None
    }

  async (~assets: ThemeTypes.assets, ~themeId): HyperSwitchConfigTypes.urlThemeConfig => {
    let assetUploadUrl = getURL(
      ~entityName=V1(USERS),
      ~methodType=Post,
      ~id=Some(themeId),
      ~userType=#THEME_UPLOAD_ASSET,
    )

    let results = await PromiseUtils.allSettledResultPolyfill([
      toOptPromise(assets.logo, "logo.png", assetUploadUrl, themeId),
      toOptPromise(assets.favicon, "favicon.png", assetUploadUrl, themeId),
    ])

    let logoUrl = resolveUrl(results->Array.get(0), "logo")
    let faviconUrl = resolveUrl(results->Array.get(1), "favicon")

    let allFailed = results->Array.every(result =>
      switch result {
      | Error(_) => true
      | _ => false
      }
    )

    if allFailed {
      Exn.raiseError("Asset upload failed")
    }

    {logoUrl, faviconUrl}
  }
}
