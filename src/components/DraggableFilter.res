type rec options = {
  title: string,
  value: string,
  options: option<array<options>>,
}

external formToArray: 'a => ReactEvent.Form.t = "%identity"

module TypeText = {
  @react.component
  let make = () => {
    <svg fill="none" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 22 22">
      <path
        d="M18 14.894V9.78c0-2.119-3.77-2.119-4.308-.53"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
      />
      <path
        d="M18 11.367c-2.543-.53-4.577.045-4.577 1.78 0 2.257 3.77 1.853 4.577.424v-2.204z"
        stroke="currentColor"
        strokeWidth="1.5"
      />
      <path
        d="M4 15l1.077-3M11 15l-1.077-3m0 0L7.86 6.253A.383.383 0 007.5 6v0a.383.383 0 00-.36.253L5.077 12m4.846 0H5.077"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
      />
    </svg>
  }
}
type ob = {
  field: string,
  values: array<string>,
  relation: string,
}

type obL1 = {
  field: string,
  values: array<ob>,
  relation: string,
}
module ShowItemView = {
  let ruleSet = ["IS", "IS NOT", "CONTAINS", "DOES NOT CONTAIN"]
  @react.component
  let make = (~item: ob, ~options, ~setData, ~index, ~i2) => {
    let (endSelected, setEndSelected) = React.useState(_ => item.values)
    let (showSelect, setSelect) = React.useState(_ => false)
    let (ruleSelected, setRuleSelected) = React.useState(_ => item.relation)
    let (showRuleDropDown, setRuleDropDown) = React.useState(_ => false)
    React.useEffect1(() => {
      setEndSelected(_ => item.values)
      None
    }, [item])

    let onClick = _ => {
      setData(old =>
        old->Js.Array2.mapi((x, i) =>
          if i == index {
            let newVal = {
              let a: obL1 = {
                field: x.field,
                values: {
                  let arrN = x.values->Js.Array2.mapi(
                    (ob, iN) =>
                      if iN == i2 {
                        let newOb: ob = {
                          field: ob.field,
                          values: endSelected,
                          relation: ruleSelected,
                        }
                        newOb
                      } else {
                        ob
                      },
                  )
                  arrN
                },
                relation: x.relation,
              }
              a
            }

            newVal
          } else {
            x
          }
        )
      )
      setSelect(_ => false)
    }
    // find the item,let user choose value
    let optionSelected = options->Js.Array2.filter(x => x.value == item.field)->Belt.Array.get(0)

    let getArrStr = () => {
      switch optionSelected {
      | Some(opt) =>
        switch opt.options {
        | Some(arr) =>
          arr
          ->Js.Array2.filter(x => endSelected->Js.Array2.includes(x.value))
          ->Js.Array2.map(x => x.title)
          ->Js.Array2.joinWith(", ")
        | None => ""
        }
      | None => ""
      }
    }
    switch optionSelected {
    | Some(data) =>
      <div>
        <div className="flex gap-2">
          <div className="h-[20px] w-[20px]">
            <TypeText />
          </div>
          {React.string(data.title)}
        </div>
        {switch data.options {
        | Some(opts) =>
          showSelect
            ? <div className="flex">
                {showRuleDropDown
                  ? <SelectBox.BaseRadio
                      options={ruleSet->SelectBox.makeOptions}
                      onSelect={str => {
                        setRuleSelected(_ => str)
                        setRuleDropDown(_ => false)
                        setData(old =>
                          old->Js.Array2.mapi((x, i) =>
                            if i == index {
                              let newVal = {
                                let a: obL1 = {
                                  field: x.field,
                                  values: {
                                    let arrN = x.values->Js.Array2.mapi(
                                      (ob, iN) =>
                                        if iN == i2 {
                                          let newOb: ob = {
                                            field: ob.field,
                                            values: endSelected,
                                            relation: str,
                                          }
                                          newOb
                                        } else {
                                          ob
                                        },
                                    )
                                    arrN
                                  },
                                  relation: x.relation,
                                }
                                a
                              }

                              newVal
                            } else {
                              x
                            }
                          )
                        )
                      }}
                      value={ruleSelected->Js.Json.string}
                      isDropDown=false
                      deselectDisable=true
                    />
                  : <Button
                      buttonType=Secondary
                      showBorder=false
                      text={ruleSelected}
                      onClick={_ => {setRuleDropDown(_ => true)}}
                    />}
                <div className="mb-2">
                  <SelectBox.BaseSelect
                    isDropDown=false
                    options={opts->Js.Array2.map(x => {
                      let a: SelectBox.dropdownOption = {
                        label: x.title,
                        value: x.value,
                      }
                      a
                    })}
                    onSelect={arr => {
                      setEndSelected(_ => arr)
                    }}
                    value={endSelected->Js.Json.stringArray}
                    showSelectAll=false
                    showSerialNumber=true
                    maxHeight="max-h-full"
                    searchable=true
                    searchInputPlaceHolder={`Search in  options`}
                    customStyle="px-2 py-1"
                    customSearchStyle="bg-white dark:bg-jp-gray-lightgray_background"
                  />
                  <Button buttonType=Primary text={`Apply`} onClick />
                </div>
              </div>
            : <div className="flex">
                {showRuleDropDown
                  ? <SelectBox.BaseRadio
                      options={ruleSet->SelectBox.makeOptions}
                      onSelect={str => {
                        setRuleSelected(_ => str)
                        setRuleDropDown(_ => false)
                        setData(old =>
                          old->Js.Array2.mapi((x, i) =>
                            if i == index {
                              let newVal = {
                                let a: obL1 = {
                                  field: x.field,
                                  values: {
                                    let arrN = x.values->Js.Array2.mapi(
                                      (ob, iN) =>
                                        if iN == i2 {
                                          let newOb: ob = {
                                            field: ob.field,
                                            values: endSelected,
                                            relation: str,
                                          }
                                          newOb
                                        } else {
                                          ob
                                        },
                                    )
                                    arrN
                                  },
                                  relation: x.relation,
                                }
                                a
                              }

                              newVal
                            } else {
                              x
                            }
                          )
                        )
                      }}
                      value={ruleSelected->Js.Json.string}
                      isDropDown=false
                      deselectDisable=true
                    />
                  : <Button
                      buttonType=Secondary
                      showBorder=false
                      text={ruleSelected}
                      onClick={_ => {setRuleDropDown(_ => true)}}
                    />}
                <Button
                  buttonType=Secondary
                  showBorder=false
                  text={`${Js.Array.length(endSelected) == 0 ? "Select Values" : getArrStr()}`}
                  onClick={_ => {setSelect(_ => true)}}
                />
              </div>
        | None => React.null
        }}
      </div>

    | None => React.null
    }
  }
}
module RenderOption = {
  let ruleSet = ["AND", "OR"]
  @react.component
  let make = (~isDragging, ~index, ~data, ~setData, ~options) => {
    let selectedOption = options->Js.Array2.filter(x => x.value == data.field)->Belt.Array.get(0)
    let (selectedRule, setSelectedRule) = React.useState(_ => data.relation)
    React.useEffect1(() => {
      setSelectedRule(_ => data.relation)
      None
    }, [data])

    let (showAddView, setAddView) = React.useState(_ => false)
    let optionsN = switch selectedOption {
    | Some(option) =>
      switch option.options {
      | Some(opt) => opt
      | None => []
      }
    | None => []
    }

    let selectedOpts = data.values

    let style = isDragging ? "border rounded-md bg-jp-gray-100 dark:bg-jp-gray-950" : ""
    let onClickCross = _ => {
      setData(p => p->Js.Array2.filteri((_v, i) => i !== index))
    }
    let onFilter = _ => setAddView(_ => true)
    switch selectedOption {
    | Some(optionData) =>
      <div
        className={`mt-2 px-3   text-jp-gray-900 dark:text-jp-gray-600 border-jp-gray-500 dark:border-jp-gray-960 border border-jp-gray-lightmode_steelgray border-opacity-75 rounded-lg
           ${style}`}>
        <div className="flex flex-row items-center justify-between h-[50px] my-2">
          <NewThemeUtils.Badge number={index + 1} />
          <div> {React.string(optionData.title)} </div>
          <div className="flex">
            <UIUtils.RenderIf condition={optionData.options->Belt.Option.isSome}>
              <div className="ml-5" onClick=onFilter>
                <Icon name="filter" size=15 />
              </div>
            </UIUtils.RenderIf>
            <div className="ml-5" onClick=onClickCross>
              <Icon name="close" size=15 />
            </div>
          </div>
        </div>
        {selectedOpts->Js.Array.length > 1
          ? <div className="m-2">
              <ButtonGroup>
                <Button
                  buttonType={selectedRule == "AND" ? Primary : Secondary}
                  showBorder=false
                  text={`AND`}
                  onClick={_ => {
                    setSelectedRule(_ => "AND")
                    setData(oldData => {
                      oldData->Js.Array2.mapi((ob, i) =>
                        i == index
                          ? {
                              let a = {
                                field: ob.field,
                                relation: "AND",
                                values: ob.values,
                              }
                              a
                            }
                          : ob
                      )
                    })
                  }}
                />
                <Button
                  buttonType={selectedRule == "OR" ? Primary : Secondary}
                  showBorder=false
                  text={`OR`}
                  onClick={_ => {
                    setSelectedRule(_ => "OR")
                    setData(oldData => {
                      oldData->Js.Array2.mapi((ob, i) =>
                        i == index
                          ? {
                              let a = {
                                field: ob.field,
                                relation: "OR",
                                values: ob.values,
                              }
                              a
                            }
                          : ob
                      )
                    })
                  }}
                />
              </ButtonGroup>
            </div>
          : React.null}
        {selectedOpts
        ->Js.Array2.mapi((item, i2) => {
          <ShowItemView item options=optionsN index setData i2 />
        })
        ->React.array}
        <UIUtils.RenderIf condition=showAddView>
          <div className="">
            <SelectBox.BaseSelect
              isDropDown=false
              options={optionsN->Js.Array2.map(x => {
                let a: SelectBox.dropdownOption = {
                  label: x.title,
                  value: x.value,
                }
                a
              })}
              onSelect={arr => {
                setData(prevData =>
                  prevData->Js.Array2.mapi((x, i) =>
                    if i == index {
                      let newOb: obL1 = {
                        field: x.field,
                        relation: selectedRule,
                        values: {
                          let initOb: ob = {
                            field: arr->Belt.Array.get(0)->Belt.Option.getWithDefault(""),
                            relation: "IS",
                            values: [],
                          }
                          Js.Array2.concat(x.values, [initOb])
                        },
                      }
                      newOb
                    } else {
                      x
                    }
                  )
                )
                setAddView(_ => false)
              }}
              value={[]->Js.Json.stringArray}
              showSelectAll=false
              showSerialNumber=true
              maxHeight="max-h-full"
              searchable=true
              searchInputPlaceHolder={`Search in  options`}
              customStyle="px-2 py-1"
              customSearchStyle="bg-white dark:bg-jp-gray-lightgray_background"
            />
          </div>
        </UIUtils.RenderIf>
      </div>
    | None => React.null
    }
  }
}

@react.component
let make = (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~options: array<options>,
  ~title: string,
) => {
  let (dataSelectedBase, setData) = React.useState(_ => [])

  let (showSideOpt, setSideOpt) = React.useState(_ => false)
  let onClick = _ => {
    setSideOpt(val => !val)
  }

  React.useEffect1(() => {
    input.onChange(dataSelectedBase->formToArray)
    None
  }, [dataSelectedBase])
  let keyExtractor = (index, data, isDragging) => {
    <RenderOption isDragging index data setData options />
  }
  <div className="w-[400px]">
    <div className="flex relative">
      <div
        className={`w-[400px] p-2 flex justify-between ${showSideOpt
            ? "bg-blue-200 border rounded-lg border-blue-200"
            : ""}`}>
        {React.string(title)}
        <Icon name="plus" size=15 onClick />
      </div>
      <UIUtils.RenderIf condition={showSideOpt}>
        <div
          className="p-2 absolute cursor-pointer origin-top border border-jp-gray-lightmode_steelgray border-opacity-75 dark:border-jp-gray-960 rounded  shadow-generic_shadow dark:shadow-generic_shadow_dark z-20  bg-gray-50 dark:bg-jp-gray-950 "
          style={ReactDOMStyle.make(~marginLeft={`410px`}, ~width="150px", ())}>
          {options
          ->Js.Array2.mapi((item, _i) =>
            <div
              className="pt-2  "
              onClick={_ => {
                let initData: obL1 = {
                  field: item.value,
                  relation: "AND",
                  values: [],
                }
                setData(old => Js.Array2.concat(old, [initData]))

                setSideOpt(_ => false)
              }}>
              {React.string(item.title)}
            </div>
          )
          ->React.array}
        </div>
      </UIUtils.RenderIf>
    </div>
    <UIUtils.RenderIf condition={Js.Array.length(dataSelectedBase) > 0}>
      <DragDropComponent
        listItems=dataSelectedBase
        setListItems={v => {
          setData(_ => v)
        }}
        keyExtractor
        isHorizontal=false
      />
    </UIUtils.RenderIf>
  </div>
}
