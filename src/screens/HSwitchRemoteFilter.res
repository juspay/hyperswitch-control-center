type filterBody = {
  start_time: string,
  end_time: string,
}

let formateDateString = date => {
  date->Date.toISOString->TimeZoneHook.formattedISOString("YYYY-MM-DDTHH:mm:[00][Z]")
}

let getDateFilteredObject = (~range=7, ()) => {
  let currentDate = Date.make()

  let end_time = currentDate->formateDateString

  let start_time =
    Js.Date.makeWithYMD(
      ~year=currentDate->Js.Date.getFullYear,
      ~month=currentDate->Js.Date.getMonth,
      ~date=currentDate->Js.Date.getDate,
      (),
    )
    ->Js.Date.setDate((currentDate->Js.Date.getDate->Float.toInt - range)->Int.toFloat)
    ->Js.Date.fromFloat
    ->formateDateString

  {
    start_time,
    end_time,
  }
}

let useSetInitialFilters = (
  ~updateExistingKeys,
  ~startTimeFilterKey,
  ~endTimeFilterKey,
  ~range=7,
  (),
) => {
  let {filterValueJson} = FilterContext.filterContext->React.useContext

  () => {
    let inititalSearchParam = Dict.make()

    let defaultDate = getDateFilteredObject(~range, ())

    if filterValueJson->Dict.keysToArray->Array.length < 1 {
      [
        (startTimeFilterKey, defaultDate.start_time),
        (endTimeFilterKey, defaultDate.end_time),
      ]->Array.forEach(item => {
        let (key, defaultValue) = item
        switch inititalSearchParam->Dict.get(key) {
        | Some(_) => ()
        | None => inititalSearchParam->Dict.set(key, defaultValue)
        }
      })

      inititalSearchParam->updateExistingKeys
    }
  }
}

module SearchBarFilter = {
  @react.component
  let make = (~placeholder, ~setSearchVal, ~searchVal) => {
    let (baseValue, setBaseValue) = React.useState(_ => "")
    let onChange = ev => {
      let value = ReactEvent.Form.target(ev)["value"]
      setBaseValue(_ => value)
    }

    React.useEffect1(() => {
      let onKeyPress = event => {
        let keyPressed = event->ReactEvent.Keyboard.key

        if keyPressed == "Enter" {
          setSearchVal(_ => baseValue)
        }
      }
      Window.addEventListener("keydown", onKeyPress)
      Some(() => Window.removeEventListener("keydown", onKeyPress))
    }, [baseValue])

    React.useEffect1(() => {
      if baseValue->String.length === 0 && searchVal->LogicUtils.isNonEmptyString {
        setSearchVal(_ => baseValue)
      }
      None
    }, [baseValue])

    let inputSearch: ReactFinalForm.fieldRenderPropsInput = {
      name: "name",
      onBlur: _ev => (),
      onChange,
      onFocus: _ev => (),
      value: baseValue->JSON.Encode.string,
      checked: true,
    }

    <div className="w-64">
      {InputFields.textInput(
        ~input=inputSearch,
        ~placeholder,
        ~customStyle="rounded-lg placeholder:opacity-90",
        ~customPaddingClass="px-0",
        ~leftIcon=<Icon size=14 name="search" />,
        ~iconOpacity="opacity-100",
        ~leftIconCustomStyle="pl-4",
        ~inputStyle="!placeholder:opacity-90",
        (),
      )}
    </div>
  }
}

module RemoteTableFilters = {
  open LogicUtils
  @react.component
  let make = (
    ~filterUrl,
    ~setFilters,
    ~endTimeFilterKey,
    ~startTimeFilterKey,
    ~initialFilters,
    ~initialFixedFilter,
    ~setOffset,
    ~customLeftView,
    (),
  ) => {
    let {filterValue, updateExistingKeys, filterValueJson, reset} =
      FilterContext.filterContext->React.useContext
    let defaultFilters = {""->JSON.Encode.string}

    React.useEffect0(() => {
      if filterValueJson->Dict.keysToArray->Array.length === 0 {
        setFilters(_ => Dict.make()->Some)
        setOffset(_ => 0)
      }
      None
    })

    let endTimeVal = filterValueJson->getString(endTimeFilterKey, "")
    let startTimeVal = filterValueJson->getString(startTimeFilterKey, "")

    let filterBody = React.useMemo3(() => {
      [
        (startTimeFilterKey, startTimeVal->JSON.Encode.string),
        (endTimeFilterKey, endTimeVal->JSON.Encode.string),
      ]->Dict.fromArray
    }, (startTimeVal, endTimeVal, filterValue))

    open APIUtils

    let (filterDataJson, setFilterDataJson) = React.useState(_ => None)
    let updateDetails = useUpdateMethod()
    let {filterValueJson} = FilterContext.filterContext->React.useContext
    let startTimeVal = filterValueJson->getString("start_time", "")
    let endTimeVal = filterValueJson->getString("end_time", "")

    let getFilters = async () => {
      let json = await updateDetails(filterUrl, filterBody->JSON.Encode.object, Post, ())
      setFilterDataJson(_ => json->Some)
    }

    React.useEffect3(() => {
      setFilterDataJson(_ => None)
      if startTimeVal->isNonEmptyString && endTimeVal->isNonEmptyString {
        try {
          getFilters()->ignore
        } catch {
        | _ => ()
        }
      }
      None
    }, (startTimeVal, endTimeVal, filterBody->JSON.Encode.object->JSON.stringify))
    let filterData = filterDataJson->Option.getOr(Dict.make()->JSON.Encode.object)

    let setInitialFilters = useSetInitialFilters(
      ~updateExistingKeys,
      ~startTimeFilterKey,
      ~endTimeFilterKey,
      ~range=30,
      (),
    )

    React.useEffect1(() => {
      if filterValueJson->Dict.keysToArray->Array.length < 1 {
        setInitialFilters()
      }
      None
    }, [filterDataJson])

    React.useEffect1(() => {
      if filterValueJson->Dict.keysToArray->Array.length != 0 {
        setFilters(_ => filterValueJson->Some)
        setOffset(_ => 0)
      } else {
        setFilters(_ => Dict.make()->Some)
        setOffset(_ => 0)
      }
      None
    }, [filterValue])

    let remoteFilters = filterData->initialFilters
    let initialDisplayFilters =
      remoteFilters->Array.filter((item: EntityType.initialFilters<'t>) =>
        item.localFilter->Option.isSome
      )
    let remoteOptions = []

    switch filterDataJson {
    | Some(_) =>
      <Filter
        key="0"
        customLeftView
        defaultFilters
        fixedFilters={initialFixedFilter()}
        requiredSearchFieldsList=[]
        localFilters={initialDisplayFilters}
        localOptions=[]
        remoteOptions
        remoteFilters
        autoApply=false
        defaultFilterKeys=[startTimeFilterKey, endTimeFilterKey]
        updateUrlWith={updateExistingKeys}
        clearFilters={() => reset()}
      />
    | _ =>
      <Filter
        key="1"
        customLeftView
        defaultFilters
        fixedFilters={initialFixedFilter()}
        requiredSearchFieldsList=[]
        localFilters=[]
        localOptions=[]
        remoteOptions=[]
        remoteFilters=[]
        autoApply=false
        defaultFilterKeys=[startTimeFilterKey, endTimeFilterKey]
        updateUrlWith={updateExistingKeys}
        clearFilters={() => reset()}
      />
    }
  }
}
