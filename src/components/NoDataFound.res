type renderType = InfoBox | Painting | NotFound | Locked | LoadError

@react.component
let make = (
  ~title=?,
  ~message,
  ~renderType: renderType=InfoBox,
  ~children=?,
  ~customCssClass="my-6",
  ~customBorderClass="",
  ~customMessageCss="",
) => {
  let prefix = LogicUtils.useUrlPrefix()
  let isMobileView = MatchMedia.useMobileChecker()
  let marginPaddingClass = {
    let marginPaddingClass = switch renderType {
    | Painting => "mt-16 p-16"
    | NotFound => "mt-16 p-5 mb-12"
    | Locked => "mt-32 p-16"
    | LoadError => "mt-32 p-16"
    | InfoBox => ""
    }
    isMobileView ? "" : marginPaddingClass
  }
  let containerClass = `flex flex-col ${marginPaddingClass} container mx-auto items-center`
  let msgCss = isMobileView
    ? `text-l text-center mt-4 ${customMessageCss}`
    : `px-3 text-2xl mt-32 ${customMessageCss}`

  <AddDataAttributes attributes=[("data-component", message)]>
    {<div className={`${customCssClass} rounded-md`}>
      {switch title {
      | Some(val) =>
        <DesktopView>
          <div
            className="font-bold text-fs-16 text-jp-gray-900 text-opacity-75 mb-4 mt-4 dark:text-white dark:text-opacity-75">
            {React.string(val)}
          </div>
        </DesktopView>

      | None => React.null
      }}
      <div
        className={`border ${customBorderClass} bg-white p-3 pl-5 rounded font-semibold text-jp-gray-900 text-opacity-50 dark:bg-jp-gray-lightgray_background dark:text-jp-gray-text_darktheme dark:text-opacity-50 dark:border-jp-gray-no_data_border`}>
        {switch renderType {
        | InfoBox =>
          <div className="flex flex-row items-center">
            <Icon
              name="no_data"
              size=18
              className="opacity-50 hover:opacity-100 dark:brightness-50 dark:opacity-75 dark:invert"
            />
            <div className="px-3 text-fs-16"> {React.string(message)} </div>
          </div>
        | Painting =>
          <div className=containerClass>
            <div className=" mb-8 mt-8 max-w-full h-auto">
              <img src={`/icons/Illustration.svg`} />
            </div>
            <div className={`${msgCss}`}> {React.string(message)} </div>
            <div>
              {switch children {
              | Some(child) => child
              | None => React.null
              }}
            </div>
          </div>
        | NotFound =>
          <div className=containerClass>
            <div className="mb-8 mt-4 max-w-full h-auto">
              <img src={`${prefix}/notfound.svg`} />
            </div>
            <div className="px-3 text-base mt-2"> {React.string(message)} </div>
          </div>
        | Locked =>
          <div className=containerClass>
            <div className="mb-8 mt-8 max-w-full h-auto">
              <img src={`/icons/Locked.svg`} />
            </div>
            <div className="px-3 text-base"> {React.string(message)} </div>
            <div>
              {switch children {
              | Some(child) => child
              | None => React.null
              }}
            </div>
          </div>
        | LoadError =>
          <div className=containerClass>
            <div className="mb-8 mt-8 max-w-full h-auto">
              <img src={`/icons/LoadError.svg`} />
            </div>
            <div className="px-3 text-base"> {React.string(message)} </div>
            <div>
              {switch children {
              | Some(child) => child
              | None => React.null
              }}
            </div>
          </div>
        }}
      </div>
    </div>}
  </AddDataAttributes>
}
