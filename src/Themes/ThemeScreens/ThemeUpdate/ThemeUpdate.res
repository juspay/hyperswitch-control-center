@react.component
let make = (~themeId, ~orgId, ~merchantId, ~profileId) => {
  open ThemeCreateType
  open APIUtils
  open ThemeUpdateUtils
  open LogicUtils
  open Typography

  let internalSwitch = OMPSwitchHooks.useInternalSwitch()
  let lineage = ThemeCreateUtils.createLineage(
    ~orgId=orgId->Option.getOr(""),
    ~merchantId=merchantId->Option.getOr(""),
    ~profileId=profileId->Option.getOr(""),
  )
  let (initialValues, setIntitalValues) = React.useState(() =>
    defaultCreate(~lineage)->Identity.genericTypeToJson
  )
  let {getUserInfo} = OMPSwitchHooks.useUserInfo()
  let {setApplicationState} = React.useContext(UserInfoProvider.defaultContext)
  let (screenState, setScreenState) = React.useState(() => PageLoaderWrapper.Loading)
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let updateDetails = useUpdateMethod(~showErrorToast=false)
  let showToast = ToastState.useShowToast()
  let showPopUp = PopUpState.useShowPopUp()
  let (logoAction, setLogoAction) = React.useState(_ => ThemeFeatureUtils.Unchanged)
  let (faviconAction, setFaviconAction) = React.useState(_ => ThemeFeatureUtils.Unchanged)
  let (originalLogoUrl, setOriginalLogoUrl) = React.useState(_ => None)
  let (originalFaviconUrl, setOriginalFaviconUrl) = React.useState(_ => None)
  let themeConfigVersion = HyperSwitchEntryUtils.getThemeConfigVersionfromStore()
  let getThemeByThemeId = async () => {
    try {
      setScreenState(_ => Loading)

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
      let mappedTheme = res->themeBodyMapper
      let themeUrls = mappedTheme.theme_data.urls
      setOriginalLogoUrl(_ => themeUrls.logoUrl)
      setOriginalFaviconUrl(_ => themeUrls.faviconUrl)
      setIntitalValues(_ => mappedTheme->Identity.genericTypeToJson)
      setScreenState(_ => Success)
    } catch {
    | _ => {
        showToast(~message="Failed to fetch theme details", ~toastType=ToastState.ToastError)
        setScreenState(_ => Error("Failed to fetch theme details"))
      }
    }
  }

  let assetUploadUrl = getURL(
    ~entityName=V1(USERS),
    ~methodType=Post,
    ~id=Some(themeId),
    ~userType=#THEME_UPLOAD_ASSET,
  )

  let uploadFn = async (~assetFile, ~assetName) => {
    let formData = FormDataUtils.formData()
    FormDataUtils.append(formData, "asset_name", assetName)
    FormDataUtils.append(formData, "asset_data", assetFile)
    await updateDetails(
      assetUploadUrl,
      Dict.make()->JSON.Encode.object,
      Post,
      ~bodyFormData=formData,
      ~headers=Dict.make(),
      ~contentType=AuthHooks.Unknown,
    )
  }

  React.useEffect(() => {
    getThemeByThemeId()->ignore
    None
  }, [])

  let deleteTheme = async () => {
    try {
      setScreenState(_ => Loading)
      let deleteUrl = getURL(
        ~entityName=V1(USERS),
        ~methodType=Delete,
        ~id=Some(themeId),
        ~userType=#THEME,
      )
      let _ = await updateDetails(deleteUrl, JSON.Encode.object(Dict.make()), Delete)
      let res = await getUserInfo()

      setApplicationState(_ => DashboardSession(res))

      showToast(~message="Theme deleted successfully", ~toastType=ToastSuccess)
      RescriptReactRouter.push(GlobalVars.appendDashboardPath(~url="/theme"))
    } catch {
    | _ => {
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
      let valuesDict = values->getDictFromJsonObject

      let urlsDict = await ThemeFeatureUtils.processAssets(
        ~logoAction,
        ~faviconAction,
        ~originalLogoUrl,
        ~originalFaviconUrl,
        ~uploadFn,
        ~themeId,
      )

      let settingsDict = valuesDict->getDictfromDict("theme_data")->getDictfromDict("settings")
      let requestBody = ThemeFeatureUtils.buildThemeDataBody(~settingsDict, ~urlsDict)

      let updateUrl = getURL(
        ~entityName=V1(USERS),
        ~methodType=Put,
        ~id=Some(`${themeId}`),
        ~userType=#THEME,
      )

      let _ = await updateDetails(updateUrl, requestBody, Put)

      showToast(~message="Theme updated successfully", ~toastType=ToastSuccess)
      setScreenState(_ => Success)
      redirectToList()
    } catch {
    | _ => {
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
            <div className="flex flex-col gap-2">
              <ThemeSettingsHelper.IconSettings
                originalLogoUrl
                originalFaviconUrl
                logoAction
                setLogoAction
                faviconAction
                setFaviconAction
                themeConfigVersion
              />
              <ThemeSettings />
            </div>
            <div className="flex flex-col gap-8 w-full lg:col-span-2">
              <div className={`${body.lg.semibold} mt-2`}> {React.string("Preview")} </div>
              <div className="border h-3/4 rounded-xl p-8 px-10 flex items-center relative">
                <div
                  className="absolute top-3 right-3 z-10 bg-white bg-opacity-80 rounded-full p-1 flex items-center justify-center shadow">
                  <Icon name="eye" size=18 className="text-nd_gray-500 opacity-70" />
                </div>
                <ThemeMockDashboard />
              </div>
              <ThemeUpdateHelper.ActionButtons handleDelete />
            </div>
          </div>
        </div>
      </div>
    </Form>
  </PageLoaderWrapper>
}
