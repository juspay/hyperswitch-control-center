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
type chat = {
  message: string,
  response: string,
}
@react.component
let make = () => {
  let fetchApiWindow = AuthHooks.useApiFetcher()
  let {xFeatureRoute, forceCookies} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let (html, setHtml) = React.useState(_ => "")
  let (loading, setLoading) = React.useState(_ => false)
  let (chat, setChat) = React.useState(_ => [])

  let onSubmit = async (values, form: ReactFinalForm.formApi) => {
    try {
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
      setChat(_ =>
        [
          ...chat,
          {
            message,
            response: html,
          },
        ]
      )
      setLoading(_ => false)
    } catch {
    | _ => setLoading(_ => false)
    }

    form.reset(JSON.Encode.object(Dict.make())->Nullable.make)

    Nullable.null
  }
  <>
    <RenderIf condition={html != ""}>
      <div />
      <div className="flex flex-col gap-2">
        {chat
        ->Array.map(item =>
          <div className="flex flex-col gap-1">
            <div className="text-hyperswitch_black font-semibold"> {"User:"->React.string} </div>
            <div className="text-hyperswitch_black"> {item.message->React.string} </div>
            <div className="text-hyperswitch_black font-semibold"> {"Bot:"->React.string} </div>
            // <div className="text-hyperswitch_black" dangerouslySetInnerHTML={item.response} />
            <Markdown.MDEditor value={item.response} hideToolbar=true preview="preview" />
          </div>
        )
        ->React.array}
      </div>
    </RenderIf>
    <Form
      initialValues={JSON.Encode.null}
      onSubmit={(values, f) => onSubmit(values, f)}
      formClass="h-full w-full">
      <div className="fixed bottom-6 w-[70%]">
        <ChatBot loading />
      </div>
      // <FormValuesSpy />
    </Form>
  </>
}
