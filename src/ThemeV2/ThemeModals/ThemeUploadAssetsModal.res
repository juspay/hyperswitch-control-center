@react.component
let make = (~showModal, ~setShowModal, ~themeID, ~redirectToList) => {
  open Typography
  open APIUtils
  open LogicUtils
  let showToast = ToastState.useShowToast()
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod(~showErrorToast=false)
  let (screenState, setScreenState) = React.useState(() => PageLoaderWrapper.Loading)
  let fetchDetails = useGetMethod()
  let iconFileInput = (~input: ReactFinalForm.fieldRenderPropsInput, ~placeholder as _) => {
    <MultipleFileUpload
      input
      fileType=".png,.jpg,.jpeg"
      allowMultiFileSelect=false
      showUploadtoast=false
      widthClass="w-full"
      heightClass="h-20"
    />
  }

  let faviconFileInput = (~input: ReactFinalForm.fieldRenderPropsInput, ~placeholder as _) => {
    <MultipleFileUpload
      input
      fileType=".ico,.png"
      allowMultiFileSelect=false
      showUploadtoast=false
      widthClass="w-full"
      heightClass="h-20"
    />
  }

  let iconField = FormRenderer.makeFieldInfo(
    ~label="Icon",
    ~name="icon",
    ~customInput=iconFileInput,
    ~isRequired=true,
  )

  let faviconField = FormRenderer.makeFieldInfo(
    ~label="Favicon",
    ~name="favicon",
    ~customInput=faviconFileInput,
    ~isRequired=true,
  )

  let uploadAsset = async (~assetFile, ~assetName) => {
    let formData = FormDataUtils.formData()
    FormDataUtils.append(formData, "asset_name", assetName)
    FormDataUtils.append(formData, "asset_data", assetFile)
    let url = getURL(~entityName=V1(THEME_UPLOAD_ASSET), ~methodType=Post, ~id=Some(themeID))
    await updateDetails(
      ~bodyFormData=formData,
      ~headers=Dict.make(),
      url,
      Dict.make()->JSON.Encode.object,
      Post,
      ~contentType=AuthHooks.Unknown,
    )
  }
  let getThemeByThemeId = async () => {
    try {
      let url = getURL(~entityName=V1(THEME), ~methodType=Get, ~id=Some(`${themeID}`))
      let res = await fetchDetails(url, ~version=UserInfoTypes.V1)
      res
    } catch {
    | _ => JSON.Encode.null
    }
  }
  let updateThemeWithAssetUrls = async (~iconName, ~faviconName) => {
    let currentThemeData = await getThemeByThemeId()
    let baseUrl = GlobalVars.getHostUrl
    let iconUrl = `${baseUrl}/themes/${themeID}/${iconName}`
    let faviconUrl = `${baseUrl}/themes/${themeID}/${faviconName}`

    let currentThemeDict = currentThemeData->getDictFromJsonObject
    let currentThemeDataDict = currentThemeDict->getDictfromDict("theme_data")

    let updatedUrls = Dict.make()
    updatedUrls->Dict.set("logoUrl", iconUrl->JSON.Encode.string)
    updatedUrls->Dict.set("faviconUrl", faviconUrl->JSON.Encode.string)

    currentThemeDataDict->Dict.set("urls", updatedUrls->JSON.Encode.object)
    currentThemeDict->Dict.set("theme_data", currentThemeDataDict->JSON.Encode.object)

    let updateUrl = getURL(~entityName=V1(THEME), ~methodType=Put, ~id=Some(themeID))
    await updateDetails(updateUrl, currentThemeDict->JSON.Encode.object, Put)
  }

  let onSubmit = async (values, _) => {
    try {
      setScreenState(_ => Loading)

      let valuesDict = values->getDictFromJsonObject
      let iconFiles = valuesDict->getArrayFromDict("icon", [])
      let faviconFiles = valuesDict->getArrayFromDict("favicon", [])

      if iconFiles->Array.length > 0 && faviconFiles->Array.length > 0 {
        let iconFile = iconFiles->Array.get(0)->Option.getOr(JSON.Encode.null)
        let faviconFile = faviconFiles->Array.get(0)->Option.getOr(JSON.Encode.null)

        if iconFile !== JSON.Encode.null && faviconFile !== JSON.Encode.null {
          let iconName = "logo.png"
          let faviconName = "favicon.png"

          let _ = await uploadAsset(~assetFile=iconFile, ~assetName=iconName)
          let _ = await uploadAsset(~assetFile=faviconFile, ~assetName=faviconName)

          let _ = await updateThemeWithAssetUrls(~iconName, ~faviconName)

          showToast(
            ~message="Theme has been created with assets",
            ~toastType=ToastState.ToastSuccess,
          )
          setShowModal(_ => false)
          redirectToList()
        } else {
          showToast(
            ~message="Please select valid files for both icon and favicon",
            ~toastType=ToastState.ToastError,
          )
        }
      } else {
        showToast(
          ~message="Please upload both icon and favicon files",
          ~toastType=ToastState.ToastError,
        )
      }

      setScreenState(_ => Success)
    } catch {
    | Exn.Error(e) =>
      let err = Exn.message(e)->Option.getOr("Failed to upload assets!")
      showToast(~message=err, ~toastType=ToastState.ToastError)
      setScreenState(_ => Error("Failed to Upload theme assets."))
    }
    Nullable.null
  }

  let handleCancel = () => {
    setShowModal(_ => false)
    showToast(
      ~message="Theme has been created. You can upload assets later",
      ~toastType=ToastState.ToastInfo,
    )
    redirectToList()
  }

  <Form key="theme-upload-assets" onSubmit>
    <Modal
      showModal
      closeOnOutsideClick=false
      setShowModal
      modalHeading="Upload Assets"
      modalHeadingClass={`${heading.sm.semibold}`}
      modalClass="w-1/2 m-auto"
      childClass="p-0"
      modalHeadingDescriptionElement={<div className={`${body.md.medium} text-nd_gray-400 mt-2`}>
        {"Upload icon and favicon files for your theme."->React.string}
      </div>}>
      <div className="p-6 space-y-6">
        <div className="space-y-4">
          <FormRenderer.FieldRenderer
            field=iconField labelClass={`${body.md.medium} text-gray-700`}
          />
          <div className={`${body.sm.regular} text-gray-500`}>
            {"Supported formats: PNG, JPG, JPEG. Recommended size: 32x32px"->React.string}
          </div>
        </div>
        <div className="space-y-4">
          <FormRenderer.FieldRenderer
            field=faviconField labelClass={`${body.md.medium} text-gray-700`}
          />
          <div className={`${body.sm.regular} text-gray-500`}>
            {"Supported formats: ICO, PNG. Recommended size: 16x16px or 32x32px"->React.string}
          </div>
        </div>
        <div className="flex justify-end gap-3 pt-4 border-t border-gray-200">
          <Button
            text="Cancel"
            buttonType=Secondary
            buttonState=Normal
            buttonSize=Small
            onClick={_ => handleCancel()}
            customButtonStyle={`${body.md.semibold} py-2 px-4`}
          />
          <FormRenderer.SubmitButton
            text="Save & Upload"
            buttonType=Primary
            loadingText="Uploading..."
            buttonSize=Small
            customSumbitButtonStyle={`${body.md.semibold} py-2 px-4`}
          />
        </div>
      </div>
    </Modal>
  </Form>
}
