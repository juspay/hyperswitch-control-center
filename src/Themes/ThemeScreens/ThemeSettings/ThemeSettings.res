open ThemeSettingsHelper

@react.component
let make = () => {
  let formValues =
    ReactFinalForm.useFormState(
      ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
    ).values->LogicUtils.getDictFromJsonObject

  let (colorsFromForm, sidebarFromForm, buttonsFromForm) = ThemePreviewUtils.getThemeFormValues(
    ~formValues,
  )

  <div className="flex flex-col gap-8 max-h-screen overflow-y-auto p-2">
    <BrandSettings colorsFromForm={colorsFromForm} />
    <SidebarSettings sidebarFromForm={sidebarFromForm} />
    <ButtonSettings buttonsFromForm={buttonsFromForm} />
  </div>
}
