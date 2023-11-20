type dropdownOptions = {
  label: string,
  value: Js.Json.t,
}

type action<'string> = ItemClick(dropdownOptions)

module Chevron = {
  @react.component
  let make = (~color="#354052") => {
    <svg
      width="12"
      height="12"
      viewBox="0 0 12 12"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
      className="fill-current">
      <mask id="mask0" maskUnits="userSpaceOnUse" x="2" y="4" width="8" height="5">
        <path
          fillRule="evenodd"
          clipRule="evenodd"
          d="M2.81803 4.64645C2.62277 4.84171 2.62277 5.15829 2.81803 5.35355L5.64646 8.18198C5.84172 8.37724 6.1583 8.37724 6.35356 8.18198L9.18199 5.35355C9.37725 5.15829 9.37725 4.84171 9.18199 4.64645C8.98673 4.45118 8.67015 4.45118 8.47489 4.64645L6.00001 7.12132L3.52514 4.64645C3.32988 4.45118 3.01329 4.45118 2.81803 4.64645Z"
          fill="#A8AAB7"
        />
      </mask>
      <g mask="url(#mask0)">
        <rect x="12" width="12" height="12" transform="rotate(90 12 0)" fill=color />
      </g>
    </svg>
  }
}

@react.component
let make = (
  ~title="Gateway",
  ~list=["Gateway1", "Gateway2"],
  ~titleclass="text-jp-gray-900 text-xs text-white",
  ~mapper=Js.Dict.empty(),
  ~labelVal="All Merchants",
  ~customContainerStyle="py-3",
) => {
  let (clickedItem, setClickedItem) = React.useState(_ => None)
  let (showTitle, setshowTitle) = React.useState(_ => title)
  let (showList, setShowList) = React.useState(_ => false)
  let listOptions = list->Belt.Array.keepMap(val => {
    let statusObj = {
      label: val,
      value: Js.Dict.get(mapper, val)->Belt.Option.getWithDefault(val)->Js.Json.string,
    }
    Some(statusObj)
  })

  let listOptions = listOptions->Js.Array.concat([{label: labelVal, value: Js.Json.null}])
  let dropDownClassName = listOptions->Js.Array2.length < 3 ? "hidden" : ""

  let (_, dispatch) = React.useReducer((_, action) =>
    switch action {
    | ItemClick(item: dropdownOptions) => {
        let value = item.value->Js.Json.decodeString->Belt.Option.getWithDefault("")
        if value === "" {
          setClickedItem(_ => None)
          setshowTitle(_ => labelVal)
        } else {
          setClickedItem(_ => Some(value))
          setshowTitle(_ => item.label)
        }
        setShowList(_ => false)
      }
    }
  , ())

  let ref = React.useRef(Js.Nullable.null)
  OutsideClick.useOutsideClick(
    ~refs=ArrayOfRef([ref]),
    ~isActive=showList,
    ~callback=() => {
      setShowList(_ => false)
    },
    (),
  )
  <div ref={ref->ReactDOM.Ref.domRef} className={`relative inline-block ${dropDownClassName}`}>
    <div
      className={`flex flex-row items-center text-sm ] cursor-pointer rounded-md px-4 mr-4 bg-[#B3E8FF]/[.1] ${customContainerStyle}`}
      onClick={_evt => setShowList(prev => !prev)}>
      <div className={`mr-2 ${titleclass}`}> {React.string(showTitle)} </div>
      <div className="">
        <Icon name={showList ? "chevron-up" : "chevron-down"} size=10 className="text-[#0099FF]" />
      </div>
    </div>
    {showList
      ? <AddDataAttributes attributes=[("data-dropdown-for", title)]>
          <ul
            className="m-0 w-40 bg-white border border-jp-gray-100 absolute shadow-md rounded-md z-10 my-3">
            {listOptions
            ->Js.Array2.mapi((item, i) => {
              let value = item.value->Js.Json.decodeString->Belt.Option.getWithDefault("")
              <>
                <div
                  className="flex flex-row justify-between px-4 py-2 bg-white hover:bg-jp-gray-100 cursor-pointer text-sm text-jp-gray-700 "
                  key={string_of_int(i)}
                  onClick={_evt => dispatch(ItemClick(item))}>
                  {React.string(item.label)}
                  <div className="my-auto">
                    <Tick isSelected={clickedItem === Some(value)} />
                  </div>
                </div>
              </>
            })
            ->React.array}
          </ul>
        </AddDataAttributes>
      : React.null}
  </div>
}
