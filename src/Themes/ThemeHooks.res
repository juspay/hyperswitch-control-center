let useProcessAssets = (~themeId) => {
  open GlobalVars
  open ThemeTypes
  let showToast = ToastState.useShowToast()
  let updateDetails = APIUtils.useUpdateMethod(~showErrorToast=false)
  let getURL = APIUtils.useGetURL()
  let assetUploadUrl = getURL(
    ~entityName=V1(USERS),
    ~methodType=Post,
    ~id=Some(themeId),
    ~userType=#THEME_UPLOAD_ASSET,
  )
  let uploadAsset = async (~file, ~fileName) => {
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
    Dict.make()->JSON.Encode.object
  }

  let processAsset = async (~asset, ~fileName): JSON.t =>
    switch asset {
    | Some(Url(_)) => Dict.make()->JSON.Encode.object
    | Some(File(file)) => await uploadAsset(~file, ~fileName)
    | None => JSON.Encode.null
    }

  async (~assets: ThemeTypes.assets): HyperSwitchConfigTypes.urlThemeConfig => {
    let results = await PromiseUtils.allSettledPolyfill([
      processAsset(~asset=assets.logo, ~fileName="logo.png"),
      processAsset(~asset=assets.favicon, ~fileName="favicon.png"),
    ])

    let resolveUrl = (index, label, fileName) => {
      switch results->Array.get(index)->Option.map(JSON.Classify.classify) {
      | Some(Object(_)) => (Some(`${getHostUrl}/themes/${themeId}/${fileName}`), false)
      | Some(String(_)) =>
        showToast(~message=`Failed to upload ${label}`, ~toastType=ToastError)
        (None, true)
      | _ => (None, false)
      }
    }

    let (logoUrl, logoFailed) = resolveUrl(0, "logo", "logo.png")
    let (faviconUrl, faviconFailed) = resolveUrl(1, "favicon", "favicon.png")

    if logoFailed && faviconFailed {
      Exn.raiseError("Asset upload failed")
    }

    {logoUrl, faviconUrl}
  }
}
