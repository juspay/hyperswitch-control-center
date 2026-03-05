open Typography

@react.component
let make = () => {
  open ThemeCreateType
  open APIUtils

  let {orgId, merchantId, profileId} = React.useContext(
    UserInfoProvider.defaultContext,
  ).getCommonSessionDetails()

  let getURL = useGetURL()
  let lineage = ThemeCreateUtils.createLineage(~orgId, ~merchantId, ~profileId)
  let showToast = ToastState.useShowToast()
  let updateDetails = useUpdateMethod(~showErrorToast=false)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)

  let redirectToList = () => {
    RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url="/theme"))
  }

  let onSubmit = async (values, _form: ReactFinalForm.formApi) => {
    try {
      setScreenState(_ => Loading)
      let themeURL = getURL(~entityName=V1(USERS), ~methodType=Post, ~id=None, ~userType=#THEME)
      let _ = await updateDetails(themeURL, values, Post)
      setScreenState(_ => Success)
      redirectToList()
    } catch {
    | _ => {
        showToast(~message="Failed to create theme.", ~toastType=ToastError)
        setScreenState(_ => Error("Failed to create theme."))
      }
    }
    Nullable.null
  }

  <PageLoaderWrapper screenState>
    <Form onSubmit initialValues={defaultCreate(~lineage)->Identity.genericTypeToJson}>
      <div className="flex flex-col h-screen gap-8">
        <div className="flex flex-col flex-1 h-full">
          <PageUtils.PageHeading
            title="Theme Configuration"
            subTitle="Personalize your dashboard look with a live preview."
            customSubTitleStyle={`${body.lg.medium} text-nd_gray-400`}
          />
          <div className="grid grid-cols-1 mt-4 lg:grid-cols-3 gap-8">
            <ThemeSettings />
            <div className="flex flex-col gap-8 w-full lg:col-span-2">
              <div className={`${body.lg.semibold} mt-2`}> {React.string("Preview")} </div>
              <div className="border h-3/4 rounded-xl p-8 px-10 flex items-center relative">
                <div
                  className="absolute top-3 right-3 z-10 bg-white bg-opacity-80 rounded-full p-1 flex items-center justify-center shadow">
                  <Icon name="eye" size=18 className="text-nd_gray-500 opacity-70" />
                </div>
                <ThemeMockDashboard />
              </div>
              <div className="flex flex-row gap-4 justify-end w-full">
                <FormRenderer.SubmitButton
                  text="Apply Theme"
                  buttonType=Primary
                  buttonSize={Small}
                  customSumbitButtonStyle={`${body.md.semibold} py-4`}
                  tooltipForWidthClass="w-full"
                />
              </div>
            </div>
          </div>
        </div>
      </div>
    </Form>
  </PageLoaderWrapper>
}
