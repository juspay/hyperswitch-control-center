external strToFormEvent: Js.String.t => ReactEvent.Form.t = "%identity"
let validateConditionJson = json => {
  open LogicUtils
  let checkValue = dict => {
    dict
    ->getArrayFromDict("value", [])
    ->Array.filter(ele => {
      ele != ""->Js.Json.string
    })
    ->Array.length > 0 ||
    dict->getString("value", "") !== "" ||
    dict->getFloat("value", -1.0) !== -1.0 ||
    dict->getString("operator", "") == "IS NULL" ||
    dict->getString("operator", "") == "IS NOT NULL"
  }
  switch json->Js.Json.decodeObject {
  | Some(dict) =>
    ["operator", "real_field"]->Array.every(key => dict->Dict.get(key)->Belt.Option.isSome) &&
      dict->checkValue
  | None => false
  }
}

module TextView = {
  @react.component
  let make = (
    ~str,
    ~fontColor="text-jp-gray-800 dark:text-jp-gray-600",
    ~fontWeight="font-medium",
  ) => {
    str !== ""
      ? <AddDataAttributes attributes=[("data-plc-text", str)]>
          <div
            className={`text-opacity-75 dark:text-opacity-75 
              hover:text-opacity-100 dark:hover:text-opacity-100  
              mx-1  ${fontColor} ${fontWeight} `}>
            {React.string(str)}
          </div>
        </AddDataAttributes>
      : React.null
  }
}

module CompressedView = {
  @react.component
  let make = (~id, ~isFirst) => {
    open LogicUtils
    let conditionInput = ReactFinalForm.useField(id).input
    let condition =
      conditionInput.value
      ->Js.Json.decodeObject
      ->Belt.Option.flatMap(dict => {
        Some(
          dict->getString("logical.operator", ""),
          dict->getString("real_field", ""),
          dict->getString("operator", ""),
          dict
          ->getOptionStrArrayFromDict("value")
          ->Belt.Option.getWithDefault([dict->getString("value", "")]),
          dict->getDictfromDict("metadata")->getOptionString("key"),
        )
      })
    switch condition {
    | Some((logical, field, operator, value, key)) =>
      <div className="flex flex-wrap items-center gap-4">
        {if !isFirst {
          <TextView str=logical fontColor="text-blue-800" fontWeight="font-semibold" />
        } else {
          React.null
        }}
        <TextView str=field />
        {switch key {
        | Some(val) => <TextView str=val />
        | None => React.null
        }}
        <TextView str=operator fontColor="text-red-500" fontWeight="font-semibold" />
        <TextView str={value->Array.filter(ele => ele != "")->Array.joinWith(", ")} />
      </div>
    | None => React.null
    }
  }
}
