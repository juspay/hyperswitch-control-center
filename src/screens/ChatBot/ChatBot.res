type response = {
  summary: string,
  markdown: string,
}
type chat = {
  message: string,
  response: response,
}

module ChatBot = {
  @react.component
  let make = (~loading) => {
    let form = ReactFinalForm.useForm()

    <div className="">
      <FormRenderer.FieldRenderer
        labelClass="sr-only"
        field={FormRenderer.makeFieldInfo(
          ~label="",
          ~description="",
          ~name="message",
          ~customInput=InputFields.textInput(
            ~customStyle="!border-nd_gray-150 dark:!border-nd_gray-700 !rounded-xl !py-6 !pl-4 !pr-14 !text-nd_gray-800 dark:!text-nd_gray-100 !bg-white dark:!bg-nd_gray-800 focus:!border-primary focus:!ring-2 focus:!ring-primary/20 !shadow-sm hover:!border-nd_gray-200 dark:hover:!border-nd_gray-600 transition-all duration-200",
            ~rightIcon={
              <div className="absolute right-2 top-1/2 transform -translate-y-1/2">
                <Button
                  buttonType=Primary
                  buttonSize=Small
                  buttonState={loading ? Loading : Normal}
                  customButtonStyle="!rounded-lg !w-6 !h-6 !p-0 !min-w-0 flex items-center justify-center"
                  onClick={_ => form.submit()->ignore}
                  rightIcon={loading ? NoIcon : FontAwesome("paper-plane")}
                />
              </div>
            },
          ),
          ~placeholder="Ask me anything about your payments...",
        )}
      />
    </div>
  }
}

module ChatMessage = {
  @react.component
  let make = (~message: string, ~response: response, ~isLatest: bool, ~loading: bool) => {
    let isTyping = isLatest && loading && response.markdown->LogicUtils.isEmptyString

    Js.log2("markdown", response.markdown)

    <div className="space-y-6">
      <div className="flex justify-end">
        <div
          className="max-w-860 bg-primary text-white rounded-2xl rounded-br-none px-4 py-3 shadow-sm">
          <p className="text-sm leading-relaxed break-words"> {message->React.string} </p>
        </div>
      </div>
      <div className="flex justify-start">
        <div className="flex space-x-3 w-full">
          <div
            className="flex-shrink-0 w-8 h-8 bg-gradient-to-br from-primary to-primary/80 rounded-full flex items-center justify-center shadow-sm">
            <Icon name="robot" size=16 customIconColor="text-white" />
          </div>
          <div className="flex-1 space-y-2">
            <RenderIf condition={response.summary->LogicUtils.isNonEmptyString}>
              <div
                className="bg-nd_gray-50 dark:bg-nd_gray-800 rounded-2xl rounded-tl-none px-4 py-3 border border-nd_gray-150 dark:border-nd_gray-700">
                <p className="text-sm text-nd_gray-700 dark:text-nd_gray-300 leading-relaxed">
                  {response.summary->React.string}
                </p>
              </div>
            </RenderIf>
            <RenderIf
              condition={!isTyping &&
              response.summary->LogicUtils.isEmptyString &&
              response.markdown->LogicUtils.isEmptyString}>
              <div
                className="bg-nd_gray-50 dark:bg-nd_gray-800 rounded-2xl rounded-tl-none px-4 py-3 border border-nd_gray-150 dark:border-nd_gray-700">
                <p className="text-sm text-nd_gray-700 dark:text-nd_gray-300 leading-relaxed">
                  {"Something went wrong, please try again."->React.string}
                </p>
              </div>
            </RenderIf>
            <RenderIf condition={isTyping || response.markdown->LogicUtils.isNonEmptyString}>
              <div
                className="bg-white dark:bg-nd_gray-800 rounded-2xl rounded-tl-none border border-nd_gray-150 dark:border-nd_gray-700 shadow-sm">
                <RenderIf condition={isTyping}>
                  <div className="px-4 py-6 flex items-center space-x-2">
                    <div className="flex space-x-1">
                      <div
                        className="w-2 h-2 bg-nd_gray-400 rounded-full animate-bounce"
                        style={ReactDOM.Style.make(~animationDelay="0ms", ())}
                      />
                      <div
                        className="w-2 h-2 bg-nd_gray-400 rounded-full animate-bounce"
                        style={ReactDOM.Style.make(~animationDelay="150ms", ())}
                      />
                      <div
                        className="w-2 h-2 bg-nd_gray-400 rounded-full animate-bounce"
                        style={ReactDOM.Style.make(~animationDelay="300ms", ())}
                      />
                    </div>
                  </div>
                </RenderIf>
                <RenderIf condition={!isTyping}>
                  <div className="max-w-none p-4 h-full">
                    <Markdown.MdPreview source={response.markdown} style={{fontSize: "14px"}} />
                  </div>
                </RenderIf>
              </div>
            </RenderIf>
          </div>
        </div>
      </div>
    </div>
  }
}

module EmptyState = {
  @react.component
  let make = () => {
    <div className="flex flex-col items-center justify-center h-full">
      <div
        className="w-16 h-16 bg-gradient-to-br from-primary/10 to-primary/5 rounded-2xl flex items-center justify-center mb-6">
        <Icon name="robot" size=32 customIconColor="text-primary" />
      </div>
      <h3 className="text-xl font-semibold text-nd_gray-800 dark:text-nd_gray-100 mb-2">
        {"Welcome to AI Assistant"->React.string}
      </h3>
      <p className="text-nd_gray-600 dark:text-nd_gray-400 text-center max-w-md leading-relaxed">
        {"I'm here to help you with questions about your payments, analytics, and platform features. Ask me anything!"->React.string}
      </p>
      <div className="mt-8 grid grid-cols-1 sm:grid-cols-2 gap-3 w-full max-w-lg">
        <div
          className="bg-nd_gray-50 dark:bg-nd_gray-800 rounded-lg p-3 border border-nd_gray-150 dark:border-nd_gray-700">
          <p className="text-sm text-nd_gray-700 dark:text-nd_gray-300">
            {"💳 \"Get me the 10 most recent successful payments \""->React.string}
          </p>
        </div>
        <div
          className="bg-nd_gray-50 dark:bg-nd_gray-800 rounded-lg p-3 border border-nd_gray-150 dark:border-nd_gray-700">
          <p className="text-sm text-nd_gray-700 dark:text-nd_gray-300">
            {"📊 \"Show me the payment trends for the last 30 days\""->React.string}
          </p>
        </div>
        <div
          className="bg-nd_gray-50 dark:bg-nd_gray-800 rounded-lg p-3 border border-nd_gray-150 dark:border-nd_gray-700">
          <p className="text-sm text-nd_gray-700 dark:text-nd_gray-300">
            {"⚙️ \"Give me the payment analytics for the last 7 days\""->React.string}
          </p>
        </div>
        <div
          className="bg-nd_gray-50 dark:bg-nd_gray-800 rounded-lg p-3 border border-nd_gray-150 dark:border-nd_gray-700">
          <p className="text-sm text-nd_gray-700 dark:text-nd_gray-300">
            {"🔍 \"Get me the 10 most recent failed payments?\""->React.string}
          </p>
        </div>
      </div>
    </div>
  }
}

@react.component
let make = () => {
  let fetchApiWindow = AuthHooks.useApiFetcher()
  let {xFeatureRoute, forceCookies} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let (loading, setLoading) = React.useState(_ => false)
  let (chat, setChat) = React.useState(_ => [])
  let chatContainerRef = React.useRef(Nullable.null)

  let scrollToBottom = () => {
    switch chatContainerRef.current->Nullable.toOption {
    | Some(element) =>
      element->Webapi.Dom.Element.setScrollTop(
        element->Webapi.Dom.Element.scrollHeight->Int.toFloat,
      )
    | None => ()
    }
  }

  React.useEffect(() => {
    if chat->Array.length > 0 {
      // Small delay to ensure DOM is updated
      let timeoutId = setTimeout(() => scrollToBottom(), 100)
      Some(() => clearTimeout(timeoutId))
    } else {
      None
    }
  }, [chat])

  let onSubmit = async (values, form: ReactFinalForm.formApi) => {
    let message = values->LogicUtils.getDictFromJsonObject->LogicUtils.getString("message", "")

    if message->String.trim->String.length === 0 {
      Nullable.null
    } else {
      form.reset(JSON.Encode.object(Dict.make())->Nullable.make)
      setChat(_ =>
        [
          ...chat,
          {
            message,
            response: {
              summary: "",
              markdown: "",
            },
          },
        ]
      )

      try {
        setLoading(_ => true)
        let res = await fetchApiWindow(
          `http://localhost:5678/webhook/n8n?message=${message}`,
          ~method_=Get,
          ~xFeatureRoute,
          ~forceCookies,
        )
        let response =
          (await res->(res => res->Fetch.Response.json))->LogicUtils.getDictFromJsonObject

        switch JSON.Classify.classify(response->LogicUtils.getJsonObjectFromDict("output")) {
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

      Nullable.null
    }
  }

  <div className="relative flex flex-col h-85-vh justify-between">
    <div className="px-6 py-4">
      <div className="flex items-center space-x-3">
        <div
          className="w-10 h-10 bg-gradient-to-br from-primary to-primary/80 rounded-full flex items-center justify-center">
          <Icon name="robot" size=20 customIconColor="text-white" />
        </div>
        <div>
          <h1 className="text-lg font-semibold text-nd_gray-800 dark:text-nd_gray-100">
            {"AI Assistant"->React.string}
          </h1>
        </div>
      </div>
    </div>
    <div className="p-6 h-80-vh overflow-y-auto" ref={chatContainerRef->ReactDOM.Ref.domRef}>
      <RenderIf condition={chat->Array.length === 0}>
        <EmptyState />
      </RenderIf>
      <RenderIf condition={chat->Array.length > 0}>
        <div className="w-full space-y-6 mb-16">
          {chat
          ->Array.mapWithIndex((item, index) => {
            let isLatest = index === chat->Array.length - 1
            <ChatMessage
              key={index->Int.toString}
              message={item.message}
              response={item.response}
              isLatest
              loading
            />
          })
          ->React.array}
        </div>
      </RenderIf>
    </div>
    <Form
      initialValues={JSON.Encode.null}
      onSubmit={(values, f) => onSubmit(values, f)}
      formClass="w-full">
      <div className="fixed bottom-4 w-77-rem">
        <ChatBot loading />
      </div>
      // <FormValuesSpy />
    </Form>
  </div>
}
