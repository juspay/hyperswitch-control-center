open WebhooksTypes
open LogicUtils

module EnhancedSearchBarFilter = {
  @react.component
  let make = (~searchVal, ~setSearchVal, ~searchType, ~setSearchType, ~onEnterPress) => {
    let (baseValue, setBaseValue) = React.useState(_ => "")
    let (showDropdown, setShowDropdown) = React.useState(_ => false)
    let (isContainerHovered, setIsContainerHovered) = React.useState(_ => false)
    let (isInputFocused, setIsInputFocused) = React.useState(_ => false)
    let (isButtonFocused, setIsButtonFocused) = React.useState(_ => false)

    let searchTypeOptions = [
      {"label": "Object ID", "value": "object_id"},
      {"label": "Event ID", "value": "event_id"},
    ]

    let onChange = ev => {
      let value = ReactEvent.Form.target(ev)["value"]
      setBaseValue(_ => value)
    }

    let onSearchTypeChange = value => {
      setSearchType(_ => value)
      setShowDropdown(_ => false)
    }

    let getCurrentLabel = () => {
      switch searchTypeOptions->Array.find(option => option["value"] === searchType) {
      | Some(option) => option["label"]
      | None => "Object ID"
      }
    }

    React.useEffect(() => {
      if baseValue->String.length === 0 && searchVal->isNonEmptyString {
        setSearchVal(_ => baseValue)
      }
      None
    }, [baseValue])

    React.useEffect(() => {
      let onKeyPress = event => {
        let keyPressed = event->ReactEvent.Keyboard.key
        if keyPressed == "Enter" {
          setSearchVal(_ => baseValue)
          onEnterPress()
        }
      }
      Window.addEventListener("keydown", onKeyPress)
      Some(() => Window.removeEventListener("keydown", onKeyPress))
    }, [baseValue])

    // Determine unified states
    let isAnyFocused = isInputFocused || isButtonFocused || showDropdown
    let isHoveredOrFocused = isContainerHovered || isAnyFocused

    let borderStyle = if isAnyFocused {
      "border border-primary"
    } else if isHoveredOrFocused {
      "border border-jp-gray-600"
    } else {
      "border border-jp-gray-600 border-opacity-75"
    }

    let backgroundStyle = if isHoveredOrFocused && !isAnyFocused {
      "bg-gray-50"
    } else {
      "bg-white"
    }

    let inputSearch: ReactFinalForm.fieldRenderPropsInput = {
      name: "name",
      onBlur: _ => setIsInputFocused(_ => false),
      onChange,
      onFocus: _ => setIsInputFocused(_ => true),
      value: baseValue->JSON.Encode.string,
      checked: true,
    }

    <div
      className="w-max relative"
      onMouseEnter={_ => setIsContainerHovered(_ => true)}
      onMouseLeave={_ => setIsContainerHovered(_ => false)}>
      <div
        className={`relative flex items-center ${borderStyle} ${backgroundStyle} rounded-lg transition-all duration-200`}>
        <div className="flex items-center pl-4">
          <Icon name="search" size=14 className="text-gray-400" />
        </div>
        <input
          type_="text"
          value=baseValue
          onChange
          onFocus={inputSearch.onFocus}
          onBlur={inputSearch.onBlur}
          placeholder="Search by ID"
          className="flex-1 px-3 py-2 bg-transparent text-sm text-gray-700 placeholder-gray-400 placeholder:opacity-90 focus:outline-none h-10"
        />
        <div className="relative">
          <button
            type_="button"
            onClick={_ => setShowDropdown(prev => !prev)}
            onFocus={_ => setIsButtonFocused(_ => true)}
            onBlur={_ => setIsButtonFocused(_ => false)}
            className="flex items-center gap-1 px-3 h-10 text-sm text-gray-700 bg-transparent rounded-r-lg transition-all duration-200 focus:outline-none active:outline-none outline-none border-0 shadow-none active:shadow-none focus:shadow-none active:border-0 focus:border-0 select-none">
            <span className="whitespace-nowrap text-xs"> {getCurrentLabel()->React.string} </span>
            <Icon
              size=10
              name="chevron-down"
              className={`transition-transform duration-200 text-gray-500 ${showDropdown
                  ? "rotate-180"
                  : ""}`}
            />
          </button>
          <RenderIf condition=showDropdown>
            <div
              className="absolute right-0 top-full mt-1 bg-white border border-gray-200 rounded-lg shadow-lg z-50 min-w-28 overflow-hidden">
              {searchTypeOptions
              ->Array.map(option => {
                <button
                  key={option["value"]}
                  type_="button"
                  onMouseDown={event => {
                    ReactEvent.Mouse.preventDefault(event)
                    onSearchTypeChange(option["value"])
                  }}
                  className={`w-full px-3 py-2 text-xs text-left transition-colors ${searchType ===
                      option["value"]
                      ? "bg-blue-50 text-blue-700 font-medium"
                      : "text-gray-700 hover:bg-gray-50"}`}>
                  {option["label"]->React.string}
                </button>
              })
              ->React.array}
            </div>
          </RenderIf>
        </div>
      </div>
    </div>
  }
}

let tabkeys: array<tabs> = [Request, Response]

let labelColor = (statusCode): TableUtils.labelColor => {
  switch statusCode {
  | 200 => LabelGreen
  | 400
  | 404
  | 422 =>
    LabelRed
  | 500 => LabelGray
  | _ => LabelGreen
  }
}

let subHeading = (~text, ~customClass="") =>
  <div className={`text-nd_gray-600 font-medium ${customClass}`}> {text->React.string} </div>

let itemToObjectMapper: dict<JSON.t> => webhookObject = dict => {
  eventId: dict->getString("event_id", ""),
  eventClass: dict->getString("event_class", ""),
  eventType: dict->getString("event_type", ""),
  merchantId: dict->getString("merchant_id", ""),
  profileId: dict->getString("profile_id", ""),
  objectId: dict->getString("object_id", ""),
  isDeliverySuccessful: dict->getBool("is_delivery_successful", false),
  initialAttemptId: dict->getString("initial_attempt_id", ""),
  created: dict->getString("created", ""),
}

let requestMapper = json => {
  body: json->getDictFromJsonObject->getString("body", ""),
  headers: json->getDictFromJsonObject->getJsonObjectFromDict("headers"),
}

let responseMapper = json => {
  body: json->getDictFromJsonObject->getString("body", ""),
  headers: json->getDictFromJsonObject->getJsonObjectFromDict("headers"),
  errorMessage: json->getDictFromJsonObject->getString("error_message", "")->getNonEmptyString,
  statusCode: json->getDictFromJsonObject->getInt("status_code", 0),
}

let itemToObjectMapperAttempts: dict<JSON.t> => attemptType = dict => {
  eventId: dict->getString("event_id", ""),
  eventClass: dict->getString("event_class", ""),
  eventType: dict->getString("event_type", ""),
  merchantId: dict->getString("merchant_id", ""),
  profileId: dict->getString("profile_id", ""),
  objectId: dict->getString("object_id", ""),
  isDeliverySuccessful: dict->getBool("is_delivery_successful", false),
  initialAttemptId: dict->getString("initial_attempt_id", ""),
  created: dict->getString("created", ""),
  deliveryAttempt: dict->getString("delivery_attempt", ""),
  request: dict->getJsonObjectFromDict("request")->requestMapper,
  response: dict->getJsonObjectFromDict("response")->responseMapper,
}

let itemToObjectMapperAttemptsTable: dict<JSON.t> => attemptTable = dict => {
  isDeliverySuccessful: dict->getBool("is_delivery_successful", false),
  deliveryAttempt: dict->getString("delivery_attempt", ""),
  eventId: dict->getString("event_id", ""),
  created: dict->getString("created", ""),
}

let (startTimeFilterKey, endTimeFilterKey) = ("start_time", "end_time")

let getAllowedDateRange = {
  let endDate = Date.now()->Js.Date.fromFloat->DateTimeUtils.toUtc->DayJs.getDayJsForJsDate //->Date.toISOString->JSON.Encode.string
  let startDate = endDate.subtract(90, "day")

  let dateObject: Calendar.dateObj = {
    startDate: startDate.toString(),
    endDate: endDate.toString(),
  }
  dateObject
}

let initialFixedFilter = () => [
  (
    {
      localFilter: None,
      field: FormRenderer.makeMultiInputFieldInfo(
        ~label="",
        ~comboCustomInput=InputFields.filterDateRangeField(
          ~startKey=startTimeFilterKey,
          ~endKey=endTimeFilterKey,
          ~format="YYYY-MM-DDTHH:mm:ss[Z]",
          ~showTime=false,
          ~disablePastDates={false},
          ~disableFutureDates={true},
          ~predefinedDays=[
            Hour(0.5),
            Hour(1.0),
            Hour(2.0),
            Today,
            Yesterday,
            Day(2.0),
            Day(7.0),
            Day(30.0),
            ThisMonth,
            LastMonth,
          ],
          ~numMonths=2,
          ~disableApply=false,
          ~dateRangeLimit=90,
          ~allowedDateRange=getAllowedDateRange,
        ),
        ~inputFields=[],
        ~isRequired=false,
      ),
    }: EntityType.initialFilters<'t>
  ),
]
