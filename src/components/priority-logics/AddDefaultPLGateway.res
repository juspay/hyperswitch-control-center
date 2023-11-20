open LogicUtils

@react.component
let make = (
  ~gatewayOptions,
  ~dropDownbuttonText="Default Gateways",
  ~dropDownSidetext="Default Gateways",
) => {
  let input = ReactFinalForm.useField(`json.default_gateways`).input
  let isMobileView = MatchMedia.useMobileChecker()

  let selected = input.value->getStrArryFromJson

  let length = selected->Js.Array2.length

  let buttonText =
    length === 0
      ? dropDownbuttonText
      : `${length->string_of_int} ${isMobileView ? "" : dropDownbuttonText} Selected`

  <div
    className="flex flex-col p-4 bg-white dark:bg-jp-gray-lightgray_background rounded-md border border-jp-gray-600 dark:border-jp-gray-850">
    <div
      className={`flex flex-row items-center gap-2 md:gap-6 mt-2 
        ${isMobileView ? "justify-between" : "justify-start"}`}>
      <div className={`flex flex-row items-center gap-2`}>
        <Icon
          name="arrow-rotate"
          size=14
          className="cursor-pointer text-jp-gray-700 dark:text-jp-gray-700"
          onClick={ev => ()}
        />
        <div className="text-jp-gray-700 dark:text-jp-gray-700">
          {React.string(dropDownSidetext)}
          <span className="text-red-500"> {React.string(" *")} </span>
        </div>
      </div>
      <AddDataAttributes attributes=[("data-gateway-dropdown", "DefaultGateways")]>
        <div>
          <SelectBox.BaseDropdown
            allowMultiSelect=true
            buttonText
            buttonType=Button.SecondaryFilled
            hideMultiSelectButtons=true
            input
            options={gatewayOptions}
            searchable=true
            fixedDropDownDirection=SelectBox.TopRight
            defaultLeftIcon={FontAwesome("plus")}
          />
        </div>
      </AddDataAttributes>
    </div>
    <div className="flex flex-wrap items-center gap-4 mt-4">
      {selected
      ->Array.mapWithIndex((op, i) => {
        <div className="flex flex-row items-center gap-2 my-1" key={i->Belt.Int.toString}>
          <div
            className="px-2 rounded-full bg-jp-gray-300 dark:bg-jp-gray-800 text-jp-gray-800 dark:text-white font-semibold text-sm md:text-md">
            {React.string(string_of_int(i + 1))}
          </div>
          <div> {React.string(op)} </div>
          {if i !== length - 1 {
            <Icon
              name="chevron-right"
              size=14
              className="cursor-pointer text-jp-gray-800"
              onClick={ev => ()}
            />
          } else {
            React.null
          }}
        </div>
      })
      ->React.array}
    </div>
  </div>
}
