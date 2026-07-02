@react.component
let make = () => {
  open APIUtils
  open LogicUtils
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let showToast = ToastAdapter.useShowToast()
  let (hidden, setHidden) = React.useState(_ => false)
  let (loading, setLoading) = React.useState(_ => false)

  let onClick = async () => {
    if !loading {
      setLoading(_ => true)
      try {
        let url = getURL(~entityName=V1(USERS), ~userType=#LAUNCH_SAGE, ~methodType=Post)
        let res = await updateDetails(url, JSON.Encode.object(Dict.make()), Post)
        let handoffUrl = res->getDictFromJsonObject->getString("handoff_url", "")
        if handoffUrl->String.length > 0 {
          Window.Location.assign(handoffUrl)
        } else {
          showToast(~toastType=ToastError, ~message="Launch failed; try again in a minute.")
        }
      } catch {
      | Exn.Error(e) =>
        let msg = Exn.message(e)->Option.getOr("")
        let status = try {
          msg->JSON.parseExn->getDictFromJsonObject->getInt("status_code", 0)
        } catch {
        | _ => 0
        }
        switch status {
        | 404 => setHidden(_ => true)
        | 401 => ()
        | 500 | 502 | 503 | 504 =>
          showToast(~toastType=ToastError, ~message="Launch failed; try again in a minute.")
        | _ => showToast(~toastType=ToastError, ~message="Something went wrong. Please try again.")
        }
      }
      setLoading(_ => false)
    }
  }

  <RenderIf condition={!hidden}>
    <div
      onClick={_ => onClick()->ignore}
      className="flex flex-row items-center gap-5 cursor-pointer rounded-lg px-3 py-1.5 mx-1 hover:bg-sidebar-hoverColor">
      <Icon size=18 name="nd-sparkle" />
      <div className="whitespace-nowrap"> {React.string("Launch Trace")} </div>
      <RenderIf condition=loading>
        <Icon name="spinner" size=14 className="ml-2 animate-spin" />
      </RenderIf>
    </div>
  </RenderIf>
}
