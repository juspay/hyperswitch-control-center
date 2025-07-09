@react.component
let make = () => {
  open LogicUtils
  open ThemeListUtils
  open ThemeV2Types
  open Typography
  open ThemeHelper
  let getURL = APIUtils.useGetURL()
  let getMethod = APIUtils.useGetMethod()

  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)
  let themeList = Recoil.useRecoilValueFromAtom(HyperswitchAtom.themeListAtom)
  let themeId = HyperSwitchEntryUtils.getThemeIdfromStore()
  let (currentTheme, setCurrentTheme) = React.useState(_ => None)

  let themeListArray = themeList->LogicUtils.getArrayFromJson([])
  let (_, getNameForId) = OMPSwitchHooks.useOMPData()
  // let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()

  let fetchTheme = async (~id) => {
    try {
      let url = getURL(~entityName=V1(THEME), ~methodType=Get, ~id=Some(id))
      let res = await getMethod(url)
      setCurrentTheme(_ => Some(res))
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Theme doesn't exist for this Lineage.")
        Exn.raiseError(err)
      }
    }
  }

  React.useEffect(() => {
    switch themeId {
    | Some(id) if id->isNonEmptyString => fetchTheme(~id)->ignore
    | _ => ()
    }
    None
  }, [])

  // Helper function to render entity rows
  let renderEntityRow = (label, value, entityType) => {
    <React.Fragment key={label}>
      <div className="text-nd_gray-500"> {label->React.string} </div>
      <div>
        {value != "All" ? getNameForId(entityType)->React.string : `All ${label}s`->React.string}
      </div>
    </React.Fragment>
  }

  <PageLoaderWrapper screenState>
    <div className="flex flex-col h-screen gap-8">
      <div className="flex flex-col flex-1 h-full w-full">
        <div className="flex flex-row items-center justify-between w-full">
          <div className="flex-1">
            <PageUtils.PageHeading
              title="Theme Configuration"
              subTitle="Personalize your dashboard look with a live preview."
              customSubTitleStyle={`${body.lg.medium} text-nd_gray-400`}
            />
          </div>
          <div>
            <CreateNewThemeButton />
          </div>
        </div>
        <RenderIf condition={themeListArray->Array.length == 0}>
          <div />
          //create theme button triggering modal
        </RenderIf>
        <RenderIf condition={themeListArray->Array.length > 0}>
          {switch currentTheme {
          | None =>
            <div className="flex flex-col gap-2 my-4">
              <span className={`${body.lg.semibold} text-nd_gray-800`}>
                {"Current Theme"->React.string}
              </span>
              <div className={`text-nd_gray-500 ${body.lg.regular}`}>
                {"No active theme exists for this lineage. Please create a new theme to proceed."->React.string}
              </div>
            </div>
          | Some(themeObj) =>
            let themeData = extractThemeData(themeObj)
            let entityLevelLabel =
              themeData["entityType"]
              ->entityTypeToLevel
              ->entityLevelToLabel

            let entityConfig = [
              ("Organization", themeData["orgId"], #Organization),
              ("Merchant Account", themeData["merchantId"], #Merchant),
              ("Profile", themeData["profileId"], #Profile),
            ]

            <div className="flex flex-col gap-4 mt-4">
              <span className={`${body.lg.semibold} text-nd_gray-800`}>
                {"Current Theme"->React.string}
              </span>
              <div
                className="rounded-xl border border-gray-200 p-4 mb-8 flex flex-col gap-6 max-w-fit">
                <div className="flex items-center gap-4">
                  <span className={`${body.md.semibold}`}>
                    {themeData["themeName"]->React.string}
                  </span>
                  <span
                    className={`px-3 py-1 rounded-full bg-purple-100 text-purple-700 ${body.xs.semibold}`}>
                    {entityLevelLabel->React.string}
                  </span>
                </div>
                <div
                  className={`grid grid-cols-2 gap-y-2 gap-x-20 text-gray-600 ${body.md.medium}`}>
                  {entityConfig
                  ->Array.map(((label, value, entityType)) =>
                    renderEntityRow(label, value, entityType)
                  )
                  ->React.array}
                </div>
                <OverlappingCircles
                  colorA={themeData["primaryColor"]} colorB={themeData["sidebarColor"]}
                />
              </div>
            </div>
          }}
          <LoadedTable
            title="List of created themes"
            hideTitle=false
            actualData={themeListArray->Array.map(Nullable.make)}
            entity=ThemeEntity.themeTableEntity
            resultsPerPage=20
            showSerialNumber=true
            totalResults={themeListArray->Array.length}
            offset=0
            setOffset={_ => ()}
            currrentFetchCount={themeListArray->Array.length}
          />
        </RenderIf>
      </div>
    </div>
  </PageLoaderWrapper>
}
