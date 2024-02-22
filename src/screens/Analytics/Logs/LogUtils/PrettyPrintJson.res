open LogicUtils
@react.component
let make = (
  ~jsonToDisplay,
  ~headerText=None,
  ~maxHeightClass="max-h-25-rem",
  ~overrideBackgroundColor="bg-hyperswitch_background",
) => {
  let showToast = ToastState.useShowToast()
  let (isTextVisible, setIsTextVisible) = React.useState(_ => false)
  let (parsedJson, setParsedJson) = React.useState(_ => "")
  let parseJsonValue = () => {
    try {
      let parsedValue = jsonToDisplay->JSON.parseExn->JSON.stringifyWithIndent(3)
      setParsedJson(_ => parsedValue)
    } catch {
    | _ => setParsedJson(_ => jsonToDisplay)
    }
  }
  React.useEffect1(() => {
    parseJsonValue()->ignore
    None
  }, [jsonToDisplay])

  let handleOnClickCopy = (~parsedValue) => {
    Clipboard.writeText(parsedValue)
    showToast(~message="Copied to Clipboard!", ~toastType=ToastSuccess, ())
  }

  let copyParsedJson =
    <div onClick={_ => handleOnClickCopy(~parsedValue=parsedJson)} className="cursor-pointer">
      <Icon name="copy-code" />
    </div>

  <div className="flex flex-col gap-2">
    <UIUtils.RenderIf condition={parsedJson->isNonEmptyString}>
      {<>
        <UIUtils.RenderIf condition={headerText->Option.isSome}>
          <div className="flex justify-between items-center">
            <p className="font-bold text-fs-16 text-jp-gray-900 text-opacity-75">
              {headerText->Option.getOr("")->React.string}
            </p>
            {copyParsedJson}
          </div>
        </UIUtils.RenderIf>
        <div
          className={isTextVisible
            ? "overflow-visible "
            : `overflow-clip  h-fit ${maxHeightClass}`}>
          <ReactSyntaxHighlighter.SyntaxHighlighter
            style={ReactSyntaxHighlighter.lightfair}
            language="json"
            showLineNumbers={true}
            lineNumberContainerStyle={{
              paddingLeft: "0px",
              backgroundColor: "red",
              padding: "100px",
            }}
            customStyle={{
              backgroundColor: "transparent",
              lineHeight: "1.7rem",
              fontSize: "0.875rem",
              padding: "5px",
            }}>
            {parsedJson}
          </ReactSyntaxHighlighter.SyntaxHighlighter>
        </div>
        <Button
          text={isTextVisible ? "Hide" : "See more"}
          customButtonStyle="h-6 w-8 flex flex-1 justify-center m-1"
          onClick={_ => setIsTextVisible(_ => !isTextVisible)}
        />
      </>}
    </UIUtils.RenderIf>
    <UIUtils.RenderIf condition={parsedJson->isEmptyString}>
      <div className="flex flex-col justify-start items-start gap-2 h-25-rem">
        <p className="font-bold text-fs-16 text-jp-gray-900 text-opacity-75">
          {headerText->Option.getOr("")->React.string}
        </p>
        <p className="font-normal text-fs-14 text-jp-gray-900 text-opacity-50">
          {"Failed to load!"->React.string}
        </p>
      </div>
    </UIUtils.RenderIf>
  </div>
}
