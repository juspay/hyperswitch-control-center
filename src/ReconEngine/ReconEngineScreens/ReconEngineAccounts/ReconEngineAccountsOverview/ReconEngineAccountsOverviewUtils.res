open LogicUtils
open ReconEngineFileManagementTypes

let sortByDescendingVersion = (c1: ingestionHistoryType, c2: ingestionHistoryType) => {
  compareLogic(c1.version, c2.version)
}
