open Typography

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
            key={index->Int.toString}
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
          allSubHeaderTypes->Array.mapWithIndex((subHeaderType, subIndex) => {
            let isLastSubHeader = subIndex === Array.length(allSubHeaderTypes) - 1
            let isLastAmountType = amountTypeIndex === Array.length(allAmountTypes) - 1
            let subHeaderText = (subHeaderType :> string)
            let borderClass = isLastSubHeader && !isLastAmountType ? " border-r" : ""

            <div
              key={subIndex->Int.toString}
              className={`${body.sm.semibold} px-4 py-3 text-center text-nd_gray-400 border-nd_br_gray-150${borderClass}`}>
              {subHeaderText->React.string}
            </div>
          })
        })
        ->Array.flat
        ->React.array}
      </div>
    </div>
  }
}

module AmountCell = {
  open ReconEngineOverviewSummaryTypes
  open ReconEngineOverviewTypes
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
          `${creditAmount.value->valueFormatter(
              AmountWithSuffix,
            )} ${creditAmount.currency}`->React.string
        | Out =>
          `${debitAmount.value->valueFormatter(
              AmountWithSuffix,
            )} ${debitAmount.currency}`->React.string
        }}
      </div>
    </div>
  }
}

module AccountRow = {
  open ReconEngineOverviewTypes
  open ReconEngineOverviewSummaryUtils

  @react.component
  let make = (~data: accountType, ~index: int, ~isLastRow: bool, ~isTotalRow: bool) => {
    let rowBgClass = isTotalRow ? "bg-nd_gray-25" : "bg-white hover:bg-nd_gray-50"
    let nameText = isTotalRow ? "Total" : data.account_name
    let textStyle = isTotalRow
      ? `${body.md.semibold} text-nd_gray-600`
      : `${body.md.medium} text-nd_gray-500`
    let borderClass = !isLastRow ? "border-b border-nd_br_gray-150" : ""

    <div
      key={index->Int.toString}
      className={`grid grid-cols-7 ${rowBgClass} transition duration-300 ease-in-out ${borderClass}`}>
      <div
        className="px-4 py-3 text-center flex items-center justify-center border-r border-nd_br_gray-150">
        <div className={`${textStyle}`}> {nameText->React.string} </div>
      </div>
      {allAmountTypes
      ->Array.mapWithIndex((amountType, amountIndex) => {
        let (creditAmount, debitAmount) = getAmountPair(amountType, data)
        let isLastAmount = amountIndex === Array.length(allAmountTypes) - 1

        allSubHeaderTypes->Array.mapWithIndex((subHeaderType, subIndex) => {
          let isLastSubHeader = subIndex === Array.length(allSubHeaderTypes) - 1
          let shouldShowBorder = !(isLastAmount && isLastSubHeader)
          let borderClass = shouldShowBorder ? "border-r border-nd_br_gray-150" : ""

          <AmountCell
            key={`${amountIndex->Int.toString}-${subIndex->Int.toString}`}
            subHeaderType
            creditAmount
            debitAmount
            borderClass
          />
        })
      })
      ->Array.flat
      ->React.array}
    </div>
  }
}

module AccountsList = {
  open ReconEngineOverviewTypes

  @react.component
  let make = (~allRowsData: array<accountType>, ~accountsData: array<accountType>) => {
    <div className="bg-white border-t border-nd_br_gray-150">
      {allRowsData
      ->Array.mapWithIndex((data, index) => {
        let isLastRow = index === Array.length(allRowsData) - 1
        let isTotalRow = index === Array.length(accountsData)

        <AccountRow key={index->Int.toString} data index isLastRow isTotalRow />
      })
      ->React.array}
    </div>
  }
}

@react.component
let make = () => {
  open LogicUtils
  open ReconEngineOverviewTypes
  open ReconEngineOverviewSummaryUtils
  open APIUtils

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

  let (allRowsData, currency) = React.useMemo(() => {
    let totals = calculateTotals(accountsData)
    let account =
      accountsData->getValueFromArray(
        0,
        Dict.make()->ReconEngineOverviewUtils.accountItemToObjMapper,
      )
    let allRows = Array.concat(accountsData, [totals])
    (allRows, account.currency)
  }, [accountsData])

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
        <div className="overflow-x-auto">
          <AccountsHeader currency />
          <AccountsList allRowsData accountsData />
        </div>
      </div>
    </PageLoaderWrapper>
  </div>
}
