@react.component
let make = () => {
  open LogicUtils
  open Typography
  open ThemeHelper
  open ThemeListHelper

  let getURL = APIUtils.useGetURL()
  let getMethod = APIUtils.useGetMethod()

  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)
  let themeList = Recoil.useRecoilValueFromAtom(HyperswitchAtom.themeListAtom)
  let themeId = HyperSwitchEntryUtils.getThemeIdfromStore()
  let (currentTheme, setCurrentTheme) = React.useState(_ => None)
  let themeListArray = themeList->getArrayFromJson([])
  let (_, getNameForId) = OMPSwitchHooks.useOMPData()

  let fetchCurrentTheme = async (~id) => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let url = getURL(~entityName=V1(USERS), ~methodType=Get, ~id=Some(id), ~userType=#THEME)
      let res = await getMethod(url)
      setCurrentTheme(_ => Some(res))
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Theme doesn't exist for this Lineage.")
        Exn.raiseError(err)
      }
    }
  }

  React.useEffect(() => {
    switch themeId {
    | Some(id) if id->isNonEmptyString => fetchCurrentTheme(~id)->ignore
    | _ => ()
    }
    None
  }, [themeId])

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
          <RenderIf condition={themeListArray->Array.length > 0}>
            <div>
              <CreateNewThemeButton />
            </div>
          </RenderIf>
        </div>
        <NoThemesFound themeListArray />
        <RenderIf condition={themeListArray->Array.length > 0}>
          <CurrentThemeCard currentTheme getNameForId />
          <LoadedTable
            title="List of created themes"
            hideTitle=false
            actualData={themeListArray->Array.map(Nullable.make)}
            entity=ThemeListEntity.themeTableEntity
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
