external toReactFormEvent: 'a => ReactEvent.Form.t = "%identity"
@react.component
let make = (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~placeholder,
  ~isDisabled,
  ~rows=?,
  ~cols=?,
  ~customClass="",
  ~readOnly=?,
  ~maxLength=?,
  ~class="",
  ~roundedBorder=false,
  ~prefix=?,
  ~handleRemove=_ => (),
  ~setShow=_ => (),
) => {
  let (focus, setFocus) = React.useState(_ => false)
  let (error, setError) = React.useState(_ => None)
  let cursorClass = if isDisabled {
    "cursor-not-allowed"
  } else {
    ""
  }

  let handleRemove = _ => {
    input.onChange(""->toReactFormEvent)
    setError(_ => None)
    setFocus(_ => false)
    handleRemove()
  }

  let className = `rounded-md border border-jp-gray-lightmode_steelgray border-opacity-75 font-normal p-2 text-jp-gray-900  text-opacity-75 placeholder-jp-gray-900 placeholder-opacity-25 hover:bg-jp-gray-lightmode_steelgray hover:bg-opacity-20 hover:border-jp-gray-900 hover:border-opacity-20 focus:text-opacity-100 focus:outline-none focus:border-blue-800 focus:border-opacity-100 dark:text-jp-gray-text_darktheme dark:text-opacity-75 dark:border-jp-gray-960 dark:hover:border-jp-gray-960 dark:hover:bg-jp-gray-970 dark:bg-jp-gray-darkgray_background dark:placeholder-jp-gray-text_darktheme dark:placeholder-opacity-25 dark:focus:text-opacity-100 dark:focus:border-blue-800 ${cursorClass} ${customClass}`
  let value = switch input.value->Js.Json.classify {
  | JSONString(str) => str
  | JSONNumber(num) => num->Belt.Float.toString
  | _ => ""
  }

  let onBlur = _ => {
    let value = value->Js_string.trim

    let lengthError =
      maxLength->Belt.Option.flatMap(length =>
        value->Js_string.length <= length
          ? None
          : Some(`Maximum length should be ${length->Belt.Int.toString}`)
      )

    let error = lengthError

    if value === "" || error->Belt.Option.isNone {
      setFocus(_ => false)
      input.onChange(value->toReactFormEvent)
      setShow(_ => false)
    } else {
      setError(_ => error)
      setShow(_ => false)
    }
  }

  let isError = error->Belt.Option.isSome

  let borderColor = isError
    ? "border rounded-md border-red-600 dark:border-red-600"
    : focus
    ? "border-opacity-100 border-blue-800"
    : roundedBorder
    ? "border-gray-300 dark:border-jp-gray-800"
    : "border-opacity-75 border-gray-300 dark:border-jp-gray-800"

  let textAreaComponent =
    <textarea
      className
      name={input.name}
      onBlur
      onChange={input.onChange}
      onFocus={_ => {
        setError(_ => None)
        setFocus(_ => true)
        setShow(_ => true)
      }}
      value
      disabled={isDisabled}
      placeholder={placeholder}
      autoFocus=focus
      type_="text"
      inputMode="text"
      ?rows
      ?cols
      ?readOnly
    />

  if focus || value === "" {
    <div className="flex flex-col gap-1 w-full">
      <div className="w-full flex flex-row gap-2 items-center">
        <div className={`flex flex-row w-full pb-1 ${borderColor}`}>
          {switch prefix {
          | Some(text) =>
            <div
              className={`bg-transparent px-2 h-10 flex flex-row items-center bg-gray-200 dark:bg-jp-gray-800 text-gray-700 dark:text-gray-100 rounded-l-md`}>
              {React.string(text)}
            </div>
          | None => React.null
          }}
          textAreaComponent
        </div>
      </div>
      {switch error {
      | Some(errorMessage) =>
        <div className="text-red-600 ml-1 text-base"> {errorMessage->React.string} </div>
      | None => React.null
      }}
    </div>
  } else {
    let alignItems = roundedBorder ? "items-center" : "items-end"
    <div className={`${class} flex flex-row gap-4 ml-1 ${alignItems}`}>
      <div
        className={`text-gray-500 dark:text-gray-300 text-md font-semibold text-ellipsis overflow-hidden`}>
        {React.string(prefix->Belt.Option.getWithDefault("") ++ value)}
      </div>
      <div style={ReactDOMStyle.make(~minWidth="2rem", ())}>
        <Icon
          name="edit-pen"
          size=22
          onClick={_ => setFocus(_ => true)}
          themeBased=true
          className="cursor-pointer"
        />
      </div>
      <div style={ReactDOMStyle.make(~minWidth="2rem", ())}>
        <Icon
          onClick=handleRemove
          name="trash"
          size=17
          className="text-jp-gray-800 dark:text-jp-gray-400 opacity-50 mb-1 ml-2 cursor-pointer"
        />
      </div>
    </div>
  }
}
