open Typography

module MismatchDataDisplay = {
  @react.component
  let make = (~mismatchData: Js.Json.t, ~accountNames: array<string>) => {
    let (mismatchHeading, mismatchAmount, currency) = React.useMemo(() => {
      ReconExceptionTransactionUtils.getMismatchAmountDisplay(mismatchData)
    }, [mismatchData])

    <div className="bg-nd_gray-50 border border-nd_gray-150 rounded-lg p-4 mb-6">
      <div className={`text-nd_red-700 ${body.md.semibold} mb-2`}>
        {mismatchHeading->React.string}
      </div>
      <div className={`${body.md.regular} text-nd_gray-600`}>
        {`There is a ${mismatchHeading} of ${currency} ${mismatchAmount->Float.toString} found between ${accountNames->Array.joinWith(
            ", ",
          )}`->React.string}
      </div>
    </div>
  }
}

module ExpectedDataDisplay = {
  @react.component
  let make = (~currentExceptionDetails: ReconEngineTypes.transactionType) => {
    <div className="bg-nd_gray-150 border border-nd_gray-50 rounded-lg p-4 mb-6">
      <div className={`text-nd_gray-700 ${body.md.semibold} mb-2`}>
        {"Expected"->React.string}
      </div>
      <div className={`${body.md.regular} text-nd_gray-600`}>
        {`This transaction is marked as expected since ${currentExceptionDetails.created_at->DateTimeUtils.getFormattedDate(
            "DD MMM YYYY, hh:mm A",
          )}`->React.string}
      </div>
    </div>
  }
}

module AccountEntriesSection = {
  @react.component
  let make = (~accountName: string, ~accountEntries: array<ReconEngineTypes.entryType>) => {
    open EntriesTableEntity
    open ReconEngineUtils
    open ReconEngineTransactionsUtils

    let (expandedRowIndexArray, setExpandedRowIndexArray) = React.useState(_ => [])
    let detailsFields = [EntryType, Amount, Currency, Status, EntryId, EffectiveAt, CreatedAt]

    let onExpandIconClick = (isExpanded, rowIndex) => {
      if isExpanded {
        setExpandedRowIndexArray(prev => prev->Array.filter(index => index !== rowIndex))
      } else {
        setExpandedRowIndexArray(prev => prev->Array.concat([rowIndex]))
      }
    }

    let getRowDetails = (rowIndex: int) => {
      let entry =
        accountEntries->Array.get(rowIndex)->Option.getOr(Dict.make()->entryItemToObjMapper)
      let filteredEntryMetadata = entry.metadata->getFilteredMetadataFromEntries
      let hasEntryMetadata = filteredEntryMetadata->Dict.keysToArray->Array.length > 0

      <RenderIf condition={rowIndex < accountEntries->Array.length}>
        <RenderIf condition={hasEntryMetadata}>
          <div className="p-4">
            <div className="w-full bg-nd_gray-50 rounded-xl overflow-y-scroll !max-h-60 py-2 px-6">
              <PrettyPrintJson
                jsonToDisplay={filteredEntryMetadata->JSON.Encode.object->JSON.stringify}
              />
            </div>
          </div>
        </RenderIf>
      </RenderIf>
    }

    let heading = detailsFields->Array.map(getHeading)
    let accountRows =
      accountEntries->Array.map(entry =>
        detailsFields->Array.map(colType => getCell(entry, colType))
      )

    let (totalAmount, currency) = ReconExceptionTransactionUtils.getSumOfAmountWithCurrency(
      accountEntries,
    )

    <div key=accountName className="flex flex-col gap-4 mb-8">
      <div className="flex justify-between items-center">
        <p className={`text-nd_gray-700 ${body.lg.semibold}`}> {accountName->React.string} </p>
        <div className={`text-nd_gray-700 ${body.lg.medium}`}>
          {(currency ++ " " ++ totalAmount->Float.toString)->React.string}
        </div>
      </div>
      <CustomExpandableTable
        title=""
        tableClass="border rounded-xl overflow-y-auto"
        borderClass=" "
        firstColRoundedHeadingClass="rounded-tl-xl"
        lastColRoundedHeadingClass="rounded-tr-xl"
        headingBgColor="bg-nd_gray-25"
        headingFontWeight="font-semibold"
        headingFontColor="text-nd_gray-400"
        rowFontColor="text-nd_gray-600"
        customRowStyle="text-sm"
        rowFontStyle="font-medium"
        heading
        rows=accountRows
        onExpandIconClick
        expandedRowIndexArray
        getRowDetails
        showSerial=false
        showScrollBar=true
      />
    </div>
  }
}

@react.component
let make = (
  ~entriesList: array<ReconEngineTypes.entryType>,
  ~currentExceptionDetails: ReconEngineTypes.transactionType,
) => {
  let (groupedEntries, accountIdNameMap) = React.useMemo(() => {
    let groupDict = Dict.make()
    let idNameDict = Dict.make()

    entriesList->Array.forEach(entry => {
      let accountId = entry.account_id
      let existingEntries = groupDict->Dict.get(accountId)->Option.getOr([])
      groupDict->Dict.set(accountId, existingEntries->Array.concat([entry]))
      idNameDict->Dict.set(accountId, entry.account_name)
    })

    (groupDict, idNameDict)
  }, [entriesList])

  let mismatchDataList = React.useMemo(() => {
    entriesList
    ->Array.filter(entry => entry.status == Mismatched)
    ->Array.map(entry => entry.data)
  }, [entriesList])

  <div className="overflow-visible mt-7">
    <RenderIf condition={currentExceptionDetails.transaction_status === Mismatched}>
      {mismatchDataList
      ->Array.map(mismatchData =>
        <MismatchDataDisplay mismatchData accountNames={accountIdNameMap->Dict.valuesToArray} />
      )
      ->React.array}
    </RenderIf>
    <RenderIf condition={currentExceptionDetails.transaction_status === Expected}>
      <ExpectedDataDisplay currentExceptionDetails />
    </RenderIf>
    {groupedEntries
    ->Dict.keysToArray
    ->Array.map(accountId => {
      let accountName = accountIdNameMap->Dict.get(accountId)->Option.getOr("")
      let accountEntries = groupedEntries->Dict.get(accountId)->Option.getOr([])
      <AccountEntriesSection accountName accountEntries />
    })
    ->React.array}
  </div>
}
