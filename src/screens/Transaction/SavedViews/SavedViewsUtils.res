open LogicUtils

let maxViews = 5

let primitiveJsonToString = jsonValue =>
  switch jsonValue->getStringFromJson("")->getNonEmptyString {
  | Some(str) => str
  | None =>
    switch jsonValue->getOptionFloatFromJson {
    | Some(num) => num->Float.toString
    | None => jsonValue->getBoolFromJson(false)->getStringFromBool
    }
  }

let jsonValueToString = jsonValue =>
  switch jsonValue->getOptionStrArrayFromJson {
  | Some(_) =>
    let sortedStrArr =
      jsonValue
      ->getArrayFromJson([])
      ->Array.map(primitiveJsonToString)
      ->Array.toSorted(String.compare)
    "[" ++ sortedStrArr->Array.joinWith(",") ++ "]"
  | None => jsonValue->primitiveJsonToString
  }

let foldAmountOption = filtersDict => {
  let amountOption = filtersDict->getString(SavedViewTypes.FilterKeys.amountOption, "")
  if amountOption->isNonEmptyString {
    let startAmountStr = filtersDict->getString(SavedViewTypes.FilterKeys.startAmount, "")
    let endAmountStr = filtersDict->getString(SavedViewTypes.FilterKeys.endAmount, "")
    filtersDict->Dict.delete(SavedViewTypes.FilterKeys.startAmount)
    filtersDict->Dict.delete(SavedViewTypes.FilterKeys.endAmount)

    let amountFilterDict = Dict.make()
    let setIfSome = (key, str) =>
      switch Float.fromString(str) {
      | Some(num) => amountFilterDict->Dict.set(key, num->JSON.Encode.float)
      | None => ()
      }

    switch amountOption->AmountFilterUtils.mapStringToAmountRangeType {
    | GreaterThanOrEqualTo => setIfSome(SavedViewTypes.FilterKeys.startAmount, startAmountStr)
    | LessThanOrEqualTo => setIfSome(SavedViewTypes.FilterKeys.endAmount, endAmountStr)
    | EqualTo =>
      setIfSome(SavedViewTypes.FilterKeys.startAmount, startAmountStr)
      setIfSome(SavedViewTypes.FilterKeys.endAmount, startAmountStr)
    | InBetween =>
      setIfSome(SavedViewTypes.FilterKeys.startAmount, startAmountStr)
      setIfSome(SavedViewTypes.FilterKeys.endAmount, endAmountStr)
    | UnknownRange(_) => filtersDict->Dict.delete(SavedViewTypes.FilterKeys.amountOption)
    }

    if amountFilterDict->Dict.keysToArray->isNonEmptyArray {
      filtersDict->Dict.set("amount_filter", amountFilterDict->JSON.Encode.object)
    }
  }
}

let flattenToDict = (dictToSet, key, value) => {
  let filtersToFlatten = [(key, value)]
  let idx = ref(0)
  while idx.contents < filtersToFlatten->Array.length {
    switch filtersToFlatten->Array.get(idx.contents) {
    | Some((k, v)) =>
      idx := idx.contents + 1
      switch v->JSON.Classify.classify {
      | Null => ()
      | _ if ["limit", "offset"]->Array.includes(k) => ()
      | Object(dict) =>
        dict
        ->Dict.toArray
        ->Array.forEach(((nestedKey, nestedValue)) => {
          let flattenedKey = switch SavedViewTypes.classifyFilterKey(k) {
          | FlattenRoot => nestedKey
          | Prefixed(prefix) => `${prefix}.${nestedKey}`
          }
          filtersToFlatten->Array.push((flattenedKey, nestedValue))->ignore
        })
      | _ =>
        let strVal = jsonValueToString(v)
        if strVal->isNonEmptyString {
          dictToSet->Dict.set(k, strVal)
        }
      }
    | None => idx := idx.contents + 1
    }
  }
}

let normalizeFilters = dict => {
  let normalized = Dict.make()
  dict
  ->Dict.toArray
  ->Array.forEach(((key, value)) => {
    if key->isNonEmptyString && value->isNonEmptyString && !SavedViewTypes.isReservedKey(key) {
      normalized->Dict.set(key, value)
    }
  })
  normalized
}

let getApplyFilters = (~filterDict, ~filterValue, ~version) => {
  let stringDict = Dict.make()
  let newFiltersDict = Dict.make()

  filterDict
  ->Dict.toArray
  ->Array.forEach(((key, value)) => flattenToDict(newFiltersDict, key, value))

  let startTimeKey = OrderUIUtils.startTimeFilterKey(version)
  let endTimeKey = OrderUIUtils.endTimeFilterKey(version)
  let savedHasDates = newFiltersDict->getOptionValFromDict(startTimeKey)->Option.isSome

  filterValue
  ->Dict.keysToArray
  ->Array.forEach(key => {
    if !savedHasDates && (key === startTimeKey || key === endTimeKey) {
      ()
    } else {
      stringDict->Dict.set(key, "")
    }
  })

  let rawKeys = newFiltersDict->Dict.keysToArray
  newFiltersDict->Dict.toArray->Array.forEach(((key, value)) => stringDict->Dict.set(key, value))

  let displayKeys =
    rawKeys
    ->Array.map(key => {
      if (
        [
          SavedViewTypes.FilterKeys.amountOption,
          SavedViewTypes.FilterKeys.startAmount,
          SavedViewTypes.FilterKeys.endAmount,
        ]->Array.includes(key)
      ) {
        SavedViewTypes.FilterKeys.amount
      } else {
        key
      }
    })
    ->Array.filter(key => {
      !(["start_time", "end_time", "created.gte", "created.lte"]->Array.includes(key))
    })

  let uniqueDisplayKeys = displayKeys->getUniqueArray

  let startAmountStr = stringDict->getValueFromDict(SavedViewTypes.FilterKeys.startAmount, "")
  let endAmountStr = stringDict->getValueFromDict(SavedViewTypes.FilterKeys.endAmount, "")
  let hasStart = startAmountStr->isNonEmptyString
  let hasEnd = endAmountStr->isNonEmptyString
  let hasAmountOption =
    stringDict->getValueFromDict(SavedViewTypes.FilterKeys.amountOption, "")->isNonEmptyString

  if hasStart || hasEnd {
    if !hasAmountOption {
      let constructorName = switch (hasStart, hasEnd) {
      | (true, true) => startAmountStr === endAmountStr ? "EqualTo" : "InBetween"
      | (true, false) => "GreaterThanOrEqualTo"
      | (false, true) => "LessThanOrEqualTo"
      | (false, false) => ""
      }
      if constructorName->isNonEmptyString {
        stringDict->Dict.set(SavedViewTypes.FilterKeys.amountOption, constructorName)
      }
    }

    if !(uniqueDisplayKeys->Array.includes(SavedViewTypes.FilterKeys.amount)) {
      uniqueDisplayKeys->Array.push(SavedViewTypes.FilterKeys.amount)->ignore
    }
  }

  (stringDict, uniqueDisplayKeys)
}

let buildCurrentFiltersDict = filterValue => {
  let currentFiltersDict = Dict.make()
  filterValue
  ->Dict.toArray
  ->Array.forEach(((key, value)) => {
    if !(["limit", "offset"]->Array.includes(key)) {
      currentFiltersDict->Dict.set(key, value)
    }
  })
  currentFiltersDict
}

let findMatchingView = (
  ~savedViews: array<SavedViewTypes.savedView>,
  ~currentFiltersDict,
  ~version,
) => {
  savedViews->Array.find(view => {
    let savedFilters = view.filters->getDictFromJsonObject
    let savedFiltersStringDict = Dict.make()
    let tempCurrentFiltersDict = currentFiltersDict->Dict.copy
    savedFilters
    ->Dict.toArray
    ->Array.forEach(((key, value)) => flattenToDict(savedFiltersStringDict, key, value))
    let startTimeKey = OrderUIUtils.startTimeFilterKey(version)
    let endTimeKey = OrderUIUtils.endTimeFilterKey(version)
    if savedFiltersStringDict->getOptionValFromDict(startTimeKey)->Option.isNone {
      tempCurrentFiltersDict->Dict.delete(startTimeKey)
    }
    if savedFiltersStringDict->getOptionValFromDict(endTimeKey)->Option.isNone {
      tempCurrentFiltersDict->Dict.delete(endTimeKey)
    }
    DictionaryUtils.equalDicts(
      savedFiltersStringDict->normalizeFilters,
      tempCurrentFiltersDict->normalizeFilters,
    )
  })
}

let buildViewOptions = (
  ~savedViews: array<SavedViewTypes.savedView>,
  ~activeView: option<SavedViewTypes.savedView>,
  ~defaultViewName: string,
  ~panelState: SavedViewTypes.savedViewsPanelState,
  ~setPanelState: (
    SavedViewTypes.savedViewsPanelState => SavedViewTypes.savedViewsPanelState
  ) => unit,
  ~performRename: (SavedViewTypes.savedView, string) => promise<unit>,
  ~handleDelete: (SavedViewTypes.savedView, ReactEvent.Mouse.t) => unit,
): array<HeadlessUISelectBox.updatedOptionWithIcons> => {
  let defaultOpt: HeadlessUISelectBox.updatedOptionWithIcons = {
    label: defaultViewName,
    value: "",
    isDisabled: false,
    leftIcon: activeView->Option.isNone ? CustomIcon(<Tick isSelected=true />) : NoIcon,
    customTextStyle: None,
    customIconStyle: None,
    rightIcon: NoIcon,
    description: None,
    customComponent: None,
  }
  let savedOptions = savedViews->Array.mapWithIndex((view, i) => {
    let name = view.view_name
    let opt: HeadlessUISelectBox.updatedOptionWithIcons = {
      label: name,
      value: name,
      isDisabled: false,
      leftIcon: activeView->mapOptionOrDefault(false, activeView =>
        activeView.view_id === view.view_id
      )
        ? CustomIcon(<Tick isSelected=true />)
        : NoIcon,
      customTextStyle: None,
      customIconStyle: None,
      rightIcon: NoIcon,
      description: None,
      customComponent: Some(
        <InlineEditInput
          index=i
          labelText=name
          isUnderEdit={switch panelState {
          | RenamingViewAtIndex(idx) => idx === i
          | _ => false
          }}
          handleEdit={index =>
            setPanelState(_ =>
              switch index {
              | Some(index) => RenamingViewAtIndex(index)
              | None => NoActiveInteraction
              }
            )}
          onSubmit={newName => performRename(view, newName)->ignore}
          showEditIcon={true}
          showEditIconOnHover={false}
          iconSize=18
          paddingClass="!p-0"
          bgClass="!bg-transparent !py-0"
          inputPaddingClass="!py-1 !px-2"
          customInputStyle="!py-1 !px-2 !bg-transparent text-nd_gray-700"
          customIconStyle="text-nd_gray-300 hover:text-nd_gray-900"
          customWidth="w-full"
          validateInput={newName => {
            let errors = Dict.make()
            if newName->isEmptyString {
              errors->Dict.set("view_name", "Name cannot be empty"->JSON.Encode.string)
            }
            errors
          }}
          customIconComponent={<div
            className="text-nd_gray-300 hover:text-nd_red-500 cursor-pointer ml-2"
            onClick={ev => handleDelete(view, ev)}>
            <Icon name="trash-outline" size=18 />
          </div>}
        />,
      ),
    }
    opt
  })
  [defaultOpt]->Array.concat(savedOptions)
}
let savedViewsQueryParam = (entity: SavedViewTypes.entity) =>
  `keys=${entity->SavedViewTypes.entityToKey}`

let buildActionPayload = (
  entity: SavedViewTypes.entity,
  action: SavedViewTypes.action,
  dataDict,
) => {
  let keys = entity->SavedViewTypes.entityToKey
  let actionDict =
    [
      ("type", action->SavedViewTypes.actionToString->JSON.Encode.string),
      ("data", dataDict->JSON.Encode.object),
    ]
    ->Dict.fromArray
    ->JSON.Encode.object
  [(keys, actionDict)]->Dict.fromArray->JSON.Encode.object
}

let buildDeletePayload = (entity: SavedViewTypes.entity, viewId) => {
  let dataDict =
    [
      ("entity", entity->SavedViewTypes.entityToString->JSON.Encode.string),
      ("view_id", viewId->JSON.Encode.string),
    ]->Dict.fromArray
  buildActionPayload(entity, Delete, dataDict)
}

let buildSavedViewDataDict = (
  entity: SavedViewTypes.entity,
  name,
  filters: JSON.t,
  viewId: option<string>,
  ~savedViewDataVersion,
) => {
  let versionStr = (savedViewDataVersion->SavedViewTypes.versionToSavedViewVersion :> string)
  let dataDict =
    [
      ("view_name", name->JSON.Encode.string),
      ("filters", filters),
      ("entity", entity->SavedViewTypes.entityToString->JSON.Encode.string),
      ("version", versionStr->JSON.Encode.string),
    ]->Dict.fromArray
  dataDict->setOptionString("view_id", viewId)
  dataDict
}

let buildRenamePayload = (
  entity: SavedViewTypes.entity,
  view: SavedViewTypes.savedView,
  newName,
  ~savedViewDataVersion,
) => {
  let dataDict = buildSavedViewDataDict(
    entity,
    newName,
    view.filters,
    Some(view.view_id),
    ~savedViewDataVersion,
  )
  buildActionPayload(entity, Update, dataDict)
}

let buildSavePayload = (
  entity: SavedViewTypes.entity,
  action: SavedViewTypes.action,
  name,
  filters: JSON.t,
  viewId: option<string>,
  ~savedViewDataVersion,
) => {
  let dataDict = buildSavedViewDataDict(entity, name, filters, viewId, ~savedViewDataVersion)
  buildActionPayload(entity, action, dataDict)
}

let filterNullValues = json => {
  json
  ->getDictFromJsonObject
  ->Dict.toArray
  ->Array.filterMap(((key, value)) => {
    switch value->JSON.Classify.classify {
    | Null => None
    | Object(innerDict) =>
      let filteredInner =
        innerDict
        ->Dict.toArray
        ->Array.filterMap(((ik, iv)) => {
          switch iv->JSON.Classify.classify {
          | Null => None
          | _ => Some((ik, iv))
          }
        })
        ->Dict.fromArray
        ->JSON.Encode.object
      Some((key, filteredInner))
    | _ => Some((key, value))
    }
  })
  ->Dict.fromArray
  ->JSON.Encode.object
}

let itemToSavedView = json => {
  let dict = json->getDictFromJsonObject
  let dataDict = dict->getOptionValFromDict("data")->mapOptionOrDefault(dict, getDictFromJsonObject)
  let savedView: SavedViewTypes.savedView = {
    view_id: dict->getString("view_id", ""),
    view_name: dict->getString("view_name", ""),
    entity: dataDict->getString("entity", ""),
    version: dataDict->getString("version", "v1")->UserInfoUtils.versionMapper,
    filters: dataDict->getJsonObjectFromDict("filters")->filterNullValues,
    created_at: dict->getString("created_at", ""),
    updated_at: dict->getString("updated_at", ""),
  }
  savedView
}

let savedViewsResponseMapper = (json, entity: SavedViewTypes.entity) => {
  let viewsArray =
    json
    ->getArrayFromJson([])
    ->getValueFromArray(0, Dict.make()->JSON.Encode.object)
    ->getDictFromJsonObject
    ->getArrayFromDict(entity->SavedViewTypes.entityToKey, [])

  let response: SavedViewTypes.savedViewsResponse = {
    count: viewsArray->Array.length,
    views: viewsArray->Array.map(itemToSavedView),
  }
  response
}
