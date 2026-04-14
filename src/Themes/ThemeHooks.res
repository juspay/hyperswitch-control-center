let useProcessAssets = (~themeId) => {
  open LogicUtils
  let updateDetails = APIUtils.useUpdateMethod(~showErrorToast=false)
  let getURL = APIUtils.useGetURL()
  let assetUploadUrl = getURL(
    ~entityName=V1(USERS),
    ~methodType=Post,
    ~id=Some(themeId),
    ~userType=#THEME_UPLOAD_ASSET,
  )

  async (~assets: Dict.t<JSON.t>) => {
    try {
      let urlsDict = Dict.make()
      let baseUrl = GlobalVars.getHostUrl

      let processAsset = async (~assetKey, ~fileName, ~urlKey) => {
        switch assets->getvalFromDict(assetKey) {
        | Some(value) =>
          let url = switch value->JSON.Decode.string {
          | Some(url) => url->JSON.Encode.string
          | None =>
            let formData = FormDataUtils.formData()
            FormDataUtils.append(formData, "asset_name", fileName)
            FormDataUtils.append(formData, "asset_data", Some(value))
            let _ = await updateDetails(
              assetUploadUrl,
              Dict.make()->JSON.Encode.object,
              Post,
              ~bodyFormData=formData,
              ~headers=Dict.make(),
              ~contentType=AuthHooks.Unknown,
            )
            `${baseUrl}/themes/${themeId}/${fileName}`->JSON.Encode.string
          }
          urlsDict->Dict.set(urlKey, url)
        | None => ()
        }
      }

      await processAsset(~assetKey="logo", ~fileName="logo.png", ~urlKey="logoUrl")
      await processAsset(~assetKey="favicon", ~fileName="favicon.png", ~urlKey="faviconUrl")

      urlsDict
    } catch {
    | _ => Exn.raiseError("Error uploading assets")
    }
  }
}
