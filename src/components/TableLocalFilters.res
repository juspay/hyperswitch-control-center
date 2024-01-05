external formEventToJsonArr: ReactEvent.Form.t => array<Js.Json.t> = "%identity"

module RangeSliderLocalFilter = {
  @react.component
  let make = (
    ~filterKey,
    ~minVal: float,
    ~maxVal: float,
    ~maxSlide: ReactFinalForm.fieldRenderPropsInput,
    ~minSlide: ReactFinalForm.fieldRenderPropsInput,
  ) => {
    let (lclFiltrState, setLclFltrState) = React.useContext(DatatableContext.datatableContext)
    let dropdownRef = React.useRef(Js.Nullable.null)
    let (showDropDown, setShowDropDown) = React.useState(() => false)
    let selectedFilterVal = Dict.get(lclFiltrState, filterKey)
    let filterIconName = "bars-filter"
    let strokeColor = ""
    let rightIcon = switch selectedFilterVal {
    | Some(val) =>
      <div className="flex flex-row justify-between w-full">
        <div className="px-2 text-fs-13 font-medium truncate whitespace-pre ">
          {val
          ->Array.mapWithIndex((item, index) =>
            index > 0 ? `...${item->String.make}` : item->String.make
          )
          ->Array.reduce("", (acc, item) => acc ++ item)
          ->React.string}
        </div>
        <span className={`flex items-center `}>
          <Icon
            className="align-middle"
            name="cross"
            onClick={_ => {
              setLclFltrState(filterKey, [])
            }}
          />
        </span>
      </div>

    | None =>
      <div className="flex flex-row justify-between w-full">
        <div className="px-2 text-fs-13 font-medium truncate whitespace-pre ">
          {"All"->React.string}
        </div>
        <span className={`flex items-center `}>
          <Icon className={`align-middle ${strokeColor}`} size=12 name=filterIconName />
        </span>
      </div>
    }

    OutsideClick.useOutsideClick(
      ~refs=ArrayOfRef([dropdownRef]),
      ~isActive=showDropDown,
      ~callback=() => {
        setShowDropDown(_ => false)
      },
      (),
    )

    let min = minVal->Js.Float.toString

    let max = maxVal->Js.Float.toString

    <div className="flex relative flex-row flex-wrap">
      <div className="flex relative flex-row flex-wrap w-full">
        <div
          className="flex justify-center relative h-10 flex flex-row min-w-min items-center bg-white text-jp-gray-900 text-opacity-75 hover:shadow hover:text-jp-gray-900 hover:text-opacity-75 dark:bg-jp-gray-darkgray_background dark:hover:bg-jp-gray-950 dark:text-jp-gray-text_darktheme dark:text-opacity-50 focus:outline-none rounded-md  border border-jp-gray-950 border-opacity-20 dark:border-jp-gray-960 dark:border-opacity-100  text-jp-gray-950 hover:text-black dark:text-jp-gray-text_darktheme dark:hover:text-jp-gray-text_darktheme dark:hover:text-opacity-75 cursor-pointer px-2  w-full justify-between overflow-hidden w-full"
          type_="button"
          onClick={_ => setShowDropDown(prev => !prev)}>
          {rightIcon}
        </div>
        <UIUtils.RenderIf condition={min !== max && showDropDown}>
          <div
            ref={dropdownRef->ReactDOM.Ref.domRef}
            className=" top-3.5 px-4 pt-4 pb-2 bg-white border dark:bg-jp-gray-lightgray_background border-jp-gray-lightmode_steelgray border-opacity-75 dark:border-jp-gray-960 rounded shadow-generic_shadow dark:shadow-generic_shadow_dark mt-8 absolute border border-jp-gray-lightmode_steelgray border-opacity-75 dark:border-jp-gray-960 rounded shadow-generic_shadow dark:shadow-generic_shadow_dark z-20 ">
            <div className="flex">
              <RangeSlider min max maxSlide minSlide />
            </div>
          </div>
        </UIUtils.RenderIf>
      </div>
    </div>
  }
}

module FilterDropDown = {
  @react.component
  let make = (~val, ~arr: array<Js.Json.t>=[]) => {
    let (lclFiltrState, setLclFltrState) = React.useContext(DatatableContext.datatableContext)
    let filterIconName = "bars-filter"
    let strokeColor = ""

    // Making the options Unique
    let dummyDict = Dict.make()
    arr->LogicUtils.getStrArrayFromJsonArray->Array.forEach(item => Dict.set(dummyDict, item, ""))
    let options =
      dummyDict->Dict.keysToArray->Array.filter(item => item != "")->SelectBox.makeOptions

    let selectedValue = Dict.get(lclFiltrState, val)->Belt.Option.getWithDefault([])

    let filterInput: ReactFinalForm.fieldRenderPropsInput = {
      name: val,
      onBlur: _ev => (),
      onChange: ev => setLclFltrState(val, ev->formEventToJsonArr),
      onFocus: _ev => (),
      value: selectedValue->Js.Json.array,
      checked: true,
    }

    let (buttonText, icon) = switch selectedValue->Array.length > 0 {
    | true => (
        selectedValue->Js.Json.array->Js.Json.stringify,
        Button.CustomIcon(
          <div onClick={e => e->ReactEvent.Mouse.stopPropagation}>
            <span
              className={`flex items-center `}
              onClick={e => {
                setLclFltrState(val, [])
              }}>
              <Icon className="align-middle" name="cross" />
            </span>
          </div>,
        ),
      )
    | false => ("All", Button.Euler(filterIconName))
    }

    if options->Array.length > 1 {
      <SelectBox.BaseDropdown
        allowMultiSelect=true
        hideMultiSelectButtons=true
        buttonText
        input={filterInput}
        options
        baseComponent={<Button
          text=buttonText
          rightIcon=icon
          ellipsisOnly=true
          customButtonStyle="w-full justify-between"
          disableRipple=true
          buttonSize=Small
          buttonType=Secondary
        />}
        autoApply=true
        addButton=true
        searchable=true
        fullLength=false
        fixedDropDownDirection=SelectBox.BottomRight
        showClearAll=false
        showSelectAll=false
      />
    } else {
      <div
        className="flex justify-center relative h-10 flex flex-row min-w-min items-center bg-white text-jp-gray-900 text-opacity-75 hover:shadow hover:text-jp-gray-900 hover:text-opacity-75 dark:bg-jp-gray-darkgray_background dark:hover:bg-jp-gray-950 dark:text-jp-gray-text_darktheme dark:text-opacity-50 focus:outline-none rounded-md  border border-jp-gray-950 border-opacity-20 dark:border-jp-gray-960 dark:border-opacity-100  text-jp-gray-950 hover:text-black dark:text-jp-gray-text_darktheme dark:hover:text-jp-gray-text_darktheme dark:hover:text-opacity-75 cursor-pointer px-2  w-full justify-between overflow-hidden w-full"
        type_="button">
        <div className="max-w-[250px] md:max-w-xs">
          <div className="px-2 text-fs-13 font-medium truncate whitespace-pre ">
            {"All"->React.string}
          </div>
        </div>
        <span className={`flex items-center `}>
          <Icon className={`align-middle ${strokeColor}`} size=12 name=filterIconName />
        </span>
      </div>
    }
  }
}

module TextFilterCell = {
  @react.component
  let make = (~val) => {
    let (lclFiltrState, setLclFltrState) = React.useContext(DatatableContext.datatableContext)
    let filterIconName = "bars-filter"
    let strokeColor = ""
    let showPopUp = PopUpState.useShowPopUp()

    let selectedValue =
      Dict.get(lclFiltrState, val)
      ->Belt.Option.getWithDefault([])
      ->Belt.Array.get(0)
      ->Belt.Option.getWithDefault(""->Js.Json.string)
    let localInput = React.useMemo1((): ReactFinalForm.fieldRenderPropsInput => {
      {
        name: "--",
        onBlur: _ev => (),
        onChange: ev => {
          let value = {ev->ReactEvent.Form.target}["value"]
          if value->String.includes("<script>") || value->String.includes("</script>") {
            showPopUp({
              popUpType: (Warning, WithIcon),
              heading: `Script Tags are not allowed`,
              description: React.string(`Input cannot contain <script>, </script> tags`),
              handleConfirm: {text: "OK"},
            })
          }
          let value = value->String.replace("<script>", "")->String.replace("</script>", "")

          setLclFltrState(val, [value->Js.Json.string])
        },
        onFocus: _ev => (),
        value: selectedValue,
        checked: false,
      }
    }, [selectedValue])
    let rightIcon =
      selectedValue === ""->Js.Json.string
        ? <span className={`flex items-center `}>
            <Icon className={`align-middle ${strokeColor}`} size=12 name=filterIconName />
          </span>
        : <span
            className={`flex items-center `}
            onClick={_ => setLclFltrState(val, [""->Js.Json.string])}>
            <Icon className="align-middle" name="cross" />
          </span>

    <div className="flex">
      <TextInput
        input=localInput
        customStyle="flex justify-center h-10 flex flex-row items-center  text-opacity-50 hover:text-opacity-100  dark:hover:text-jp-gray-text_darktheme dark:hover:text-opacity-75 rounded-md border-jp-gray-500 dark:border-jp-gray-960 to-jp-gray-350 dark:from-jp-gray-lightgray_background dark:to-jp-gray-lightgray_background hover:shadow dark:text-jp-gray-text_darktheme dark:text-opacity-50 px-2  w-full justify-between "
        placeholder="All"
        isDisabled=false
        inputMode="text"
        rightIcon
      />
    </div>
  }
}

module RangeFilterCell = {
  @react.component
  let make = (~minVal, ~maxVal, ~val) => {
    let (lclFiltrState, setLclFltrState) = React.useContext(DatatableContext.datatableContext)
    let minVal = Js.Math.floor_float(minVal)
    let maxVal = Js.Math.ceil_float(maxVal)
    let selectedValueStr =
      Dict.get(lclFiltrState, val)->Belt.Option.getWithDefault([
        minVal->Js.Json.number,
        maxVal->Js.Json.number,
      ])

    let minSlide = React.useMemo1((): ReactFinalForm.fieldRenderPropsInput => {
      {
        name: "--",
        onBlur: _ev => (),
        onChange: ev => {
          let value = {ev->ReactEvent.Form.target}["value"]

          let leftVal = value->Js.Float.fromString->Js.Json.number
          let rightvalue = selectedValueStr[1]->Belt.Option.getWithDefault(Js.Json.null)
          switch selectedValueStr[1] {
          | Some(ele) => setLclFltrState(val, [leftVal > rightvalue ? rightvalue : leftVal, ele])
          | None => ()
          }
        },
        onFocus: _ev => (),
        value: selectedValueStr[0]->Belt.Option.getWithDefault(Js.Json.number(0.0)),
        checked: false,
      }
    }, [selectedValueStr])

    let maxSlide = React.useMemo1((): ReactFinalForm.fieldRenderPropsInput => {
      {
        name: "--",
        onBlur: _ev => (),
        onChange: ev => {
          let value = {ev->ReactEvent.Form.target}["value"]

          let rightvalue = value->Js.Float.fromString->Js.Json.number
          switch selectedValueStr[0] {
          | Some(ele) => setLclFltrState(val, [ele, ele > rightvalue ? ele : rightvalue])
          | None => ()
          }
        },
        onFocus: _ev => (),
        value: selectedValueStr[1]->Belt.Option.getWithDefault(Js.Json.number(0.0)),
        checked: false,
      }
    }, [selectedValueStr])

    <RangeSliderLocalFilter filterKey=val minVal maxVal maxSlide minSlide />
  }
}
