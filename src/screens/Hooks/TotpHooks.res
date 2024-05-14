let useBeginTotp = () => {
  open APIUtils
  open LogicUtils
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  async _ => {
    try {
      let url = getURL(~entityName=USERS, ~userType=#BEGIN_TOTP, ~methodType=Get, ())
      let response = await fetchDetails(url)
      let dict = response->getDictFromJsonObject->getJsonObjectFromDict("secret")
      dict
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
        Exn.raiseError(err)
      }
    }
  }
}

let useVerifyTotp = () => {
  open APIUtils
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  async body => {
    try {
      let url = getURL(~entityName=USERS, ~userType=#VERIFY_TOTP, ~methodType=Get, ())
      let response = await updateDetails(url, body, Post, ())
      response
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
        Exn.raiseError(err)
      }
    }
  }
}
