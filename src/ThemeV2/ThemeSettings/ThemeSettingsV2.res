open Typography
let makeFieldInfo = FormRenderer.makeFieldInfo
let labelClass = `${body.md.medium} text-gray-700`
// module UploadAssets = {
//   @react.component
//   let make = (~theme, ~updateTheme) => {
//     <div className="flex flex-col gap-4">
//       <div className={`${body.lg.semibold}`}> {React.string("Assets")} </div>
//       {renderImageUploader(~asset="Favicon", theme.theme_data.urls.faviconUrl, v =>
//         updateTheme(t => {
//           ...t,
//           theme_data: {
//             ...t.theme_data,
//             urls: {
//               ...t.theme_data.urls,
//               faviconUrl: Some(v),
//             },
//           },
//         })
//       )}
//       {renderImageUploader(~asset="Logo", theme.theme_data.urls.logoUrl, v =>
//         updateTheme(t => {
//           ...t,
//           theme_data: {
//             ...t.theme_data,
//             urls: {
//               ...t.theme_data.urls,
//               logoUrl: Some(v),
//             },
//           },
//         })
//       )}
//     </div>
//   }
// }

module BrandSettings = {
  @react.component
  let make = (~colorsFromForm: HyperSwitchConfigTypes.colorPalette) => {
    Js.log2("colorsFromForm", colorsFromForm)
    Js.log2("colorsFromForm.primary", colorsFromForm.primary)

    let primaryColor = makeFieldInfo(
      ~label="Primary Color",
      ~name="theme_data.settings.colors.primary",
      ~placeholder="Enter Primary Color.",
      ~customInput=InputFields.colorPickerInput(
        ~colorSquarePosition="left",
        ~defaultValue=colorsFromForm.primary,
      ),
    )

    let themeNameField = makeFieldInfo(
      ~label="Theme Name",
      ~name="theme_name",
      ~placeholder="Enter a name for your theme.",
      ~customInput=InputFields.textInput(),
    )

    <div className="flex flex-col gap-4">
      <div className={`${body.lg.semibold}`}> {React.string("Brand Settings")} </div>
      <div className="space-y-4">
        <FormRenderer.FieldRenderer field=themeNameField labelClass />
        <FormRenderer.FieldRenderer field=primaryColor labelClass />
      </div>
    </div>
  }
}

module SidebarSettings = {
  @react.component
  let make = (~sidebarFromForm: HyperSwitchConfigTypes.sidebarConfig) => {
    let backgroundSidebar = makeFieldInfo(
      ~label="Background Color",
      ~name="theme_data.settings.sidebar.primary",
      ~placeholder="Enter sidebar background color.",
      ~customInput=InputFields.colorPickerInput(
        ~colorSquarePosition="left",
        ~defaultValue=sidebarFromForm.primary,
      ),
    )

    let textColorSidebar = makeFieldInfo(
      ~label="Text Color",
      ~name="theme_data.settings.sidebar.textColor",
      ~placeholder="Enter sidebar text color.",
      ~customInput=InputFields.colorPickerInput(
        ~colorSquarePosition="left",
        ~defaultValue=sidebarFromForm.textColor,
      ),
    )
    let activeItemColor = makeFieldInfo(
      ~label="Active Item Color",
      ~name="theme_data.settings.sidebar.textColorPrimary",
      ~placeholder="Enter active item color.",
      ~customInput=InputFields.colorPickerInput(
        ~colorSquarePosition="left",
        ~defaultValue=sidebarFromForm.textColorPrimary,
      ),
    )
    <div className="flex flex-col gap-4">
      <div className={`${body.lg.semibold}`}> {React.string("Sidebar Settings")} </div>
      <div className="space-y-4">
        <FormRenderer.FieldRenderer field=backgroundSidebar labelClass />
        <FormRenderer.FieldRenderer field=textColorSidebar labelClass />
        <FormRenderer.FieldRenderer field=activeItemColor labelClass />
      </div>
    </div>
  }
}

module ButtonSettings = {
  @react.component
  let make = (~buttonsFromForm: HyperSwitchConfigTypes.buttonConfig) => {
    let primaryButtonBackground = makeFieldInfo(
      ~label="Background",
      ~name="theme_data.settings.buttons.primary.backgroundColor",
      ~customInput=InputFields.colorPickerInput(
        ~colorSquarePosition="left",
        ~defaultValue=buttonsFromForm.primary.backgroundColor,
      ),
    )
    let primaryButtonTextColor = makeFieldInfo(
      ~label="Text Color",
      ~name="theme_data.settings.buttons.primary.textColor",
      ~customInput=InputFields.colorPickerInput(
        ~colorSquarePosition="left",
        ~defaultValue=buttonsFromForm.primary.textColor,
      ),
    )
    let primaryButtonHoverBackground = makeFieldInfo(
      ~label="Hover Background",
      ~name="theme_data.settings.buttons.primary.hoverBackgroundColor",
      ~customInput=InputFields.colorPickerInput(
        ~colorSquarePosition="left",
        ~defaultValue=buttonsFromForm.primary.hoverBackgroundColor,
      ),
    )

    let secondaryButtonBackground = makeFieldInfo(
      ~label="Background",
      ~name="theme_data.settings.buttons.secondary.backgroundColor",
      ~customInput=InputFields.colorPickerInput(
        ~colorSquarePosition="left",
        ~defaultValue=buttonsFromForm.secondary.backgroundColor,
      ),
    )
    let secondaryButtonTextColor = makeFieldInfo(
      ~label="Text Color",
      ~name="theme_data.settings.buttons.secondary.textColor",
      ~customInput=InputFields.colorPickerInput(
        ~colorSquarePosition="left",
        ~defaultValue=buttonsFromForm.secondary.textColor,
      ),
    )
    let secondaryButtonHoverBackground = makeFieldInfo(
      ~label="Hover Background",
      ~name="theme_data.settings.buttons.secondary.hoverBackgroundColor",
      ~customInput=InputFields.colorPickerInput(
        ~colorSquarePosition="left",
        ~defaultValue=buttonsFromForm.secondary.hoverBackgroundColor,
      ),
    )

    <div className="flex flex-col gap-4">
      <div className={`${body.lg.semibold}`}> {React.string("Button Settings")} </div>
      <div className="flex flex-col gap-4">
        <div className={`${body.md.semibold}`}> {React.string("Primary Button")} </div>
        <div className="space-y-3 pointer-events-auto">
          <FormRenderer.FieldRenderer field=primaryButtonBackground labelClass />
          <FormRenderer.FieldRenderer field=primaryButtonTextColor labelClass />
          <FormRenderer.FieldRenderer field=primaryButtonHoverBackground labelClass />
        </div>
        <div className="flex flex-col gap-4">
          <div className={`${body.md.semibold}`}> {React.string("Secondary Button")} </div>
          <div className="space-y-3 pointer-events-auto">
            <FormRenderer.FieldRenderer field=secondaryButtonBackground labelClass />
            <FormRenderer.FieldRenderer field=secondaryButtonTextColor labelClass />
            <FormRenderer.FieldRenderer field=secondaryButtonHoverBackground labelClass />
          </div>
        </div>
      </div>
    </div>
  }
}

@react.component
let make = () => {
  let (
    _themeName,
    colorsFromForm,
    sidebarFromForm,
    buttonsFromForm,
  ) = ThemeHookV2.useThemeFormValues()

  <div className="flex flex-col gap-8 max-h-screen overflow-y-auto p-2">
    // <UploadAssets theme updateTheme />
    <BrandSettings colorsFromForm={colorsFromForm} />
    <SidebarSettings sidebarFromForm={sidebarFromForm} />
    <ButtonSettings buttonsFromForm={buttonsFromForm} />
  </div>
}
