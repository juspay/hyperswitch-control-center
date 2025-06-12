module ChatBot = {
  @react.component
  let make = (~loading) => {
    let form = ReactFinalForm.useForm()
    <FormRenderer.FieldRenderer
      labelClass="font-semibold !text-hyperswitch_black"
      field={FormRenderer.makeFieldInfo(
        ~label="Chat Bot",
        ~description="Chat Bot",
        ~name="message",
        ~customInput=InputFields.textInput(
          ~rightIcon={
            if loading {
              <div className={`animate-spin`}>
                <Icon name="spinner" size=13 />
              </div>
            } else {
              <Icon name="nd-arrow-up" size=13 onClick={_ => form.submit()->ignore} />
            }
          },
        ),
        ~placeholder=`Enter text`,
      )}
    />
  }
}
@react.component
let make = () => {
  let fetchApiWindow = AuthHooks.useApiFetcher()
  let {xFeatureRoute, forceCookies} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let (html, setHtml) = React.useState(_ => "")
  let (loading, setLoading) = React.useState(_ => false)
  let onSubmit = async values => {
    setLoading(_ => true)
    let message = values->LogicUtils.getDictFromJsonObject->LogicUtils.getString("message", "")
    let res = await fetchApiWindow(
      `http://0.0.0.0:8000/api/bot?message=${message}`,
      ~method_=Get,
      ~xFeatureRoute,
      ~forceCookies,
    )
    let response = await res->(res => res->Fetch.Response.json)
    let html = response->LogicUtils.getDictFromJsonObject->LogicUtils.getString("html", "")
    setHtml(_ => html)
    setLoading(_ => false)

    Nullable.null
  }

  <>
    <RenderIf condition={html != ""}>
      <Markdown.MDEditor value=html hideToolbar=true preview="preview" />
    </RenderIf>
    <Form initialValues={JSON.Encode.null} onSubmit={(values, _) => onSubmit(values)}>
      <ChatBot loading />
    </Form>
  </>
}
