module DateCalendar = {
  open Calendar
  @react.component
  let make = (
    ~changeHighlightCellStyle="",
    ~onDateClick=?,
    ~count=1,
    ~cellHighlighter=?,
    ~cellRenderer=?,
  ) => {
    let (hoverdDate, setHoverdDate) = React.useState(_ => "")
    let _ = onDateClick

    let dummyRow = Belt.Array.make(count, 1)
    <span
      className={`flex flex-1 flex-row justify-center overflow-auto bg-jp-gray-50 dark:bg-jp-gray-950 rounded border border-jp-gray-500 dark:border-jp-gray-960 select-none pt-1`}>
      {dummyRow
      ->Js.Array2.mapi((_item, i) => {
        <Calendar
          key={string_of_int(i)}
          month=Nov
          year=2020
          showTitle=false
          hoverdDate
          setHoverdDate
          ?cellHighlighter
          ?cellRenderer
          ?onDateClick
          disablePastDates=false
          disableFutureDates=false
          changeHighlightCellStyle
          showHead=false
        />
      })
      ->React.array}
    </span>
  }
}
@react.component
let make = (~input: ReactFinalForm.fieldRenderPropsInput) => {
  let (selectedDate, setSelectedDate) = React.useState(_ =>
    input.value->Js.Json.decodeString->Belt.Option.getWithDefault("")
  )
  let dropdownRef = React.useRef(Js.Nullable.null)
  let (isExpanded, setIsExpanded) = React.useState(_ => false)
  let dropdownVisibilityClass = if isExpanded {
    "inline-block z-100"
  } else {
    "hidden"
  }

  let onDateClick = str => {
    setIsExpanded(p => !p)
    let currentDateSplit = Js.String2.split(str, "-")
    let currentDateDay = currentDateSplit[2]->Belt.Option.getWithDefault("")
    setSelectedDate(_ => currentDateDay)
    input.onChange(currentDateDay->Identity.stringToFormReactEvent)
  }
  OutsideClick.useOutsideClick(
    ~refs=ArrayOfRef([dropdownRef]),
    ~isActive=isExpanded,
    ~callback=() => {
      setIsExpanded(p => !p)
    },
    (),
  )
  let changeVisibility = _ev => {
    setIsExpanded(p => !p)
  }

  let buttonText = {
    let startDateStr = selectedDate === "" ? "Select Date" : selectedDate
    startDateStr
  }

  let buttonIcon = if isExpanded {
    "angle-up"
  } else {
    "angle-down"
  }
  <div className="md:relative">
    <Button
      text=buttonText
      leftIcon={FontAwesome("calendar")}
      rightIcon={FontAwesome(buttonIcon)}
      onClick={changeVisibility}
    />
    <div className=dropdownVisibilityClass>
      <div>
        <div className="absolute flex flex-row w-max z-10">
          <DateCalendar count=1 onDateClick />
        </div>
      </div>
    </div>
  </div>
}
