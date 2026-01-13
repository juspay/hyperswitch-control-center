open ThemePreviewUtils
open Typography
open ThemePreviewHelper

@react.component
let make = () => {
  let formState = ReactFinalForm.useFormState(
    ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
  )
  let formValues = formState.values->LogicUtils.getDictFromJsonObject
  let (_, sidebarFromForm, buttonsFromForm) = getThemeFormValues(~formValues)

  <div className="bg-white rounded-lg overflow-hidden w-full shadow-xl h-3/4">
    <div className="flex h-full">
      <MockOrgTiles sidebarFromForm orgs=["S", "A"] />
      <div
        className="w-36 flex flex-col border-r bg-nd_gray-50"
        style={ReactDOM.Style.make(~backgroundColor=sidebarFromForm.primary, ())}>
        <div className="p-2 pt-3 border-b border-gray-200">
          <div
            className={`${body.xs.semibold}`}
            style={ReactDOM.Style.make(~color=sidebarFromForm.textColor, ())}>
            {React.string("Merchant Tester")}
          </div>
        </div>
        <nav className="flex-1 py-1">
          {sidebarItems
          ->Array.mapWithIndex((item, index) => <MockSidebarItem item index sidebarFromForm />)
          ->React.array}
        </nav>
        <div className="p-3 border-t flex items-center gap-2">
          <span
            className="rounded-full bg-nd_gray-600 w-4 h-4 flex items-center justify-center text-fs-10 text-white">
            <Icon name="user" size=8 />
          </span>
          <span
            className={`text-nd_gray-600 truncate ${body.xs.medium}`}
            style={ReactDOM.Style.make(~color=sidebarFromForm.textColor, ())}>
            {"test@gmail.com"->React.string}
          </span>
          <Icon name="chevron-down" size=10 className="text-nd_gray-400" />
        </div>
      </div>
      <div className="flex-1 flex flex-col overflow-hidden">
        <MockNavbar />
        <div className="p-2">
          <span className={`text-nd_gray-800 ${body.sm.semibold}`}>
            {React.string("Page Heading")}
          </span>
          <p className={`text-nd_gray-600 mb-4 ${body.xs.medium}`}>
            {React.string("Page Descriptions will go here")}
          </p>
        </div>
        <div className="p-2 m-2 rounded-lg border-nd_gray-50 border flex flex-col gap-0.5">
          <span className={`${body.xs.semibold}`}> {"Card Heading"->React.string} </span>
          <span className={`${body.xs.medium} text-nd_gray-400`}>
            {"Card Heading goes here"->React.string}
          </span>
          <div className="flex flex-row gap-2 mt-2 font-semibold text-fs-8">
            <button
              className="px-2 py-3 h-4 rounded flex items-center justify-between cursor-pointer"
              style={ReactDOM.Style.make(
                ~backgroundColor=buttonsFromForm.primary.backgroundColor,
                ~color=buttonsFromForm.primary.textColor,
                (),
              )}>
              {React.string("Primary Button")}
            </button>
            <button
              className="px-2 py-3 rounded h-4 flex justify-between items-center cursor-pointer"
              style={ReactDOM.Style.make(
                ~backgroundColor=buttonsFromForm.secondary.backgroundColor,
                ~color=buttonsFromForm.secondary.textColor,
                (),
              )}>
              {React.string("Secondary Button")}
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
}
