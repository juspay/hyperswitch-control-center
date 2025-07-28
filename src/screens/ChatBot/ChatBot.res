open ChatBotTypes
open Typography
module ChatBot = {
  @react.component
  let make = (~loading, ~onNewChat) => {
    let form = ReactFinalForm.useForm()

    <div className="">
      <FormRenderer.FieldRenderer
        labelClass="sr-only"
        field={FormRenderer.makeFieldInfo(
          ~label="",
          ~description="",
          ~name="message",
          ~customInput=InputFields.textInput(
            ~customStyle="!border-nd_gray-150 dark:!border-nd_gray-700 !rounded-xl !py-6 !pl-12 !pr-14 !text-nd_gray-800 dark:!text-nd_gray-100 !bg-white dark:!bg-nd_gray-800 focus:!border-primary focus:!ring-2 focus:!ring-primary/20 !shadow-sm hover:!border-nd_gray-200 dark:hover:!border-nd_gray-600 transition-all duration-200",
            ~leftIcon={
              <div
                onClick={_ => onNewChat()}
                className="border border-nd_gray-500 p-1.5 rounded-full cursor-pointer">
                <Icon name="plus" size=16 customIconColor="text-nd_gray-900" />
              </div>
            },
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
          <div className="flex-1 space-y-2 min-w-0">
            <RenderIf condition={response.summary->LogicUtils.isNonEmptyString}>
              <div
                className="bg-nd_gray-50 dark:bg-nd_gray-800 rounded-2xl rounded-tl-none px-4 py-3 border border-nd_gray-150 dark:border-nd_gray-700">
                <p className={`text-nd_gray-700 dark:text-nd_gray-300 ${body.md.regular}`}>
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
                <div className={`text-nd_gray-700 dark:text-nd_gray-300 ${body.md.regular}`}>
                  <p className="mb-2">
                    {"I\'m having trouble understanding which data you need."->React.string}
                  </p>
                </div>
              </div>
            </RenderIf>
            <RenderIf condition={isTyping || response.markdown->LogicUtils.isNonEmptyString}>
              <div
                className="bg-white dark:bg-nd_gray-800 rounded-2xl rounded-tl-none border border-nd_gray-150 dark:border-nd_gray-700 shadow-sm min-w-0">
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
                  <div
                    className="px-7 py-4 max-h-96 overflow-auto overscroll-contain min-w-0 w-full">
                    <div className="min-w-max">
                      <Markdown.MdPreview source={response.markdown} style={{fontSize: "14px"}} />
                    </div>
                  </div>
                </RenderIf>
              </div>
            </RenderIf>
            <RenderIf condition={!isTyping && response.responseTime->Option.isSome}>
              <div className="flex justify-start mt-1">
                <div className="text-xs text-nd_gray-500 px-2 py-1 flex items-center space-x-1">
                  <Icon
                    name="clock" size=10 customIconColor="text-nd_gray-500 dark:text-nd_gray-400"
                  />
                  <span>
                    {switch response.responseTime {
                    | Some(time) =>
                      if time < 1.0 {
                        `Responded in ${(time *. 1000.0)
                          ->Float.toString
                          ->String.slice(~start=0, ~end=3)}ms`
                      } else {
                        `Responded in ${time->Float.toString->String.slice(~start=0, ~end=4)}s`
                      }
                    | None => "Response time unavailable"
                    }->React.string}
                  </span>
                </div>
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
  let make = (~onQuestionClick) => {
    let questions = [
      (
        "💳 Get me the 10 most recent successful payments",
        "Get me the 10 most recent successful payments",
      ),
      (
        "📊 Show me the payment trends for the last 30 days",
        "Show me the payment trends for the last 30 days",
      ),
      (
        "⚙️ Give me the payment analytics for the last 7 days",
        "Give me the payment analytics for the last 7 days",
      ),
      (
        "🔍 Get me the 10 most recent failed payments?",
        "Get me the 10 most recent failed payments?",
      ),
    ]

    <div className="flex flex-col items-center justify-center h-full px-6 py-8">
      // Header Section
      <div className="text-center mb-8">
        <h2 className="text-2xl font-bold text-nd_gray-800 dark:text-nd_gray-100 mb-3">
          {"Welcome to Data Assistant"->React.string}
        </h2>
        <p
          className="text-nd_gray-600 dark:text-nd_gray-400 text-center max-w-lg leading-relaxed text-base">
          {"Ask questions about your payments, refunds, and analytics. Get instant insights without writing any SQL queries."->React.string}
        </p>
      </div>
      // Example Questions Section
      <div className="w-full max-w-2xl">
        <div className="text-center mb-6">
          <h3 className="text-lg font-semibold text-nd_gray-800 dark:text-nd_gray-100 mb-2">
            {"Try these examples"->React.string}
          </h3>
          <p className="text-sm text-nd_gray-500 dark:text-nd_gray-400">
            {"Click on any question below to get started"->React.string}
          </p>
        </div>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {questions
          ->Array.mapWithIndex(((displayText, messageText), index) => {
            <div
              key={index->Int.toString}
              className="group bg-white dark:bg-nd_gray-800 rounded-xl p-4 border border-nd_gray-200 dark:border-nd_gray-600 cursor-pointer hover:border-primary hover:bg-primary/5 dark:hover:bg-primary/10 hover:shadow-md transition-all duration-200"
              onClick={_ => onQuestionClick(messageText)}>
              <div className="flex items-start space-x-3">
                <div
                  className="flex-shrink-0 w-8 h-8 bg-primary/10 rounded-lg flex items-center justify-center group-hover:bg-primary/20 transition-colors duration-200">
                  <span className="text-lg">
                    {displayText->String.slice(~start=0, ~end=2)->React.string}
                  </span>
                </div>
                <div className="flex-1">
                  <p
                    className="text-sm font-medium text-nd_gray-700 dark:text-nd_gray-300 group-hover:text-primary transition-colors duration-200 leading-relaxed">
                    {displayText->String.sliceToEnd(~start=2)->React.string}
                  </p>
                </div>
              </div>
            </div>
          })
          ->React.array}
        </div>
      </div>
      // Footer Section
      <div className="mt-8 text-center">
        <p className="text-xs text-nd_gray-500 dark:text-nd_gray-400">
          {"Or type your own question in the input field below"->React.string}
        </p>
      </div>
    </div>
  }
}

@react.component
let make = () => {
  open APIUtils
  open SessionStorage
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let (loading, setLoading) = React.useState(_ => false)
  let (chat, setChat) = React.useState(_ => [])
  let chatContainerRef = React.useRef(Nullable.null)

  let generateNewSession = () => {
    let sessionKey = "chatbot_session_id"
    let newId = LogicUtils.randomString(~length=32)
    sessionStorage.setItem(sessionKey, newId)
  }

  React.useEffect(() => {
    generateNewSession()
    None
  }, [])

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
      let timeoutId = setTimeout(() => scrollToBottom(), 100)
      Some(() => clearTimeout(timeoutId))
    } else {
      None
    }
  }, [chat])

  let submitMessage = async (message: string) => {
    if message->String.trim->String.length === 0 {
      ()
    } else {
      setChat(_ =>
        [
          ...chat,
          {
            message,
            response: {
              summary: "",
              markdown: "",
              responseTime: None,
            },
          },
        ]
      )

      try {
        let dict = [("message", message->JSON.Encode.string)]->LogicUtils.getJsonFromArrayOfJson
        setLoading(_ => true)

        let startTime = Date.now()
        let url = getURL(~entityName=V1(CHAT_BOT), ~methodType=Post)
        let res = await updateDetails(url, dict, Post)
        let response = res->LogicUtils.getDictFromJsonObject

        let endTime = Date.now()
        let responseTime = (endTime -. startTime) /. 1000.0 // Convert to seconds

        switch JSON.Classify.classify(response->LogicUtils.getJsonObjectFromDict("response")) {
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
                  responseTime: Some(responseTime),
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
                  responseTime: Some(responseTime),
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
                  responseTime: Some(responseTime),
                },
              },
            ]
          )
        }

        setLoading(_ => false)
      } catch {
      | _ => setLoading(_ => false)
      }
    }
  }

  let onSubmit = async (values, form: ReactFinalForm.formApi) => {
    let message = values->LogicUtils.getDictFromJsonObject->LogicUtils.getString("message", "")

    if message->String.trim->String.length === 0 {
      Nullable.null
    } else {
      form.reset(JSON.Encode.object(Dict.make())->Nullable.make)
      await submitMessage(message)
      Nullable.null
    }
  }

  let onQuestionClick = (question: string) => {
    submitMessage(question)->ignore
  }

  let onNewChat = () => {
    setChat(_ => [])
    generateNewSession()
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
            {"Data Assistant"->React.string}
          </h1>
        </div>
      </div>
    </div>
    <div className="h-80-vh overflow-y-auto" ref={chatContainerRef->ReactDOM.Ref.domRef}>
      <RenderIf condition={chat->Array.length === 0}>
        <EmptyState onQuestionClick />
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
        <ChatBot loading onNewChat />
      </div>
      // <FormValuesSpy />
    </Form>
  </div>
}
