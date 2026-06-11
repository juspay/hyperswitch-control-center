@react.component
let make = (~themeId, ~orgId, ~merchantId, ~profileId) => {
  open ThemeCreateType
  open APIUtils
  open ThemeUpdateUtils
  open LogicUtils
  open Typography
  open ThemeFeatureUtils

  let internalSwitch = OMPSwitchHooks.useInternalSwitch()
  let lineage = ThemeCreateUtils.createLineage(
    ~orgId=orgId->Option.getOr(""),
    ~merchantId=merchantId->Option.getOr(""),
    ~profileId=profileId->Option.getOr(""),
  )
  let (initialValues, setInitialValues) = React.useState(() =>
    defaultCreate(~lineage)->Identity.genericTypeToJson
  )
  let {getUserInfo} = OMPSwitchHooks.useUserInfo()
  let {setApplicationState} = React.useContext(UserInfoProvider.defaultContext)
  let setThemeList = HyperswitchAtom.themeListAtom->Recoil.useSetRecoilState
  let (screenState, setScreenState) = React.useState(() => PageLoaderWrapper.Loading)
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let showToast = ToastState.useShowToast()
  let showPopUp = PopUpState.useShowPopUp()
  let updateDetails = useUpdateMethod(~showErrorToast=false)
  let processAssets = ThemeHooks.useProcessAssets()
  let (assets, setAssets) = React.useState(_ => Dict.make()->assetsMapper)
  let themeConfigVersion = HyperSwitchEntryUtils.getThemeConfigVersionfromStore()
  let getThemeByThemeId = async () => {
    try {
      let url = getURL(~entityName=V1(USERS), ~methodType=Get, ~id=Some(themeId), ~userType=#THEME)
      let res = await fetchDetails(url, ~version=UserInfoTypes.V1)
      let mappedTheme = res->themeBodyMapper
      let resDict = res->getDictFromJsonObject
      let urlsDict = resDict->getDictFromNestedDict("theme_data", "urls")
      let emailLogoUrl = resDict->getDictfromDict("email_config")->getString("entity_logo_url", "")
      if emailLogoUrl->isNonEmptyString {
        urlsDict->Dict.set("emailLogoUrl", emailLogoUrl->JSON.Encode.string)
      }
      setAssets(_ => urlsDict->assetsMapper)
      setInitialValues(_ => mappedTheme->Identity.genericTypeToJson)
      setScreenState(_ => Success)
    } catch {
    | Exn.Error(e) =>
      let err = Exn.message(e)->Option.getOr("Failed to switch!")
      Exn.raiseError(err)
    }
  }

  let loadPageData = async () => {
    try {
      let _ = await internalSwitch(
        ~expectedOrgId=orgId,
        ~expectedMerchantId=merchantId,
        ~expectedProfileId=profileId,
      )
      let _ = await getThemeByThemeId()
      setScreenState(_ => Success)
    } catch {
    | _ =>
      showToast(~message="Failed to fetch theme details", ~toastType=ToastState.ToastError)
      setScreenState(_ => Error("Failed to fetch theme details"))
    }
  }

  React.useEffect(() => {
    loadPageData()->ignore
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

      let url = getURL(
        ~entityName=V1(USERS),
        ~methodType=Get,
        ~queryParameters=Some(`entity_type=organization`),
        ~userType=#THEME_LIST,
      )
      let updatedThemeList = await fetchDetails(url, ~version=UserInfoTypes.V1)
      setThemeList(_ => updatedThemeList)

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
      let {theme_data: {settings}, email_config} = values->themeBodyMapper
      let processed = if (
        assets.logo->Option.isSome ||
        assets.favicon->Option.isSome ||
        assets.emailLogo->Option.isSome
      ) {
        await processAssets(~assets, ~themeId)
      } else {
        {urls: {logoUrl: None, faviconUrl: None}, emailLogoUrl: None}
      }

      let updatedEmailConfig =
        email_config->buildEmailConfigObject(~emailLogoUrl=processed.emailLogoUrl)

      let requestBody = buildThemeDataBody(
        ~settings,
        ~urls=processed.urls,
        ~emailConfig=updatedEmailConfig,
      )

      let updateUrl = getURL(
        ~entityName=V1(USERS),
        ~methodType=Put,
        ~id=Some(themeId),
        ~userType=#THEME,
      )

      let _ = await updateDetails(updateUrl, requestBody, Put)

      showToast(
        ~message="Theme updated successfully. Refresh the page to apply any changes.",
        ~toastType=ToastSuccess,
      )
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

  let tabs: array<Tabs.tab> = [
    {
      title: "Dashboard Config",
      renderContent: () =>
        <div className="grid grid-cols-1 mt-4 lg:grid-cols-3 gap-8">
          <div className="flex flex-col gap-2 max-h-750-px overflow-y-scroll show-scrollbar pr-2 ">
            <ThemeSettingsHelper.IconSettings
              mode={#Dashboard}
              assets
              onLogoSelect={file => setAssets(prev => {...prev, logo: Some(File(file))})}
              onLogoRemove={() => setAssets(prev => {...prev, logo: None})}
              onFaviconSelect={file => setAssets(prev => {...prev, favicon: Some(File(file))})}
              onFaviconRemove={() => setAssets(prev => {...prev, favicon: None})}
              themeConfigVersion
            />
            <ThemeSettings isUpdatePage=true />
          </div>
          <div className="flex flex-col gap-8 w-full lg:col-span-2">
            <div className={`${body.lg.semibold} mt-2`}> {React.string("Preview")} </div>
            <div className="border h-3/4 rounded-xl px-10 flex items-center relative ">
              <ThemeMockDashboard />
            </div>
            <ThemeUpdateHelper.ActionButtons handleDelete />
          </div>
        </div>,
    },
    {
      title: "Email Config",
      renderContent: () =>
        <div className="grid grid-cols-1 mt-4 lg:grid-cols-3 gap-8">
          <div className="flex flex-col gap-4 overflow-y-auto pr-2">
            <ThemeSettingsHelper.IconSettings
              mode=#Email
              assets
              onEmailLogoSelect={file => setAssets(prev => {...prev, emailLogo: Some(File(file))})}
              onEmailLogoRemove={() => setAssets(prev => {...prev, emailLogo: None})}
              themeConfigVersion
            />
            <ThemeSettingsHelper.EmailSettings />
          </div>
          <div className="flex flex-col gap-8 w-full lg:col-span-2">
            <div className={`${body.lg.semibold} mt-2`}> {React.string("Preview")} </div>
            <div className="border h-3/4 rounded-xl py-2 px-10 flex items-center relative">
              <ThemeMockEmail />
            </div>
            <ThemeUpdateHelper.ActionButtons handleDelete />
          </div>
        </div>,
    },
  ]

  <PageLoaderWrapper screenState={screenState}>
    <Form key={themeId} onSubmit initialValues>
      <div className="flex flex-col h-screen gap-8">
        <div className="flex flex-col flex-1 h-full">
          <PageUtils.PageHeading
            title="Theme Configuration"
            customTitleStyle="text-nd_gray-800"
            subTitle="Update your configuration."
            customSubTitleStyle={`${body.lg.medium} text-nd_gray-400 !opacity-100`}
          />
          <Tabs tabs />
        </div>
      </div>
    </Form>
  </PageLoaderWrapper>
}
