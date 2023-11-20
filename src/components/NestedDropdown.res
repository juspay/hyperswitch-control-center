type rec options = {
  title: string,
  value: string,
  options?: array<options>,
}
external formToArray: 'a => ReactEvent.Form.t = "%identity"

module RenderOption = {
  @react.component
  let make = (
    ~option,
    ~input: ReactFinalForm.fieldRenderPropsInput,
    ~selectedInd,
    ~setSelectedInd,
    ~index,
    ~depth,
    ~setMaxDepthSelection,
    ~maxDepthSelection as _,
    ~prevMaxDepthSelection as _,
    ~selectedData,
    ~setSelectedData,
    ~selectedDataVal,
    ~setSelectedDataVal,
  ) => {
    let hasOptions = option.options->Belt.Option.isSome || option.value == "timeP"

    let onClick = _ => {
      if option.value == "timeP" {
        let data = if Js.Array2.includes(selectedData, option.value) {
          selectedData->Js.Array2.filter(x => x !== option.value)
        } else {
          Js.Array2.concat(selectedData, [option.value])
        }
        let dataN = if Js.Array2.includes(selectedDataVal, option.title) {
          selectedDataVal->Js.Array2.filter(x => x !== option.title)
        } else {
          Js.Array2.concat(selectedDataVal, [option.title])
        }
        setSelectedData(_ => data)
        setSelectedDataVal(_ => dataN)
        input.onChange(data->formToArray)
      }
      if selectedInd != index {
        setSelectedInd(_ => index)
        // setPrevMaxDepthSelection(_ => maxDepthSelection)
        setMaxDepthSelection(_ => depth)
      } else {
        setSelectedInd(_ => -1)
        // setPrevMaxDepthSelection(_ => maxDepthSelection)
        setMaxDepthSelection(_ => depth - 1)
      }
    }

    if hasOptions {
      <div
        className={`w-[185px] p-2  cursor-pointer  ${selectedInd == index
            ? "bg-blue-100 border rounded"
            : ""} flex justify-between items-center`}
        onClick>
        {React.string(option.title)}
        <Icon name="angle-right" size=18 />
      </div>
    } else {
      let isSelected = selectedData->Js.Array2.indexOf(option.value) > -1
      let onClick = _ => {
        let data = if Js.Array2.includes(selectedData, option.value) {
          selectedData->Js.Array2.filter(x => x !== option.value)
        } else {
          Js.Array2.concat(selectedData, [option.value])
        }
        let dataN = if Js.Array2.includes(selectedDataVal, option.title) {
          selectedDataVal->Js.Array2.filter(x => x !== option.title)
        } else {
          Js.Array2.concat(selectedDataVal, [option.title])
        }
        setSelectedData(_ => data)
        setSelectedDataVal(_ => dataN)
      }
      <div onClick className={`w-[185px] p-2 items-center cursor-pointer flex `}>
        <CheckBoxIcon isSelected />
        <div className="ml-2"> {React.string(option.title)} </div>
      </div>
    }
  }
}
module RenderOptionList = {
  @react.component
  let rec make = (
    ~options: array<options>,
    ~input: ReactFinalForm.fieldRenderPropsInput,
    ~depth,
    ~setDepth,
    ~maxDepthSelection,
    ~setMaxDepthSelection,
    ~prevMaxDepthSelection,
    ~selectedData,
    ~setSelectedData,
    ~selectedDataVal,
    ~setSelectedDataVal,
  ) => {
    let (selectedInd, setSelectedIndOrig) = React.useState(_ => -1)
    let setSelectedInd = React.useCallback1(fn => {
      setSelectedIndOrig(fn)
      setSelectedData(_ => [])
      setSelectedDataVal(_ => [])
    }, [setSelectedIndOrig])
    let nestedOptions = React.useMemo1(() => {
      switch Belt.Array.get(options, selectedInd) {
      | Some(opt) =>
        switch opt.options {
        | Some(arr) => arr
        | None => []
        }
      | None => []
      }
    }, [selectedInd])

    // React.useEffect1(() => {

    //   None
    // }, [selectedInd])
    React.useEffect2(() => {
      if prevMaxDepthSelection > maxDepthSelection {
        setSelectedInd(_ => -1)
      }
      None
    }, (prevMaxDepthSelection, maxDepthSelection))
    let hasNestedOptions = switch Belt.Array.get(options, 1) {
    | Some(opt) =>
      switch opt.options {
      | Some(_arr) => true
      | None => false
      }
    | None => false
    }
    let onClick = _ => {
      input.onChange(selectedData->formToArray)
    }
    <>
      <div
        className="mt-2  absolute  origin-top border border-jp-gray-lightmode_steelgray border-opacity-75 dark:border-jp-gray-960 rounded  shadow-generic_shadow dark:shadow-generic_shadow_dark z-20  bg-gray-50 dark:bg-jp-gray-950 "
        style={ReactDOMStyle.make(
          ~width="200px",
          ~marginLeft={`${(depth * 200 + 5)->Belt.Int.toString}px`},
          ~marginTop={`${(depth * 35)->Belt.Int.toString}px`},
          (),
        )}>
        <div
          className="bg-white  dark:bg-jp-gray-lightgray_background w-auto overflow-auto font-medium flex flex-col p-2 ">
          <UIUtils.RenderIf condition={!hasNestedOptions}>
            {React.string("Please select 2 or more values to compare")}
          </UIUtils.RenderIf>
          {options
          ->Js.Array2.mapi((opt, index) =>
            <RenderOption
              option=opt
              input
              selectedInd
              setSelectedInd
              index
              depth
              setMaxDepthSelection
              maxDepthSelection
              prevMaxDepthSelection
              selectedData
              setSelectedData
              selectedDataVal
              setSelectedDataVal
              key={index->Belt.Int.toString}
            />
          )
          ->React.array}
          <UIUtils.RenderIf condition={!hasNestedOptions}>
            <Button
              buttonType=Primary
              text={`Compare (${selectedData->Js.Array2.length->Belt.Int.toString})`}
              onClick
              type_="submit"
            />
          </UIUtils.RenderIf>
        </div>
      </div>
      <UIUtils.RenderIf condition={Js.Array.length(nestedOptions) > 0}>
        {React.createElement(
          make,
          {
            options: nestedOptions,
            input,
            depth: {depth + 1},
            setDepth,
            maxDepthSelection,
            setMaxDepthSelection,
            prevMaxDepthSelection,
            selectedData,
            setSelectedData,
            selectedDataVal,
            setSelectedDataVal,
          },
        )}
      </UIUtils.RenderIf>
    </>
  }
}

@react.component
let make = (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~options: array<options>,
  ~title: string,
) => {
  let (showDropDown, setShowDropDown) = React.useState(_ => false)
  let (selectedData, setSelectedDataOrig) = React.useState(_ => [])
  let setSelectedData = React.useCallback1(fn => {
    setSelectedDataOrig(p => {
      let next = fn(p)
      if next->Js.Array.length == 0 && p->Js.Array.length == 0 {
        p
      } else {
        next
      }
    })
  }, [setSelectedDataOrig])
  let (selectedDataVal, setSelectedDataValOrig) = React.useState(_ => [])
  let setSelectedDataVal = React.useCallback1(fn => {
    setSelectedDataValOrig(p => {
      let next = fn(p)
      if next->Js.Array.length == 0 && p->Js.Array.length == 0 {
        p
      } else {
        next
      }
    })
  }, [setSelectedDataValOrig])
  let (btnText, setButtonText) = React.useState(_ => title)
  React.useEffect1(() => {
    setShowDropDown(_ => false)

    if selectedDataVal->Js.Array.length > 0 {
      let valStr = selectedDataVal->Js.Array2.joinWith(", ")
      setButtonText(_ => `${title}: ${valStr}`)
    }
    None
  }, [input.value])
  let (depthTuple, setDepthTuple) = React.useState(_ => (0, 0))
  let (prevMaxDepthSelection, maxDepthSelection) = depthTuple
  let setMaxDepthSelection = React.useCallback1(fn => {
    setDepthTuple(prevTuple => {
      let (_oldPrev, oldCurr) = prevTuple
      let newCurr = fn(oldCurr)
      (oldCurr, newCurr)
    })
  }, [setDepthTuple])
  // let (maxDepthSelection, setMaxDepthSelection) = React.useState(_ => 0)
  // let (prevMaxDepthSelection, setPrevMaxDepthSelection) = React.useState(_ => 0)
  let onClick = _ev => {
    setShowDropDown(val => !val)
  }
  let buttonIcon = if showDropDown {
    "angle-up"
  } else {
    "angle-down"
  }
  let (depth, setDepth) = React.useState(_ => 0)

  <div className="relative">
    <Button
      buttonType=Dropdown
      text=btnText
      customButtonStyle={`w-auto items-center ${showDropDown ? "border-blue" : ""}`}
      onClick
      rightIcon={FontAwesome(buttonIcon)}
    />
    <UIUtils.RenderIf condition=showDropDown>
      <div className="w-full flex">
        <RenderOptionList
          options
          input
          depth
          setDepth
          maxDepthSelection
          setMaxDepthSelection
          prevMaxDepthSelection
          // setPrevMaxDepthSelection
          selectedData
          setSelectedData
          selectedDataVal
          setSelectedDataVal
        />
      </div>
    </UIUtils.RenderIf>
  </div>
}
