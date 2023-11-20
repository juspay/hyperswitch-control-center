@react.component
let make = (
  ~data,
  ~filterLogic=_ => {()},
  ~placeholder,
  ~searchVal,
  ~setSearchVal,
  ~customSearchBarWrapperWidth="w-1/4",
  ~customInputBoxWidth="w-72",
) => {
  let filterData = React.useCallback0(filterLogic)

  React.useEffect1(() => {
    filterData((searchVal, data))
    None
  }, [searchVal])

  let onChange = ev => {
    let value = ReactEvent.Form.target(ev)["value"]
    setSearchVal(_ => value)
  }

  let handleSubmit = (_, _) => {Js.Nullable.null->Js.Promise.resolve}

  let inputSearch: ReactFinalForm.fieldRenderPropsInput = {
    name: "name",
    onBlur: _ev => (),
    onChange,
    onFocus: _ev => (),
    value: searchVal->Js.Json.string,
    checked: true,
  }

  <div className=customSearchBarWrapperWidth>
    <ReactFinalForm.Form
      subscription=ReactFinalForm.subscribeToValues
      onSubmit=handleSubmit
      initialValues={""->Js.Json.string}
      render={_handleSubmit => {
        InputFields.textInput(
          ~input=inputSearch,
          ~placeholder,
          ~leftIcon=<Icon name="search" size=16 />,
          ~customStyle=`!h-10 ${customInputBoxWidth}`,
          (),
        )
      }}
    />
  </div>
}
