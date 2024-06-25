let useAuthMethods = () => {
  open APIUtils
  open LogicUtils
  let getURL = useGetURL()
  let fetchDetails = useGetMethod(~showErrorToast=false, ())
  async () => {
    try {
      let authId = HyperSwitchEntryUtils.getSessionData(~key="auth_id")
      let authListUrl = getURL(~entityName=USERS, ~userType=#GET_AUTH_LIST, ~methodType=Get, ())
      let listOfAuthMethods = await fetchDetails(`${authListUrl}?auth_id=${authId}`)
      let arrayFromJson = listOfAuthMethods->getArrayFromJson([])
      arrayFromJson
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
        Exn.raiseError(err)
      }
    }
  }
}
