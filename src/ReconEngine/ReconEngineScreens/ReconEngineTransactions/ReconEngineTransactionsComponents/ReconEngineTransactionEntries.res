@react.component
let make = (
  ~entriesList: array<ReconEngineTypes.entryType>,
  ~currentTransactionDetails: ReconEngineTypes.transactionType,
  ~accountsData: array<ReconEngineTypes.accountType>,
) => {
  open LogicUtils
  open EntriesTableEntity
  open ReconEngineExceptionTransactionUtils
  open ReconEngineExceptionTransactionHelper

  let detailsFields = [
    EntryType,
    Amount,
    Currency,
    Status,
    EntryId,
    OrderID,
    EffectiveAt,
    CreatedAt,
    Actions,
  ]

  let (groupedEntries, accountInfoMap) = React.useMemo(() => {
    getGroupedEntriesAndAccountMaps(
      ~accountsData,
      ~updatedEntriesList=entriesList->addUniqueIdsToEntries,
    )
  }, (entriesList, accountsData))

  let sectionDetails = (sectionIndex: int, rowIndex: int) => {
    getSectionRowDetails(
      ~sectionIndex,
      ~rowIndex,
      ~groupedEntries=groupedEntries->convertGroupedEntriesToEntryType,
    )
  }

  let tableSections = React.useMemo(() => {
    let sections = getEntriesSections(
      ~groupedEntries,
      ~accountInfoMap,
      ~detailsFields,
      ~showTotalAmount=false,
    )
    let accountIds = groupedEntries->Dict.keysToArray
    sections->Array.mapWithIndex((section, index) => {
      let accountId = accountIds->getValueFromArray(index, "")
      let entriesWithUniqueId = groupedEntries->Dict.get(accountId)->Option.getOr([])
      {
        ...section,
        rowData: entriesWithUniqueId->Array.map(entry => entry->Identity.genericTypeToJson),
      }
    })
  }, (groupedEntries, accountInfoMap, detailsFields, currentTransactionDetails.transaction_status))

  <div className="flex flex-col gap-4 mt-6 mb-16">
    <ReconEngineCustomExpandableSelectionTable
      title=""
      heading={detailsFields->Array.map(getHeading)}
      getSectionRowDetails=sectionDetails
      showScrollBar=true
      showOptions=false
      selectedRows=[]
      onRowSelect={_ => ()}
      sections=tableSections
    />
  </div>
}
