open ThemeSettingsHelper

@react.component
let make = (~isUpdatePage=false) => {
  let formValues =
    ReactFinalForm.useFormState(
      ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
    ).values->LogicUtils.getDictFromJsonObject

  let (colorsFromForm, sidebarFromForm, buttonsFromForm, _) = ThemePreviewUtils.getThemeFormValues(
    ~formValues,
  )

  <div className="flex flex-col gap-8">
    <BrandSettings colorsFromForm={colorsFromForm} isUpdatePage />
    <FontSettings />
    <SidebarSettings sidebarFromForm={sidebarFromForm} />
    <ButtonSettings buttonsFromForm={buttonsFromForm} />
  </div>
}
