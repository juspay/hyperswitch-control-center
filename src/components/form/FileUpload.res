@val external atob: string => string = "atob"
@send external focus: Dom.element => unit = "focus"
@react.component
let make = (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~fileType=".pdf",
  ~fileNameInput: option<ReactFinalForm.fieldRenderPropsInput>=?,
  ~isDisabled=false,
  ~shouldParse=true,
  ~showUploadtoast=true,
  ~parseFile=str => str,
  ~decodeParsedfile=false,
  ~widthClass=`w-40`,
  ~leftIcon=<Icon name={"upload"} size=15 />,
  ~rowsLimit=?,
  ~validateUploadedFile=?,
) => {
  let (key, setKey) = React.useState(_ => 1)
  let formInput = ReactFinalForm.useField(input.name ++ "_filename").input
  let fileNameInput = switch fileNameInput {
  | Some(filenameInput) => filenameInput
  | None => formInput
  }
  let defaultFileName = fileNameInput.value->LogicUtils.getStringFromJson("")

  let (fileName, setFilename) = React.useState(_ => defaultFileName)
  let showToast = ToastState.useShowToast()

  React.useEffect1(() => {
    fileNameInput.onChange(fileName->Identity.anyTypeToReactEvent)
    None
  }, [fileName])

  let clearData = _ev => {
    setFilename(_ => "")
    input.onChange(""->Js.Json.string->Identity.anyTypeToReactEvent)
    setKey(prev => prev + 1)
  }

  let toast = (message, toastType) => {
    showToast(~message, ~toastType, ())
  }

  let onChange = evt => {
    let target = ReactEvent.Form.target(evt)
    let value = target["files"]["0"]
    if target["files"]->Array.length > 0 {
      let filename = value["name"]
      let fileTypeArr = fileType->String.split(",")
      let isCorrectFileFormat = fileTypeArr->Array.some(item => fileTypeArr->Array.includes(item))
      let fileReader = FileReader.reader
      let _file =
        filename->String.includes("p12")
          ? fileReader.readAsBinaryString(. value)
          : fileReader.readAsText(. value)
      fileReader.onload = e => {
        let target = ReactEvent.Form.target(e)
        let file = target["result"]

        let value = shouldParse ? file->parseFile : value
        let isValid = switch validateUploadedFile {
        | Some(fn) => fn(file)
        | _ => true
        }
        if !isCorrectFileFormat {
          input.onChange(Identity.anyTypeToReactEvent(""))
          toast("Invalid file format", ToastError)
        } else if isValid {
          switch rowsLimit {
          | Some(val) =>
            let rows = String.split(file, "\n")->Array.length
            if value !== "" && rows - 1 < val {
              setFilename(_ => filename)
              input.onChange(Identity.anyTypeToReactEvent(value))
              if showUploadtoast {
                toast("File Uploaded Successfully", ToastSuccess)
              }
            } else if showUploadtoast {
              toast("File Size Exceeded", ToastError)
            }
          | None =>
            if value !== "" {
              setFilename(_ => filename)
              input.onChange(Identity.anyTypeToReactEvent(value))

              if showUploadtoast {
                toast("File Uploaded Successfully", ToastSuccess)
              }
            } else {
              toast("Error uploading file", ToastError)
            }
          }
        } else {
          toast("Invalid file", ToastError)
        }
      }
    }
  }

  let val = LogicUtils.getStringFromJson(input.value, "")

  let onClick = _ev => {
    DownloadUtils.downloadOld(
      ~fileName,
      ~content=decodeParsedfile
        ? try {
            val->atob
          } catch {
          | _ =>
            toast("Error : Unable to parse file", ToastError)
            ""
          }
        : val,
    )
  }

  let fileUploaded = val !== ""
  let cursor = isDisabled ? "cursor-not-allowed" : "cursor-pointer"

  <div className="flex">
    <label className=widthClass>
      {if !isDisabled {
        <input key={string_of_int(key)} type_="file" accept={fileType} hidden=true onChange />
      } else {
        React.null
      }}
      <span
        className={`${cursor} whitespace-pre overflow-hidden justify-center h-10
             flex flex-row items-center text-jp-gray-800 dark:text-dark_theme dark:hover:text-jp-gray-300 rounded-md border border-jp-gray-500 dark:border-jp-gray-960 bg-gradient-to-b
              from-jp-gray-250 to-jp-gray-200 dark:from-jp-gray-950 dark:to-jp-gray-950 
              dark:text-opacity-50 dark:text-jp-gray-text_darktheme hover:shadow 
              hover:text-opacity-100 text-opacity-50 focus:outline-none focus:text-opacity-100 px-1 ${widthClass}`}>
        leftIcon
        <div className="ml-2"> {React.string(fileUploaded ? "Uploaded" : "Upload File")} </div>
      </span>
    </label>
    {if fileUploaded {
      <>
        <div
          className="flex flex-row p-2  text-base text-jp-gray-900 dark:text-jp-gray-text_darktheme dark:text-opacity-40 text-opacity-50 font-medium"
          onClick>
          {React.string(fileName)}
        </div>
        {if !isDisabled {
          <span
            onClick=clearData
            className={`rounded-md ${cursor} flex items-center pl-2 pr-2 dark:bg-transparent bg-white h-auto`}>
            <Icon
              className="align-middle bg-opacity-25 text-white p-1 bg-gray-900 dark:bg-jp-gray-text_darktheme dark:bg-opacity-25 dark:text-jp-gray-lightgray_background rounded-full"
              size=18
              name="times"
            />
          </span>
        } else {
          React.null
        }}
      </>
    } else {
      React.null
    }}
  </div>
}
