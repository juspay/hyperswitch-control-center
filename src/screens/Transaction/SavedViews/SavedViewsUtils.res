open LogicUtils
open OrderUIUtils
open SavedViewTypes
open OrderTypes

let maxViews = 5

let connectorFilterKey = (#connector: filter)->getValueFromFilterType
let connectorLabelKey = (#connector_label: filter)->getLabelFromFilterType
let connectorLabelValueKey = (#connector_label: filter)->getValueFromFilterType

let versionToSavedViewVersion = (version: UserInfoTypes.version): savedViewVersion =>
  switch version {
  | V1 => #v1
  | V2 => #v2
  }

let isReservedKey = (key: string): bool =>
  [(#amount_option: filterKey :> string), (#amount: filterKey :> string)]->Array.includes(key)

let primitiveJsonToString = jsonValue =>
  switch jsonValue->getStringFromJson("")->getNonEmptyString {
  | Some(str) => str
  | None =>
    switch jsonValue->getOptionFloatFromJson {
    | Some(num) => num->Float.toString
    | None => jsonValue->getBoolFromJson(false)->getStringFromBool
    }
  }

let jsonValueToString = (key, jsonValue) =>
  switch jsonValue->getOptionStrArrayFromJson {
  | Some(_) =>
    let sortedStrArr =
      jsonValue
      ->getArrayFromJson([])
      ->Array.map(primitiveJsonToString)
      ->Array.toSorted(String.compare)
    advancedPaymentTextListFilterTypes->Array.map(getValueFromFilterType)->Array.includes(key)
      ? sortedStrArr->getValueFromArray(0, "")
      : "[" ++ sortedStrArr->Array.joinWith(",") ++ "]"
  | None => jsonValue->primitiveJsonToString
  }

let foldAmountOption = filtersDict => {
  let amountOption = filtersDict->getString((#amount_option: filterKey :> string), "")
  if amountOption->isNonEmptyString {
    let startAmountStr = filtersDict->getString((#start_amount: filterKey :> string), "")
    let endAmountStr = filtersDict->getString((#end_amount: filterKey :> string), "")
    filtersDict->Dict.delete((#start_amount: filterKey :> string))
    filtersDict->Dict.delete((#end_amount: filterKey :> string))

    let amountFilterDict = Dict.make()
    let setIfSome = (key, str) =>
      switch Float.fromString(str) {
      | Some(num) => amountFilterDict->Dict.set(key, num->JSON.Encode.float)
      | None => ()
      }

    switch amountOption->AmountFilterUtils.mapStringToAmountRangeType {
    | GreaterThanOrEqualTo => setIfSome((#start_amount: filterKey :> string), startAmountStr)
    | LessThanOrEqualTo => setIfSome((#end_amount: filterKey :> string), endAmountStr)
    | EqualTo =>
      setIfSome((#start_amount: filterKey :> string), startAmountStr)
      setIfSome((#end_amount: filterKey :> string), startAmountStr)
    | InBetween =>
      setIfSome((#start_amount: filterKey :> string), startAmountStr)
      setIfSome((#end_amount: filterKey :> string), endAmountStr)
    | UnknownRange(_) => filtersDict->Dict.delete((#amount_option: filterKey :> string))
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
    | Some((flattenedKey, flattenedValue)) =>
      idx := idx.contents + 1
      switch flattenedValue->JSON.Classify.classify {
      | Null => ()
      | _ if ["limit", "offset"]->Array.includes(flattenedKey) => ()
      | Object(dict) =>
        dict
        ->Dict.toArray
        ->Array.forEach(((nestedKey, nestedValue)) => {
          let flattenedKey = switch classifyFilterKey(flattenedKey) {
          | FlattenRoot => nestedKey
          | Prefixed(prefix) => `${prefix}.${nestedKey}`
          }
          filtersToFlatten->Array.push((flattenedKey, nestedValue))->ignore
        })
      | _ =>
        let strVal = jsonValueToString(flattenedKey, flattenedValue)
        if strVal->isNonEmptyString {
          dictToSet->Dict.set(flattenedKey, strVal)
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
    if key->isNonEmptyString && value->isNonEmptyString && !isReservedKey(key) {
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

  filterDict->getOptionValFromDict(connectorLabelValueKey)->mapOptionOrDefault((), value => {
    if newFiltersDict->getValueFromDict(connectorFilterKey, "")->isNonEmptyString {
      newFiltersDict->Dict.set(connectorLabelValueKey, jsonValueToString(connectorLabelKey, value))
    }
  })

  let startTimeKey = startTimeFilterKey(version)
  let endTimeKey = endTimeFilterKey(version)
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
          (#amount_option: filterKey :> string),
          (#start_amount: filterKey :> string),
          (#end_amount: filterKey :> string),
        ]->Array.includes(key)
      ) {
        (#amount: filterKey :> string)
      } else {
        key
      }
    })
    ->Array.filter(key => {
      !(["start_time", "end_time", "created.gte", "created.lte"]->Array.includes(key))
    })

  let uniqueDisplayKeys = displayKeys->getUniqueArray

  let startAmountStr = stringDict->getValueFromDict((#start_amount: filterKey :> string), "")
  let endAmountStr = stringDict->getValueFromDict((#end_amount: filterKey :> string), "")
  let hasStart = startAmountStr->isNonEmptyString
  let hasEnd = endAmountStr->isNonEmptyString
  let hasAmountOption =
    stringDict
    ->getValueFromDict((#amount_option: filterKey :> string), "")
    ->isNonEmptyString

  if hasStart || hasEnd {
    if !hasAmountOption {
      let constructorName = switch (hasStart, hasEnd) {
      | (true, true) => startAmountStr === endAmountStr ? "EqualTo" : "InBetween"
      | (true, false) => "GreaterThanOrEqualTo"
      | (false, true) => "LessThanOrEqualTo"
      | (false, false) => ""
      }
      if constructorName->isNonEmptyString {
        stringDict->Dict.set((#amount_option: filterKey :> string), constructorName)
      }
    }

    if !(uniqueDisplayKeys->Array.includes((#amount: filterKey :> string))) {
      uniqueDisplayKeys->Array.push((#amount: filterKey :> string))->ignore
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

let findMatchingView = (~savedViews: array<savedView>, ~currentFiltersDict, ~version) => {
  savedViews->Array.find(view => {
    let savedFilters = view.filters->getDictFromJsonObject
    let savedFiltersStringDict = Dict.make()
    let tempCurrentFiltersDict = currentFiltersDict->Dict.copy
    savedFilters
    ->Dict.toArray
    ->Array.forEach(((key, value)) => flattenToDict(savedFiltersStringDict, key, value))

    savedFilters->getOptionValFromDict(connectorLabelValueKey)->mapOptionOrDefault((), value => {
      if savedFiltersStringDict->getValueFromDict(connectorFilterKey, "")->isNonEmptyString {
        savedFiltersStringDict->Dict.set(
          connectorLabelValueKey,
          jsonValueToString(connectorLabelKey, value),
        )
      }
    })
    
    let startTimeKey = startTimeFilterKey(version)
    let endTimeKey = endTimeFilterKey(version)
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
  ~savedViews: array<savedView>,
  ~activeView: option<savedView>,
  ~defaultViewName: string,
  ~panelState: savedViewsPanelState,
  ~setPanelState: (savedViewsPanelState => savedViewsPanelState) => unit,
  ~performRename: (savedView, string) => promise<unit>,
  ~handleDelete: (savedView, ReactEvent.Mouse.t) => unit,
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
          | NoActiveInteraction | SaveViewModalOpen => false
          }}
          handleEdit={index =>
            setPanelState(_ =>
              index->mapOptionOrDefault(NoActiveInteraction, idx => RenamingViewAtIndex(idx))
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
let savedViewsQueryParam = (entity: entity) => `keys=${entity->entityToKey}`

let buildActionPayload = (entity: entity, action: action, dataDict) => {
  let keys = entity->entityToKey
  let actionDict =
    [("type", action->actionToString->JSON.Encode.string), ("data", dataDict->JSON.Encode.object)]
    ->Dict.fromArray
    ->JSON.Encode.object
  [(keys, actionDict)]->Dict.fromArray->JSON.Encode.object
}

let buildDeletePayload = (entity: entity, viewId) => {
  let dataDict =
    [
      ("entity", entity->entityToString->JSON.Encode.string),
      ("view_id", viewId->JSON.Encode.string),
    ]->Dict.fromArray
  buildActionPayload(entity, Delete, dataDict)
}

let buildSavedViewDataDict = (
  entity: entity,
  name,
  filters: JSON.t,
  viewId: option<string>,
  ~savedViewDataVersion,
) => {
  let versionStr = (savedViewDataVersion->versionToSavedViewVersion :> string)
  let dataDict =
    [
      ("view_name", name->JSON.Encode.string),
      ("filters", filters),
      ("entity", entity->entityToString->JSON.Encode.string),
      ("version", versionStr->JSON.Encode.string),
    ]->Dict.fromArray
  dataDict->setOptionString("view_id", viewId)
  dataDict
}

let buildRenamePayload = (entity: entity, view: savedView, newName, ~savedViewDataVersion) => {
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
  entity: entity,
  action: action,
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
  let savedView: savedView = {
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

let savedViewsResponseMapper = (json, entity: entity) => {
  let viewsArray =
    json
    ->getArrayFromJson([])
    ->getValueFromArray(0, Dict.make()->JSON.Encode.object)
    ->getDictFromJsonObject
    ->getArrayFromDict(entity->entityToKey, [])

  let response: savedViewsResponse = {
    count: viewsArray->Array.length,
    views: viewsArray->Array.map(itemToSavedView),
  }
  response
}
