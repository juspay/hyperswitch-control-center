module SftpSetup = {
  @react.component
  let make = () => {
    open Typography

    <div className="flex flex-col gap-6 p-6">
      <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
        <div className="flex flex-col gap-6">
          // SFTP Server Status
          <div className="flex flex-col gap-2">
            <span className={`${body.md.semibold} text-nd_gray-400`}>
              {"SFTP Server Status"->React.string}
            </span>
            <div className="flex items-center gap-2">
              <div className="w-2 h-2 bg-green-500 rounded-full" />
              <span className={`${body.md.medium} text-nd_gray-800`}>
                {"Active"->React.string}
              </span>
            </div>
          </div>
          // Last Sync
          <div className="flex flex-col gap-2">
            <span className={`${body.md.medium} text-nd_gray-400`}>
              {"Last Sync"->React.string}
            </span>
            <span className={`${body.md.medium} text-nd_gray-800`}>
              {"Jul 2, 2025, 9:57:30 PM"->React.string}
            </span>
          </div>
          // File Path on Server
          <div className="flex flex-col gap-2">
            <span className={`${body.md.medium} text-nd_gray-400`}>
              {"File Path on Server"->React.string}
            </span>
            <span className={`${body.md.medium} text-nd_gray-800`}>
              {"data/orders/*.csv"->React.string}
            </span>
          </div>
        </div>
        <div className="flex flex-col gap-6">
          // Manual Upload
          <div className="flex flex-col gap-2">
            <span className={`${body.md.semibold} text-nd_gray-400`}>
              {"Manual Upload"->React.string}
            </span>
            <span
              className={`${body.sm.medium} text-status-green bg-nd_green-50 px-2 py-1 rounded w-fit`}>
              {"ACTIVE"->React.string}
            </span>
          </div>
          // Password
          <div className="flex flex-col gap-2">
            <span className={`${body.md.medium} text-nd_gray-400`}>
              {"Password"->React.string}
            </span>
            <span className={`${body.md.medium} text-nd_gray-800`}>
              {"**********"->React.string}
            </span>
          </div>
          // File Format
          <div className="flex flex-col gap-2">
            <span className={`${body.md.medium} text-nd_gray-400`}>
              {"File Format"->React.string}
            </span>
            <span className={`${body.md.medium} text-nd_gray-800`}> {".txt"->React.string} </span>
          </div>
        </div>
      </div>
    </div>
  }
}

module PaymentProcessor = {
  @react.component
  let make = () => {
    open Typography

    <div className="flex flex-col gap-6 p-6">
      <div className="text-center py-12">
        <span className={`${body.lg.medium} text-nd_gray-500`}>
          {"Payment Processor configuration will be available here"->React.string}
        </span>
      </div>
    </div>
  }
}

module BankAccount = {
  @react.component
  let make = () => {
    open Typography

    <div className="flex flex-col gap-6 p-6">
      <div className="text-center py-12">
        <span className={`${body.lg.medium} text-nd_gray-500`}>
          {"Bank Account configuration will be available here"->React.string}
        </span>
      </div>
    </div>
  }
}

@react.component
let make = () => {
  open APIUtils
  open LogicUtils
  open Typography
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (accountData, setAccountData) = React.useState(_ => [])
  let (tabIndex, setTabIndex) = React.useState(_ => 0)

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
      setAccountData(_ => accountData)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch accounts"))
    }
  }

  React.useEffect(() => {
    getAccountsData()->ignore
    None
  }, [])

  let tabs: array<Tabs.tab> = React.useMemo(() => {
    open Tabs
    accountData->Array.mapWithIndex((account, index) => {
      let renderContent = () => {
        switch index {
        | 0 => <SftpSetup />
        | 1 => <PaymentProcessor />
        | 2 => <BankAccount />
        | _ => <SftpSetup />
        }
      }
      {
        title: account.account_name,
        renderContent,
      }
    })
  }, [accountData])

  <div className="flex flex-col gap-6 w-full">
    <PageUtils.PageHeading
      title="Connections"
      subTitle="Manage and monitor external data integrations like SFTP and manual uploads."
      customSubTitleStyle={body.lg.medium}
      customTitleStyle={`${heading.lg.semibold} py-0`}
    />
    <PageLoaderWrapper screenState>
      <RenderIf condition={accountData->Array.length == 0}>
        <div className="my-4">
          <NoDataFound
            message="No accounts found. Please configure accounts to view connections."
            renderType={Painting}
            customMessageCss={`${body.lg.semibold} text-nd_gray-400`}
          />
        </div>
      </RenderIf>
      <RenderIf condition={accountData->Array.length > 0}>
        <Tabs
          initialIndex={tabIndex >= 0 ? tabIndex : 0}
          tabs
          showBorder=true
          includeMargin=false
          defaultClasses={`!w-max flex flex-auto flex-row items-center justify-center px-6 ${body.md.semibold}`}
          onTitleClick={index => {
            setTabIndex(_ => index)
          }}
          selectTabBottomBorderColor="bg-primary"
          customBottomBorderColor="bg-nd_gray-150"
        />
      </RenderIf>
    </PageLoaderWrapper>
  </div>
}
