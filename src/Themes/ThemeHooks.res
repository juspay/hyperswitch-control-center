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

      switch assets->getvalFromDict("logo") {
      | Some(value) =>
        let url = switch value->JSON.Decode.string {
        | Some(url) => url->JSON.Encode.string
        | None =>
          let formData = FormDataUtils.formData()
          FormDataUtils.append(formData, "asset_name", "logo.png")
          FormDataUtils.append(formData, "asset_data", Some(value))
          let _ = await updateDetails(
            assetUploadUrl,
            Dict.make()->JSON.Encode.object,
            Post,
            ~bodyFormData=formData,
            ~headers=Dict.make(),
            ~contentType=AuthHooks.Unknown,
          )
          `${baseUrl}/themes/${themeId}/logo.png`->JSON.Encode.string
        }
        urlsDict->Dict.set("logoUrl", url)
      | None => ()
      }

      switch assets->getvalFromDict("favicon") {
      | Some(value) =>
        let url = switch value->JSON.Decode.string {
        | Some(url) => url->JSON.Encode.string
        | None =>
          let formData = FormDataUtils.formData()
          FormDataUtils.append(formData, "asset_name", "favicon.png")
          FormDataUtils.append(formData, "asset_data", Some(value))
          let _ = await updateDetails(
            assetUploadUrl,
            Dict.make()->JSON.Encode.object,
            Post,
            ~bodyFormData=formData,
            ~headers=Dict.make(),
            ~contentType=AuthHooks.Unknown,
          )
          `${baseUrl}/themes/${themeId}/favicon.png`->JSON.Encode.string
        }
        urlsDict->Dict.set("faviconUrl", url)
      | None => ()
      }

      urlsDict
    } catch {
    | _ => Exn.raiseError("Error uploading assets")
    }
  }
}
