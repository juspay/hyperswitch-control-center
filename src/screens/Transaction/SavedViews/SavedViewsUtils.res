open LogicUtils

let maxViews = 5

let entityToKey = entity =>
  switch entity {
  | "payment_views" => "PaymentViews"
  | "refund_views" => "RefundViews"
  | "dispute_views" => "DisputeViews"
  | "payout_views" => "PayoutViews"
  | _ => "PaymentViews"
  }

let jsonValueToString = jsonValue => {
  switch jsonValue->JSON.Classify.classify {
  | String(s) => s
  | Number(n) => n->Float.toString
  | Bool(b) => b ? "true" : "false"
  | Array(arr) => {
      let strArr = arr->getStrArrayFromJsonArray
      let sortedStrArr = strArr->Array.toSorted((a, b) => String.compare(a, b))
      "[" ++ sortedStrArr->Array.joinWith(",") ++ "]"
    }
  | Null => ""
  | _ => ""
  }
}

let stringFromFilterValue = (dict, key) => {
  switch dict->Dict.get(key) {
  | Some(json) =>
    switch json->JSON.Classify.classify {
    | String(s) => s
    | Number(n) => n->Float.toString
    | Array(arr) =>
      switch arr->Array.get(0) {
      | Some(ele) =>
        switch ele->JSON.Classify.classify {
        | String(s) => s
        | Number(n) => n->Float.toString
        | _ => ""
        }
      | None => ""
      }
    | _ => ""
    }
  | None => ""
  }
}

let foldAmountOption = filtersDict => {
  let amountOption = filtersDict->stringFromFilterValue("amount_option")
  if amountOption->isNonEmptyString {
    let startAmountStr = filtersDict->stringFromFilterValue("start_amount")
    let endAmountStr = filtersDict->stringFromFilterValue("end_amount")
    filtersDict->Dict.delete("start_amount")
    filtersDict->Dict.delete("end_amount")

    let amountFilterDict = Dict.make()
    let setIfSome = (key, str) =>
      switch Float.fromString(str) {
      | Some(num) => amountFilterDict->Dict.set(key, num->JSON.Encode.float)
      | None => ()
      }

    switch amountOption->AmountFilterUtils.stringRangetoTypeAmount {
    | GreaterThanOrEqualTo => setIfSome("start_amount", startAmountStr)
    | LessThanOrEqualTo => setIfSome("end_amount", endAmountStr)
    | EqualTo =>
      setIfSome("start_amount", startAmountStr)
      setIfSome("end_amount", startAmountStr)
    | InBetween =>
      setIfSome("start_amount", startAmountStr)
      setIfSome("end_amount", endAmountStr)
    | UnknownRange(_) => filtersDict->Dict.delete("amount_option")
    }

    if amountFilterDict->Dict.keysToArray->Array.length > 0 {
      filtersDict->Dict.set("amount_filter", amountFilterDict->JSON.Encode.object)
    }
  }
}

let flattenToDict = (dictToSet, key, value) => {
  let work = [(key, value)]
  let idx = ref(0)
  while idx.contents < work->Array.length {
    let (k, v) = work->Array.getUnsafe(idx.contents)
    idx := idx.contents + 1
    switch v->JSON.Classify.classify {
    | Null => ()
    | _ if ["limit", "offset"]->Array.includes(k) => ()
    | Object(objDict) =>
      objDict->Dict.toArray->Array.forEach(item => work->Array.push(item)->ignore)
    | _ =>
      let strVal = jsonValueToString(v)
      if strVal->isNonEmptyString {
        dictToSet->Dict.set(k, strVal)
      }
    }
  }
}

let normalizeFilters = dict => {
  let normalized = Dict.make()
  dict
  ->Dict.toArray
  ->Array.forEach(((key, value)) => {
    if (
      key->isNonEmptyString &&
      value->isNonEmptyString &&
      key !== "amount_option" &&
      key !== "amount"
    ) {
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
  let savedHasDates = newFiltersDict->Dict.get(startTimeKey)->Option.isSome

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
      if ["amount_option", "start_amount", "end_amount"]->Array.includes(key) {
        "amount"
      } else {
        key
      }
    })
    ->Array.filter(key => {
      !(["start_time", "end_time", "created.gte", "created.lte"]->Array.includes(key))
    })

  let uniqueDisplayKeys = displayKeys->getUniqueArray

  let startAmountStr = stringDict->Dict.get("start_amount")->Option.getOr("")
  let endAmountStr = stringDict->Dict.get("end_amount")->Option.getOr("")
  let hasStart = startAmountStr->isNonEmptyString
  let hasEnd = endAmountStr->isNonEmptyString
  let hasAmountOption = stringDict->Dict.get("amount_option")->Option.getOr("")->isNonEmptyString

  if hasStart || hasEnd {
    if !hasAmountOption {
      let constructorName = switch (hasStart, hasEnd) {
      | (true, true) => startAmountStr === endAmountStr ? "EqualTo" : "InBetween"
      | (true, false) => "GreaterThanOrEqualTo"
      | (false, true) => "LessThanOrEqualTo"
      | (false, false) => ""
      }
      if constructorName->isNonEmptyString {
        stringDict->Dict.set("amount_option", constructorName)
      }
    }

    if !(uniqueDisplayKeys->Array.includes("amount")) {
      uniqueDisplayKeys->Array.push("amount")->ignore
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
    if savedFiltersStringDict->Dict.get(startTimeKey)->Option.isNone {
      tempCurrentFiltersDict->Dict.delete(startTimeKey)
    }
    if savedFiltersStringDict->Dict.get(endTimeKey)->Option.isNone {
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
  ~activeViewName: string,
  ~defaultViewName: string,
  ~currentlyEditingIndex: option<int>,
  ~setCurrentlyEditingIndex: (option<int> => option<int>) => unit,
  ~performRename: (SavedViewTypes.savedView, string) => promise<unit>,
  ~handleDelete: (SavedViewTypes.savedView, ReactEvent.Mouse.t) => unit,
): array<HeadlessUISelectBox.updatedOptionWithIcons> => {
  let defaultOpt: HeadlessUISelectBox.updatedOptionWithIcons = {
    label: defaultViewName,
    value: "",
    isDisabled: false,
    leftIcon: activeViewName->isEmptyString ? CustomIcon(<Tick isSelected=true />) : NoIcon,
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
      leftIcon: name === activeViewName ? CustomIcon(<Tick isSelected=true />) : NoIcon,
      customTextStyle: None,
      customIconStyle: None,
      rightIcon: NoIcon,
      description: None,
      customComponent: Some(
        <InlineEditInput
          index=i
          labelText=name
          isUnderEdit={currentlyEditingIndex->Option.mapOr(false, index => index == i)}
          handleEdit={index => setCurrentlyEditingIndex(_ => index)}
          onSubmit={newName => performRename(view, newName)->ignore}
          showEditIcon={true}
          showEditIconOnHover={false}
          iconSize=18
          paddingClass="!p-0"
          bgClass="!bg-transparent !py-0"
          inputPaddingClass="!py-1 !px-2"
          customInputStyle="!py-1 !px-2 !bg-transparent text-nd_gray-700"
          customIconStyle="text-nd_gray-300 hover:text-black"
          customWidth="w-full"
          validateInput={newName => {
            let errors = Dict.make()
            if newName->isEmptyString {
              errors->Dict.set("view_name", "Name cannot be empty"->JSON.Encode.string)
            }
            errors
          }}
          customIconComponent={<div
            className="text-nd_gray-300 hover:text-red-500 cursor-pointer ml-2"
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
let savedViewsQueryParam = entity => `keys=${entityToKey(entity)}`

let buildActionPayload = (entity, actionType, dataDict) => {
  let keys = entityToKey(entity)
  let actionDict =
    [("type", actionType->JSON.Encode.string), ("data", dataDict->JSON.Encode.object)]
    ->Dict.fromArray
    ->JSON.Encode.object
  [(keys, actionDict)]
  ->Dict.fromArray
  ->JSON.Encode.object
}

let buildDeletePayload = (entity, viewId) => {
  let dataDict =
    [
      ("entity", entity->JSON.Encode.string),
      ("view_id", viewId->JSON.Encode.string),
    ]->Dict.fromArray
  buildActionPayload(entity, "Delete", dataDict)
}

let buildRenamePayload = (entity, view: SavedViewTypes.savedView, newName) => {
  let dataDict =
    [
      ("view_id", view.view_id->JSON.Encode.string),
      ("view_name", newName->JSON.Encode.string),
      ("filters", view.filters),
      ("entity", entity->JSON.Encode.string),
      ("version", "v1"->JSON.Encode.string),
    ]->Dict.fromArray
  buildActionPayload(entity, "Update", dataDict)
}

let buildSavePayload = (entity, actionType, name, filters: JSON.t, viewId: option<string>) => {
  let dataDict =
    [
      ("view_name", name->JSON.Encode.string),
      ("filters", filters),
      ("entity", entity->JSON.Encode.string),
      ("version", "v1"->JSON.Encode.string),
    ]->Dict.fromArray
  switch viewId {
  | Some(id) => dataDict->Dict.set("view_id", id->JSON.Encode.string)
  | None => ()
  }
  buildActionPayload(entity, actionType, dataDict)
}

let filterNullValues = json => {
  json
  ->getDictFromJsonObject
  ->Dict.toArray
  ->Belt.Array.keepMap(((key, value)) => {
    switch value->JSON.Classify.classify {
    | Null => None
    | Object(innerDict) =>
      let filteredInner =
        innerDict
        ->Dict.toArray
        ->Belt.Array.keepMap(((ik, iv)) => {
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
  let dataDict = dict->getJsonObjectFromDict("data")->getDictFromJsonObject
  let savedView: SavedViewTypes.savedView = {
    view_id: dict->getString("view_id", ""),
    view_name: dict->getString("view_name", ""),
    entity: dataDict->getString("entity", ""),
    filters: dataDict->getJsonObjectFromDict("filters")->filterNullValues,
    created_at: dict->getString("created_at", ""),
    updated_at: dict->getString("updated_at", ""),
  }
  savedView
}

let savedViewsResponseMapper = json => {
  let viewsArray =
    json
    ->getArrayFromJson([])
    ->getValueFromArray(0, Dict.make()->JSON.Encode.object)
    ->getDictFromJsonObject
    ->getArrayFromDict("PaymentViews", [])

  let response: SavedViewTypes.savedViewsResponse = {
    count: viewsArray->Array.length,
    views: viewsArray->Array.map(itemToSavedView),
  }
  response
}
