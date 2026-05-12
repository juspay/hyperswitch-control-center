open FormRenderer
open Typography
open ThemeFeatureUtils

module BrandSettings = {
  @react.component
  let make = (~colorsFromForm: HyperSwitchConfigTypes.colorPalette, ~isUpdatePage=false) => {
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
        <RenderIf condition={!isUpdatePage}>
          <FormRenderer.FieldRenderer field=themeNameField labelClass />
        </RenderIf>
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
    ~displayUrl: option<string>,
    ~onFileChange: ReactEvent.Form.t => unit,
    ~onRemove: unit => unit,
    ~accept: string,
    ~inputId: string,
    ~themeConfigVersion: option<string>,
  ) => {
    <div className="flex flex-col gap-2">
      <div className={`${body.md.medium} text-nd_gray-700`}> {React.string(label)} </div>
      <div className="flex items-center gap-3">
        {switch displayUrl {
        | Some(url) => {
            let imgSrc = getImgSrc(url, ~themeConfigVersion)
            <>
              <div
                className="w-16 h-16 border border-nd_gray-200 rounded-md flex items-center justify-center overflow-hidden bg-white">
                <img src={imgSrc} alt={label} className="max-w-full max-h-full object-contain" />
              </div>
              <div onClick={_ => onRemove()}>
                <Icon name="nd-cross" size=16 className="text-nd_gray-500 cursor-pointer" />
              </div>
            </>
          }
        | None =>
          <RawFileInput buttonText={`Upload ${label}`} accept inputId onChange=onFileChange />
        }}
      </div>
    </div>
  }
}

module IconSettings = {
  @react.component
  let make = (
    ~assets: ThemeTypes.assets,
    ~onLogoSelect: JSON.t => unit,
    ~onLogoRemove: unit => unit,
    ~onFaviconSelect: JSON.t => unit,
    ~onFaviconRemove: unit => unit,
    ~themeConfigVersion,
  ) => {
    let getDisplayUrl = (asset: option<ThemeTypes.assetValue>) =>
      asset->Option.map(value =>
        switch value {
        | Url(url) => url
        | File(file) =>
          DownloadUtils.createObjectURL(
            (file->Identity.jsonToAnyType: DownloadUtils.blobInstanceType),
          )
        }
      )

    let handleFileChange = (onSelect, ev) =>
      ThemeFeatureUtils.getFileFromEvent(ev)->Option.forEach(onSelect)

    <div className="flex flex-col gap-4">
      <div className={`${body.lg.semibold}`}> {React.string("Icons")} </div>
      <div className="space-y-4">
        <AssetField
          label="Logo"
          displayUrl={getDisplayUrl(assets.logo)}
          onFileChange={ev => handleFileChange(onLogoSelect, ev)}
          onRemove=onLogoRemove
          accept=".png,.jpg,.jpeg"
          inputId="logoFileInput"
          themeConfigVersion
        />
        <AssetField
          label="Favicon"
          displayUrl={getDisplayUrl(assets.favicon)}
          onFileChange={ev => handleFileChange(onFaviconSelect, ev)}
          onRemove=onFaviconRemove
          accept=".png,.ico,.jpg,.jpeg"
          inputId="faviconFileInput"
          themeConfigVersion
        />
      </div>
    </div>
  }
}
