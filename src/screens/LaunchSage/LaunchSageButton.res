// Sidebar launcher that mints a federated session on Hyperswitch BE
// via `POST /user/launch_sage` and full-page-navigates the browser to
// the returned one-shot handoff URL. HS BE derives everything from the
// caller's JWT — the request body is an empty JSON object.
//
// Gated by the `dev_launch_sage` feature flag; unrendered when off.
// On a 404 from the mint endpoint (flag off server-side), the button
// hides itself for the rest of the session so the sidebar doesn't keep
// showing a dead launcher.

@react.component
let make = () => {
  open APIUtils
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
        let handoffUrl =
          res->LogicUtils.getDictFromJsonObject->LogicUtils.getString("handoff_url", "")
        if handoffUrl->String.length > 0 {
          Window.Location.assign(handoffUrl)
        } else {
          showToast(
            ~toastType=ToastError,
            ~message="Launch failed; try again in a minute.",
          )
        }
      } catch {
      | Exn.Error(e) =>
        let msg = Exn.message(e)->Option.getOr("")
        // ``responseHandler`` throws a stringified JSON payload containing
        // ``status_code``. Non-JSON fallthrough means an infra error we
        // treat as generic.
        let status = try {
          msg->JSON.parseExn->LogicUtils.getDictFromJsonObject->LogicUtils.getInt("status_code", 0)
        } catch {
        | _ => 0
        }
        switch status {
        | 404 => setHidden(_ => true)
        | 401 => () // AuthHooks global 401 handler owns the redirect
        | 500 | 502 | 503 | 504 =>
          showToast(
            ~toastType=ToastError,
            ~message="Launch failed; try again in a minute.",
          )
        | _ =>
          showToast(
            ~toastType=ToastError,
            ~message="Something went wrong. Please try again.",
          )
        }
      }
      setLoading(_ => false)
    }
  }

  // Inline the icon-plus-label layout instead of reaching for
  // ``Sidebar.SidebarOption`` — the component is registered from
  // ``SidebarValues.res``, which is itself pulled in by
  // ``SidebarHooks.res``, and referencing back into ``Sidebar.res``
  // would close a module cycle
  //   SidebarHooks -> SidebarValues -> LaunchSageButton -> Sidebar -> SidebarHooks
  // that the ReScript build rejects.
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
