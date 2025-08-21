open Typography
open APIUtils
open LogicUtils
open ReconEngineOverviewTypes
open ReconEngineOverviewSummaryHelper
open ReconEngineOverviewSummaryUtils

module LedgerTableHeader = {
  @react.component
  let make = (~currency) => {
    let amountTypes = AmountTypeUtils.getAllAmountTypes()
    let subHeaderTypes = AmountTypeUtils.getAllSubHeaderTypes()

    <thead className="bg-nd_gray-25 dark:bg-jp-gray-darkgray_background">
      <tr>
        {LedgerTableHeaderHelper.makeHeaderCell(~text="Accounts", ~colSpan=2)}
        {amountTypes
        ->Array.mapWithIndex((amountType, index) => {
          let isLast = index === Array.length(amountTypes) - 1
          let headerText = AmountTypeUtils.getHeaderText(amountType, currency)
          LedgerTableHeaderHelper.makeHeaderCell(~text=headerText, ~colSpan=2, ~isLast)
        })
        ->React.array}
      </tr>
      <tr>
        {LedgerTableHeaderHelper.makeEmptyCell()}
        {LedgerTableHeaderHelper.makeEmptyCell(~isRightBorder=true)}
        {amountTypes
        ->Array.map(_ => {
          subHeaderTypes->Array.mapWithIndex((subHeaderType, subIndex) => {
            let isLastSubHeader = subIndex === Array.length(subHeaderTypes) - 1
            let subHeaderText = (subHeaderType :> string)
            let isRightBorder = isLastSubHeader
            LedgerTableHeaderHelper.makeSubHeaderCell(~text=subHeaderText, ~isRightBorder)
          })
        })
        ->Array.flat
        ->React.array}
      </tr>
    </thead>
  }
}

module LedgerTableRow = {
  @react.component
  let make = (~data: accountType, ~isTotal: bool=false) => {
    let rowClass = isTotal ? "bg-nd_gray-25 font-semibold" : "bg-white hover:bg-nd_gray-50"
    let amountTypes = AmountTypeUtils.getAllAmountTypes()

    <tr className={`${rowClass} transition duration-300 ease-in-out`}>
      {if isTotal {
        <>
          {LedgerTableCellHelper.makeTotalCell(~text="Total")}
          {amountTypes
          ->Array.mapWithIndex((amountType, index) => {
            let (creditAmount, debitAmount) = AmountTypeUtils.getAmountPair(amountType, data)
            let isLastPair = index === Array.length(amountTypes) - 1

            if isLastPair {
              <>
                {LedgerTableCellHelper.makeAmountCell(
                  ~value=creditAmount.value,
                  ~currency=creditAmount.currency,
                  ~isRightBorder=false,
                  ~isTotal,
                )}
                {LedgerTableCellHelper.makeAmountCell(
                  ~value=debitAmount.value,
                  ~currency=debitAmount.currency,
                  ~isRightBorder=false,
                  ~isTotal,
                )}
              </>
            } else {
              LedgerTableCellHelper.makeAmountPair(
                ~creditValue=creditAmount.value,
                ~creditCurrency=creditAmount.currency,
                ~debitValue=debitAmount.value,
                ~debitCurrency=debitAmount.currency,
                ~isTotal,
              )
            }
          })
          ->React.array}
        </>
      } else {
        <>
          {LedgerTableCellHelper.makeTextCell(
            ~text=data.account_name,
            ~colSpan=2,
            ~isRightBorder=true,
          )}
          {amountTypes
          ->Array.mapWithIndex((amountType, index) => {
            let (creditAmount, debitAmount) = AmountTypeUtils.getAmountPair(amountType, data)
            let isLastPair = index === Array.length(amountTypes) - 1

            if isLastPair {
              <>
                {LedgerTableCellHelper.makeAmountCell(
                  ~value=creditAmount.value,
                  ~currency=creditAmount.currency,
                  ~isRightBorder=false,
                  ~isTotal,
                )}
                {LedgerTableCellHelper.makeAmountCell(
                  ~value=debitAmount.value,
                  ~currency=debitAmount.currency,
                  ~isRightBorder=false,
                  ~isTotal,
                )}
              </>
            } else {
              LedgerTableCellHelper.makeAmountPair(
                ~creditValue=creditAmount.value,
                ~creditCurrency=creditAmount.currency,
                ~debitValue=debitAmount.value,
                ~debitCurrency=debitAmount.currency,
                ~isTotal,
              )
            }
          })
          ->React.array}
        </>
      }}
    </tr>
  }
}

@react.component
let make = () => {
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (accountsData, setAccountsData) = React.useState(_ => [])
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()

  let getAccountsData = async _ => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let url = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Get,
        ~hyperswitchReconType=#ACCOUNTS_LIST,
      )
      let res = await fetchDetails(url)
      let accountData = res->getArrayDataFromJson(ReconEngineOverviewUtils.accountItemToObjMapper)
      setAccountsData(_ => accountData)

      if accountData->Array.length > 0 {
        setScreenState(_ => PageLoaderWrapper.Success)
      } else {
        setScreenState(_ => PageLoaderWrapper.Custom)
      }
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Custom)
    }
  }

  React.useEffect(() => {
    getAccountsData()->ignore
    None
  }, [])

  let (totals, currency) = React.useMemo(() => {
    let totals = ReconEngineOverviewSummaryUtils.calculateTotals(accountsData)
    let account =
      accountsData->getValueFromArray(
        0,
        Dict.make()->ReconEngineOverviewUtils.accountItemToObjMapper,
      )
    (totals, account.currency)
  }, [accountsData])

  let tableScrollbarCss = `
  @supports (-webkit-appearance: none) {
    .ledger-table-scrollbar {
      scrollbar-width: auto;
      scrollbar-color: #CACFD8;
    }

    .ledger-table-scrollbar::-webkit-scrollbar {
      display: block;
      height: 6px;
      width: 5px;
    }

    .ledger-table-scrollbar::-webkit-scrollbar-thumb {
      background-color: #CACFD8;
      border-radius: 3px;
    }

    .ledger-table-scrollbar::-webkit-scrollbar-track {
      display: none;
    }
  }
    `

  <div className="space-y-4">
    <div className="flex flex-col gap-2">
      <p className={`text-nd_gray-800 ${heading.sm.semibold}`}> {"Accounts View"->React.string} </p>
      <p className={`text-nd_gray-500 ${body.md.medium} mb-4`}>
        {"Quickly assess reconciliation health across your accounts, highlighting matched, pending and mismatched transactions."->React.string}
      </p>
    </div>
    <PageLoaderWrapper
      screenState
      customUI={<NewAnalyticsHelper.NoData height="h-64" message="No data available." />}
      customLoader={<Shimmer styleClass="h-64 w-full rounded-xl" />}>
      <div className="border border-nd_br_gray-150 rounded-xl overflow-hidden">
        <style> {React.string(tableScrollbarCss)} </style>
        <div className="overflow-x-auto ledger-table-scrollbar">
          <table className="w-full table-auto">
            <LedgerTableHeader currency />
            <tbody>
              {accountsData
              ->Array.mapWithIndex((data, index) => {
                <LedgerTableRow key={index->Int.toString} data />
              })
              ->React.array}
              <LedgerTableRow data=totals isTotal=true />
            </tbody>
          </table>
        </div>
      </div>
    </PageLoaderWrapper>
  </div>
}
