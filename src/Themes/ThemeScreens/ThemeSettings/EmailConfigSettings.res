open ThemeSettingsHelper

@react.component
let make = () => {
  <div className="flex flex-col gap-8 max-h-screen overflow-y-auto p-2">
    <EmailSettings />
  </div>
}
