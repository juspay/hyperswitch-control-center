let productOptions = [
  ("orchestration", "Orchestration"),
  ("recon", "Reconciliation"),
  ("dynamic_routing", "Intelligent Routing"),
  ("recovery", "Revenue Recovery"),
  ("cost_observability", "Cost Observability"),
]

module ProductSelector = {
  @react.component
  let make = () => {
    let form = ReactFinalForm.useForm()
    let fieldInput = ReactFinalForm.useField("selected_products").input
    let selectedProducts =
      fieldInput.value->LogicUtils.getStrArrayFromJson

    let allSelected = selectedProducts->Array.length === productOptions->Array.length

    let updateProducts = updated => {
      form.change(
        "selected_products",
        updated->Array.map(JSON.Encode.string)->JSON.Encode.array,
      )
    }

    let toggleProduct = product => {
      let updated = if selectedProducts->Array.includes(product) {
        selectedProducts->Array.filter(p => p !== product)
      } else {
        selectedProducts->Array.concat([product])
      }
      updateProducts(updated)
    }

    let toggleAll = () => {
      let updated = if allSelected {
        []
      } else {
        productOptions->Array.map(((value, _)) => value)
      }
      updateProducts(updated)
    }

    let unselectedProducts =
      productOptions->Array.filter(((value, _)) => !(selectedProducts->Array.includes(value)))

    <div className="flex flex-col gap-4">
      <div className="flex items-center justify-between">
        <p className="text-sm font-medium text-gray-700">
          {"Request production access for:"->React.string}
        </p>
        <label className="inline-flex items-center gap-2 cursor-pointer">
          <div className="relative">
            <input
              type_="checkbox"
              className="sr-only peer"
              checked={allSelected}
              onChange={_ => toggleAll()}
            />
            <div
              className="w-9 h-5 bg-gray-200 rounded-full peer-checked:bg-blue-600 after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:rounded-full after:h-4 after:w-4 after:transition-all peer-checked:after:translate-x-full"
            />
          </div>
          <span className="text-sm text-gray-600"> {"All products"->React.string} </span>
        </label>
      </div>
      <div
        className="flex flex-wrap gap-2 min-h-10 p-3 rounded-lg bg-gray-50 border border-gray-200">
        {if selectedProducts->Array.length > 0 {
          productOptions
          ->Array.filter(((value, _)) => selectedProducts->Array.includes(value))
          ->Array.map(((value, label)) =>
            <button
              key={value}
              type_="button"
              className="flex items-center gap-1.5 px-3 py-1.5 rounded-full text-sm bg-white border border-gray-300 text-gray-700 cursor-pointer hover:bg-gray-50"
              onClick={_ => toggleProduct(value)}>
              {label->React.string}
              <Icon name="times" size=10 />
            </button>
          )
          ->React.array
        } else {
          <span className="text-sm text-gray-400 py-1.5">
            {"Select at least one product"->React.string}
          </span>
        }}
      </div>
      <RenderIf condition={unselectedProducts->Array.length > 0}>
        <div className="flex flex-wrap gap-2">
          {unselectedProducts
          ->Array.map(((value, label)) =>
            <button
              key={value}
              type_="button"
              className="flex items-center gap-1.5 px-3 py-1.5 rounded-full text-sm border border-gray-200 text-gray-600 cursor-pointer hover:border-gray-300 hover:bg-gray-50"
              onClick={_ => toggleProduct(value)}>
              <span className="text-gray-400"> {"+"->React.string} </span>
              {label->React.string}
            </button>
          )
          ->React.array}
        </div>
      </RenderIf>
    </div>
  }
}

module CountryField = {
  @react.component
  let make = (~fieldsArray: array<ReactFinalForm.fieldRenderProps>) => {
    let businessLocationField = (
      fieldsArray[0]->Option.getOr(ReactFinalForm.fakeFieldRenderProps)
    ).input
    let businessCountryNameField = (
      fieldsArray[1]->Option.getOr(ReactFinalForm.fakeFieldRenderProps)
    ).input

    let input: ReactFinalForm.fieldRenderPropsInput = {
      name: "string",
      onBlur: _ => (),
      onChange: ev => {
        let stringVal = ev->Identity.formReactEventToString
        let countryName = stringVal->HubspotUtils.getNameFromList
        businessLocationField.onChange(stringVal->Identity.anyTypeToReactEvent)
        businessCountryNameField.onChange(countryName->Identity.anyTypeToReactEvent)
      },
      onFocus: _ => (),
      value: businessLocationField.value,
      checked: true,
    }

    <SelectBox.BaseDropdown
      allowMultiSelect=false
      buttonText="Select Country"
      customButtonStyle="!rounded-md !py-5"
      input
      options={CountryUtils.countriesList->Array.map(CountryUtils.getCountryOption)}
      hideMultiSelectButtons=true
      fullLength=true
      dropdownClassName={`h-64 oveflow-scroll`}
      dropdownCustomWidth="!w-full"
      addButton=false
      deselectDisable=true
    />
  }
}
