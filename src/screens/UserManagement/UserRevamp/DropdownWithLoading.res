open HeadlessUI

type dropDownState = Loading | Success

let commonDropdownCss = "absolute origin-bottom md:max-h-36 md:min-h-36 overflow-scroll show-scrollbar z-30 w-full origin-top-right bg-white dark:bg-jp-gray-950 rounded-sm shadow-lg ring-1 ring-black ring-opacity-5 focus:outline-none my-1"

module DropDownItems = {
  @react.component
  let make = (~options: array<SelectBox.dropdownOption>, ~formKey, ~initalFormValue, ~setArrow) => {
    let form = ReactFinalForm.useForm()
    let onItemSelect = value => {
      form.change(formKey, value->Identity.genericTypeToJson)
    }
    <Menu.Items className={`divide-y divide-gray-100 ${commonDropdownCss}`}>
      {props => {
        if props["open"] {
          setArrow(_ => true)
        } else {
          setArrow(_ => false)
        }

        <div className="px-1 py-1 ">
          {options
          ->Array.mapWithIndex((option, i) =>
            <Menu.Item key={i->Int.toString}>
              {props =>
                <div className="relative">
                  <button
                    onClick={_ => option.value->onItemSelect}
                    className={
                      let activeClasses = if props["active"] {
                        "group flex rounded-md items-center w-full px-2 py-2 text-sm bg-gray-100 dark:bg-black"
                      } else {
                        "group flex rounded-md items-center w-full px-2 py-2 text-sm"
                      }
                      `${activeClasses} font-medium text-start`
                    }>
                    <div className="mr-5"> {option.label->React.string} </div>
                  </button>
                  <RenderIf condition={initalFormValue === option.value}>
                    <Icon className={`absolute top-2 right-2 `} name="check" size=15 />
                  </RenderIf>
                </div>}
            </Menu.Item>
          )
          ->React.array}
        </div>
      }}
    </Menu.Items>
  }
}

@react.component
let make = (
  ~options: array<SelectBox.dropdownOption>,
  ~onClickDropDownApi,
  ~formKey,
  ~dropDownLoaderState: dropDownState,
) => {
  let (arrow, setArrow) = React.useState(_ => false)

  let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
    ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
  )

  let initalFormValue =
    formState.values->LogicUtils.getDictFromJsonObject->LogicUtils.getString(formKey, "")

  let getNameByLabel = value => {
    let abc = options->Array.find(v => v.value === value)
    switch abc {
    | Some(value) => value.label
    | None => "Select a role"
    }
  }

  let buttonValue = React.useMemo(() => {
    switch formState.values->LogicUtils.getDictFromJsonObject->Dict.get(formKey) {
    | Some(value) => getNameByLabel(value->LogicUtils.getStringFromJson(""))
    | None => "Select a role"
    }
  }, [initalFormValue])

  <Menu \"as"="div" className="relative inline-block text-left p-1">
    {_menuProps => <>
      <Menu.Button className="w-full">
        {_buttonProps => {
          <div className="w-full flex flex-col">
            <div
              className="flex justify-start pt-2 pb-2 text-fs-13 text-jp-gray-900 ml-1 font-semibold">
              {"Role"->React.string}
            </div>
            <div
              className="relative inline-flex whitespace-pre leading-5 justify-between text-sm py-3 px-4 font-medium rounded-md hover:bg-opacity-80 bg-white border w-full">
              <span
                className="px-1 text-fs-13 text-sm font-medium leading-5  whitespace-pre !text-gray-500">
                {buttonValue->React.string}
              </span>
              <Icon
                className={arrow
                  ? `rotate-0 transition duration-[250ms] ml-1 mt-1 opacity-60`
                  : `rotate-180 transition duration-[250ms] ml-1 mt-1 opacity-60`}
                name="arrow-without-tail"
                size=15
                onClick={_ => arrow ? () : onClickDropDownApi()->ignore}
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
        | Success => <DropDownItems options initalFormValue formKey setArrow />
        | Loading =>
          <div className={`${commonDropdownCss} flex justify-center items-center`}>
            <div className={`flex flex-col text-center items-center animate-spin `}>
              <Icon name="spinner" size=20 />
            </div>
          </div>
        }}
      </Transition>
    </>}
  </Menu>
}
