let useGetDefaultPath = () => {
  let isLiveMode = (HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom).isLiveMode

  if isLiveMode {
    "/v2/recovery/invoices"
  } else {
    "/v2/recovery/overview"
  }
}

/* Fetches the connectors that support MIT (mandates) from the hyperswitch backend
   feature matrix, restricted to the processors the dashboard can onboard.
   Falls back to the statically maintained recovery lists when the call fails or
   returns nothing usable. */
let useMitSupportedConnectors = () => {
  open APIUtils
  open APIUtilsTypes
  open LogicUtils

  let getURL = useGetURL()
  let fetchDetails = useGetMethod(~showErrorToast=false)
  let isLiveMode = (HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom).isLiveMode

  let fallbackConnectors = isLiveMode
    ? RecoveryConnectorUtils.recoveryConnectorProdList
    : RecoveryConnectorUtils.recoveryConnectorList

  let onboardableConnectorNames = React.useMemo(() => {
    let list = isLiveMode ? ConnectorUtils.connectorListForLive : ConnectorUtils.connectorList
    list->Array.map(ConnectorUtils.getConnectorNameString)
  }, [isLiveMode])

  let (connectors, setConnectors) = React.useState(_ => fallbackConnectors)
  let (isLoading, setIsLoading) = React.useState(_ => true)

  let fetchMitSupportedConnectors = async () => {
    try {
      setIsLoading(_ => true)
      let url = getURL(~entityName=V2(V2_FEATURE_MATRIX), ~methodType=Get)
      let response = await fetchDetails(url, ~version=UserInfoTypes.V2)

      let mitSupportedConnectors =
        response
        ->getDictFromJsonObject
        ->getArrayFromDict("connectors", [])
        ->Array.filterMap(connectorJson => {
          let connectorDict = connectorJson->getDictFromJsonObject
          let connectorName = connectorDict->getString("name", "")

          let supportsMandates =
            connectorDict
            ->getArrayFromDict("supported_payment_methods", [])
            ->Array.some(paymentMethodJson => {
              paymentMethodJson
              ->getDictFromJsonObject
              ->getString("mandates", "")
              ->String.toLowerCase === "supported"
            })

          if supportsMandates && onboardableConnectorNames->Array.includes(connectorName) {
            Some(connectorName->ConnectorUtils.getConnectorNameTypeFromString)
          } else {
            None
          }
        })

      setConnectors(_ =>
        mitSupportedConnectors->Array.length > 0 ? mitSupportedConnectors : fallbackConnectors
      )
      setIsLoading(_ => false)
    } catch {
    | _ => {
        setConnectors(_ => fallbackConnectors)
        setIsLoading(_ => false)
      }
    }
  }

  React.useEffect(() => {
    fetchMitSupportedConnectors()->ignore
    None
  }, [isLiveMode])

  (connectors, isLoading)
}
