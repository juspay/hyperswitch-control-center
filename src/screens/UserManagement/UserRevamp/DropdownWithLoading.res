open HeadlessUI

type dropDownState = Loading | Success | NoData

let commonDropdownCss = "absolute md:max-h-36 md:min-h-fit overflow-scroll z-30 w-full bg-white rounded-sm shadow-lg  focus:outline-none my-1 border border-jp-gray-lightmode_steelgray border-opacity-75  ring-1 ring-black ring-opacity-5"

module DropDownItems = {
  @react.component
  let make = (~options: array<SelectBox.dropdownOption>, ~formKey, ~keyValueFromForm) => {
    let form = ReactFinalForm.useForm()
    let onItemSelect = value => {
      form.change(formKey, value->Identity.genericTypeToJson)
    }
    <Menu.Items className={`divide-y divide-gray-100 ${commonDropdownCss}`}>
      {_ => {
        <div className="px-1 py-1 ">
          {options
          ->Array.mapWithIndex((option, i) =>
            <Menu.Item key={i->Int.toString}>
              {props =>
                <div className="relative">
                  <div
                    onClick={_ => option.value->onItemSelect}
                    className={
                      let activeClasses = if props["active"] {
                        "group flex justify-between rounded-md items-center w-full px-2 py-2 text-sm bg-gray-100 dark:bg-black"
                      } else {
                        "group flex justify-between rounded-md items-center w-full px-2 py-2 text-sm"
                      }
                      `${activeClasses} font-medium text-start`
                    }>
                    <div className="mr-5">
                      {option.label
                      ->LogicUtils.snakeToTitle
                      ->React.string}
                    </div>
                    <Tick isSelected={keyValueFromForm === option.value} />
                  </div>
                </div>}
            </Menu.Item>
          )
          ->React.array}
        </div>
      }}
    </Menu.Items>
  }
}

module DropDownLoading = {
  @react.component
  let make = () => {
    <div className={`${commonDropdownCss} flex flex-col justify-center items-center p-6 gap-4`}>
      <div className={`flex flex-col text-center items-center animate-spin `}>
        <Icon name="spinner" size=20 />
      </div>
      <p className="text-gray-600"> {"Fetching data..."->React.string} </p>
    </div>
  }
}

module DropDownNoData = {
  @react.component
  let make = () => {
    <div className={`${commonDropdownCss} flex justify-center items-center p-6`}>
      <p className="text-semibold text-gray-600 opacity-60">
        {"No data to display"->React.string}
      </p>
    </div>
  }
}

@react.component
let make = (
  ~options: array<SelectBox.dropdownOption>,
  ~onClickDropDownApi,
  ~formKey,
  ~dropDownLoaderState: dropDownState,
  ~isRequired=false,
) => {
  open LogicUtils

  let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
    ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
  )
  let keyValueFromForm = formState.values->getDictFromJsonObject->getString(formKey, "")

  let getNameByLabel = value => {
    let filteredValueFromForm = options->Array.find(v => v.value === value)
    switch filteredValueFromForm {
    | Some(value) => value.label->snakeToTitle
    | None => "Select a role"
    }
  }

  let buttonValue = React.useMemo(() => {
    switch formState.values->getDictFromJsonObject->Dict.get(formKey) {
    | Some(value) => getNameByLabel(value->getStringFromJson(""))
    | None => "Select a role"
    }
  }, [keyValueFromForm])

  <Menu \"as"="div" className="relative inline-block text-left p-1">
    {_ => <>
      <Menu.Button className="w-full">
        {props => {
          let arrow = props["open"]
          <div className="w-full flex flex-col">
            <div
              className="flex justify-start pt-2 pb-2 text-fs-13 text-jp-gray-900 ml-1 font-semibold">
              {"Role"->React.string}
              <RenderIf condition=isRequired>
                <span className="text-red-950"> {React.string("*")} </span>
              </RenderIf>
            </div>
            <div
              className="relative inline-flex whitespace-pre leading-5 justify-between text-sm py-3 px-4 font-medium rounded-md hover:bg-opacity-80 bg-white border w-full"
              onClick={_ => {
                if arrow {
                  onClickDropDownApi()->ignore
                }
              }}>
              <span
                className="px-1 text-fs-13 text-sm font-medium leading-5  whitespace-pre !text-gray-500">
                {buttonValue->React.string}
              </span>
              <Icon
                className={`transition duration-[250ms] ml-1 mt-1 opacity-60 ${arrow
                    ? "rotate-0"
                    : "rotate-180"}`}
                name="arrow-without-tail"
                size=15
              />
            </div>
          </div>
        }}
      </Menu.Button>
      <Transition
        \"as"="div"
        className="relative"
        enter="transition ease-out duration-100"
        enterFrom="transform opacity-0 scale-95"
        enterTo="transform opacity-100 scale-100"
        leave="transition ease-in duration-75"
        leaveFrom="transform opacity-100 scale-100"
        leaveTo="transform opacity-0 scale-95">
        {switch dropDownLoaderState {
        | Success => <DropDownItems options keyValueFromForm formKey />
        | Loading => <DropDownLoading />
        | NoData => <DropDownNoData />
        }}
      </Transition>
    </>}
  </Menu>
}
