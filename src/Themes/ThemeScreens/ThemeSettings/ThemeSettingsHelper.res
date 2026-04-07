open FormRenderer
open Typography

module BrandSettings = {
  @react.component
  let make = (~colorsFromForm: HyperSwitchConfigTypes.colorPalette) => {
    let labelClass = `${body.md.medium} text-nd_gray-700`
    let primaryColor = makeFieldInfo(
      ~label="Primary Color",
      ~name="theme_data.settings.colors.primary",
      ~placeholder="Enter Primary Color.",
      ~customInput=InputFields.colorPickerInput(~defaultValue=colorsFromForm.primary),
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
    let labelClass = `${body.md.medium} text-nd_gray-700`
    let backgroundSidebar = makeFieldInfo(
      ~label="Background Color",
      ~name="theme_data.settings.sidebar.primary",
      ~placeholder="Enter sidebar background color.",
      ~customInput=InputFields.colorPickerInput(~defaultValue=sidebarFromForm.primary),
    )

    let textColorSidebar = makeFieldInfo(
      ~label="Text Color",
      ~name="theme_data.settings.sidebar.textColor",
      ~placeholder="Enter sidebar text color.",
      ~customInput=InputFields.colorPickerInput(~defaultValue=sidebarFromForm.textColor),
    )
    let activeItemColor = makeFieldInfo(
      ~label="Active Item Color",
      ~name="theme_data.settings.sidebar.textColorPrimary",
      ~placeholder="Enter active item color.",
      ~customInput=InputFields.colorPickerInput(~defaultValue=sidebarFromForm.textColorPrimary),
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
    let labelClass = `${body.md.medium} text-nd_gray-700`
    let primaryButtonBackground = makeFieldInfo(
      ~label="Background",
      ~name="theme_data.settings.buttons.primary.backgroundColor",
      ~customInput=InputFields.colorPickerInput(
        ~defaultValue=buttonsFromForm.primary.backgroundColor,
      ),
    )
    let primaryButtonTextColor = makeFieldInfo(
      ~label="Text Color",
      ~name="theme_data.settings.buttons.primary.textColor",
      ~customInput=InputFields.colorPickerInput(~defaultValue=buttonsFromForm.primary.textColor),
    )
    let primaryButtonHoverBackground = makeFieldInfo(
      ~label="Hover Background",
      ~name="theme_data.settings.buttons.primary.hoverBackgroundColor",
      ~customInput=InputFields.colorPickerInput(
        ~defaultValue=buttonsFromForm.primary.hoverBackgroundColor,
      ),
    )

    let secondaryButtonBackground = makeFieldInfo(
      ~label="Background",
      ~name="theme_data.settings.buttons.secondary.backgroundColor",
      ~customInput=InputFields.colorPickerInput(
        ~defaultValue=buttonsFromForm.secondary.backgroundColor,
      ),
    )
    let secondaryButtonTextColor = makeFieldInfo(
      ~label="Text Color",
      ~name="theme_data.settings.buttons.secondary.textColor",
      ~customInput=InputFields.colorPickerInput(~defaultValue=buttonsFromForm.secondary.textColor),
    )
    let secondaryButtonHoverBackground = makeFieldInfo(
      ~label="Hover Background",
      ~name="theme_data.settings.buttons.secondary.hoverBackgroundColor",
      ~customInput=InputFields.colorPickerInput(
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

module AssetField = {
  @react.component
  let make = (
    ~label: string,
    ~originalUrl: option<string>,
    ~action: ThemeFeatureUtils.assetAction,
    ~setAction: (ThemeFeatureUtils.assetAction => ThemeFeatureUtils.assetAction) => unit,
    ~accept: string,
    ~inputId: string,
    ~themeConfigVersion: option<string>,
  ) => {
    let handleFileChange = ev => {
      let files = ReactEvent.Form.target(ev)["files"]
      switch files[0] {
      | Some(file) => setAction(_ => ThemeFeatureUtils.Updated({file: Some(file)}))
      | None => ()
      }
    }

    let handleRemove = () => {
      switch action {
      | Updated(_)
      | Unchanged =>
        setAction(_ => Updated({file: None}))
      }
    }

    let versionedUrl = switch originalUrl {
    | Some(url) => `${url}?version=${themeConfigVersion->Option.getOr("")}`
    | None => ""
    }

    let uploadInput =
      <div className="flex flex-col gap-2">
        <input type_="file" accept hidden=true onChange={handleFileChange} id={inputId} />
        <label
          htmlFor={inputId}
          className="inline-flex items-center justify-center px-4 py-2 text-sm font-medium text-nd_gray-700 bg-white border border-nd_gray-300 rounded-md hover:bg-nd_gray-50 cursor-pointer transition">
          {React.string(`Upload ${label}`)}
        </label>
      </div>

    <div className="flex flex-col gap-2">
      <div className={`${body.md.medium} text-nd_gray-700`}> {React.string(label)} </div>
      <div className="flex items-center gap-3">
        {switch action {
        | Unchanged =>
          switch originalUrl {
          | Some(_) =>
            <>
              <div
                className="w-16 h-16 border border-nd_gray-200 rounded-md flex items-center justify-center overflow-hidden bg-white">
                <img
                  src={versionedUrl} alt={label} className="max-w-full max-h-full object-contain"
                />
              </div>
              <button
                type_="button"
                onClick={_ => handleRemove()}
                className="p-2 hover:bg-nd_gray-100 rounded-md transition">
                <Icon name="nd-cross" size=16 className="text-gray-500" />
              </button>
            </>
          | None => uploadInput
          }
        | Updated({file: Some(file)}) =>
          <div className="flex items-center gap-2">
            <div className="flex items-center gap-2 text-sm text-nd_gray-600">
              <Icon name="file-icon" size=16 />
              <span> {(file->Identity.jsonToAnyType)["name"]->React.string} </span>
            </div>
            <button
              type_="button"
              onClick={_ => handleRemove()}
              className="p-2 hover:bg-nd_gray-100 rounded-md transition">
              <Icon name="nd-cross" size=16 className="text-gray-500" />
            </button>
          </div>
        | Updated({file: None}) => uploadInput
        }}
      </div>
    </div>
  }
}
open ThemeFeatureUtils
module IconSettings = {
  @react.component
  let make = (
    ~originalLogoUrl: option<string>,
    ~originalFaviconUrl: option<string>,
    ~logoAction: assetAction,
    ~setLogoAction: (assetAction => assetAction) => unit,
    ~faviconAction: assetAction,
    ~setFaviconAction: (assetAction => assetAction) => unit,
    ~themeConfigVersion,
  ) => {
    <div className="flex flex-col gap-4">
      <div className={`${body.lg.semibold}`}> {React.string("Icons")} </div>
      <div className="space-y-4">
        <AssetField
          label="Logo"
          originalUrl=originalLogoUrl
          action=logoAction
          setAction=setLogoAction
          accept=".png,.jpg,.jpeg"
          inputId="logoFileInput"
          themeConfigVersion
        />
        <AssetField
          label="Favicon"
          originalUrl=originalFaviconUrl
          action=faviconAction
          setAction=setFaviconAction
          accept=".png,.ico,.jpg,.jpeg"
          inputId="faviconFileInput"
          themeConfigVersion
        />
      </div>
    </div>
  }
}
