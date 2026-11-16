open SuperpositionTypes
open LogicUtils

let getConfigKey = ({folder, name}: HyperSwitchConfigTypes.superpositionDisplayConfig) =>
  folder->mapOptionOrDefault(name, folder => `${folder}.${name}`)

let getDimensionsForFixedContext = dimensionEntity =>
  switch dimensionEntity {
  | OrganizationId => "organization_id"
  | ProcessorMerchantId => "processor_merchant_id"
  | ProviderMerchantId => "provider_merchant_id"
  | ProfileID => "profile_id"
  }

let getDimensionLabel = dimensionEntity =>
  switch dimensionEntity {
  | OrganizationId => "Organization"
  | ProcessorMerchantId => "Processor Merchant"
  | ProviderMerchantId => "Provider Merchant"
  | ProfileID => "Profile"
  }

let scopeDimensionEntities = [OrganizationId, ProviderMerchantId, ProcessorMerchantId, ProfileID]

let scopeDimensionNames = scopeDimensionEntities->Array.map(getDimensionsForFixedContext)

// Superposition's own dimensions (experiments); never shown or set from here.
let reservedDimensionNames = ["variantIds"]

let isReservedDimension = (dimension: dimension) =>
  reservedDimensionNames->Array.includes(dimension.name)

let getScopeContext = (~orgId, ~processorMerchantId, ~profileId, ~providerMerchantId) =>
  [
    (getDimensionsForFixedContext(OrganizationId), JSON.Encode.string(orgId)),
    (getDimensionsForFixedContext(ProcessorMerchantId), JSON.Encode.string(processorMerchantId)),
    (getDimensionsForFixedContext(ProviderMerchantId), JSON.Encode.string(providerMerchantId)),
    (getDimensionsForFixedContext(ProfileID), JSON.Encode.string(profileId)),
  ]->Dict.fromArray

let getDimensionDisplayName = name =>
  switch scopeDimensionEntities->Array.find(entity =>
    getDimensionsForFixedContext(entity) == name
  ) {
  | Some(entity) => getDimensionLabel(entity)
  | None => name->snakeToTitle
  }

let rec canonicalJson = (json: JSON.t) =>
  switch json->JSON.Classify.classify {
  | Object(dict) =>
    dict
    ->Dict.toArray
    ->Array.toSorted(((a, _), (b, _)) => String.compare(a, b))
    ->Array.map(((key, value)) => (key, value->canonicalJson))
    ->Dict.fromArray
    ->JSON.Encode.object
  | Array(items) => items->Array.map(canonicalJson)->JSON.Encode.array
  | _ => json
  }

let jsonEquals = (a, b) => a->canonicalJson->JSON.stringify == b->canonicalJson->JSON.stringify

let formatValue = (json: JSON.t) =>
  switch json->JSON.Classify.classify {
  | String(value) => value
  | Null => "null"
  | _ => json->JSON.stringify
  }

let formatDimensionValue = formatValue

let describeConditions = (conditions: Dict.t<JSON.t>) =>
  conditions
  ->Dict.toArray
  ->Array.map(((name, value)) => `${name->getDimensionDisplayName}: ${value->formatValue}`)
  ->Array.joinWith(", ")

let getListFromResponse = json => {
  switch json->JSON.Classify.classify {
  | Array(items) => items
  | _ => json->getDictFromJsonObject->getArrayFromDict("data", [])
  }
}

let getDictValue = (dict, key) => dict->Dict.get(key)->Option.getOr(JSON.Encode.null)

let parseDefaultConfig = (json): defaultConfig => {
  let dict = json->getDictFromJsonObject
  {
    key: dict->getString("key", ""),
    value: dict->getDictValue("value"),
    schema: dict->getDictfromDict("schema"),
    description: dict->getString("description", ""),
  }
}

let parseDimension = (json): dimension => {
  let dict = json->getDictFromJsonObject
  {
    name: dict->getString("dimension", ""),
    position: dict->getInt("position", 0),
    schema: dict->getDictfromDict("schema"),
    description: dict->getString("description", ""),
  }
}

let parseWeight = json =>
  switch json->JSON.Classify.classify {
  | Number(value) => value
  | String(value) => value->Float.fromString->Option.getOr(0.0)
  | _ => 0.0
  }

let parseContext = (json): context => {
  let dict = json->getDictFromJsonObject
  {
    id: dict->getString("id", ""),
    condition: dict->getDictfromDict("value"),
    override: dict->getDictfromDict("override"),
    weight: dict->getDictValue("weight")->parseWeight,
    description: dict->getString("description", ""),
    changeReason: dict->getString("change_reason", ""),
    lastModifiedAt: dict->getString("last_modified_at", ""),
    lastModifiedBy: dict->getString("last_modified_by", ""),
  }
}

let parseResolved = (json): Dict.t<resolvedEntry> =>
  json
  ->getDictFromJsonObject
  ->Dict.toArray
  ->Array.map(((key, entryJson)) => {
    (key, {resolvedValue: entryJson->getDictFromJsonObject->getDictValue("value")})
  })
  ->Dict.fromArray

let parseExplainTimeline = (json): array<explainStep> =>
  json
  ->getDictFromJsonObject
  ->getArrayFromDict("timeline", [])
  ->Array.map(stepJson => {
    let step = stepJson->getDictFromJsonObject
    {
      stepContextId: step->getString("context_id", ""),
      stepCondition: step->getDictfromDict("condition"),
      valueBefore: step->getDictValue("value_before"),
      valueAfter: step->getDictValue("value_after"),
    }
  })

// The explain timeline lists every context that matches the scope, including ones that
// don't set the key. Keep only the steps whose context overrides it.
let getOverridingSteps = (steps: array<explainStep>, ~key, ~contexts: array<context>) =>
  steps->Array.filter(step =>
    switch contexts->Array.find(context => context.id == step.stepContextId) {
    | Some(context) => context.override->Dict.get(key)->Option.isSome
    | None => step.valueBefore != step.valueAfter
    }
  )

let parseAuditLog = (json): auditLog => {
  let dict = json->getDictFromJsonObject
  let optionalJson = key =>
    switch dict->Dict.get(key) {
    | Some(value) if value != JSON.Encode.null => Some(value)
    | _ => None
    }
  {
    auditId: dict->getString("id", ""),
    tableName: dict->getString("table_name", ""),
    userName: dict->getString("user_name", ""),
    timestamp: dict->getString("timestamp", ""),
    action: dict->getString("action", ""),
    originalData: optionalJson("original_data"),
    newData: optionalJson("new_data"),
  }
}

let isContextAudit = (log: auditLog) => log.tableName == "contexts"

let getAuditTableLabel = tableName =>
  switch tableName {
  | "contexts" => "Value"
  | "default_configs" => "Default value"
  | "dimensions" => "Dimension"
  | tableName => tableName->snakeToTitle
  }

let getAuditActionVerb = action =>
  switch action->String.toUpperCase {
  | "INSERT" => "created"
  | "DELETE" => "removed"
  | _ => "updated"
  }

let getAuditSnapshot = (data: option<JSON.t>) =>
  data->Option.mapOr(Dict.make(), getDictFromJsonObject)

let getAuditValues = (log: auditLog, data) => {
  let snapshot = data->getAuditSnapshot
  if log->isContextAudit {
    snapshot->getDictfromDict("override")
  } else {
    switch (snapshot->getOptionString("key"), snapshot->Dict.get("value")) {
    | (Some(key), Some(value)) => [(key, value)]->Dict.fromArray
    | _ => Dict.make()
    }
  }
}

let getAuditValueChanges = (log: auditLog) => {
  let before = log->getAuditValues(log.originalData)
  let after = log->getAuditValues(log.newData)
  before
  ->Dict.keysToArray
  ->Array.concat(after->Dict.keysToArray)
  ->Array.reduce([], (acc, key) => acc->Array.includes(key) ? acc : acc->Array.concat([key]))
  ->Array.filterMap(key => {
    let change = {changedKey: key, before: before->Dict.get(key), after: after->Dict.get(key)}
    switch (change.before, change.after) {
    | (Some(a), Some(b)) if jsonEquals(a, b) => None
    | _ => Some(change)
    }
  })
}

let getAuditChangedKeys = (log: auditLog) =>
  log->getAuditValueChanges->Array.map(change => change.changedKey)

let getAuditConditions = (log: auditLog) => {
  let conditionOf = data =>
    log->isContextAudit && data->Option.isSome
      ? Some(data->getAuditSnapshot->getDictfromDict("value"))
      : None
  (log.originalData->conditionOf, log.newData->conditionOf)
}

// An update that changed no value, condition or description, such as the stamp Superposition
// writes before a delete or the reason recorded ahead of one.
let isNoOpAuditUpdate = (log: auditLog) => {
  let field = (data, name) => data->getAuditSnapshot->Dict.get(name)->Option.getOr(JSON.Encode.null)
  log.action->String.toUpperCase == "UPDATE" &&
  log->isContextAudit &&
  log->getAuditValueChanges->Array.length == 0 &&
  ["value", "description"]->Array.every(name =>
    jsonEquals(log.originalData->field(name), log.newData->field(name))
  )
}

// Superposition records the writer on the row itself; `user_name` is the database role.
// Before a delete it stamps the row, so the removed snapshot names who removed it.
let getAuditAuthor = (log: auditLog) =>
  [log.newData, log.originalData]
  ->Array.findMap(data =>
    data->getAuditSnapshot->getOptionString("last_modified_by")->Option.filter(isNonEmptyString)
  )
  ->Option.getOr(log.userName)

let getAuditReason = (log: auditLog) =>
  [log.newData, log.originalData]
  ->Array.findMap(data => data->getAuditSnapshot->getOptionString("change_reason"))
  ->Option.getOr("")

let getSchemaType = (schema: Dict.t<JSON.t>) =>
  switch schema->Dict.get("type")->Option.map(JSON.Classify.classify) {
  | Some(String(schemaType)) => schemaType
  | Some(Array(types)) =>
    types
    ->Array.filterMap(JSON.Decode.string)
    ->Array.find(schemaType => schemaType != "null")
    ->Option.getOr("")
  | _ => ""
  }

let getSchemaEnum = (schema: Dict.t<JSON.t>) =>
  schema->getArrayFromDict("enum", [])->Array.filterMap(JSON.Decode.string)

let getValueKind = (schema: Dict.t<JSON.t>, value: JSON.t) => {
  let enumValues = schema->getSchemaEnum
  switch schema->getSchemaType {
  | "boolean" => BoolValue
  | "integer" => IntegerValue
  | "number" => NumberValue
  | "string" if enumValues->isNonEmptyArray => EnumValue(enumValues)
  | "string" => StringValue
  | "array" => {
      let items = schema->getDictfromDict("items")
      items->getSchemaType == "string" ? StringListValue(items->getSchemaEnum) : JsonValue
    }
  | "object" => JsonValue
  | _ =>
    switch value->JSON.Classify.classify {
    | Bool(_) => BoolValue
    | Number(_) => NumberValue
    | String(_) => StringValue
    | _ => JsonValue
    }
  }
}

let getValueKindLabel = kind =>
  switch kind {
  | BoolValue => "Boolean"
  | IntegerValue => "Integer"
  | NumberValue => "Number"
  | StringValue => "String"
  | EnumValue(_) => "Option"
  | StringListValue(_) => "List"
  | JsonValue => "JSON"
  }

let valueToDraft = (kind, value: JSON.t) =>
  switch kind {
  | StringValue | EnumValue(_) => value->JSON.Decode.string->Option.getOr("")
  | StringListValue(_) =>
    value
    ->JSON.Decode.array
    ->Option.getOr([])
    ->Array.filterMap(JSON.Decode.string)
    ->Array.map(JSON.Encode.string)
    ->JSON.Encode.array
    ->JSON.stringify
  | JsonValue => value->JSON.stringifyWithIndent(2)
  | BoolValue | IntegerValue | NumberValue => value == JSON.Encode.null ? "" : value->JSON.stringify
  }

let draftToValue = (kind, draft): result<JSON.t, string> =>
  switch kind {
  | StringValue => Ok(draft->JSON.Encode.string)
  | EnumValue(options) =>
    options->Array.includes(draft)
      ? Ok(draft->JSON.Encode.string)
      : Error("Choose one of the listed options")
  | BoolValue =>
    switch draft {
    | "true" => Ok(true->JSON.Encode.bool)
    | "false" => Ok(false->JSON.Encode.bool)
    | _ => Error("Choose true or false")
    }
  | IntegerValue =>
    switch draft->String.trim->Int.fromString {
    | Some(value) if value->Int.toString == draft->String.trim => Ok(value->JSON.Encode.int)
    | _ => Error("Enter a whole number")
    }
  | NumberValue =>
    switch draft->String.trim->Float.fromString {
    | Some(value) if draft->String.trim->isNonEmptyString => Ok(value->JSON.Encode.float)
    | _ => Error("Enter a number")
    }
  | StringListValue(_) =>
    switch draft->JSON.parseExn->JSON.Decode.array {
    | Some(items) => Ok(items->JSON.Encode.array)
    | None => Error("Enter a list")
    | exception _ => Error("Enter a list")
    }
  | JsonValue =>
    try Ok(draft->JSON.parseExn) catch {
    | _ => Error("Enter valid JSON")
    }
  }

let conditionValueMatches = (scope: Dict.t<JSON.t>, name, value) =>
  scope->Dict.get(name)->Option.mapOr(false, scopeValue => jsonEquals(scopeValue, value))

let appliesToScope = (condition: Dict.t<JSON.t>, scope) =>
  condition->Dict.toArray->Array.every(((name, value)) => scope->conditionValueMatches(name, value))

let isThisLevel = (condition: Dict.t<JSON.t>, scope: Dict.t<JSON.t>) =>
  condition->appliesToScope(scope) &&
    condition->Dict.keysToArray->Array.length == scope->Dict.keysToArray->Array.length

let isBroaderLevel = (condition, scope) =>
  condition->appliesToScope(scope) && !(condition->isThisLevel(scope))

let getExtraConditions = (condition: Dict.t<JSON.t>, scope: Dict.t<JSON.t>) =>
  condition
  ->Dict.toArray
  ->Array.filter(((name, _)) => scope->Dict.get(name)->Option.isNone)
  ->Dict.fromArray

let mergeConditions = (scope: Dict.t<JSON.t>, extra: Dict.t<JSON.t>) =>
  scope->Dict.toArray->Array.concat(extra->Dict.toArray)->Dict.fromArray

let getLevelLabel = (condition: Dict.t<JSON.t>) =>
  scopeDimensionEntities
  ->Array.reduce(None, (deepest, entity) =>
    condition->Dict.get(getDimensionsForFixedContext(entity))->Option.isSome
      ? Some(entity)
      : deepest
  )
  ->Option.mapOr("Default", getDimensionLabel)

// Keys shown read-only under "Owned". Every other key the proxy returns is customizable, so
// the two together are the backend's allowlist.
let ownedKeys: array<string> = []

let getKeyOwnership = key => ownedKeys->Array.includes(key) ? Owned : Managed

let getValueStatus = (row: configRow) =>
  switch row.thisLevelContext {
  | Some(_) => CustomStatus
  | None => jsonEquals(row.value, row.defaultValue) ? DefaultStatus : UpdatedStatus
  }

let getValueStatusLabel = status =>
  switch status {
  | DefaultStatus => "Default"
  | UpdatedStatus => "Updated"
  | CustomStatus => "Custom"
  }

let valueStatuses = [DefaultStatus, UpdatedStatus, CustomStatus]

let getResetStatus = (row: configRow) =>
  jsonEquals(row.inheritedValue, row.defaultValue) ? DefaultStatus : UpdatedStatus

let humanizeKeySegment = segment => {
  let words = segment->String.split("_")->Array.filter(isNonEmptyString)->Array.joinWith(" ")
  `${words->String.charAt(0)->String.toUpperCase}${words->String.sliceToEnd(~start=1)}`
}

let getKeyPath = key => {
  let segments = key->String.split(".")->Array.filter(isNonEmptyString)
  let count = segments->Array.length
  switch segments {
  | [] => {namespace: "general", groupPath: [], leaf: key}
  | [leaf] => {namespace: "general", groupPath: [], leaf}
  | _ => {
      namespace: segments->Array.get(0)->Option.getOr(""),
      groupPath: segments->Array.slice(~start=1, ~end=count - 1),
      leaf: segments->Array.get(count - 1)->Option.getOr(""),
    }
  }
}

let getGroupLabel = groupPath =>
  groupPath->isEmptyArray
    ? "General"
    : groupPath->Array.map(humanizeKeySegment)->Array.joinWith(" › ")

let getKeyLabel = key => key->getKeyPath->(path => path.leaf->humanizeKeySegment)

let getKeyLocation = key => key->getKeyPath->(path => path.groupPath->getGroupLabel)

let getKeySegments = key => key->String.split(".")->Array.filter(isNonEmptyString)

let getKeyLocationBelow = (key, ~depth) => {
  let segments = key->getKeySegments
  segments
  ->Array.slice(~start=depth, ~end=segments->Array.length - 1)
  ->Array.map(humanizeKeySegment)
  ->Array.joinWith(" › ")
}

let getSegmentTabs = (rows: array<configRow>, ~depth) => {
  let leaves = []
  let tabs: array<segmentTab> = []
  rows->Array.forEach(row => {
    let segments = row.key->getKeySegments
    if segments->Array.length - 1 <= depth {
      leaves->Array.push(row)
    } else {
      let label = segments->Array.get(depth)->Option.getOr("")->humanizeKeySegment
      switch tabs->Array.find(tab => tab.label == label) {
      | Some(tab) => tab.tabRows->Array.push(row)
      | None => tabs->Array.push({label, tabRows: [row], depth: depth + 1})
      }
    }
  })
  (leaves, tabs)
}

let matchesDisplayPrefixes = (key, prefixes) =>
  prefixes->Array.length == 0 || prefixes->Array.some(prefix => key->String.startsWith(prefix))

// Contexts arrive sorted by weight, lowest first, so the last broader match wins.
let buildConfigRows = (~data: configsData, ~scope, ~displayPrefixes) => {
  let broaderContexts =
    data.contexts->Array.filter(context => context.condition->isBroaderLevel(scope))
  let thisLevelContext = data.contexts->Array.find(context => context.condition->isThisLevel(scope))

  data.defaults
  ->Array.filter(config => config.key->matchesDisplayPrefixes(displayPrefixes))
  ->Array.toSorted((a, b) => String.compare(a.key, b.key))
  ->Array.map(config => {
    let key = config.key
    let lastBroader =
      broaderContexts->Array.reduce(None, (last, context) =>
        context.override->Dict.get(key)->Option.isSome ? Some(context) : last
      )
    let inheritedValue =
      lastBroader
      ->Option.flatMap(context => context.override->Dict.get(key))
      ->Option.getOr(config.value)
    let thisLevel =
      thisLevelContext->Option.filter(context => context.override->Dict.get(key)->Option.isSome)

    let fallbackValue =
      thisLevel
      ->Option.flatMap(context => context.override->Dict.get(key))
      ->Option.getOr(inheritedValue)
    let value =
      data.resolved
      ->Option.flatMap(resolved => resolved->Dict.get(key))
      ->Option.mapOr(fallbackValue, entry => entry.resolvedValue)

    {
      key,
      description: config.description,
      kind: getValueKind(config.schema, config.value),
      value,
      inheritedValue,
      defaultValue: config.value,
      ownership: key->getKeyOwnership,
      thisLevelContext: thisLevel,
    }
  })
}

// Superposition rejects an empty change reason and caps it at 255 characters.
let changeReasonMaxLength = 255

let validateChangeReason = reason => {
  let trimmed = reason->String.trim
  if trimmed->isEmptyString {
    Error("Add a reason for this change.")
  } else if trimmed->String.length > changeReasonMaxLength {
    Error(`Keep the reason to ${changeReasonMaxLength->Int.toString} characters or fewer.`)
  } else {
    Ok(trimmed)
  }
}

// Superposition already limits `contexts` to this level and narrower, highest weight first.
// What's left here: drop this level's own context and group the rest by key.
let getSpecializationGroups = (~rows: array<configRow>, ~contexts: array<context>, ~scope) =>
  rows->Array.filterMap(row => {
    let entries =
      contexts
      ->Array.filter(context =>
        context.override->Dict.get(row.key)->Option.isSome &&
          !(context.condition->isThisLevel(scope))
      )
      ->Array.mapWithIndex((context, index) => {
        entryRow: row,
        spec: {context, extraConditions: context.condition->getExtraConditions(scope)},
        rank: index + 1,
      })
    entries->isNonEmptyArray ? Some({groupRow: row, entries}) : None
  })

let getDimensionQuery = (scope: Dict.t<JSON.t>) =>
  scope
  ->Dict.toArray
  ->Array.map(((name, value)) =>
    `${`dimension[${name}]`->encodeURIComponent}=${value
      ->formatDimensionValue
      ->encodeURIComponent}`
  )
  ->Array.joinWith("&")

let getAuditTimestamp = timestamp =>
  timestamp->isNonEmptyString ? timestamp->Js.Date.fromString->Js.Date.toLocaleString : "-"
