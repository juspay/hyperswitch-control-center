type dataTransfer
@get external dataTransfer: ReactEvent.Mouse.t => 'a = "dataTransfer"
@get external files: dataTransfer => 'a = "files"

@react.component
let make = (~fileValue, ~setFileValue, ~fileName, ~setFilename, ~viewJson=false) => {
  let theme = switch ThemeProvider.useTheme() {
  | Dark => "vs-dark"
  | Light => "light"
  }

  let (showModal, setShowModal) = React.useState(_ => false)
  let (strFile, setStrFile) = React.useState(_ => "")
  let showToast = ToastState.useShowToast()

  let saveFile = file => {
    if file->Js.String2.length > 0 {
      let fileReader = FileReader.reader
      let _file = fileReader.readAsText(. file)
      fileReader.onload = e => {
        let target = ReactEvent.Form.target(e)
        let csv = target["result"]->LogicUtils.safeParse
        setFileValue(_ => csv)
      }
    }
  }

  let onModalClick = _ => {
    setShowModal(_ => true)
  }
  React.useEffect1(() => {
    if strFile != "" {
      if fileName->Js.String2.endsWith(".json") {
        saveFile(strFile)
        showToast(~message="File Uploaded Successfully", ~toastType=ToastSuccess, ())
      } else {
        setFilename(_ => "")
        setStrFile(_ => "")
        setFileValue(_ => Js.Json.null)
        showToast(~message="Invalid File! Please upload Json file", ~toastType=ToastError, ())
      }
    }
    None
  }, [strFile])
  <div className="flex flex-col mt-4" style={ReactDOMStyle.make(~height="300px", ())}>
    <div
      onDragOver={ev => {
        ev->ReactEvent.Mouse.preventDefault
      }}
      onDrop={ev => {
        ReactEvent.Mouse.preventDefault(ev)
        let files = ev->dataTransfer->files
        if files->Js.Array2.length > 0 {
          let file = files["0"]
          setFilename(_ => file["name"])
          setStrFile(_ => file)
        }
      }}
      className={"flex flex-col justify-center items-center border border-dashed m-6 dark:border-jp-gray-960 h-full"}>
      <Icon name="file-upload" size=50 />
      <div className="text-xl font-bold text-gray-400 mt-4 mb-2">
        {React.string("Drag and drop to add JSON File")}
      </div>
      <div className="text-xs font-semibold text-gray-400 mb-4">
        {React.string("or browse to choose a file")}
      </div>
      <div className="flex flex-col items-center">
        <label>
          <input
            type_="file"
            accept=".json"
            hidden=true
            value=""
            onChange={evt => {
              let target = ReactEvent.Form.target(evt)
              if target["files"]->Js.Array2.length > 0 {
                let file = target["files"]["0"]
                setFilename(_ => target["files"]["0"]["name"])
                setStrFile(_ => file)
              }
            }}
          />
          <AddDataAttributes attributes=[("data-button", "Browse File")]>
            <span
              className={`cursor-pointer whitespace-pre overflow-hidden flex flex-row items-center justify-center text-jp-gray-800 dark:text-dark_theme dark:hover:text-jp-gray-300 rounded-md border border-jp-gray-500 dark:border-jp-gray-960 bg-gradient-to-b
              from-jp-gray-250 to-jp-gray-200 dark:from-jp-gray-950 dark:to-jp-gray-950 
              dark:text-opacity-50 dark:text-jp-gray-text_darktheme hover:shadow 
              hover:text-opacity-100 text-opacity-50 focus:outline-none focus:text-opacity-100 px-6 py-2 w-max h-auto text-xs font-semibold`}>
              <div> {React.string(fileValue !== Js.Json.null ? "Uploaded" : "Browse File")} </div>
            </span>
          </AddDataAttributes>
        </label>
        {if fileValue !== Js.Json.null {
          <div className="flex flex-row">
            <div
              className="flex flex-row p-2  text-base text-jp-gray-900 dark:text-jp-gray-text_darktheme dark:text-opacity-40 text-opacity-50 font-medium">
              {React.string(fileName)}
            </div>
            <span
              onClick={_ => {
                setFilename(_ => "")
                setStrFile(_ => "")
                setFileValue(_ => Js.Json.null)
              }}
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
    </div>
    {if viewJson {
      <>
        <div className={`pr-5 flex justify-end`}>
          <Button
            text="View Uploaded Json"
            onClick={onModalClick}
            buttonSize=Small
            buttonType=Primary
            customButtonStyle="w-max"
            buttonState={fileValue === Js.Json.null ? Disabled : Normal}
          />
        </div>
        <Modal
          modalHeading="Display Json Data"
          showModal
          setShowModal
          modalClass="w-full md:w-6/12 mx-auto">
          <MonacoEditorLazy
            defaultLanguage="json"
            height="15rem"
            width="100%"
            value={fileValue->Js.Json.stringify->LogicUtils.getJsonFromStr}
            theme
          />
        </Modal>
      </>
    } else {
      React.null
    }}
  </div>
}
