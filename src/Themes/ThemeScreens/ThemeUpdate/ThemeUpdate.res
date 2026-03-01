open Typography
module ActionButtons = {
  @react.component
  let make = (~handleDelete) => {
    <div className="flex flex-row gap-4 justify-end w-full">
      <Button
        text="Delete Theme"
        buttonType=Secondary
        buttonState=Normal
        buttonSize=Small
        customButtonStyle={`${body.md.semibold} py-4`}
        onClick={_ => handleDelete()}
      />
      <FormRenderer.SubmitButton
        text="Update Theme"
        buttonType=Primary
        buttonSize={Small}
        customSumbitButtonStyle={`${body.md.semibold} py-4`}
        tooltipForWidthClass="w-full"
      />
    </div>
  }
}

@react.component
let make = (~themeId, ~orgId, ~merchantId, ~profileId) => {
  open ThemeCreateType
  open APIUtils
  open ThemeUpdateUtils
  open LogicUtils
  // let {orgId, merchantId, profileId} = React.useContext(
  //   UserInfoProvider.defaultContext,
  // ).getCommonSessionDetails()

  let internalSwitch = OMPSwitchHooks.useInternalSwitch()
  let lineage = createLineage(
    ~orgId=orgId->Option.getOr(""),
    ~merchantId=merchantId->Option.getOr(""),
    ~profileId=profileId->Option.getOr(""),
  )
  let (initialValues, setIntitalValues) = React.useState(() =>
    defaultCreate(~lineage)->Identity.genericTypeToJson
  )
  let {getUserInfo} = OMPSwitchHooks.useUserInfo()
  let {setApplicationState} = React.useContext(UserInfoProvider.defaultContext)
  let fetchDetails = useGetMethod()
  let (screenState, setScreenState) = React.useState(() => PageLoaderWrapper.Loading)
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let updateDetails = useUpdateMethod(~showErrorToast=false)
  let showToast = ToastState.useShowToast()
  let showPopUp = PopUpState.useShowPopUp()
  let {logoURL, faviconUrl, getThemesJson} = React.useContext(ThemeProvider.themeContext)
  let (selectedLogoFile, setSelectedLogoFile) = React.useState(_ => None)
  let (selectedFaviconFile, setSelectedFaviconFile) = React.useState(_ => None)
  let themeConfigVersion = HyperSwitchEntryUtils.getThemeConfigVersionfromStore()

  let getThemeByThemeId = async () => {
    try {
      setScreenState(_ => Loading)
      Js.log4("orgid and other", orgId, merchantId, profileId)
      let _ = await internalSwitch(
        ~expectedOrgId=orgId,
        ~expectedMerchantId=merchantId,
        ~expectedProfileId=profileId,
      )
      let url = getURL(
        ~entityName=V1(USERS),
        ~methodType=Get,
        ~id=Some(`${themeId}`),
        ~userType=#THEME,
      )
      let res = await fetchDetails(url, ~version=UserInfoTypes.V1)
      Js.log3("res", res, res->themeBodyMapper)
      setIntitalValues(_ => res->themeBodyMapper->Identity.genericTypeToJson)
      setScreenState(_ => Success)
    } catch {
    | _ => setScreenState(_ => Error("Failed to fetch theme details"))
    }
  }

  let uploadAsset = async (~assetFile, ~assetName) => {
    let formData = FormDataUtils.formData()
    FormDataUtils.append(formData, "asset_name", assetName)
    FormDataUtils.append(formData, "asset_data", assetFile)

    let url = getURL(
      ~entityName=V1(USERS),
      ~methodType=Post,
      ~id=Some(themeId),
      ~userType=#THEME_UPLOAD_ASSET,
    )

    await updateDetails(
      ~bodyFormData=formData,
      ~headers=Dict.make(),
      url,
      Dict.make()->JSON.Encode.object,
      Post,
      ~contentType=AuthHooks.Unknown,
    )
  }

  React.useEffect(() => {
    Js.log2("themeId in useEffect", themeId)
    getThemeByThemeId()->ignore
    None
  }, [])

  let deleteTheme = async () => {
    try {
      setScreenState(_ => Loading)
      let deleteUrl = getURL(
        ~entityName=V1(USERS),
        ~methodType=Delete,
        ~id=Some(`${themeId}`),
        ~userType=#THEME,
      )
      let _ = await updateDetails(deleteUrl, JSON.Encode.object(Dict.make()), Delete)
      let res = await getUserInfo()

      setApplicationState(_ => DashboardSession(res))

      showToast(~message="Theme deleted successfully", ~toastType=ToastSuccess)
      // setScreenState(_ => Success)
      RescriptReactRouter.push(GlobalVars.appendDashboardPath(~url="/theme"))
    } catch {
    | Exn.Error(e) => {
        setScreenState(_ => Success)
        showToast(~message="Failed to delete theme", ~toastType=ToastError)
      }
    }
  }

  let handleDelete = () => {
    showPopUp({
      popUpType: (Warning, WithIcon),
      heading: "Delete Theme",
      description: React.string(
        "Are you sure you want to delete this theme? This action cannot be undone.",
      ),
      handleConfirm: {
        text: "Delete",
        onClick: _ => deleteTheme()->ignore,
      },
      handleCancel: {text: "Cancel"},
    })
  }
  let redirectToList = () => {
    RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url="/theme"))
  }
  let onSubmit = async (values, _form: ReactFinalForm.formApi) => {
    try {
      setScreenState(_ => Loading)
      Js.log("update onsubmit called")
      let valuesDict = values->getDictFromJsonObject
      let iconName = "logo.png"
      let faviconName = "favicon.png"
      let iconUrl = `https://app.hyperswitch.io/themes/${themeId}/${iconName}`
      let faviconUrl = `https://app.hyperswitch.io/themes/${themeId}/${faviconName}`
      let urlsDict = Dict.make()

      // Upload logo if selected from form values
      if selectedLogoFile->Option.isSome {
        let _ = await uploadAsset(~assetFile=selectedLogoFile, ~assetName=iconName)
        urlsDict->Dict.set("logo_url", iconUrl)
      }
      if selectedFaviconFile->Option.isSome {
        let _ = await uploadAsset(~assetFile=selectedFaviconFile, ~assetName=faviconName)
        urlsDict->Dict.set("favicon_url", faviconUrl)
      }

      // Then update theme data (existing code)
      Js.log2("valuesDict", valuesDict)
      let themeDataDict = valuesDict->getDictfromDict("theme_data")
      let settingsDict = themeDataDict->getDictfromDict("settings")
      let urlsDict = themeDataDict->getDictfromDict("urls")
      Js.log2("urlsDict", urlsDict)

      let requestBody =
        [
          (
            "theme_data",
            Array.concat(
              [("settings", settingsDict->JSON.Encode.object)],
              [("urls", urlsDict->JSON.Encode.object)],
            )->getJsonFromArrayOfJson,
          ),
        ]->getJsonFromArrayOfJson

      let updateUrl = getURL(
        ~entityName=V1(USERS),
        ~methodType=Put,
        ~id=Some(`${themeId}`),
        ~userType=#THEME,
      )

      let _ = await updateDetails(updateUrl, requestBody, Put)

      // Reload theme to apply changes to dashboard
      // let {themeId: themeIdFromUserInfo} = await getUserInfo()
      // let _ = await getThemesJson(~themesID=Some(themeIdFromUserInfo))

      showToast(~message="Theme updated successfully", ~toastType=ToastSuccess)
      setScreenState(_ => Success)
      redirectToList()
    } catch {
    | Exn.Error(e) => {
        setScreenState(_ => Success)
        showToast(~message="Failed to update theme", ~toastType=ToastError)
      }
    }
    Nullable.null
  }
  <PageLoaderWrapper screenState={screenState}>
    <Form key={themeId} onSubmit initialValues>
      <div className="flex flex-col h-screen gap-8">
        <div className="flex flex-col flex-1 h-full">
          <PageUtils.PageHeading
            title="Theme Configuration"
            subTitle="Update your configuration."
            customSubTitleStyle={`${body.lg.medium} text-nd_gray-400`}
          />
          <div className="grid grid-cols-1 mt-4 lg:grid-cols-3 gap-8">
            <div className="flex flex-col gap-2 ">
              <ThemeSettingsHelper.IconSettings
                logoUrl={logoURL}
                faviconUrl
                themeId
                selectedLogoFile
                setSelectedLogoFile
                selectedFaviconFile
                setSelectedFaviconFile
                themeConfigVersion
              />
              <ThemeSettings />
            </div>
            <div className="flex flex-col gap-8 w-full lg:col-span-2">
              <div className={`${body.lg.semibold} mt-2`}> {React.string("Preview")} </div>
              <div className="border h-3/4 rounded-xl p-8 px-10 flex items-center relative">
                <div
                  className="absolute top-3 right-3 z-10 bg-white bg-opacity-80 rounded-full p-1 flex items-center justify-center shadow">
                  <Icon name="eye" size=18 className="text-gray-500 opacity-70" />
                </div>
                <ThemeMockDashboard />
              </div>
              <ActionButtons handleDelete />
            </div>
          </div>
        </div>
      </div>
      <FormValuesSpy />
    </Form>
  </PageLoaderWrapper>
}
