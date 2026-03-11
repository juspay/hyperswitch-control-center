open LogicUtils
open ReconEngineTypes
open ReconEngineUtils

let sortByDescendingVersion = (c1: ingestionHistoryType, c2: ingestionHistoryType) => {
  compareLogic(c1.version, c2.version)
}

let getAccountsOverviewIngestionHistoryPayloadFromDict = dict => {
  dict->ingestionHistoryItemToObjMapper
}

let getAccountsOverviewTransformationHistoryPayloadFromDict = dict => {
  dict->transformationHistoryItemToObjMapper
}
