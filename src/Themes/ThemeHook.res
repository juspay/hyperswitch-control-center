open APIUtils
open APIUtilsTypes
let useFetchThemeList = (
  ~entityName=V1(USERS),
  ~version=UserInfoTypes.V1,
  ~userType=#THEME_LIST,
) => {
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let setThemeList = HyperswitchAtom.themeListAtom->Recoil.useSetRecoilState

  async _ => {
    try {
      let url = getURL(
        ~entityName,
        ~methodType=Get,
        ~queryParameters=Some(`entity_type=organization`),
        ~userType,
      )
      let res = await fetchDetails(url, ~version)
      setThemeList(_ => res)
      res
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
        Exn.raiseError(err)
      }
    }
  }
}
