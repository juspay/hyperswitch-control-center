// TODO: need refactor
let useDeleteTrackingDetails = () => {
  open APIUtils
  let updateDetails = useUpdateMethod(~showErrorToast=false)
  let getURL = useGetURL()
  async (connectorId, connector) => {
    try {
      let url = getURL(~entityName=RESET_TRACKING_ID, ~methodType=Post)
      let body =
        [
          ("connector_id", connectorId->JSON.Encode.string),
          ("connector", connector->JSON.Encode.string),
        ]->LogicUtils.getJsonFromArrayOfJson
      let _ = await updateDetails(url, body, Post)
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Failed to update!")
        Exn.raiseError(err)
      }
    }
  }
}

// TODO: need refactor
let useDeleteConnectorAccountDetails = () => {
  open LogicUtils
  open APIUtils
  let updateDetails = useUpdateMethod(~showErrorToast=false)
  let getURL = useGetURL()
  async (initialValues, connectorId, connector, isUpdateFlow, disabled, status) => {
    try {
      let dictOfJson = initialValues->getDictFromJsonObject
      let profileIdValue = dictOfJson->getString("profile_id", "")
      let body = PayPalFlowUtils.generateConnectorPayloadPayPal(
        ~profileId=profileIdValue,
        ~connectorId,
        ~connector,
        ~bodyType="TemporaryAuth",
        ~connectorLabel={
          dictOfJson->getString("connector_label", "")
        },
        ~disabled,
        ~status,
      )
      let url = getURL(
        ~entityName=CONNECTOR,
        ~methodType=Post,
        ~id=isUpdateFlow ? Some(connectorId) : None,
      )
      let res = await updateDetails(url, body, Post)
      res
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
        Exn.raiseError(err)
      }
    }
  }
}
