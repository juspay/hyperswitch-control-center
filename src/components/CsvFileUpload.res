type t

type formData
external formDataToStr: t => string = "%identity"

external toString: 't => string = "%identity"
external toRef: 'a => 't = "%identity"
@new external formData: unit => t = "FormData"

@send external append: (t, string, 'a) => unit = "append"
@send external delete: (t, string) => unit = "delete"
@send external get: (t, string) => 'k = "get"
@send external click: Dom.element => unit = "click"
@react.component
let make = (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~customButtonStyle=?,
  ~buttonText,
  ~onFileUpload,
  ~messageId,
) => {
  let (isfileTooLarge, setIsfileTooLarge) = React.useState(_ => false)
  let (filenameVal, setFilenameVal) = React.useState(_ => "")

  let showToasts = ToastState.useShowToast()
  let clearImage = () => {
    setFilenameVal(_ => "")
    onFileUpload(None)

    input.onChange(""->Identity.stringToFormReactEvent)
  }

  let onChange = evt => {
    let target = ReactEvent.Form.target(evt)
    let value = target["files"]["0"]
    let filename = value["name"]
    setFilenameVal(_ => filename)
    let size = value["size"]
    setIsfileTooLarge(_ => size > 5000000)
    let formData = formData()
    append(formData, "type", "Include")

    append(formData, "csvFile", value)

    append(formData, "messageId", messageId->Js.Json.string)

    if value != "" && !isfileTooLarge {
      onFileUpload(value->Some)
    }
  }
  if isfileTooLarge {
    showToasts(~toastType=ToastError, ~message="File too big, needs to be smaller than 5 mb", ())
  }

  let buttonStyle = switch customButtonStyle {
  | Some(style) => style
  | None => `font-bold whitespace-pre overflow-hidden justify-center h-10
             flex flex-row items-center text-jp-gray-800 dark:text-dark_theme dark:hover:text-jp-gray-300 cursor-pointer rounded-md border border-jp-gray-500 dark:border-jp-gray-960 bg-gradient-to-b from-jp-gray-250 to-jp-gray-200 dark:from-jp-gray-950 dark:to-jp-gray-950 dark:text-opacity-50 dark:text-jp-gray-text_darktheme hover:shadow hover:text-opacity-100 text-opacity-50 focus:outline-none focus:text-opacity-100 px-1`
  }
  <div className="flex items-center justify-center flex-col">
    <div
      className="bg-white flex items-center w-fit justifly-center dark:bg-jp-gray-lightgray_background border-jp-gray-lightmode_steelgray border border-opacity-75 dark:border-jp-gray-960 dark:shadow-generic_shadow_dark rounded m-5 bg-blue-900">
      <div className="flex flex-row  p-3 flex items-center justifly-center">
        <label>
          <input type_="file" accept=".csv" hidden=true onChange />
          <div className="flex">
            <span className={buttonStyle}> {React.string(buttonText)} </span>
          </div>
        </label>
      </div>
    </div>
    {<>
      <div className="flex items-center justify-center ">
        {if filenameVal != "" && !isfileTooLarge {
          <div className="flex flex-row">
            <div
              className="flex flex-row p-2  text-base text-jp-gray-900 dark:text-jp-gray-text_darktheme dark:text-opacity-40 text-opacity-50 font-medium">
              {React.string(filenameVal)}
            </div>
            <span
              onClick={_ => clearImage()}
              className={`rounded-md cursor-pointer flex items-center pl-2 pr-2 dark:bg-transparent bg-white h-auto`}>
              <Icon
                className="align-middle bg-opacity-25 text-white p-1 bg-gray-900 dark:bg-jp-gray-text_darktheme dark:bg-opacity-25 dark:text-jp-gray-lightgray_background rounded-full"
                size=18
                name="times"
              />
            </span>
          </div>
        } else {
          React.null
        }}
      </div>
    </>}
  </div>
}
