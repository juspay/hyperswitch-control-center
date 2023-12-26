open LogicUtils

type customInputFn = (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~placeholder: string,
) => React.element

type comboCustomInputFn = array<ReactFinalForm.fieldRenderProps> => React.element
type comboCustomInputRecord = {
  fn: comboCustomInputFn,
  names: array<string>,
}

module DOBPicker = {
  @react.component
  let make = (
    ~input: ReactFinalForm.fieldRenderPropsInput,
    ~disablePastDates=true,
    ~disableFutureDates=false,
    ~format="YYYY-MM-DD",
    ~disableCalender=false,
  ) => {
    let isoStringToCustomTimeZone = TimeZoneHook.useIsoStringToCustomTimeZone()
    let _ = format
    let (selectedDate, setSelectedDate) = React.useState(_ =>
      input.value
      ->Js.Json.decodeString
      ->Belt.Option.getWithDefault("")
      ->DateRangePicker.getDateStringForValue(isoStringToCustomTimeZone)
    )

    let onHandleChange = event => {
      let val = ref(ReactEvent.Form.currentTarget(event)["value"])
      let oldValLength = selectedDate->Js.String2.length
      let newValLength = val.contents->Js.String2.length
      let backpressed = !(
        (newValLength == 5 && oldValLength == 6) ||
        newValLength == 2 && oldValLength == 3 ||
        newValLength == oldValLength
      )
      if (
        (val.contents->Js.String2.length == 2 || val.contents->Js.String2.length == 5) &&
          backpressed
      ) {
        val := Js.String.concat("-", val.contents)
      }
      setSelectedDate(_ => val.contents)
      input.onChange(val.contents->Identity.stringToFormReactEvent)
    }
    let dropdownRef = React.useRef(Js.Nullable.null)
    let (isExpanded, setIsExpanded) = React.useState(_ => false)
    let dropdownVisibilityClass = if isExpanded {
      "inline-block z-100"
    } else {
      "hidden"
    }
    let changeDOBFormat = str => {
      str->Js.String2.split("-")->Js.Array2.reverseInPlace->Js.Array2.joinWith("-")
    }

    let onDateClick = str => {
      setIsExpanded(p => !p)
      if format == "DD-MM-YYYY" {
        setSelectedDate(_ => changeDOBFormat(str))
        input.onChange(changeDOBFormat(str)->Identity.stringToFormReactEvent)
      } else {
        setSelectedDate(_ => str)
        input.onChange(str->Identity.stringToFormReactEvent)
      }
    }
    React.useEffect1(() => {
      if input.value == ""->Js.Json.string {
        setSelectedDate(_ => "")
      }

      None
    }, [input.value])

    let defaultCellHighlighter = currDate => {
      let highlighter: Calendar.highlighter = {
        highlightSelf: currDate === selectedDate,
        highlightLeft: false,
        highlightRight: false,
      }
      highlighter
    }
    OutsideClick.useOutsideClick(
      ~refs=ArrayOfRef([dropdownRef]),
      ~isActive=isExpanded,
      ~callback=() => {
        setIsExpanded(p => !p)
      },
      (),
    )
    let changeVisibility = _ev => {
      setIsExpanded(p => !p)
    }

    let buttonText = {
      let startDateStr =
        selectedDate === ""
          ? input.value->Js.Json.decodeString->Belt.Option.getWithDefault("")
          : selectedDate
      startDateStr
    }

    {
      switch disableCalender {
      | true =>
        <input
          type_="text"
          className="w-full border border-jp-gray-lightmode_steelgray border-opacity-75 pl-2 h-10 text-jp-gray-900 text-sm text-opacity-75 placeholder-jp-gray-900 placeholder-opacity-25 hover:bg-jp-gray-lightmode_steelgray hover:bg-opacity-20 hover:border-jp-gray-900 hover:border-opacity-20 focus:text-opacity-100 focus:outline-none focus:border-blue-800 focus:border-opacity-100 dark:text-jp-gray-text_darktheme dark:text-opacity-75 dark:border-jp-gray-960 dark:hover:border-jp-gray-960 dark:hover:bg-jp-gray-970 dark:bg-jp-gray-darkgray_background dark:placeholder-jp-gray-text_darktheme dark:placeholder-opacity-25 dark:focus:text-opacity-100 dark:focus:border-blue-800 rounded-md "
          onChange=onHandleChange
          onBlur=input.onBlur
          onFocus=input.onFocus
          maxLength=10
          value={buttonText}
          placeholder="DD-MM-YYYY"
        />
      | false =>
        <div className="flex flex-row relative">
          <input
            type_="text"
            className="w-full border border-jp-gray-lightmode_steelgray border-opacity-75 pl-2 h-10 text-jp-gray-900 text-sm text-opacity-75 placeholder-jp-gray-900 placeholder-opacity-25 hover:bg-jp-gray-lightmode_steelgray hover:bg-opacity-20 hover:border-jp-gray-900 hover:border-opacity-20 focus:text-opacity-100 focus:outline-none focus:border-blue-800 focus:border-opacity-100 dark:text-jp-gray-text_darktheme dark:text-opacity-75 dark:border-jp-gray-960 dark:hover:border-jp-gray-960 dark:hover:bg-jp-gray-970 dark:bg-jp-gray-darkgray_background dark:placeholder-jp-gray-text_darktheme dark:placeholder-opacity-25 dark:focus:text-opacity-100 dark:focus:border-blue-800 rounded-md "
            onChange=onHandleChange
            onBlur=input.onBlur
            onFocus=input.onFocus
            maxLength=10
            value={buttonText}
            placeholder="DD-MM-YYYY"
          />
          <Icon
            className="cursor-pointer opacity-75 -ml-8 my-auto"
            name="calendar-regular"
            onClick={changeVisibility}
          />
          <div ref={dropdownRef->ReactDOM.Ref.domRef} className="relative">
            <div className=dropdownVisibilityClass>
              <div className="-right-[11px] top-[45px] absolute flex flex-row w-max z-10">
                <CalendarList
                  count=1
                  cellHighlighter=defaultCellHighlighter
                  onDateClick
                  disablePastDates
                  disableFutureDates
                />
              </div>
            </div>
          </div>
        </div>
      }
    }
  }
}
module NumericArrayInput = {
  @react.component
  let make = (~input: ReactFinalForm.fieldRenderPropsInput, ~placeholder) => {
    let (localValue, setLocalValue) = React.useState(() => input.value)
    let newInput = React.useMemo3(() => {
      {
        ...input,
        value: localValue,
        onChange: ev => {
          let value = ReactEvent.Form.target(ev)["value"]
          let value = if (
            !Js.Re.test_(%re("/^[0-9]{0,2}(,[0-9]{0,2})*$/"), value) ||
            value->Js.String2.includes(",,")
          ) {
            value->Js.String.slice(~from=0, ~to_=-1)->Js.Json.string
          } else {
            value->Js.Json.string
          }
          setLocalValue(_ => value)
          input.onChange(value->Identity.jsonToFormReactEvent)
        },
      }
    }, (input, localValue, setLocalValue))
    <TextInput input=newInput placeholder />
  }
}
////////

let useGetAccessLevel = () => {
  let accessLevel = React.useContext(FormAuthContext.formAuthContext)
  () => {
    accessLevel
  }
}

let selectInput = (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~options: array<SelectBox.dropdownOption>,
  ~placeholder as _,
  ~buttonText,
  ~deselectDisable=false,
  ~isHorizontal=true,
  ~disableSelect=false,
  ~fullLength=false,
  ~customButtonStyle="",
  ~textStyle="",
  ~marginTop="mt-12",
  ~customStyle="",
  ~searchable=?,
  ~showBorder=?,
  ~showToolTipOptions=false,
  ~textEllipsisForDropDownOptions=false,
  ~showCustomBtnAtEnd=false,
  ~dropDownCustomBtnClick=false,
  ~addDynamicValue=false,
  ~showMatchingRecordsText=true,
  ~fixedDropDownDirection=?,
  ~customButton=React.null,
  ~buttonType=Button.SecondaryFilled,
  ~dropdownCustomWidth="w-80",
  ~allowButtonTextMinWidth=?,
  ~setExtSearchString=_ => (),
  ~textStyleClass=?,
  ~ellipsisOnly=false,
  ~showBtnTextToolTip=false,
  ~dropdownClassName="",
  ~descriptionOnHover=false,
  (),
) => {
  let accessHook = useGetAccessLevel()
  <SelectBox
    input
    options
    buttonText
    allowMultiSelect=false
    deselectDisable
    isHorizontal
    disableSelect={disableSelect || accessHook() == AuthTypes.Read}
    fullLength
    customButtonStyle
    textStyle
    marginTop
    customStyle
    ?showBorder
    showToolTipOptions
    textEllipsisForDropDownOptions
    ?searchable
    showCustomBtnAtEnd
    dropDownCustomBtnClick
    addDynamicValue
    showMatchingRecordsText
    ?fixedDropDownDirection
    customButton
    buttonType
    dropdownCustomWidth
    ?allowButtonTextMinWidth
    setExtSearchString
    ?textStyleClass
    ellipsisOnly
    showBtnTextToolTip
    dropdownClassName
    descriptionOnHover
  />
}

let asyncSelectInput = (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~url="",
  ~body="",
  ~method=Fetch.Post,
  ~dataKey="",
  ~placeholder as _,
  ~buttonText,
  ~disableSelect=false,
  ~allowMultiSelect=false,
  (),
) => {
  <AsyncSelectBox input url body method dataKey buttonText disableSelect allowMultiSelect />
}

let textChipInput = (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~placeholder,
  ~isDisabled=false,
  ~type_="text",
  ~inputMode="text",
  ~pattern=?,
  ~autoComplete=?,
  ~showButton=?,
  ~converterFn=?,
  (),
) => {
  <ChipTextInput
    input placeholder isDisabled type_ inputMode ?pattern ?autoComplete ?showButton ?converterFn
  />
}

module CellWithInput = {
  @react.component
  let make = (~defValue="", ~displayVal) => {
    let (textBox, setTextBox) = React.useState(() => false)
    let (text, setText) = React.useState(() => defValue)
    let (boolVal, setBoolVal) = React.useState(() => "off")
    let setTextVal = React.useCallback1(ev => {
      let target = ReactEvent.Form.target(ev)
      let value = target["value"]
      setText(_ => value)
    }, [setText])
    let showTextBox = React.useCallback1(ev => {
      let target = ReactEvent.Form.target(ev)
      let value = target["value"] == "on" ? "off" : "on"
      setBoolVal(_ => value)
      setTextBox(_ => value == "on")
    }, [setTextBox])
    <span className="w-4 h-2">
      <input type_="checkbox" onChange=showTextBox value=boolVal />
      {React.string(displayVal)}
      {!textBox
        ? <span />
        : <div>
            {React.string("Count is : ")}
            <input className="w-5 h-3" type_="text" value=text onChange=setTextVal />
          </div>}
    </span>
  }
}
let cellRenderer = obj => {
  // Highlighting could be weekly day wise here and cell is date
  switch obj {
  | Some(a) => {
      let day = Js.String2.split(a, "-")
      React.string(day[2]->Belt.Option.getWithDefault(""))
    }

  | None => React.string("")
  }
}
let calendarInputHighlighted = (
  ~input as _: ReactFinalForm.fieldRenderPropsInput,
  ~placeholder as _,
  ~count,
  ~cellHighlighter,
  ~start_time: Js.Json.t,
  ~end_time: Js.Json.t,
) => {
  <SpreadCalendarList count cellHighlighter start_time end_time />
}
let infraSelectInput = (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~options: array<SelectBox.dropdownOption>,
  ~placeholder as _,
  ~deselectDisable=false,
  ~borderRadius="rounded-full",
  ~selectedClass="border-jp-gray-900 dark:border-jp-gray-300 text-jp-gray-900 dark:text-jp-gray-300 font-semibold",
  ~nonSelectedClass="border-jp-gray-600 dark:border-jp-gray-800 text-jp-gray-850 dark:text-jp-gray-400",
  ~showTickMark=true,
  ~allowMultiSelect=true,
  (),
) => {
  <SelectBox.InfraSelectBox
    input
    options
    deselectDisable
    borderRadius
    selectedClass
    nonSelectedClass
    showTickMark
    allowMultiSelect
  />
}
let chipFilterSelectBox = (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~options: array<SelectBox.dropdownOption>,
  ~placeholder as _,
  ~deselectDisable=false,
  (),
) => {
  <SelectBox.ChipFilterSelectBox input options deselectDisable />
}

let multiSelectInput = (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~options: array<SelectBox.dropdownOption>,
  ~optionSize: CheckBoxIcon.size=Small,
  ~placeholder as _,
  ~buttonText,
  ~buttonSize=?,
  ~hideMultiSelectButtons=false,
  ~showSelectionAsChips=true,
  ~showToggle=false,
  ~isDropDown=true,
  ~searchable=false,
  ~showBorder=?,
  ~optionRigthElement=?,
  ~customStyle="",
  ~customMargin="",
  ~customButtonStyle=?,
  ~hideBorder=false,
  ~allSelectType=SelectBox.Icon,
  ~showToolTip=false,
  ~showNameAsToolTip=false,
  ~buttonType=Button.SecondaryFilled,
  ~showSelectAll=true,
  ~isHorizontal=false,
  ~fullLength=?,
  ~fixedDropDownDirection=?,
  ~dropdownCustomWidth=?,
  ~customMarginStyle=?,
  ~buttonTextWeight=?,
  ~marginTop=?,
  ~customButtonLeftIcon=?,
  ~customButtonPaddingClass=?,
  ~customButtonIconMargin=?,
  ~customTextPaddingClass=?,
  ~listFlexDirection="",
  ~buttonClickFn=?,
  ~showDescriptionAsTool=true,
  ~optionClass="",
  ~selectClass="",
  ~toggleProps="",
  ~showSelectCountButton=true,
  ~showAllSelectedOptions=true,
  ~leftIcon=?,
  ~customBackColor=?,
  ~customSelectAllStyle=?,
  ~onItemSelect=(_, _) => (),
  ~wrapBasis="",
  ~dropdownClassName="",
  ~baseComponentMethod=?,
  (),
) => {
  let accessHook = useGetAccessLevel()
  <SelectBox
    input
    options
    optionSize
    buttonText
    ?buttonSize
    allowMultiSelect=true
    hideMultiSelectButtons
    showSelectionAsChips
    isDropDown
    showToggle
    searchable
    ?showBorder
    customStyle
    customMargin
    ?optionRigthElement
    hideBorder
    allSelectType
    ?customButtonStyle
    ?fixedDropDownDirection
    showToolTip
    showNameAsToolTip
    disableSelect={accessHook() == AuthTypes.Read}
    buttonType
    showSelectAll
    ?fullLength
    isHorizontal
    ?customMarginStyle
    ?dropdownCustomWidth
    ?buttonTextWeight
    ?marginTop
    ?customButtonLeftIcon
    ?customButtonPaddingClass
    ?customButtonIconMargin
    ?customTextPaddingClass
    listFlexDirection
    ?buttonClickFn
    showDescriptionAsTool
    optionClass
    selectClass
    toggleProps
    showSelectCountButton
    showAllSelectedOptions
    ?leftIcon
    ?customBackColor
    ?customSelectAllStyle
    onItemSelect
    wrapBasis
    dropdownClassName
    ?baseComponentMethod
  />
}

let btnGroupInput = (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~options: array<SelectBox.dropdownOption>,
  ~isDisabled=false,
  ~buttonClass="",
  ~placeholder as _,
  ~isSeparate=false,
  ~buttonSize=?,
  (),
) => {
  <ButtonGroupIp input options buttonClass isDisabled isSeparate ?buttonSize />
}
let radioInput = (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~options: array<SelectBox.dropdownOption>,
  ~placeholder as _,
  ~buttonText,
  ~disableSelect=true,
  ~optionSize: CheckBoxIcon.size=Small,
  ~isHorizontal=false,
  ~deselectDisable=true,
  ~customStyle="",
  ~baseComponentCustomStyle="",
  ~customSelectStyle="",
  ~fill=?,
  ~maxHeight=?,
  (),
) => {
  <SelectBox
    input
    disableSelect
    optionSize
    options
    buttonText
    allowMultiSelect=false
    isDropDown=false
    isHorizontal
    deselectDisable
    customStyle
    baseComponentCustomStyle
    customSelectStyle
    ?fill
    ?maxHeight
  />
}
let checkboxInput = (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~isHorizontal=false,
  ~options: array<SelectBox.dropdownOption>,
  ~optionSize: CheckBoxIcon.size=Small,
  ~isSelectedStateMinus=false,
  ~disableSelect=false,
  ~buttonText="",
  ~placeholder as _,
  ~maxHeight=?,
  ~searchable=?,
  ~searchInputPlaceHolder=?,
  ~dropdownCustomWidth=?,
  ~customSearchStyle="bg-jp-gray-100 dark:bg-jp-gray-950 p-2",
  ~customLabelStyle=?,
  ~customMarginStyle="mx-3 py-2 gap-2",
  ~customStyle="",
  ~checkboxDimension="",
  ~wrapBasis="",
  (),
) => {
  <SelectBox
    input
    options
    optionSize
    isSelectedStateMinus
    disableSelect
    allowMultiSelect=true
    isDropDown=false
    showSelectAll=false
    buttonText
    isHorizontal
    ?maxHeight
    ?searchable
    ?searchInputPlaceHolder
    ?dropdownCustomWidth
    customSearchStyle
    ?customLabelStyle
    customMarginStyle
    customStyle
    checkboxDimension
    wrapBasis
  />
}

let rangeInput = (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~placeholder,
  ~isDisabled=false,
  ~inputMode="range",
  ~min=?,
  ~max=?,
  (),
) => {
  <RangeInput input placeholder isDisabled inputMode ?min ?max />
}
let nestedDropdown = (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~placeholder as _,
  ~options,
  ~title,
) => {
  <NestedDropdown input options title />
}
let draggableFilters = (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~placeholder as _,
  ~options,
  ~title,
) => {
  <DraggableFilter input options title />
}
let nestedDropdownWithCalendar = (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~placeholder as _,
  ~options,
  ~dateRangeLimit=60,
  ~addMore=true,
  ~title,
  (),
) => {
  <NestedDropdownWithCalendar input options title dateRangeLimit addMore />
}
let textInput = (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~placeholder,
  ~description="",
  ~isDisabled=false,
  ~autoFocus=false,
  ~type_="text",
  ~inputMode="text",
  ~pattern=?,
  ~autoComplete=?,
  ~maxLength=?,
  ~leftIcon=?,
  ~rightIcon=?,
  ~rightIconOnClick=?,
  ~inputStyle="",
  ~customStyle="",
  ~customWidth="w-full",
  ~customPaddingClass="",
  ~iconOpacity="opacity-30",
  ~rightIconCustomStyle="",
  ~leftIconCustomStyle="",
  ~customDashboardClass=?,
  ~onHoverCss=?,
  ~onDisabledStyle=?,
  ~onActiveStyle=?,
  ~customDarkBackground=?,
  ~phoneInput=false,
  ~widthMatchwithPlaceholderLength=None,
  (),
) => {
  let accessHook = useGetAccessLevel()
  <TextInput
    input
    placeholder
    description
    isDisabled={isDisabled || accessHook() == AuthTypes.Read}
    type_
    inputMode
    ?pattern
    ?autoComplete
    ?maxLength
    ?leftIcon
    ?rightIcon
    ?rightIconOnClick
    inputStyle
    customStyle
    customWidth
    autoFocus
    iconOpacity
    customPaddingClass
    rightIconCustomStyle
    leftIconCustomStyle
    ?customDashboardClass
    ?onHoverCss
    ?onDisabledStyle
    ?onActiveStyle
    ?customDarkBackground
    phoneInput
    widthMatchwithPlaceholderLength
  />
}

let yesNoRadioInput = (~input: ReactFinalForm.fieldRenderPropsInput, ~placeholder as _, ()) => {
  <YesNoRadioInput input />
}

let numericArrayInput = (~input: ReactFinalForm.fieldRenderPropsInput, ~placeholder) => {
  <NumericArrayInput input placeholder />
}

let textTagInput = (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~placeholder,
  ~name="",
  ~customStyle=?,
  ~disabled=false,
  ~seperateByComma=false,
  ~seperateBySpace=false,
  ~customButtonStyle=?,
  (),
) => {
  <MultipleTextInput
    input name disabled seperateByComma seperateBySpace ?customStyle ?customButtonStyle placeholder
  />
}

let fileInput = (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~placeholder as _,
  ~fileType,
  ~buttonElement=React.null,
  ~buttonText="Browse",
  ~leftIcon=React.null,
  ~widthClass,
  ~outerWidthClass="",
  (),
) => {
  <CsvInputField input fileType buttonText buttonElement outerWidthClass widthClass leftIcon />
}

let multipleFileInput = (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~widthClass=?,
  ~heightClass=?,
  ~buttonHeightClass=?,
  ~displayClass=?,
  ~parentDisplayClass=?,
  ~buttonElement=?,
  ~fileType=?,
  ~shouldParse=?,
  ~shouldEncodeBase64=?,
  ~showUploadtoast=?,
  ~placeholder as _,
  ~allowMultiFileSelect=?,
  ~fileOnClick=?,
  ~customDownload=?,
  ~sizeLimit=?, // in bytes
  ~isDisabled=?,
  ~pointerDisable=?,
  (),
) => {
  <MultipleFileUpload
    input
    ?widthClass
    ?heightClass
    ?buttonHeightClass
    ?displayClass
    ?parentDisplayClass
    ?buttonElement
    ?fileType
    ?showUploadtoast
    ?shouldParse
    ?shouldEncodeBase64
    ?allowMultiFileSelect
    ?fileOnClick
    ?customDownload
    ?sizeLimit
    ?isDisabled
    ?pointerDisable
  />
}

let csvFileUploadInput = (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~placeholder as _,
  ~customButtonStyle=?,
  ~buttonText,
  ~messageId,
  (),
) => {
  let onFileUpload = _ => ()
  <CsvFileUpload input ?customButtonStyle buttonText onFileUpload messageId />
}

let imageInput = (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~placeholder as _,
  ~customButtonStyle=?,
  ~customFileStyle=?,
  ~showImage=?,
  ~buttonText,
  (),
) => {
  <Base64ImageInputWithDnD input ?customButtonStyle ?customFileStyle ?showImage buttonText />
}
let colorPickerInput = (~input: ReactFinalForm.fieldRenderPropsInput, ~placeholder as _, ()) => {
  <ColorPickerInput input />
}

let customFileInput = (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~widthClass=?,
  ~leftIcon=?,
  ~fileType=?,
  ~shouldParse=?,
  ~showUploadtoast=?,
  ~placeholder as _,
  (),
) => {
  <FileUpload input ?widthClass ?leftIcon ?fileType ?showUploadtoast ?shouldParse />
}

let customFileInputCsv = (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~placeholder as _,
  ~downloadFilename="SampleOfferCodes",
  ~heading="",
  ~fileType=".csv",
  ~sampleFileContent=?,
  ~rowsLimit,
  ~removeSampleDataAfterUpload=false,
  (),
) => {
  let onClick = _ev => {
    let fileContent = `${heading}\n${sampleFileContent->Belt.Option.getWithDefault("")}`
    DownloadUtils.downloadOld(~fileName=`${downloadFilename}.csv`, ~content=fileContent)
  }

  let validateUploadedFile = file => {
    switch fileType {
    | ".csv" =>
      let fileJson = try CsvToJson.csvtojson.csv2json(. file) catch {
      | _e => Js.Json.null
      }
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
          getArrayFromJson(fileJson, [])
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
            let mandatoryFields = ["product_id"]
            let numericInputs = [
              "min_quantity",
              "max_quantity",
              "min_amount",
              "max_amount",
              "applicable_max_quantity",
            ]
            let valCheck = dict_arr->Js.Array2.map(item => {
              let itemCheck = switch item->Js.Json.decodeObject {
              | Some(val) => {
                  let minMaxCheck = (val, key1, key2, fieldCheck) => {
                    let value1 = val->getString(key1, "")
                    let value2 = val->getString(key2, "")
                    if fieldCheck {
                      value1->getFloatFromString(0.) <= value2->getFloatFromString(0.) ||
                      value1 == "" ||
                      value2 == ""
                    } else {
                      false
                    }
                  }
                  let fieldCheck = val->Js.Dict.entries->Js.Array2.reduce((acc, entry) => {
                      let (key, value) = entry

                      let acc = switch value->Js.Json.decodeString {
                      | Some(str) => {
                          let isNumeric = numericInputs->Js.Array2.includes(key)
                          let number = str->Belt.Float.fromString
                          let notEmpty = isNumeric ? number->Belt.Option.isSome : str != ""
                          let splCharCheck = Js.Re.test_(%re("/^[\w-]*$/"), str)
                          let mandateNumericCheck = if isNumeric {
                            number->Belt.Option.isSome ? acc : false
                          } else {
                            acc
                          }
                          let numericCheck = if str != "" {
                            mandateNumericCheck
                          } else {
                            acc
                          }
                          if mandatoryFields->Js.Array2.includes(key) {
                            notEmpty && splCharCheck ? mandateNumericCheck : false
                          } else {
                            numericCheck
                          }
                        }

                      | None => acc
                      }
                      acc
                    }, true)
                  let qualityFieldCheck = minMaxCheck(
                    val,
                    "min_quantity",
                    "max_quantity",
                    fieldCheck,
                  )
                  let amountFieldCheck = minMaxCheck(val, "min_amount", "max_amount", fieldCheck)
                  fieldCheck && qualityFieldCheck && amountFieldCheck
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
    | _ => false
    }
  }

  <>
    <FileUpload input fileType rowsLimit validateUploadedFile />
    {sampleFileContent->Belt.Option.isSome && removeSampleDataAfterUpload === false
      ? <div
          onClick
          className="text-jp-gray-800 hover:text-blue-800 items-center flex cursor-pointer dark:text-dark_theme w-min mt-3 whitespace-nowrap text-sm text-jp-gray-90">
          <Icon size=11 name="download" className="stroke-current opacity-60 mr-2" />
          {React.string("Download Sample Data")}
        </div>
      : React.null}
  </>
}

let numericTextInput = (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~placeholder,
  ~isDisabled=false,
  ~customStyle="",
  ~inputMode=?,
  ~precision=?,
  ~maxLength=?,
  ~removeLeadingZeroes=false,
  ~leftIcon=?,
  ~rightIcon=?,
  ~customPaddingClass=?,
  ~rightIconCustomStyle=?,
  ~leftIconCustomStyle=?,
  (),
) => {
  <NumericTextInput
    customStyle
    input
    placeholder
    isDisabled
    ?inputMode
    ?precision
    ?maxLength
    removeLeadingZeroes
    ?leftIcon
    ?rightIcon
    ?customPaddingClass
    ?rightIconCustomStyle
    ?leftIconCustomStyle
  />
}

let datePickerInput = (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~placeholder as _,
  ~disablePastDates=false,
  ~customButtonStyle=?,
  ~buttonType=?,
  ~buttonSize=?,
  ~leftIcon=?,
  ~rightIcon=?,
  ~disableFutureDates=true,
  ~format="YYYY-MM-DDTHH:mm:ss",
  (),
) => {
  let accessHook = useGetAccessLevel()
  <DatePicker
    input
    isDisabled={accessHook() !== AuthTypes.ReadWrite}
    disablePastDates
    ?customButtonStyle
    ?buttonType
    ?buttonSize
    ?leftIcon
    ?rightIcon
    disableFutureDates
    format
  />
}

let singleDatePickerInput = (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~placeholder as _,
  ~disablePastDates=true,
  ~disableFutureDates=false,
  ~customDisabledFutureDays=0.0,
  ~format="YYYY-MM-DDTHH:mm:ss",
  ~currentDateHourFormat="00",
  ~currentDateMinuteFormat="00",
  ~currentDateSecondsFormat="00",
  ~customButtonStyle=?,
  ~newThemeCustomButtonStyle=?,
  ~calendarContaierStyle=?,
  ~buttonSize=?,
  ~showTime=?,
  ~fullLength=?,
  (),
) => {
  <DatePicker
    input
    disablePastDates
    disableFutureDates
    format
    customDisabledFutureDays
    currentDateHourFormat
    currentDateMinuteFormat
    currentDateSecondsFormat
    ?customButtonStyle
    ?newThemeCustomButtonStyle
    ?calendarContaierStyle
    ?buttonSize
    ?showTime
    ?fullLength
  />
}

let dobPickerInput = (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~placeholder as _,
  ~format="YYYY-MM-DD",
  ~disableCalender=false,
  ~disableFutureDates=false,
  ~disablePastDates=false,
  (),
) => {
  <DOBPicker input disablePastDates disableFutureDates format disableCalender />
}

let datePickInput = (~input: ReactFinalForm.fieldRenderPropsInput, ~placeholder as _, ()) => {
  <DateOnlySelector input />
}

let dateRangeField = (
  ~startKey: string,
  ~endKey: string,
  ~format,
  ~disablePastDates=false,
  ~disableFutureDates=false,
  ~showTime=false,
  ~predefinedDays=[],
  ~disableApply=false,
  ~numMonths=1,
  ~dateRangeLimit=?,
  ~removeFilterOption=?,
  ~optFieldKey=?,
  ~showSeconds=true,
  ~hideDate=false,
  ~selectStandardTime=false,
  ~customButtonStyle=?,
  ~isTooltipVisible=true,
  (),
): comboCustomInputRecord => {
  let fn = (_fieldsArray: array<ReactFinalForm.fieldRenderProps>) => {
    <DateRangePicker
      disablePastDates
      disableFutureDates
      format
      predefinedDays
      numMonths
      showTime
      disableApply
      startKey
      endKey
      ?dateRangeLimit
      ?removeFilterOption
      ?optFieldKey
      showSeconds
      hideDate
      selectStandardTime
      ?customButtonStyle
      isTooltipVisible
    />
  }

  {fn, names: [startKey, endKey]}
}

let newDateRangeField = (
  ~startKey: string,
  ~endKey: string,
  ~format,
  ~disablePastDates=false,
  ~disableFutureDates=false,
  ~showTime=false,
  ~predefinedDays=[],
  ~disableApply=false,
  ~numMonths=1,
  ~dateRangeLimit=?,
  ~removeFilterOption=?,
  ~optFieldKey=?,
  ~showSeconds=true,
  ~hideDate=false,
  ~selectStandardTime=false,
  ~customButtonStyle=?,
  (),
): comboCustomInputRecord => {
  let fn = (_fieldsArray: array<ReactFinalForm.fieldRenderProps>) => {
    <NewDateRangePicker
      disablePastDates
      disableFutureDates
      format
      predefinedDays
      numMonths
      showTime
      disableApply
      startKey
      endKey
      ?dateRangeLimit
      ?removeFilterOption
      ?optFieldKey
      showSeconds
      hideDate
      selectStandardTime
      ?customButtonStyle
    />
  }

  {fn, names: [startKey, endKey]}
}
let dateTimeRangeField = (
  ~startKey: string,
  ~endKey: string,
  ~disablePastDates=false,
  ~showTime=false,
  ~disableFutureDates=false,
  ~predefinedDays=[],
  ~format,
) => {
  _fieldsArray => {
    <DateRangePicker
      startKey endKey showTime disablePastDates disableFutureDates format predefinedDays
    />
  }
}

let infraDateRangeField = (
  fieldsArray: array<ReactFinalForm.fieldRenderPropsInput>,
  ~disablePastDates=false,
  ~disableFutureDates=false,
  ~showTime=false,
  ~format,
) => {
  <InfraDateRangePicker input=fieldsArray disablePastDates disableFutureDates format showTime />
}

let tabularInput = (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~placeholder as _,
  ~tableHeadings,
  ~fields,
) => {
  <TabularInput input headings=tableHeadings fields />
}
let buttonInput = (~input: ReactFinalForm.fieldRenderPropsInput, ~placeholder as _placeholder) => {
  switch input.value->Js.Json.decodeString {
  | Some(str) => <Button text=str />
  | None => React.null
  }
}

let iconButtonInput = (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~placeholder as _placeholder,
) => {
  switch input.value->Js.Json.decodeString {
  | Some(str) =>
    <Button buttonState=NoHover text=str leftIcon={CustomIcon(<Icon name="avatar" size=13 />)} />
  | None => React.null
  }
}
let buttonUnsetInput = (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~placeholder as _placeholder,
) => {
  switch input.value->Js.Json.decodeString {
  | Some(str) => <Button buttonState=NoHover text=str />
  | None => React.null
  }
}

let boolButtonInput = (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~trueLabel="True",
  ~falseLabel="False",
  ~isDisabled=false,
  ~customWidthCss="",
  ~placeholder as _,
  ~enableNewTheme=false,
  (),
) => {
  <BoolButtonInput input trueLabel falseLabel isDisabled customWidthCss enableNewTheme />
}

let boolInput = (~input: ReactFinalForm.fieldRenderPropsInput, ~placeholder as _, ~isDisabled) => {
  <BoolInput input isDisabled />
}

let boolCheckInput = (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~placeholder as _,
  ~isCheckBox=false,
  ~isDisabled,
) => {
  <BoolInput input isDisabled isCheckBox />
}
let boolCustomInput = (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~placeholder as _,
  ~boolCustomClass="",
  ~isDisabled,
) => {
  <BoolInput input isDisabled boolCustomClass />
}
let revBoolInput = (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~placeholder as _,
  ~isDisabled,
) => {
  <BoolInput input isDisabled />
}
let csvInput = (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~heading: string,
  ~subHeading=?,
  ~placeholder as _,
  ~downloadFilename,
  ~downloadSampleFileClass=?,
  ~mainClassStyle=?,
  ~buttonDivClass=?,
  ~widthClass=?,
  ~sampleFileContent,
  ~fileNameKey=?,
  ~regex=?,
  ~ignoreEmptySpace=?,
  ~validateData=?,
  ~removeSampleDataAfterUpload=?,
  (),
) => {
  <CsvInputField
    input
    heading
    ?subHeading
    downloadFilename
    ?downloadSampleFileClass
    ?mainClassStyle
    ?buttonDivClass
    ?widthClass
    ?fileNameKey
    ?regex
    ?validateData
    ?ignoreEmptySpace
    sampleFileContent
    ?removeSampleDataAfterUpload
  />
}

let multiLineTextInput = (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~placeholder,
  ~isDisabled,
  ~rows,
  ~cols,
  ~customClass="text-lg",
  ~leftIcon=?,
  ~maxLength=?,
  (),
) => {
  <MultiLineTextInput ?maxLength input placeholder isDisabled ?rows ?cols customClass ?leftIcon />
}

let fieldWithMessage = (
  mainInputField,
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~placeholder,
  ~getMessage,
  ~messageClass="",
  (),
) => {
  <div>
    <div> {mainInputField(~input, ~placeholder)} </div>
    {switch input.value->getMessage {
    | Some(str) => <div className=messageClass> {React.string(str)} </div>
    | None => React.null
    }}
  </div>
}
let iconFieldWithMessageDes = (
  mainInputField,
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~placeholder,
  ~description="",
  (),
) => {
  <div>
    <div> {mainInputField(~input, ~placeholder)} </div>
    <div>
      {switch description {
      | "" => React.null
      | _ =>
        <div
          className="pt-2 pb-2 text-sm text-bold text-jp-gray-900 text-opacity-50 dark:text-jp-gray-text_darktheme dark:text-opacity-50 ">
          {React.string(description)}
        </div>
      }}
    </div>
  </div>
}

let passwordCreateField = (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~placeholder,
  ~leftIcon=?,
  (),
) => {
  <PasswordStrengthInput input placeholder ?leftIcon />
}
let passwordFieldWithCheckWindow = (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~placeholder,
  ~leftIcon=?,
  ~autoComplete=?,
  ~customStyle="",
  ~customPaddingClass="",
  ~customTextStyle="",
  ~specialCharatersInfoText="",
  ~customDashboardClass=?,
  (),
) => {
  <PasswordStrengthCheckAsWindow
    input
    placeholder
    ?leftIcon
    ?autoComplete
    customStyle
    customPaddingClass
    customTextStyle
    specialCharatersInfoText
    ?customDashboardClass
  />
}

let passwordFieldWithCheckChips = (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~placeholder,
  ~leftIcon=?,
  ~autoComplete=?,
  ~customStyle="",
  ~customPaddingClass="",
  ~customTextStyle="",
  ~specialCharatersInfoText="",
  ~customDashboardClass=?,
  (),
) => {
  <PasswordStrengthInputAsChips
    input
    placeholder
    ?leftIcon
    ?autoComplete
    customStyle
    customPaddingClass
    customTextStyle
    specialCharatersInfoText
    ?customDashboardClass
  />
}
let passwordMatchField = (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~placeholder,
  ~leftIcon=?,
  (),
) => {
  <PasswordStrengthInput input placeholder displayStatus=false ?leftIcon />
}
