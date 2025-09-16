@react.component
let make = (~setCurrentStep, ~connector, ~setInitialValues, ~initialValues, ~isUpdateFlow) => {
  open LogicUtils
  open ConnectorUtils
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let connectorDetails = React.useMemo(() => {
    try {
      if connector->isNonEmptyString {
        let dict = Window.getConnectorConfig(connector)
        setScreenState(_ => Success)
        dict
      } else {
        Dict.make()->JSON.Encode.object
      }
    } catch {
    | Exn.Error(e) => {
        Js.log2("FAILED TO LOAD CONNECTOR CONFIG", e)
        let err = Exn.message(e)->Option.getOr("Something went wrong")
        setScreenState(_ => PageLoaderWrapper.Error(err))
        Dict.make()->JSON.Encode.object
      }
    }
  }, [connector])
  let {connectorMetaDataFields} = getConnectorFields(connectorDetails)

  {
    switch connector->getConnectorNameTypeFromString {
    | Processors(PAYSAFE) => <PaySafe connectorMetaDataFields initialValues connector setInitialValues/>
    | _ => React.null
    }
  }
}
