open APIUtils
open AlertsUtils

let useAlertsList = () => {
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod(~showErrorToast=false)

  async (~limit, ~offset, ~startTime, ~endTime, ~filterValueJson, ~isResolved, ~onTotalCount=?) => {
    try {
      let url = getURL(~entityName=V1(ALERTS), ~methodType=Post, ~alertsType=#ALERTS_LIST)
      let body = buildListBody(~limit, ~offset, ~startTime, ~endTime, ~filterValueJson, ~isResolved)
      let onRawResponse = res => {
        let totalCount =
          res
          ->Fetch.Response.headers
          ->Fetch.Headers.get("x-total-count")
          ->Option.flatMap(str => str->Int.fromString)
          ->Option.getOr(0)
        onTotalCount->Option.forEach(fn => fn(totalCount))
      }
      let response = await updateDetails(url, body, Post, ~onRawResponse)
      response->alertsResponseMapper
    } catch {
    | Exn.Error(e) => Exn.raiseError(Exn.message(e)->Option.getOr("Failed to fetch alerts"))
    }
  }
}

let useAlertDetails = () => {
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod(~showErrorToast=false)

  async (~id) => {
    try {
      let url = getURL(~entityName=V1(ALERTS), ~methodType=Post, ~alertsType=#ALERTS_DETAILS)
      let body = [("id", id->JSON.Encode.string)]->LogicUtils.getJsonFromArrayOfJson
      let response = await updateDetails(url, body, Post)
      response->responseToAlertDetail
    } catch {
    | Exn.Error(e) => Exn.raiseError(Exn.message(e)->Option.getOr("Failed to fetch alert"))
    }
  }
}

let useSaveAlertConfig = () => {
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod(~showErrorToast=false)

  async (~body: JSON.t) => {
    try {
      let url = getURL(~entityName=V1(ALERTS), ~methodType=Post, ~alertsType=#ALERTS_SAVE)
      let _ = await updateDetails(url, body, Post)
    } catch {
    | Exn.Error(e) => Exn.raiseError(Exn.message(e)->Option.getOr("Failed to save alert"))
    }
  }
}

let useAlertsDictionary = () => {
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod(~showErrorToast=false)

  async () => {
    try {
      let url = getURL(~entityName=V1(ALERTS), ~methodType=Post, ~alertsType=#ALERTS_DICTIONARY)
      let body = [("name", "dashboard"->JSON.Encode.string)]->LogicUtils.getJsonFromArrayOfJson
      let response = await updateDetails(url, body, Post)
      response->alertsDictionaryResponseMapper
    } catch {
    | Exn.Error(e) =>
      Exn.raiseError(Exn.message(e)->Option.getOr("Failed to fetch alerts dictionary"))
    }
  }
}

// Internal view-only users and internal admins can act on alerts
let useAlertsManageAccess = (): CommonAuthTypes.authorization => {
  let {roleId} = React.useContext(UserInfoProvider.defaultContext).getResolvedUserInfo()
  roleId->HyperSwitchUtils.checkIsInternalUser ? Access : NoAccess
}
