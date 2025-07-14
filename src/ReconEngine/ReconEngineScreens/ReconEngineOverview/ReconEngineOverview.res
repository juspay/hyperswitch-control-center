open Typography

module AccountCard = {
  open ReconEngineOverviewUtils
  @react.component
  let make = (~account: ReconEngineOverviewTypes.accountType, ~index) => {
    let iconName = getAccountIcon(index)
    let handleCardClick = _ => {
      RescriptReactRouter.replace(
        GlobalVars.appendDashboardPath(~url=`v1/recon-engine/overview/${account.account_id}`),
      )
    }
    <div
      className="bg-white border border-nd_gray-200 rounded-lg p-6 shadow-sm hover:shadow-md transition-shadow cursor-pointer"
      onClick={handleCardClick}>
      <div className="flex items-center gap-3 mb-6">
        <div className="w-8 h-8 bg-purple-100 rounded flex items-center justify-center">
          <Icon name=iconName size=16 className="text-purple-600" />
        </div>
        <div className={`${body.lg.semibold} text-nd_gray-800`}>
          {account.account_name->React.string}
        </div>
      </div>
      <div className="grid grid-cols-2 gap-6 mb-4">
        <div>
          <div className={`${body.sm.regular} text-nd_gray-500 mb-1`}>
            {"Currency"->React.string}
          </div>
          <div className={`${body.md.medium} text-nd_gray-900`}>
            {account.currency->React.string}
          </div>
        </div>
      </div>
      <div className="grid grid-cols-2 gap-6 mb-4">
        <div>
          <div className={`${body.sm.regular} text-nd_gray-500 mb-1`}>
            {"Posted Balance"->React.string}
          </div>
          <div className={`${body.md.medium} text-nd_gray-900`}>
            {account.posted_balance->React.string}
          </div>
        </div>
        <div>
          <div className={`${body.sm.regular} text-nd_gray-500 mb-1`}>
            {"Pending Balance"->React.string}
          </div>
          <div className={`${body.md.medium} text-nd_gray-900`}>
            {account.pending_balance->React.string}
          </div>
        </div>
      </div>
    </div>
  }
}

@react.component
let make = () => {
  open ReconEngineOverviewUtils
  let (accountData, setAccountData) = React.useState(_ => [])
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let getAccountData = async _ => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let response =
        SampleOverviewData.account->LogicUtils.getArrayDataFromJson(accountItemToObjMapper)
      setAccountData(_ => response)
      setScreenState(_ => Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch"))
    }
  }

  React.useEffect(() => {
    getAccountData()->ignore
    None
  }, [])
  <PageLoaderWrapper screenState>
    <div className="flex flex-col gap-6 w-full">
      <div className="flex items-center justify-between w-full">
        <PageUtils.PageHeading title="Overview" />
      </div>
      <div>
        <div className={`${body.lg.semibold} text-nd_gray-800 mb-2`}>
          {"Accounts"->React.string}
        </div>
        <div className={`${body.md.regular} text-nd_gray-600 mb-6`}>
          {"Monitor account-level financials including currency, balances, and reconciliation insights."->React.string}
        </div>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-2 xl:grid-cols-2 gap-6">
          {accountData
          ->Array.mapWithIndex((account, index) => {
            <AccountCard key={index->Int.toString} account index />
          })
          ->React.array}
        </div>
      </div>
    </div>
  </PageLoaderWrapper>
}
