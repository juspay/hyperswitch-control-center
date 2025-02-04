@react.component
let make = () => {
  open PageLoaderWrapper

  let url = RescriptReactRouter.useUrl()

  let connectorID = HSwitchUtils.getConnectorIDFromUrl(url.path->List.toArray, "")
  let (screenState, setScreenState) = React.useState(_ => Loading)
  let (initialValues, setInitialValues) = React.useState(_ => Dict.make()->JSON.Encode.object)

  let onSubmit = async (values, _form: ReactFinalForm.formApi) => {
    Js.log(values)
    Nullable.null
  }

  <div>
    <p> {"Authenticate your processor"->React.string} </p>
    <p>
      {"Configure your credentials from your processor dashboard. Hyperswitch encrypts and stores these credentials securely."->React.string}
    </p>
    <Form onSubmit initialValues>
      <ConnectorAuthKeys initialValues setInitialValues showVertically=true />
      <FormValuesSpy />
      <FormRenderer.SubmitButton text="Submit" buttonSize={Small} />
    </Form>
  </div>
}
