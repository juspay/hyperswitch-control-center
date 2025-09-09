open Typography
open ReconEngineOverviewTypes

module AccountsHeader = {
  open ReconEngineOverviewSummaryUtils
  @react.component
  let make = (~currency: string) => {
    <div className="bg-nd_gray-25">
      <div className="grid grid-cols-7 border-b border-nd_br_gray-150">
        <div
          className={`${body.sm.semibold} px-4 py-3 text-center text-nd_gray-400 border-r border-nd_br_gray-150 row-span-2 flex items-center justify-center`}>
          {"Accounts"->React.string}
        </div>
        {allAmountTypes
        ->Array.mapWithIndex((amountType, index) => {
          let isLast = index === Array.length(allAmountTypes) - 1
          let borderClass = !isLast ? "border-r" : ""
          let headerText = getHeaderText(amountType, currency)

          <div
            key={amountType->getHeaderText(currency)}
            className={`${body.sm.semibold} px-4 py-3 text-center text-nd_gray-400 border-nd_br_gray-150 col-span-2 ${borderClass}`}>
            {headerText->React.string}
          </div>
        })
        ->React.array}
      </div>
      <div className="grid grid-cols-7">
        <div className="border-r" />
        {allAmountTypes
        ->Array.mapWithIndex((_, amountTypeIndex) => {
          allSubHeaderTypes
          ->Array.mapWithIndex((subHeaderType, subIndex) => {
            let isLastSubHeader = subIndex === Array.length(allSubHeaderTypes) - 1
            let isLastAmountType = amountTypeIndex === Array.length(allAmountTypes) - 1
            let subHeaderText = (subHeaderType :> string)
            let borderClass = isLastSubHeader && !isLastAmountType ? " border-r" : ""

            <div
              key={`${amountTypeIndex->Int.toString}-${subHeaderText}`}
              className={`${body.sm.semibold} px-4 py-3 text-center text-nd_gray-400 border-nd_br_gray-150${borderClass}`}>
              {subHeaderText->React.string}
            </div>
          })
          ->React.array
        })
        ->React.array}
      </div>
    </div>
  }
}

module AmountCell = {
  open ReconEngineOverviewSummaryTypes
  open LogicUtils

  @react.component
  let make = (
    ~subHeaderType: subHeaderType,
    ~creditAmount: balanceType,
    ~debitAmount: balanceType,
    ~borderClass: string,
  ) => {
    <div className={`px-4 py-3 text-center flex items-center justify-center ${borderClass}`}>
      <div className={`${body.md.medium} text-nd_gray-600`}>
        {switch subHeaderType {
        | In =>
          `${Math.abs(creditAmount.value)->valueFormatter(
              AmountWithSuffix,
            )} ${creditAmount.currency}`->React.string
        | Out =>
          `${Math.abs(debitAmount.value)->valueFormatter(
              AmountWithSuffix,
            )} ${debitAmount.currency}`->React.string
        }}
      </div>
    </div>
  }
}

module AccountRow = {
  open ReconEngineOverviewSummaryUtils

  @react.component
  let make = (~data: accountType, ~isLastRow: bool, ~isTotalRow: bool) => {
    let rowBgClass = isTotalRow ? "bg-nd_gray-25" : "bg-white hover:bg-nd_gray-50"
    let nameText = isTotalRow ? "Total" : data.account_name
    let textStyle = isTotalRow
      ? `${body.md.semibold} text-nd_gray-600`
      : `${body.md.medium} text-nd_gray-500`
    let borderClass = !isLastRow ? "border-b border-nd_br_gray-150" : ""

    <div
      className={`grid grid-cols-7 ${rowBgClass} transition duration-300 ease-in-out ${borderClass}`}>
      <div
        className="px-4 py-3 text-center flex items-center justify-center border-r border-nd_br_gray-150">
        <div className={`${textStyle}`}> {nameText->React.string} </div>
      </div>
      {allAmountTypes
      ->Array.mapWithIndex((amountType, amountIndex) => {
        let (creditAmount, debitAmount) = getAmountPair(amountType, data)
        let isLastAmount = amountIndex === Array.length(allAmountTypes) - 1

        allSubHeaderTypes
        ->Array.mapWithIndex((subHeaderType, subIndex) => {
          let isLastSubHeader = subIndex === Array.length(allSubHeaderTypes) - 1
          let shouldShowBorder = !(isLastAmount && isLastSubHeader)
          let borderClass = shouldShowBorder ? "border-r border-nd_br_gray-150" : ""
          let key = LogicUtils.randomString(~length=10)

          <AmountCell key subHeaderType creditAmount debitAmount borderClass />
        })
        ->React.array
      })
      ->React.array}
    </div>
  }
}

module AccountsList = {
  @react.component
  let make = (~allRowsData: array<accountType>, ~accountsData: array<accountType>) => {
    <div className="bg-white border-t border-nd_br_gray-150">
      {allRowsData
      ->Array.mapWithIndex((data, index) => {
        let isLastRow = index === Array.length(allRowsData) - 1
        let isTotalRow = index === Array.length(accountsData)
        let key = LogicUtils.randomString(~length=10)

        <AccountRow key data isLastRow isTotalRow />
      })
      ->React.array}
    </div>
  }
}

@react.component
let make = (~reconRulesList: array<reconRuleType>) => {
  open LogicUtils
  open ReconEngineOverviewTypes
  open ReconEngineOverviewSummaryUtils
  open APIUtils

  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (accountsData, setAccountsData) = React.useState(_ => [])
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let getTransactions = ReconEngineHooks.useGetTransactions()

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
      let allTransactions = await getTransactions()
      let accountTransactionData = processAllTransactionsWithAmounts(
        reconRulesList,
        allTransactions,
      )
      let accountsWithTransactionAmounts = convertTransactionDataToAccountData(
        accountData,
        accountTransactionData,
      )

      if accountsWithTransactionAmounts->Array.length > 0 {
        setAccountsData(_ => accountsWithTransactionAmounts)
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

  let (allRowsData, currency) = React.useMemo(() => {
    let totals = calculateTotals(accountsData)
    let account =
      accountsData->getValueFromArray(
        0,
        Dict.make()->ReconEngineOverviewUtils.accountItemToObjMapper,
      )
    let allRows = [...accountsData, totals]
    (allRows, account.currency)
  }, [accountsData])

  <div className="space-y-4">
    <PageLoaderWrapper
      screenState
      customUI={<NewAnalyticsHelper.NoData height="h-64" message="No data available." />}
      customLoader={<Shimmer styleClass="h-64 w-full rounded-xl" />}>
      <div className="border border-nd_br_gray-150 rounded-xl overflow-hidden">
        <div className="overflow-x-auto">
          <AccountsHeader currency />
          <AccountsList allRowsData accountsData />
        </div>
      </div>
    </PageLoaderWrapper>
  </div>
}
