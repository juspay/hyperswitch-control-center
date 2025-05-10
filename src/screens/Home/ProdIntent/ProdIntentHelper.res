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
