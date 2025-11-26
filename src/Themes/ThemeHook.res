open APIUtils
open APIUtilsTypes
let useFetchThemeList = (~entityName=V1(THEME_LIST), ~version=UserInfoTypes.V1) => {
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let setThemeList = HyperswitchAtom.themeListAtom->Recoil.useSetRecoilState

  async _ => {
    try {
      let url = getURL(
        ~entityName,
        ~methodType=Get,
        ~queryParamerters=Some(`entity_type=organization`),
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
