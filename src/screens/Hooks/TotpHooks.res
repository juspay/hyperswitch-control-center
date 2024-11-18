let useVerifyTotp = () => {
  open APIUtils
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  async (body, methodType) => {
    try {
      let url = getURL(~entityName=USERS, ~userType=#VERIFY_TOTP, ~methodType)
      let response = await updateDetails(url, body, methodType)
      response
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
        Exn.raiseError(err)
      }
    }
  }
}

let useVerifyRecoveryCode = () => {
  open APIUtils
  open LogicUtils
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let showToast = ToastState.useShowToast()
  async body => {
    try {
      let url = getURL(~entityName=USERS, ~userType=#VERIFY_RECOVERY_CODE, ~methodType=Post)
      let response = await updateDetails(url, body, Post)
      response
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
        let errorCode = err->safeParse->getDictFromJsonObject->getString("code", "")
        let errorMessage = err->safeParse->getDictFromJsonObject->getString("message", "")
        if errorCode->CommonAuthUtils.errorSubCodeMapper == UR_39 {
          showToast(~message=errorMessage, ~toastType=ToastError)
        }
        Exn.raiseError(err)
      }
    }
  }
}
