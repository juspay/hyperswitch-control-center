open Typography

@react.component
let make = () => {
  open ThemeCreateType
  open APIUtils
  open LogicUtils

  let {orgId, merchantId, profileId} = React.useContext(
    UserInfoProvider.defaultContext,
  ).getCommonSessionDetails()

  let getURL = useGetURL()
  let lineage = ThemeCreateUtils.createLineage(~orgId, ~merchantId, ~profileId)
  let showToast = ToastAdapter.useShowToast()
  let updateDetails = useUpdateMethod(~showErrorToast=false)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)
  let (showUploadModal, setShowUploadModal) = React.useState(_ => false)
  let (themeId, setThemeId) = React.useState(_ => "")
  let (initialValues, setInitialValues) = React.useState(() =>
    defaultCreate(~lineage)->Identity.genericTypeToJson
  )

  let redirectToList = () => {
    RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url="/theme"))
  }

  let onSubmit = async (values, _form: ReactFinalForm.formApi) => {
    try {
      setScreenState(_ => Loading)
      let themeURL = getURL(~entityName=V1(USERS), ~methodType=Post, ~id=None, ~userType=#THEME)
      let res = await updateDetails(themeURL, values, Post)
      let newThemeId = res->getDictFromJsonObject->getString("theme_id", "")
      setThemeId(_ => newThemeId)
      setInitialValues(_ => values)
      setScreenState(_ => Success)
      setShowUploadModal(_ => true)
    } catch {
    | _ => {
        showToast(~message="Failed to create theme.", ~toastType=ToastError)
        setScreenState(_ => Error("Failed to create theme."))
      }
    }
    Nullable.null
  }
  let submitButton =
    <div className="flex flex-row gap-4 justify-end w-full">
      <FormRenderer.SubmitButton
        text="Apply Theme"
        buttonType=Primary
        buttonSize={Small}
        customSubmitButtonStyle={`${body.md.semibold} py-4`}
      />
    </div>

  let infoBanner =
    <div
      className="flex gap-2 items-start border border-nd_yellow-500 bg-nd_yellow-50 p-3 rounded-lg">
      <Icon name="nd-info-circle" size=16 className="text-nd_gray-500" />
      <span className={`text-nd_gray-600 ${body.sm.regular}`}>
        {"Add your logo, favicon and email logo after clicking apply theme or update them later from theme settings."->React.string}
      </span>
    </div>

  let tabs: array<Tabs.tab> = [
    {
      title: "Dashboard Config",
      renderContent: () =>
        <div className="flex flex-col gap-4 mt-4">
          {infoBanner}
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
            <div
              className="self-start flex flex-col gap-4 h-62-vh lg:h-75-vh overflow-y-scroll theme-config-scrollbar p-4">
              <ThemeHelper.DashboardConfigScrollbarStyle />
              <ThemeSettings />
            </div>
            <div className="flex flex-col gap-8 w-full lg:col-span-2">
              <div className={`${body.lg.semibold} mt-2`}> {React.string("Preview")} </div>
              <div className="border h-48-vh md:h-55-vh rounded-xl p-8 flex items-center relative">
                <ThemeMockDashboard />
              </div>
              {submitButton}
            </div>
          </div>
        </div>,
    },
    {
      title: "Email Config",
      renderContent: () =>
        <div className="flex flex-col gap-4 mt-4">
          {infoBanner}
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
            <div
              className="self-start flex flex-col gap-4 h-75-vh lg:h-80-vh overflow-y-scroll theme-config-scrollbar p-4">
              <ThemeHelper.DashboardConfigScrollbarStyle />
              <ThemeSettingsHelper.EmailSettings />
            </div>
            <div className="flex flex-col gap-8 w-full lg:col-span-2">
              <div className={`${body.lg.semibold} mt-2`}> {React.string("Preview")} </div>
              <div className="border h-48-vh md:h-55-vh rounded-xl p-8 flex items-center relative">
                <ThemeMockEmail />
              </div>
              {submitButton}
            </div>
          </div>
        </div>,
    },
  ]

  <PageLoaderWrapper screenState>
    <Form onSubmit initialValues>
      <div className="flex flex-col gap-8">
        <div className="flex flex-col flex-1">
          <PageUtils.PageHeading title="Theme Configuration" customTitleStyle="text-nd_gray-800" />
          <Tabs tabs />
        </div>
      </div>
      <ThemeHelper.ThemeUploadAssetsModal
        showModal=showUploadModal setShowModal=setShowUploadModal themeId redirectToList
      />
    </Form>
  </PageLoaderWrapper>
}
