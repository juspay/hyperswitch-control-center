let useProcessAssets = (~themeId) => {
  open GlobalVars
  open ThemeTypes
  let updateDetails = APIUtils.useUpdateMethod(~showErrorToast=false)
  let getURL = APIUtils.useGetURL()
  let assetUploadUrl = getURL(
    ~entityName=V1(USERS),
    ~methodType=Post,
    ~id=Some(themeId),
    ~userType=#THEME_UPLOAD_ASSET,
  )
  let processAsset = async (~asset, ~fileName): option<string> => {
    switch asset {
    | Some(Url(url)) => Some(url)
    | Some(File(file)) =>
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
    | None => None
    }
  }

  async (~assets: ThemeTypes.assets): HyperSwitchConfigTypes.urlThemeConfig => {
    try {
      let (logoUrl, faviconUrl) = await Promise.all2((
        processAsset(~asset=assets.logo, ~fileName="logo.png"),
        processAsset(~asset=assets.favicon, ~fileName="favicon.png"),
      ))
      {logoUrl, faviconUrl}
    } catch {
    | _ => Exn.raiseError("Error uploading assets")
    }
  }
}
