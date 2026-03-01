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

module IconSettings = {
  @react.component
  let make = (
    ~logoUrl: option<string>,
    ~faviconUrl: option<string>,
    ~themeId as _,
    ~selectedLogoFile,
    ~setSelectedLogoFile,
    ~selectedFaviconFile,
    ~setSelectedFaviconFile,
    ~themeConfigVersion,
  ) => {
    Js.log2("logoUrl", logoUrl)
    Js.log2("faviconUrl", faviconUrl)

    let (previewLogoImage, setPreviewLogoImage) = React.useState(() => true)
    let (previewFaviconImage, setPreviewFaviconImage) = React.useState(() => true)

    let form = ReactFinalForm.useForm()

    let handleLogoFileChange = ev => {
      let files = ReactEvent.Form.target(ev)["files"]
      switch files[0] {
      | Some(file) => setSelectedLogoFile(_ => Some(file))
      | None => setSelectedLogoFile(_ => None)
      }
    }

    let handleFaviconFileChange = ev => {
      let files = ReactEvent.Form.target(ev)["files"]
      switch files[0] {
      | Some(file) => setSelectedFaviconFile(_ => Some(file))
      | None => setSelectedFaviconFile(_ => None)
      }
    }

    let url = React.useMemo1(() => {
      switch logoUrl {
      | Some(url) => `${url}?version=${themeConfigVersion->Option.getOr("")}`
      | None => ""
      }
    }, [logoUrl])


    let handleRemoveLogo = async () => {
      Js.log("Removing logo")
      setPreviewLogoImage(_ => false)
    }

    let handleRemoveFavicon = async () => {
      Js.log("Removing favicon")
      setPreviewFaviconImage(_ => false)
    }

    <div className="flex flex-col gap-4">
      <div className={`${body.lg.semibold}`}> {React.string("Icons")} </div>
      <div className="space-y-4">
        <div className="flex flex-col gap-2">
          <div className={`${body.md.medium} text-gray-700`}> {React.string("Logo")} </div>
          <div className="flex items-center gap-3">
            <RenderIf condition={previewLogoImage}>
              {<>
                <div
                  className="w-16 h-16 border border-gray-200 rounded-md flex items-center justify-center overflow-hidden bg-white">
                  <img src={url} alt="Logo" className="max-w-full max-h-full object-contain" />
                </div>
                <button
                  onClick={_ => handleRemoveLogo()->ignore}
                  className="p-2 hover:bg-gray-100 rounded-md transition">
                  <Icon name="nd-cross" size=16 className="text-gray-500" />
                </button>
              </>}
            </RenderIf>
            <RenderIf condition={!previewLogoImage}>
              <div className="flex flex-col gap-2">
                <input
                  type_="file"
                  accept=".png,.jpg,.jpeg"
                  hidden=true
                  onChange={handleLogoFileChange}
                  id="logoFileInput"
                />
                <label
                  htmlFor="logoFileInput"
                  className="inline-flex items-center justify-center px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50 cursor-pointer transition">
                  {React.string("Upload Logo")}
                </label>
                {switch selectedLogoFile {
                | Some(file) =>
                  <div className="mt-1 flex items-center gap-2 text-sm text-gray-600">
                    <Icon name="file-icon" size=16 />
                    <span> {file["name"]->React.string} </span>
                  </div>
                | None => React.null
                }}
              </div>
            </RenderIf>
          </div>
        </div>
        <div className="flex flex-col gap-2">
          <div className={`${body.md.medium} text-gray-700`}> {React.string("Favicon")} </div>
          <div className="flex items-center gap-3">
            <RenderIf condition={previewFaviconImage}>
              {<>
                <div
                  className="w-16 h-16 border border-gray-200 rounded-md flex items-center justify-center overflow-hidden bg-white">
                  <img
                    src={faviconUrl->Option.getOr("")}
                    alt="Favicon"
                    className="max-w-full max-h-full object-contain"
                  />
                </div>
                <button
                  onClick={_ => handleRemoveFavicon()->ignore}
                  className="p-2 hover:bg-gray-100 rounded-md transition">
                  <Icon name="nd-cross" size=16 />
                </button>
              </>}
            </RenderIf>
            <RenderIf condition={!previewFaviconImage}>
              {<div className="flex flex-col gap-2">
                <input
                  type_="file"
                  accept=".png,.ico,.jpg,.jpeg"
                  hidden=true
                  onChange={handleFaviconFileChange}
                  id="faviconFileInput"
                />
                <label
                  htmlFor="faviconFileInput"
                  className="inline-flex items-center justify-center px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50 cursor-pointer transition">
                  {React.string("Upload Favicon")}
                </label>
                {switch selectedFaviconFile {
                | Some(file) =>
                  <div className="mt-1 flex items-center gap-2 text-sm text-gray-600">
                    <Icon name="file-icon" size=16 />
                    <span> {file["name"]->React.string} </span>
                  </div>
                | None => React.null
                }}
              </div>}
            </RenderIf>
          </div>
        </div>
      </div>
    </div>
  }
}
