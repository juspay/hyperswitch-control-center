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
let make = (~themeId) => {
  open ThemeCreateType
  open APIUtils
  open ThemeMapper
  open LogicUtils
  let {userInfo: {orgId, merchantId, profileId}} = React.useContext(UserInfoProvider.defaultContext)
  let lineage = createLineage(~orgId, ~merchantId, ~profileId)
  let (initialValues, setIntitalValues) = React.useState(() =>
    defaultCreate(~lineage)->Identity.genericTypeToJson
  )
  let (screenState, setScreenState) = React.useState(() => PageLoaderWrapper.Loading)
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let updateDetails = useUpdateMethod(~showErrorToast=false)
  let showToast = ToastState.useShowToast()
  let showPopUp = PopUpState.useShowPopUp()
  Js.log2("userinfo theme", themeId)
  let getThemeByThemeId = async () => {
    try {
      setScreenState(_ => Loading)
      let url = getURL(~entityName=V1(THEME), ~methodType=Get, ~id=Some(`${themeId}`))
      let res = await fetchDetails(url, ~version=UserInfoTypes.V1)
      setIntitalValues(_ => res->themeBodyMapper->Identity.genericTypeToJson)
      setScreenState(_ => Success)
    } catch {
    | _ => setScreenState(_ => Error("Failed to fetch theme details"))
    }
  }

  React.useEffect(() => {
    Js.log2("themeId in useEffect", themeId)
    getThemeByThemeId()->ignore
    None
  }, [])

  let deleteTheme = async () => {
    try {
      setScreenState(_ => Loading)
      let deleteUrl = getURL(~entityName=V1(THEME), ~methodType=Delete, ~id=Some(`${themeId}`))
      let _ = await updateDetails(deleteUrl, JSON.Encode.object(Dict.make()), Delete)
      RescriptReactRouter.push(GlobalVars.appendDashboardPath(~url="/themev2"))
      showToast(~message="Theme deleted successfully", ~toastType=ToastSuccess)
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

  let onSubmit = async (values, _form: ReactFinalForm.formApi) => {
    try {
      setScreenState(_ => Loading)
      let valuesDict = values->getDictFromJsonObject
      let themeDataDict = valuesDict->getDictfromDict("theme_data")
      let settingsDict = themeDataDict->getDictfromDict("settings")

      let requestBody =
        [
          ("theme_data", [("settings", settingsDict->JSON.Encode.object)]->getJsonFromArrayOfJson),
        ]->getJsonFromArrayOfJson

      let updateUrl = getURL(~entityName=V1(THEME), ~methodType=Put, ~id=Some(`${themeId}`))
      let _ = await updateDetails(updateUrl, requestBody, Put)
      showToast(~message="Theme updated successfully", ~toastType=ToastSuccess)
      setScreenState(_ => Success)
    } catch {
    | Exn.Error(e) => {
        setScreenState(_ => Success)
        showToast(~message="Failed to update theme", ~toastType=ToastError)
      }
    }
    Nullable.null
  }

  <Form key={themeId} onSubmit initialValues>
    <PageLoaderWrapper screenState={screenState}>
      <div className="flex flex-col h-screen gap-8">
        <div className="flex flex-col flex-1 h-full">
          <PageUtils.PageHeading
            title="Theme Configuration"
            subTitle="Update your configuration."
            customSubTitleStyle={`${body.lg.medium} text-nd_gray-400`}
          />
          <div className="grid grid-cols-1 mt-4 lg:grid-cols-3 gap-8">
            <ThemeSettingsV2 />
            <div className="flex flex-col gap-8 w-full lg:col-span-2">
              <div className={`${body.lg.semibold} mt-2`}> {React.string("Preview")} </div>
              <div className="border h-3/4 rounded-xl p-8 px-10 flex items-center relative">
                <div
                  className="absolute top-3 right-3 z-10 bg-white bg-opacity-80 rounded-full p-1 flex items-center justify-center shadow">
                  <Icon name="eye" size=18 className="text-gray-500 opacity-70" />
                </div>
                <ThemeMockDashboardV2 />
              </div>
              <ActionButtons handleDelete />
            </div>
          </div>
        </div>
      </div>
    </PageLoaderWrapper>
    // <FormValuesSpy />
  </Form>
}
