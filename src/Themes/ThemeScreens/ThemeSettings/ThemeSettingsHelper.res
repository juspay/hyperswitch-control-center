open FormRenderer
open Typography
open ThemeFeatureUtils

// Theme color fields flip the picker above the field near the bottom of the settings box
// so it isn't clipped; fields with room below open downward as usual.
let themeColorPicker = (~defaultValue) => InputFields.colorPickerInput(~defaultValue)

module BrandSettings = {
  @react.component
  let make = (~colorsFromForm: HyperSwitchConfigTypes.colorPalette, ~isUpdatePage=false) => {
    let labelClass = `${body.md.medium} text-nd_gray-700`
    let primaryColor = makeFieldInfo(
      ~label="Primary Color",
      ~name="theme_data.settings.colors.primary",
      ~placeholder="Enter Primary Color.",
      ~customInput=themeColorPicker(~defaultValue=colorsFromForm.primary),
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
      ~customInput=themeColorPicker(~defaultValue=sidebarFromForm.primary),
    )

    let textColorSidebar = makeFieldInfo(
      ~label="Text Color",
      ~name="theme_data.settings.sidebar.textColor",
      ~placeholder="Enter sidebar text color.",
      ~customInput=themeColorPicker(~defaultValue=sidebarFromForm.textColor),
    )
    let activeItemColor = makeFieldInfo(
      ~label="Active Item Color",
      ~name="theme_data.settings.sidebar.textColorPrimary",
      ~placeholder="Enter active item color.",
      ~customInput=themeColorPicker(~defaultValue=sidebarFromForm.textColorPrimary),
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
      ~customInput=themeColorPicker(~defaultValue=buttonsFromForm.primary.backgroundColor),
    )
    let primaryButtonTextColor = makeFieldInfo(
      ~label="Text Color",
      ~name="theme_data.settings.buttons.primary.textColor",
      ~customInput=themeColorPicker(~defaultValue=buttonsFromForm.primary.textColor),
    )
    let primaryButtonHoverBackground = makeFieldInfo(
      ~label="Hover Background",
      ~name="theme_data.settings.buttons.primary.hoverBackgroundColor",
      ~customInput=themeColorPicker(~defaultValue=buttonsFromForm.primary.hoverBackgroundColor),
    )

    let secondaryButtonBackground = makeFieldInfo(
      ~label="Background",
      ~name="theme_data.settings.buttons.secondary.backgroundColor",
      ~customInput=themeColorPicker(~defaultValue=buttonsFromForm.secondary.backgroundColor),
    )
    let secondaryButtonTextColor = makeFieldInfo(
      ~label="Text Color",
      ~name="theme_data.settings.buttons.secondary.textColor",
      ~customInput=themeColorPicker(~defaultValue=buttonsFromForm.secondary.textColor),
    )
    let secondaryButtonHoverBackground = makeFieldInfo(
      ~label="Hover Background",
      ~name="theme_data.settings.buttons.secondary.hoverBackgroundColor",
      ~customInput=themeColorPicker(~defaultValue=buttonsFromForm.secondary.hoverBackgroundColor),
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

module EmailSettings = {
  @react.component
  let make = () => {
    let formValues =
      ReactFinalForm.useFormState(
        ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
      ).values->LogicUtils.getDictFromJsonObject

    let emailFromForm = ThemePreviewUtils.getEmailFormValues(~formValues)

    let labelClass = `${body.md.medium} text-nd_gray-700`

    let entityNameField = makeFieldInfo(
      ~label="Entity Name",
      ~name="email_config.entity_name",
      ~placeholder="Enter entity name for emails.",
      ~customInput=InputFields.textInput(),
    )

    let primaryColorField = makeFieldInfo(
      ~label="Primary Color",
      ~name="email_config.primary_color",
      ~placeholder="Enter primary color.",
      // Always opens downward (no auto-flip) — it's the top field in the email box.
      ~customInput=InputFields.colorPickerInput(~defaultValue=emailFromForm.primary_color),
    )

    let foregroundColorField = makeFieldInfo(
      ~label="Foreground Color",
      ~name="email_config.foreground_color",
      ~placeholder="Enter foreground color.",
      ~customInput=themeColorPicker(~defaultValue=emailFromForm.foreground_color),
    )

    let backgroundColorField = makeFieldInfo(
      ~label="Background Color",
      ~name="email_config.background_color",
      ~placeholder="Enter background color.",
      ~customInput=themeColorPicker(~defaultValue=emailFromForm.background_color),
    )

    <div className="flex flex-col gap-4">
      <div className={`${body.lg.semibold}`}> {React.string("Email Settings")} </div>
      <div className="space-y-4">
        <FormRenderer.FieldRenderer field=entityNameField labelClass />
        <FormRenderer.FieldRenderer field=primaryColorField labelClass />
        <FormRenderer.FieldRenderer field=foregroundColorField labelClass />
        <FormRenderer.FieldRenderer field=backgroundColorField labelClass />
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
    ~hint: string="",
  ) => {
    <div className="flex items-start justify-between gap-3">
      <div className="flex flex-col gap-1 min-w-0">
        <div className={`${body.md.medium} text-nd_gray-700`}> {React.string(label)} </div>
        <RenderIf condition={hint->LogicUtils.isNonEmptyString}>
          <div className={`flex items-center gap-1 text-nd_red-500 ${body.xs.regular}`}>
            <Icon name="nd-info-circle" size=12 className="text-nd_red-500" />
            {React.string(hint)}
          </div>
        </RenderIf>
      </div>
      {switch displayUrl {
      | Some(url) => {
          let imgSrc = getImgSrc(url, ~themeConfigVersion)
          <div className="relative w-12 h-12 shrink-0">
            <div
              className="w-12 h-12 border border-nd_gray-200 rounded-lg flex items-center justify-center overflow-hidden bg-white">
              <img src={imgSrc} alt={label} className="max-w-full max-h-full object-contain" />
            </div>
            <div
              onClick={_ => onRemove()}
              className="absolute -top-2 -right-2 w-5 h-5 rounded-full bg-nd_gray-800 border-2 border-white flex items-center justify-center cursor-pointer">
              <Icon name="nd-cross" size=10 className="text-white" />
            </div>
          </div>
        }
      | None => <RawFileInput accept inputId onChange=onFileChange />
      }}
    </div>
  }
}

module IconSettings = {
  @react.component
  let make = (
    ~assets: ThemeTypes.assets,
    ~mode: [#Dashboard | #Email]=#Dashboard,
    ~onLogoSelect: JSON.t => unit=_ => (),
    ~onLogoRemove: unit => unit=() => (),
    ~onFaviconSelect: JSON.t => unit=_ => (),
    ~onFaviconRemove: unit => unit=() => (),
    ~onEmailLogoSelect: JSON.t => unit=_ => (),
    ~onEmailLogoRemove: unit => unit=() => (),
    ~themeConfigVersion,
  ) => {
    let showToast = ToastState.useShowToast()

    let logoAccept = ".png,.jpg,.jpeg"
    let faviconAccept = ".png,.ico,.jpg,.jpeg"
    let emailLogoAccept = ".png,.jpg,.jpeg"

    let handleFileChange = (~onSelect, ~accept, ev) => {
      switch ThemeFeatureUtils.getFileFromEvent(ev) {
      | Some(file) =>
        if !ThemeFeatureUtils.isSupportedAssetType(~fileName=file["name"], ~accept) {
          showToast(
            ~message=`Unsupported file type. Allowed: ${accept}`,
            ~toastType=ToastState.ToastError,
          )
        } else if file["size"] > ThemeFeatureUtils.maxAssetFileSizeBytes {
          showToast(
            ~message="Image must be under 2MB. Please choose a smaller file.",
            ~toastType=ToastState.ToastError,
          )
        } else {
          onSelect(file)
        }
      | None => ()
      }
    }

    switch mode {
    | #Dashboard =>
      <div className="flex flex-col gap-4">
        <div className={`${body.lg.semibold}`}> {React.string("Icons")} </div>
        <div className="space-y-4">
          <AssetField
            label="Logo"
            displayUrl={getAssetDisplayUrl(assets.logo)}
            onFileChange={ev => handleFileChange(~onSelect=onLogoSelect, ~accept=logoAccept, ev)}
            onRemove=onLogoRemove
            accept=logoAccept
            inputId="logoFileInput"
            themeConfigVersion
            hint="PNG or JPG · Recommended: 200 × 50 px · Up to 2MB"
          />
          <AssetField
            label="Favicon"
            displayUrl={getAssetDisplayUrl(assets.favicon)}
            onFileChange={ev =>
              handleFileChange(~onSelect=onFaviconSelect, ~accept=faviconAccept, ev)}
            onRemove=onFaviconRemove
            accept=faviconAccept
            inputId="faviconFileInput"
            themeConfigVersion
            hint="PNG, ICO or JPG · Recommended 32×32px · Up to 2MB"
          />
        </div>
      </div>
    | #Email =>
      <div className="flex flex-col gap-4">
        <div className={`${body.lg.semibold}`}> {React.string("Email Icons")} </div>
        <div className="space-y-4">
          <AssetField
            label="Email Logo"
            displayUrl={getAssetDisplayUrl(assets.emailLogo)}
            onFileChange={ev =>
              handleFileChange(~onSelect=onEmailLogoSelect, ~accept=emailLogoAccept, ev)}
            onRemove=onEmailLogoRemove
            accept=emailLogoAccept
            inputId="emailLogoFileInput"
            themeConfigVersion
            hint="PNG or JPG · Recommended: 200 × 50 px · Up to 2MB"
          />
        </div>
      </div>
    }
  }
}
