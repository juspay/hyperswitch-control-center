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
  let processAsset = async (~asset, ~fileName, ~urlKey, ~urlsDict) => {
    switch asset {
    | Some(Url(url)) => urlsDict->Dict.set(urlKey, url->JSON.Encode.string)
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
      urlsDict->Dict.set(urlKey, `${getHostUrl}/themes/${themeId}/${fileName}`->JSON.Encode.string)
    | None => ()
    }
  }

  async (~assets: ThemeTypes.assets) => {
    try {
      let urlsDict = Dict.make()

      let (_, _) = await Promise.all2((
        processAsset(~asset=assets.logo, ~fileName="logo.png", ~urlKey="logoUrl", ~urlsDict),
        processAsset(
          ~asset=assets.favicon,
          ~fileName="favicon.png",
          ~urlKey="faviconUrl",
          ~urlsDict,
        ),
      ))

      urlsDict
    } catch {
    | _ => Exn.raiseError("Error uploading assets")
    }
  }
}
