let makeFieldInfo = FormRenderer.makeFieldInfo

module CheckLocalFilters = {
  @react.component
  let make = (
    ~options: array<EntityType.optionType<'t>>,
    ~checkedFilters,
    ~removeFilters,
    ~addFilters,
    ~applyFilters,
    ~selectedFiltersList,
    ~addFilterStyle,
    ~showSelectFiltersSearch,
  ) => {
    let isMobileView = MatchMedia.useMobileChecker()
    let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
      ReactFinalForm.useFormSubscription(["values"])->Js.Nullable.return,
    )
    let values = formState.values

    React.useEffect1(() => {
      if formState.dirty {
        switch formState.values->Js.Json.decodeObject {
        | Some(valuesDict) => valuesDict->applyFilters
        | None => ()
        }
      }

      None
    }, [values])
    let onChangeSelect = ev => {
      let fieldNameArr = ev->Identity.formReactEventToArrayOfString
      let newlyAdded = Array.filter(fieldNameArr, newVal => !Array.includes(checkedFilters, newVal))

      if Array.length(newlyAdded) > 0 {
        addFilters(newlyAdded)
      } else {
        removeFilters(fieldNameArr, values)
      }
    }

    let labelClass = ""
    let labelPadding = ""
    let innerClass = ""
    let fieldWrapperClass = !isMobileView ? "px-1 flex flex-col" : ""

    let selectOptions = options->Array.map(obj => obj.urlKey)

    <div className={`flex flex-row flex-wrap ${innerClass}`}>
      <FormRenderer.FieldsRenderer
        fields={selectedFiltersList} fieldWrapperClass labelClass labelPadding
      />
      <div className={`md:justify-between flex flex-row items-center flex-wrap ${addFilterStyle}`}>
        {if Array.length(options) > 0 {
          <div className={`flex`}>
            <CustomInputSelectBox
              onChange=onChangeSelect
              options={selectOptions->SelectBox.makeOptions}
              allowMultiSelect=true
              buttonText="Add Filters"
              isDropDown=true
              hideMultiSelectButtons=true
              buttonType=Button.FilterAdd
              value={checkedFilters->Js.Array.map(Js.Json.string, _)->Js.Json.array}
              searchable=showSelectFiltersSearch
            />
          </div>
        } else {
          React.null
        }}
      </div>
    </div>
  }
}

@react.component
let make = (
  ~entity: EntityType.entityType<'colType, 't>,
  ~setOffset=?,
  ~localFilters: array<EntityType.initialFilters<'t>>,
  ~localOptions: array<EntityType.optionType<'t>>,
  ~remoteOptions: array<EntityType.optionType<'t>>,
  ~remoteFilters: array<EntityType.initialFilters<'t>>,
  ~mandatoryRemoteKeys=[],
  ~path="",
  ~ignoreUrlUpdate=false,
  ~setLocalSearchFilters=?,
  ~localSearchFilters="",
  ~tableName=?,
  ~addFilterStyle="",
  ~customLocalFilterStyle="",
  ~showSelectFiltersSearch=false,
  ~disableURIdecode=false,
) => {
  let {defaultFilters} = entity
  let (selectedFiltersList, setSelectedFiltersList) = React.useState(_ =>
    localFilters->Array.map(item => item.field)
  )
  let (checkedFilters, setCheckedFilters) = React.useState(_ => [])
  let url = RescriptReactRouter.useUrl()
  let searchParams = disableURIdecode ? url.search : url.search->Js.Global.decodeURI
  let (initialValueJson, setInitialValueJson) = React.useState(_ => Js.Json.object_(Dict.make()))
  let remoteFiltersJson = RemoteFiltersUtils.getInitialValuesFromUrl(
    ~searchParams,
    ~initialFilters=remoteFilters,
    ~options=remoteOptions,
    ~mandatoryRemoteKeys,
    (),
  )
  let remoteFilterDict = remoteFiltersJson->JsonFlattenUtils.flattenObject(false)

  React.useEffect2(() => {
    let searchValues = ignoreUrlUpdate ? localSearchFilters : searchParams
    let initialValues = RemoteFiltersUtils.getInitialValuesFromUrl(
      ~searchParams=searchValues,
      ~initialFilters=localFilters,
      ~options=localOptions,
      (),
    )
    let localCheckedFilters = checkedFilters->Array.copy
    let localSelectedFiltersList = selectedFiltersList->Array.copy

    initialValues
    ->Js.Json.decodeObject
    ->Belt.Option.getWithDefault(Dict.make())
    ->Dict.toArray
    ->Array.forEach(entry => {
      let (key, _value) = entry
      let includes = Array.includes(checkedFilters, key)

      if !includes {
        let optionalOption = localOptions->Array.find(option => option.urlKey === key)
        switch optionalOption {
        | Some(optionObj) => {
            localSelectedFiltersList->Array.push(optionObj.field)->ignore
            localCheckedFilters->Array.push(key)->ignore
          }

        | None => ()
        }
      }
    })
    setCheckedFilters(_prev => localCheckedFilters)
    setSelectedFiltersList(_prev => localSelectedFiltersList)
    setInitialValueJson(_ => initialValues)

    None
  }, (searchParams, localSearchFilters))

  let applyFilters = valuesDict => {
    RemoteFiltersUtils.applyFilters(
      ~currentFilterDict=valuesDict,
      ~options=localOptions,
      ~defaultFilters,
      ~setOffset,
      ~path,
      ~existingFilterDict=remoteFilterDict,
      ~ignoreUrlUpdate,
      ~setLocalSearchFilters?,
      ~tableName,
      (),
    )
  }

  let addFilters = newlyAdded => {
    let localCheckedFilters = checkedFilters->Array.copy
    let localSelectedFiltersList = selectedFiltersList->Array.copy
    newlyAdded->Array.forEach(value => {
      let optionObjArry = localOptions->Array.filter(option => option.urlKey === value)
      let defaultEntityOptionType: EntityType.optionType<
        't,
      > = EntityType.getDefaultEntityOptionType()
      let optionObj = optionObjArry[0]->Belt.Option.getWithDefault(defaultEntityOptionType)
      localSelectedFiltersList->Array.push(optionObj.field)->ignore
      localCheckedFilters->Array.push(value)->ignore
    })
    setCheckedFilters(_prev => localCheckedFilters)
    setSelectedFiltersList(_prev => localSelectedFiltersList)
  }

  let removeFilters = (fieldNameArr, values) => {
    let toBeRemoved = checkedFilters->Array.filter(oldVal => !Array.includes(fieldNameArr, oldVal))
    let finalFieldList = selectedFiltersList->Array.filter(val => {
      val.inputNames
      ->Belt.Array.get(0)
      ->Belt.Option.map(name => !{toBeRemoved->Array.includes(name)})
      ->Belt.Option.getWithDefault(false)
    })
    let filtersAfterRemoving =
      checkedFilters->Array.filter(val => !Array.includes(toBeRemoved, val))

    let newInitialValues =
      initialValueJson
      ->Js.Json.decodeObject
      ->Belt.Option.getWithDefault(Dict.make())
      ->Dict.toArray
      ->Array.filter(entry => {
        let (key, _value) = entry
        !Array.includes(toBeRemoved, key)
      })
      ->Dict.fromArray
      ->Js.Json.object_

    switch values->Js.Json.decodeObject {
    | Some(dict) =>
      dict
      ->Dict.toArray
      ->Array.forEach(entry => {
        let (key, _val) = entry

        if toBeRemoved->Array.includes(key) {
          dict->Dict.set(key, Js.Json.string(""))
        }
        dict->applyFilters
      })
    | None => ()
    }

    setInitialValueJson(_ => newInitialValues)
    setCheckedFilters(_prev => filtersAfterRemoving)
    setSelectedFiltersList(_prev => finalFieldList)
  }
  <div className={`bg-transparent flex flex-row ${customLocalFilterStyle}`}>
    <div>
      <Form initialValues=initialValueJson>
        <CheckLocalFilters
          options={localOptions}
          checkedFilters
          addFilters
          removeFilters
          applyFilters
          selectedFiltersList
          addFilterStyle
          showSelectFiltersSearch
        />
      </Form>
    </div>
  </div>
}
