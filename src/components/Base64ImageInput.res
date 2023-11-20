external toReactEvent: 'a => ReactEvent.Form.t = "%identity"
external strToDomImg: string => Webapi.Dom.Image.t = "%identity"
@send external drawImage: (Webapi.Canvas.Canvas2d.t, 'a, int, int) => unit = "drawImage"
@send external toDataURL: 'a => string = "toDataURL"
@get external width: Dom.element => string = "width"
@get external height: Dom.element => string = "height"
@set external src: (Dom.element, string) => unit = "src"
@new external image: unit => Dom.element = "Image"
@set external setWidth: (Dom.element, string) => unit = "width"
@set external setHeight: (Dom.element, string) => unit = "height"

open Webapi.Canvas
type rotateType = Left | Right
@react.component
let make = (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~customButtonStyle=?,
  ~customFileStyle="",
  ~showImage=true,
  ~showRotate=true,
  ~showFileName=true,
  ~reverseOrder=false,
  ~buttonText,
  ~positionCSS="",
  ~imgCSS="",
  ~leftIcon=React.null,
  ~allowedType="image/*",
  ~isInputDisabled=false,
) => {
  let (fileName, setFilename) = React.useState(_ => "")
  let (isNewUpload, setIsNewUpload) = React.useState(_ => false)
  let (isfileTooLarge, setIsfileTooLarge) = React.useState(_ => false)
  let showToast = ToastState.useShowToast()

  let orderCSS = reverseOrder ? "order-last" : ""

  let buttonStyle = switch customButtonStyle {
  | Some(style) => style
  | None => `font-bold whitespace-pre overflow-hidden justify-center h-10
             flex flex-row items-center text-jp-gray-800 dark:text-dark_theme dark:hover:text-jp-gray-300 cursor-pointer rounded-md border border-jp-gray-500 dark:border-jp-gray-960 bg-gradient-to-b from-jp-gray-250 to-jp-gray-200 dark:from-jp-gray-950 dark:to-jp-gray-950 dark:text-opacity-50 dark:text-jp-gray-text_darktheme hover:shadow hover:text-opacity-100 text-opacity-50 focus:outline-none focus:text-opacity-100 px-1`
  }
  let val = React.useMemo1(() => {
    input.value->Js.Json.decodeString->Belt.Option.getWithDefault("")
  }, [input.value])
  let canvas = React.useMemo0(() =>
    Webapi.Dom.document->Webapi.Dom.Document.createElement("canvas")
  )
  let clearImage = _evt => {
    setFilename(_ => "")
    input.onChange(""->toReactEvent)
  }
  let onChange = evt => {
    let target = ReactEvent.Form.target(evt)
    let value = target["files"]["0"]
    let size = value["size"]
    setIsfileTooLarge(_ => size > 400000)

    if size > 400000 {
      showToast(~message="File size too large, upload below 400kb", ~toastType=ToastError, ())
    } else if target["files"]->Js.Array2.length > 0 {
      let filename = value["name"]
      setFilename(_ => filename)
      let fileReader = FileReader.reader
      let _file = fileReader.readAsDataURL(. value)
      fileReader.onload = e => {
        let target = ReactEvent.Form.target(e)
        let data = target["result"]
        setIsNewUpload(_ => true)
        input.onChange(toReactEvent(data))
      }
    }
  }
  let transform = (transType, _evt) => {
    let context = canvas->CanvasElement.getContext2d
    let img = image()
    src(img, val)
    setWidth(canvas, height(img))
    setHeight(canvas, width(img))
    let a = switch transType {
    | Left => {
        context->Canvas2d.translate(
          ~x=height(img)->Belt.Float.fromString->Belt.Option.getWithDefault(0.),
          ~y=0.,
        )
        context->Canvas2d.rotate(90. *. (Js.Math._PI /. 180.))
        context->drawImage(img, 0, 0)
        toDataURL(canvas)
      }

    | Right =>
      context->Canvas2d.translate(
        ~y=width(img)->Belt.Float.fromString->Belt.Option.getWithDefault(0.),
        ~x=0.,
      )
      context->Canvas2d.rotate(-90. *. (Js.Math._PI /. 180.))
      context->drawImage(img, 0, 0)
      toDataURL(canvas)
    }
    input.onChange(a->toReactEvent)
  }
  <div className=positionCSS>
    <div className={`flex ${orderCSS}`}>
      <div className="flex flex-row">
        <label>
          {if !isInputDisabled {
            <input type_="file" accept=allowedType hidden=true onChange />
          } else {
            React.null
          }}
          <div className="flex ">
            <span className={buttonStyle}>
              {leftIcon}
              {React.string(buttonText)}
            </span>
          </div>
        </label>
      </div>
      {if isNewUpload && fileName != "" && !isfileTooLarge && showFileName {
        <>
          <div
            className={`flex flex-row p-2  text-base text-jp-gray-900 dark:text-jp-gray-text_darktheme dark:text-opacity-40 text-opacity-50 font-medium ${customFileStyle}`}>
            {React.string(fileName)}
          </div>
          <span
            onClick=clearImage
            className={`rounded-md cursor-pointer flex items-center pl-2 pr-2 dark:bg-transparent bg-white h-auto`}>
            <Icon
              className="align-middle bg-opacity-25 text-white p-1 bg-gray-900 dark:bg-jp-gray-text_darktheme dark:bg-opacity-25 dark:text-jp-gray-lightgray_background rounded-full"
              size=18
              name="times"
            />
          </span>
        </>
      } else {
        React.null
      }}
    </div>
    {if val != "" && !isfileTooLarge && showImage {
      <div className="flex flex-col items-center">
        {if showRotate {
          <span
            onClick={transform(Left)}
            className={`rounded-md mt-5 cursor-pointer flex flex-col dark:bg-transparent`}>
            <Icon className="fill-white" name="arrow-rotate" size=18 />
          </span>
        } else {
          React.null
        }}
        <div className={`max-w-md max-h-md mt-2 ${imgCSS}`}>
          <img alt="" src={val} />
        </div>
      </div>
    } else {
      React.null
    }}
  </div>
}
