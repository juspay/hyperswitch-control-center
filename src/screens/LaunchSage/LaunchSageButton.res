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
        let res = await updateDetails(url, JSON.Encode.object(Dict.make()), Post)
        let handoffUrl = res->getDictFromJsonObject->getString("handoff_url", "")
        if handoffUrl->String.length > 0 {
          Window.Location.assign(handoffUrl)
        }
      } catch {
      | Exn.Error(_) =>
        showToast(~toastType=ToastError, ~message="Launch failed; try again in a minute.")
      }
      setLoading(_ => false)
    }
  }

  <Button
    text="Launch Trace"
    buttonType=Transparent
    buttonState={loading ? Loading : Normal}
    leftIcon={CustomIcon(<Icon name="nd-sparkle" size=18 />)}
    onClick={_ => onClick()->ignore}
    customButtonStyle="!w-full !justify-start !px-3 !py-1.5 !mx-1"
  />
}
