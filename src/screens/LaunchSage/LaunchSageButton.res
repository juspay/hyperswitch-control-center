open Typography

@react.component
let make = () => {
  open APIUtils
  open LogicUtils
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let showToast = ToastAdapter.useShowToast()
  let (loading, setLoading) = React.useState(_ => false)

  let onClick = async () => {
    if !loading {
      setLoading(_ => true)
      try {
        let url = getURL(~entityName=V1(USERS), ~userType=#LAUNCH_SAGE, ~methodType=Post)
        let res = await updateDetails(url, JSON.Encode.null, Post)
        let handoffUrl = res->getDictFromJsonObject->getString("handoff_url", "")
        if handoffUrl->isNonEmptyString {
          handoffUrl->Window._open
        }
      } catch {
      | Exn.Error(_) =>
        showToast(~toastType=ToastError, ~message="Launch failed; try again in a minute.")
      }
      setLoading(_ => false)
    }
  }

  <div
    onClick={_ => onClick()->ignore}
    className="flex items-center gap-2 px-3 py-2 rounded-lg border cursor-pointer  transition-all duration-200 shadow-sm relative hover:scale-105"
    style={ReactDOM.Style.make(
      ~background="linear-gradient(90deg, transparent 0%, #3b82f6 25%, transparent 50%, #3b82f6 75%, transparent 100%)",
      ~backgroundSize="200% 100%",
      ~animation="sparkleBorder 5s linear infinite",
      ~borderRadius="15px",
      ~padding="1px",
      (),
    )}>
    <div className="flex items-center gap-2 px-3 py-2 bg-nd_gray-100 dark:bg-gray-900 rounded-xl">
      <Icon name="stars" size=20 customIconColor="text-blue-500" />
      <span className={`${body.md.semibold} text-blue-500`}> {"Ask Sage"->React.string} </span>
    </div>
    <style>
      {React.string(
        "@keyframes sparkleBorder { 0% { background-position: 0% 0%; } 100% { background-position: 200% 0%; } }",
      )}
    </style>
  </div>
}
