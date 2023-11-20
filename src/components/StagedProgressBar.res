type progressPointerPosition = Start(bool) | Middle

@react.component
let make = (~selectedIdx, ~items, ~wrapperClass="", ~progressPointerPosition=Start(false)) => {
  let isMobileView = MatchMedia.useMatchMedia("(max-width: 700px)")
  let radius = isMobileView ? "h-2 w-2" : "h-3 w-3"

  let itemWidthClass = switch progressPointerPosition {
  | Middle => "flex-1"
  | Start(isLast) => isLast ? "" : "w-full"
  }

  let barWidthClass = switch progressPointerPosition {
  | Middle => "w-full"
  | Start(isLast) => isLast ? "" : "w-full"
  }

  let textClass = switch progressPointerPosition {
  | Middle => ` font-semibold ${isMobileView ? "text-xs" : ""} flex justify-center`
  | Start(_) => `w-max font-semibold ${isMobileView ? "text-xs" : ""}`
  }

  <div className={`flex flex-row items-center justify-around ${wrapperClass}`}>
    {items
    ->Js.Array2.mapi((item, index) => {
      let isLast = items->Js.Array2.length - 1 === index
      let highlighted = index <= selectedIdx
      <div key={string_of_int(index)} className={`${itemWidthClass} flex flex-col my-2`}>
        <div className={`${barWidthClass} flex flex-row items-center my-2`}>
          {switch progressPointerPosition {
          | Start(_) =>
            <>
              <div
                className={`${highlighted
                    ? "bg-blue-800"
                    : "bg-jp-gray-300"} ${radius} rounded-full`}
              />
              {if isLast {
                React.null
              } else {
                <div
                  className={`${index < selectedIdx ? "bg-blue-800" : "bg-jp-gray-300"} w-full h-1`}
                />
              }}
            </>
          | Middle =>
            if isLast {
              <div className="flex-1 flex items-center">
                <div
                  className={`${index < selectedIdx ? "bg-blue-800" : "bg-jp-gray-300"} flex-1 h-1`}
                />
                <div
                  className={`${highlighted
                      ? "bg-blue-800"
                      : "bg-jp-gray-300"} ${radius} rounded-full`}
                />
                <div className={"flex-1"} />
              </div>
            } else if index == 0 {
              <div className="flex-1 flex items-center">
                <div className={"flex-1"} />
                <div
                  className={`${highlighted
                      ? "bg-blue-800"
                      : "bg-jp-gray-300"} ${radius} rounded-full`}
                />
                <div
                  className={`${index < selectedIdx ? "bg-blue-800" : "bg-jp-gray-300"} flex-1 h-1`}
                />
              </div>
            } else {
              <div className="flex-1 flex items-center">
                <div className={`${highlighted ? "bg-blue-800" : "bg-jp-gray-300"} flex-1 h-1`} />
                <div
                  className={`${highlighted
                      ? "bg-blue-800"
                      : "bg-jp-gray-300"} ${radius} rounded-full`}
                />
                <div
                  className={`${index < selectedIdx ? "bg-blue-800" : "bg-jp-gray-300"} flex-1 h-1`}
                />
              </div>
            }
          }}
        </div>
        <div className={`${highlighted ? "text-blue-800" : "text-gray-300"} ${textClass}`}>
          {React.string(item)}
        </div>
      </div>
    })
    ->React.array}
  </div>
}
