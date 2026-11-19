open BlocklistUtils
open BlocklistTypes
open LogicUtils
open APIUtils
open BlocklistHelper

@react.component
let make = (~transactionType: blocklistTransactionType, ~onExportStarted) => {
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod(~showErrorToast=false)
  let showToast = ToastAdapter.useShowToast()
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let (exportButtonState, setExportButtonState) = React.useState(_ => Button.Normal)

  let transactionLabel = (transactionType :> string)

  let generateExport = async () => {
    try {
      setExportButtonState(_ => Button.Loading)
      let url = getURL(
        ~entityName=V1(BLOCKLIST_EXPORT),
        ~methodType=Post,
        ~queryParameters=Some(transactionType->blocklistTransactionTypeQueryParam),
      )
      let response = await updateDetails(url, Dict.make()->JSON.Encode.object, Post)
      let fileName = response->getDictFromJsonObject->getString("file_name", "")
      let message =
        fileName->isNonEmptyString
          ? `Blocklist export started. File: ${fileName}`
          : "Blocklist export started."
      showToast(~message, ~toastType=ToastSuccess)
      onExportStarted()
    } catch {
    | Exn.Error(e) =>
      let errorMessage =
        Exn.message(e)
        ->Option.getOr("Failed to generate blocklist export")
        ->parseBlocklistErrorMessage
      showToast(~message=errorMessage, ~toastType=ToastError)
    }
    setExportButtonState(_ => Button.Normal)
  }

  let onGenerateExportClick = _ => {
    mixpanelEvent(
      ~eventName="blocklist_generate_export",
      ~metadata=[
        ("transaction_type", (transactionType :> string)->JSON.Encode.string),
      ]->getJsonFromArrayOfJson,
    )
    generateExport()->ignore
  }

  <Panel>
    <PanelHeader
      title="Export as CSV"
      description={`Generates a CSV of every ${transactionLabel} entry on this profile. Download it from Background jobs once it completes.`}
      action={<ACLButton
        text="Generate Export"
        buttonType=Secondary
        onClick=onGenerateExportClick
        buttonState=exportButtonState
        authorization={userHasAccess(~groupAccess=AccountManage)}
      />}
    />
  </Panel>
}
