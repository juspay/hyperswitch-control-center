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
type response = {
  summary: string,
  markdown: string,
}
type chat = {
  message: string,
  response: response,
}
@react.component
let make = () => {
  let fetchApiWindow = AuthHooks.useApiFetcher()
  let {xFeatureRoute, forceCookies} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let (markdown, setMarkdown) = React.useState(_ => "")
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
      let response =
        (await res->(res => res->Fetch.Response.json))->LogicUtils.getDictFromJsonObject

      switch JSON.Classify.classify(response->LogicUtils.getJsonObjectFromDict("data")) {
      | Object(dict) =>
        let summary = dict->LogicUtils.getString("summary", "")
        let markdown = dict->LogicUtils.getString("markdown", "")
        setChat(_ =>
          [
            ...chat,
            {
              message,
              response: {
                summary,
                markdown,
              },
            },
          ]
        )
      | String(str) =>
        setChat(_ =>
          [
            ...chat,
            {
              message,
              response: {
                summary: "",
                markdown: str,
              },
            },
          ]
        )
      | _ =>
        setChat(_ =>
          [
            ...chat,
            {
              message,
              response: {
                summary: "",
                markdown: "Error: Invalid response format",
              },
            },
          ]
        )
      }

      setLoading(_ => false)
    } catch {
    | _ => setLoading(_ => false)
    }

    form.reset(JSON.Encode.object(Dict.make())->Nullable.make)

    Nullable.null
  }
  <>
    <RenderIf condition={chat->Array.length > 0}>
      <div />
      <div className="flex flex-col gap-2">
        {chat
        ->Array.mapWithIndex((item, index) =>
          <div key={index->Int.toString} className="flex flex-col gap-1">
            <div className="text-hyperswitch_black font-semibold"> {"User:"->React.string} </div>
            <div className="text-hyperswitch_black"> {item.message->React.string} </div>
            <div className="text-hyperswitch_black font-semibold"> {"Bot:"->React.string} </div>
            <div className="text-hyperswitch_black"> {item.response.summary->React.string} </div>
            <Markdown.MDEditor value={item.response.markdown} hideToolbar=true preview="preview" />
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
