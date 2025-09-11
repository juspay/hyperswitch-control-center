open ReconEngineExceptionTypes
open LogicUtils
open ReconEngineExceptionEntity

let processingEntriesList: JSON.t => array<processingEntryType> = json => {
  getArrayDataFromJson(json, ReconEngineExceptionStagingUtils.processingItemToObjMapper)
}

let processingTableEntity = (path: string, ~authorization: CommonAuthTypes.authorization) => {
  EntityType.makeEntity(
    ~uri=``,
    ~getObjects=processingEntriesList,
    ~defaultColumns=processingDefaultColumns,
    ~allColumns=processingDefaultColumns,
    ~getHeading=getProcessingHeading,
    ~getCell=getProcessingCell,
    ~dataKey="reports",
    ~getShowLink={
      connec => {
        GroupAccessUtils.linkForGetShowLinkViaAccess(
          ~url=GlobalVars.appendDashboardPath(~url=`/${path}/${connec.transformation_history_id}`),
          ~authorization,
        )
      }
    },
  )
}
