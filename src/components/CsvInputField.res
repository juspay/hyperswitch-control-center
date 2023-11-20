external toReactEvent: 'a => ReactEvent.Form.t = "%identity"
external jsonToarr: Js.Json.t => array<'a> = "%identity"
external arrToReactEvent: array<string> => ReactEvent.Form.t = "%identity"
external strToReactEvent: string => ReactEvent.Form.t = "%identity"

module FilenameSaver = {
  @react.component
  let make = (~input: ReactFinalForm.fieldRenderPropsInput, ~fileName) => {
    React.useEffect1(() => {
      let reactEvFilename = fileName->toReactEvent
      input.onChange(reactEvFilename)
      None
    }, [fileName])
    React.null
  }
}
let disallowedCharacters = "\\~[{!#%^=+|:;,\"'()-.&/"

@react.component
let make = (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~heading="",
  ~subHeading=?,
  ~downloadFilename="SampleData",
  ~downloadSampleFileClass="",
  ~mainClassStyle="",
  ~buttonDivClass="",
  ~sampleFileContent=?,
  ~buttonElement=React.null,
  ~fileNameKey=?,
  ~regex as optionalRegexStr=?,
  ~validateData=?,
  ~fileType=".csv",
  ~ignoreEmptySpace=false,
  ~buttonText="Browse",
  ~widthClass="w-20",
  ~outerWidthClass="",
  ~leftIcon=?,
  ~showStatus=true,
  ~removeSampleDataAfterUpload=false,
) => {
  let (key, setKey) = React.useState(_ => 1)
  let (isNewUpload, setIsNewUpload) = React.useState(_ => false)
  let (fileName, setFilename) = React.useState(_ => "")
  let showToast = ToastState.useShowToast()

  let validateUploadedFile = fileJson => {
    let allHeadings = Js.String2.split(heading, ",")
    if allHeadings->Js.Array2.length == 1 {
      let headingStr = switch Js.Json.decodeArray(fileJson) {
      | Some(dict_arr) =>
        if Js.Array2.length(dict_arr) != 0 {
          switch dict_arr[0]->Belt.Option.getWithDefault(Js.Json.null)->Js.Json.decodeObject {
          | Some(obj) => {
              let key = Js.Dict.keys(obj)
              let strval = key[0]->Belt.Option.getWithDefault("")
              strval
            }

          | None => ""
          }
        } else {
          ""
        }
      | None => ""
      }
      headingStr == heading
    } else {
      //if multiple heading are needed
      let areHeadingsMatching =
        LogicUtils.getArrayFromJson(fileJson, [])
        ->Belt.Array.get(0)
        ->Belt.Option.flatMap(Js.Json.decodeObject)
        ->Belt.Option.map(obj => {
          let computedHeading = obj->Js.Dict.keys->Js.Array2.joinWith(",")
          //if existing keys match heading
          computedHeading === heading
        })
        ->Belt.Option.getWithDefault(false)

      let fileDataCheck = switch fileJson->Js.Json.decodeArray {
      | Some(dict_arr) => {
          let valCheck = dict_arr->Js.Array2.map(item => {
            let itemCheck = switch item->Js.Json.decodeObject {
            | Some(val) => {
                let fieldCheck = val->Js.Dict.entries->Js.Array2.reduce((acc, entry) => {
                    let (_key, value) = entry
                    let acc = switch value->Js.Json.decodeString {
                    | Some(str) => ignoreEmptySpace ? true : str->Js.String2.length != 0
                    | None => acc
                    }
                    acc
                  }, false)
                fieldCheck
              }

            | _ => false
            }
            itemCheck
          })
          Js.Array2.includes(valCheck, true)
        }

      | _ => false
      }
      areHeadingsMatching && fileDataCheck
    }
  }

  let clearCsv = _evt => {
    setFilename(_ => "")
    setKey(pre => pre + 1)
    input.onChange(arrToReactEvent([]))
  }
  let clearData = _ev => {
    setFilename(_ => "")
    setKey(pre => pre + 1)
    input.onChange(strToReactEvent(""))
  }

  let toast = (message, toastType) => {
    showToast(~message, ~toastType, ())
  }

  let onChange = evt => {
    let target = ReactEvent.Form.target(evt)
    let value = target["files"]["0"]

    if target["files"]->Js.Array2.length > 0 {
      let filename = value["name"]
      setFilename(_ => filename)
      let fileReader = FileReader.reader
      let _file = fileReader.readAsText(. value)
      fileReader.onload = e => {
        let target = ReactEvent.Form.target(e)

        let csv = target["result"]
        switch fileType {
        | ".csv" =>
          let res = try CsvToJson.csvtojson.csv2json(. csv) catch {
          | _e => Js.Json.null
          }
          let isValid = switch validateData {
          | Some(validateFn) => validateFn(res)
          | None => true
          }
          if Js.Array2.length(value) == 0 {
            toast("Empty file or invalid format uploaded", ToastError)
          } else if validateUploadedFile(res) && isValid {
            setIsNewUpload(_ => true)

            switch optionalRegexStr {
            | Some(regexStr) => {
                let regex = Js.Re.fromString(regexStr)
                let errorLines = []
                jsonToarr(res)->Js.Array2.forEachi((item, i) => {
                  item
                  ->Js.Dict.values
                  ->Js.Array2.forEach(value => {
                    if Js.Re.test_(regex, value) {
                      let _ = Js.Array2.push(errorLines, i)
                    }
                  })
                })

                if errorLines->Js.Array2.length === 0 {
                  input.onChange(toReactEvent(res))
                  toast("File Uploaded Successfully", ToastSuccess)
                }

                if errorLines->Js.Array2.length > 0 {
                  let errorLineNo = string_of_int(errorLines[0]->Belt.Option.getWithDefault(0) + 1)
                  toast(`Error: Invalid file row content (line ${errorLineNo})`, ToastError)
                }
              }

            | None => {
                input.onChange(toReactEvent(res))
                toast("File Uploaded Successfully", ToastSuccess)
              }
            }
          } else if res->Js.Json.decodeNull->Js.Option.isSome {
            toast("Invalid csv file", ToastError)
          } else if isValid {
            toast("Invalid file row heading should be same as the sample file", ToastError)
          } else {
            toast("Invalid data", ToastError)
          }
        | _ =>
          setIsNewUpload(_ => true)
          input.onChange(toReactEvent(csv))
          toast("File Uploaded Successfully", ToastSuccess)
        }
      }
    }
  }

  let onClick = _ev => {
    let fileContent = `${heading}\n${sampleFileContent->Belt.Option.getWithDefault("")}`
    DownloadUtils.downloadOld(~fileName=`${downloadFilename}.csv`, ~content=fileContent)
  }

  <div className={`flex flex-col ${mainClassStyle}`}>
    {switch fileNameKey {
    | Some(key) =>
      <ReactFinalForm.Field name=key>
        {({input}) => <FilenameSaver input fileName />}
      </ReactFinalForm.Field>
    | None => React.null
    }}
    {switch subHeading {
    | Some(sb) =>
      <span
        className="text-sm text-jp-gray-900 text-opacity-50 dark:text-jp-gray-text_darktheme dark:text-opacity-50 mb-2">
        {React.string(sb)}
      </span>
    | None =>
      switch optionalRegexStr {
      | Some(_x) =>
        <span
          className="text-sm text-jp-gray-900 text-opacity-50 dark:text-jp-gray-text_darktheme dark:text-opacity-50 mb-2">
          {React.string(`Characters not allowed: ${disallowedCharacters}`)}
        </span>
      | None => React.null
      }
    }}
    <div className="flex items-center">
      <div className={`flex flex-row ${outerWidthClass}`}>
        <label className=outerWidthClass>
          <input key={string_of_int(key)} type_="file" accept=fileType hidden=true onChange />
          {if buttonElement != React.null {
            buttonElement
          } else {
            <div className={`flex ${buttonDivClass}`}>
              <span
                className={` font-bold whitespace-pre overflow-hidden justify-center h-10 gap-3
             flex flex-row items-center text-jp-gray-800 dark:text-dark_theme dark:hover:text-jp-gray-300 cursor-pointer rounded-md border border-jp-gray-500 dark:border-jp-gray-960 bg-gradient-to-b from-jp-gray-250 to-jp-gray-200 dark:from-jp-gray-950 dark:to-jp-gray-950 dark:text-opacity-50 dark:text-jp-gray-text_darktheme hover:shadow hover:text-opacity-100 text-opacity-50 focus:outline-none focus:text-opacity-100 px-1 ${widthClass}`}>
                {switch leftIcon {
                | Some(icon) => icon
                | None => React.null
                }}
                {React.string(buttonText)}
              </span>
            </div>
          }}
        </label>
      </div>
      {if fileType == ".csv" {
        if Js.Array2.length(jsonToarr(input.value)) != 0 && showStatus {
          <>
            <div
              className="flex flex-row p-2  text-base text-jp-gray-900 dark:text-jp-gray-text_darktheme dark:text-opacity-40 text-opacity-50 font-medium">
              {if isNewUpload {
                React.string(
                  Belt.Int.toString(Js.Array2.length(jsonToarr(input.value))) ++ " Rows Uploaded",
                )
              } else {
                React.string("File Uploaded")
              }}
            </div>
            <span
              onClick=clearCsv
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
        }
      } else if isNewUpload && fileName != "" {
        <>
          <div
            className="flex flex-row p-2  text-base text-jp-gray-900 dark:text-jp-gray-text_darktheme dark:text-opacity-40 text-opacity-50 font-medium">
            {React.string(fileName)}
          </div>
          <span
            onClick=clearData
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
    {sampleFileContent->Belt.Option.isSome && removeSampleDataAfterUpload === false
      ? <div
          onClick
          className={`text-jp-gray-800 hover:text-blue-800 items-center flex cursor-pointer dark:text-dark_theme w-min mt-3 whitespace-nowrap text-sm text-jp-gray-90 ${downloadSampleFileClass}`}>
          <Icon size=11 name="download" className="stroke-current opacity-60 mr-2" />
          {React.string("Download Sample Data")}
        </div>
      : React.null}
  </div>
}
