let validateConditionJson = json => {
  open LogicUtils
  let checkValue = dict => {
    dict
    ->getArrayFromDict("value", [])
    ->Array.filter(ele => {
      ele != ""->JSON.Encode.string
    })
    ->Array.length > 0 ||
    dict->getString("value", "")->LogicUtils.isNonEmptyString ||
    dict->getFloat("value", -1.0) !== -1.0 ||
    dict->getString("operator", "") == "IS NULL" ||
    dict->getString("operator", "") == "IS NOT NULL"
  }
  switch json->JSON.Decode.object {
  | Some(dict) =>
    ["operator", "real_field"]->Array.every(key => dict->Dict.get(key)->Option.isSome) &&
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
    str->LogicUtils.isNonEmptyString
      ? <AddDataAttributes attributes=[("data-plc-text", str)]>
          <div
            className={`text-opacity-75 dark:text-opacity-75 hover:text-opacity-100 dark:hover:text-opacity-100 mx-1 ${fontColor} ${fontWeight} `}>
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
    let {globalUIConfig: {font: {textColor}}} = React.useContext(ConfigContext.configContext)
    let conditionInput = ReactFinalForm.useField(id).input

    let displayForValue = value =>
      switch value->JSON.Classify.classify {
      | Array(arr) => arr->Array.joinWithUnsafe(", ")
      | String(str) => str
      | Number(num) => num->Float.toString
      | Object(obj) => obj->getString("value", "")
      | _ => ""
      }

    let condition =
      conditionInput.value
      ->JSON.Decode.object
      ->Option.flatMap(dict => {
        Some(
          dict->getString("logical", ""),
          dict->getString("lhs", ""),
          dict->getString("comparison", ""),
          dict->getDictfromDict("value")->getJsonObjectFromDict("value")->displayForValue,
          dict->getDictfromDict("metadata")->getOptionString("key"),
        )
      })
    switch condition {
    | Some((logical, field, operator, value, key)) =>
      <div className="flex flex-wrap items-center gap-4">
        {if !isFirst {
          <TextView
            str=logical fontColor={`${textColor.primaryNormal}`} fontWeight="font-semibold"
          />
        } else {
          React.null
        }}
        <TextView str=field />
        {switch key {
        | Some(val) => <TextView str=val />
        | None => React.null
        }}
        <TextView str=operator fontColor="text-red-500" fontWeight="font-semibold" />
        <TextView str={value} />
      </div>
    | None => React.null
    }
  }
}
