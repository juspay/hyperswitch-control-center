@react.component
let make = (
  ~primaryTransactionId: string,
  ~accountIds: array<string>,
  ~accountsData: array<ReconEngineTypes.accountType>,
  ~entriesDetailFields=EntriesTableEntity.transactionEntriesDetailFields,
) => {
  open LogicUtils
  open ReconEngineTransactionsUtils

  let currencyOptions = React.useMemo(() => {
    getCurrencyOptionsFromAccounts(accountsData, ~accountIds)
  }, (accountsData, accountIds))

  <div className="flex flex-col gap-6 mt-6">
    <RenderIf condition={accountIds->isEmptyArray}>
      <NoDataFound customCssClass="my-6" message="No Data Available" renderType=Painting />
    </RenderIf>
    {accountIds
    ->Array.map(accountId =>
      <FilterContext
        key=accountId
        index={`recon-engine-transaction-entries-${primaryTransactionId}-${accountId}`}>
        <ReconEngineTransactionEntriesContent
          primaryTransactionId accountId accountsData currencyOptions entriesDetailFields
        />
      </FilterContext>
    )
    ->React.array}
  </div>
}
