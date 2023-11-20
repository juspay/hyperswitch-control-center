open Button
type buttonProp = {
  text?: string,
  onClick: ReactEvent.Mouse.t => unit,
  icon: iconType,
  buttontype?: buttonType,
  buttonState?: buttonState,
  showBorder?: bool,
}

@react.component
let make = (~btnProps: array<buttonProp>) => {
  let noOfBtns = btnProps->Js.Array2.length
  let iconSize = 14
  let (showButtons, setShowButtons) = React.useState(_ => false)
  let (isGrowUp, setIsGrowUp) = React.useState(_ => false)
  let btnRef = React.useRef(Js.Nullable.null)
  let plusIconOnClick = _ => {
    setShowButtons(prev => !prev)
    Js.Global.setTimeout(() => {
      setIsGrowUp(prev => !prev)
    }, 100)->ignore
  }
  OutsideClick.useOutsideClick(
    ~refs=ArrayOfRef([btnRef]),
    ~isActive=showButtons,
    ~callback=() => {
      plusIconOnClick()
    },
    (),
  )

  let getCursorType = (buttonProp: buttonProp) => {
    let buttonState = buttonProp.buttonState->Belt.Option.getWithDefault(Normal)
    switch buttonState {
    | Loading => "cursor-wait"
    | Disabled => "cursor-not-allowed"
    | _ => "cursor-pointer"
    }
  }

  let getIconElement = (buttonProp: buttonProp) => {
    let buttonType = buttonProp.buttontype->Belt.Option.getWithDefault(Primary)
    let buttonState = buttonProp.buttonState->Belt.Option.getWithDefault(Normal)
    let showBorder = buttonProp.showBorder->Belt.Option.getWithDefault(true)
    let bgColor = useGetBgColor(~buttonType, ~buttonState, ~showBorder, ())
    let textColor = useGetTextColor(~buttonType, ~buttonState, ~showBorder, ())
    let cursorType = getCursorType(buttonProp)
    let iconClassName = `${bgColor} p-4 rounded-full ${cursorType} select-none w-fit z-10`
    let buttonState = buttonProp.buttonState->Belt.Option.getWithDefault(Normal)
    let onClick = switch buttonState {
    | Loading
    | Disabled =>
      _ => ()
    | _ => buttonProp.onClick
    }
    <div className=iconClassName onClick>
      {switch buttonProp.icon {
      | FontAwesome(name) => <Icon name className=textColor size=iconSize />
      | Euler(name) => <Icon name className=textColor size=iconSize />
      | CustomIcon(iconElement)
      | CustomRightIcon(iconElement) => iconElement
      | NoIcon => React.null
      }}
    </div>
  }

  let iconBgColor = useGetBgColor(~buttonType=Primary, ~buttonState=Normal, ~showBorder=true, ())
  let iconTextColor = useGetTextColor(
    ~buttonType=Primary,
    ~buttonState=Normal,
    ~showBorder=true,
    (),
  )
  let fixedClass = `fixed bottom-10 right-10 items-end transition duration-500`
  let style = index => {
    let translateY = ((index + 1) * 60)->Belt.Int.toString ++ "px"
    let zIndex = noOfBtns - 1 - index
    ReactDOMStyle.make(
      ~transform={showButtons ? `translateY(-${translateY})` : `translateY(0px)`},
      ~zIndex={zIndex->Belt.Int.toString},
      (),
    )
  }

  <div>
    {btnProps
    ->Js.Array2.mapi((buttonProp, index) => {
      let buttonType = buttonProp.buttontype->Belt.Option.getWithDefault(Primary)
      let buttonState = buttonProp.buttonState->Belt.Option.getWithDefault(Normal)
      let showBorder = buttonProp.showBorder->Belt.Option.getWithDefault(true)
      let bgColor = useGetBgColor(~buttonType, ~buttonState, ~showBorder, ())
      let textColor = useGetTextColor(~buttonType, ~buttonState, ~showBorder, ())

      <div
        className={`${fixedClass} rounded-full cursor-pointer select-none w-fit`}
        style={style(index)}>
        <div className="flex flex-row items-center justify-center gap-2">
          {switch buttonProp.text {
          | Some(btnText) => {
              let newFixed = "fixed right-0 items-end"
              let translateX = isGrowUp ? "translateX(-60px)" : "translateX(0px)"
              let widthHeightClass = isGrowUp ? "px-3 py-2" : "w-0 h-0"
              let btnText = isGrowUp ? btnText : ""

              <div
                style={ReactDOMStyle.make(~transform=translateX, ())}
                className={`${newFixed} ${widthHeightClass} ${bgColor} ${textColor} tansition duration-500 text-fs-12 font-semibold rounded-full`}>
                {btnText->React.string}
              </div>
            }

          | None => React.null
          }}
          {getIconElement(buttonProp)}
        </div>
      </div>
    })
    ->React.array}
    <div
      className={`${fixedClass} ${iconBgColor} ${iconTextColor} p-4 rounded-full cursor-pointer select-none w-fit`}
      onClick=plusIconOnClick
      style={ReactDOMStyle.make(
        ~transform={showButtons ? "rotate(135deg)" : ""},
        ~zIndex={noOfBtns->Belt.Int.toString},
        (),
      )}>
      <Icon name="pen" size=iconSize className=iconTextColor />
    </div>
  </div>
}
