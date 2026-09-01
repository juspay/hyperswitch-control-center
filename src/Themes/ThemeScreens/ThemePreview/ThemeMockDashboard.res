open ThemePreviewUtils
open Typography
open ThemePreviewHelper
open ThemePreviewTypes

@react.component
let make = (~logoUrl: option<string>=?, ~faviconUrl: option<string>=?) => {
  let formState = ReactFinalForm.useFormState(
    ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
  )
  let formValues = formState.values->LogicUtils.getDictFromJsonObject
  let (colorsFromForm, sidebarFromForm, buttonsFromForm) = getThemeFormValues(~formValues)

  <div className="bg-white rounded-lg overflow-hidden w-full shadow-xl h-full flex flex-col">
    <MockBrowserChrome faviconUrl />
    <div className="flex flex-1 min-h-0">
      <MockOrgTiles sidebarFromForm orgs=mockValues.orgs />
      <div
        className="w-36 flex flex-col border-r bg-nd_gray-50"
        style={ReactDOM.Style.make(~backgroundColor=sidebarFromForm.primary, ())}>
        <div className="p-2 pt-3 border-b border-gray-200">
          <div
            className={`${body.xs.semibold}`}
            style={ReactDOM.Style.make(~color=sidebarFromForm.textColor, ())}>
            {React.string(mockValues.merchantName)}
          </div>
        </div>
        <nav className="flex-1 py-1">
          {sidebarItems
          ->Array.mapWithIndex((item, index) => <MockSidebarItem item index sidebarFromForm />)
          ->React.array}
        </nav>
        <div className="p-3 border-t flex items-center gap-2">
          <span
            className={`rounded-full bg-nd_gray-600 w-4 h-4 flex items-center justify-center ${body.xs.medium} text-white`}>
            <Icon name="user" size=8 />
          </span>
          <span
            className={`text-nd_gray-600 truncate ${body.xs.medium}`}
            style={ReactDOM.Style.make(~color=sidebarFromForm.textColor, ())}>
            {React.string(mockValues.userEmail)}
          </span>
          <Icon name="chevron-down" size=10 className="text-nd_gray-400" />
        </div>
      </div>
      <div className="flex-1 flex flex-col overflow-hidden">
        <MockNavbar logoUrl />
        <div className="p-2">
          <span className={`text-nd_gray-800 ${body.sm.semibold}`}>
            {React.string(mockValues.pageHeading)}
          </span>
          <p className={`text-nd_gray-600 mb-4 ${body.xs.medium}`}>
            {React.string(mockValues.pageDescription)}
          </p>
        </div>
        <div className="p-2 m-2 rounded-lg border-nd_gray-50 border flex flex-col gap-0.5">
          <span className={`${body.xs.semibold}`}> {React.string(mockValues.cardHeading)} </span>
          <span className={`${body.xs.medium} text-nd_gray-400`}>
            {React.string(mockValues.cardDescription)}
          </span>
          <div className={`flex flex-row gap-2 mt-2 ${body.xs.semibold}`}>
            <MockButton
              text=mockValues.primaryButtonText
              backgroundColor=buttonsFromForm.primary.backgroundColor
              hoverBackgroundColor=buttonsFromForm.primary.hoverBackgroundColor
              textColor=buttonsFromForm.primary.textColor
            />
            <MockButton
              text=mockValues.secondaryButtonText
              backgroundColor=buttonsFromForm.secondary.backgroundColor
              hoverBackgroundColor=buttonsFromForm.secondary.hoverBackgroundColor
              textColor=buttonsFromForm.secondary.textColor
            />
          </div>
        </div>
        <span
          className={`px-2 mt-2 cursor-pointer ${body.xs.semibold}`}
          style={ReactDOM.Style.make(~color=colorsFromForm.primary, ())}>
          {React.string(mockValues.linkText)}
        </span>
      </div>
    </div>
  </div>
}
