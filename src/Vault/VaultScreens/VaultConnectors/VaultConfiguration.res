@react.component
let make = (~isOrchestrationVault=false) => {
  open Typography
  let (tabIndex, setTabIndex) = React.useState(_ => 0)
  let setCurrentTabName = Recoil.useSetRecoilState(HyperswitchAtom.currentTabNameRecoilAtom)
  let {setShowSideBar} = React.useContext(GlobalProvider.defaultContext)

  let vaultPspTokenizationTabElement = {
    <div className="flex gap-2 items-center">
      <ToolTip
        description="Hyperswitch securely converts card details into tokens from your existing PSP accounts (Stripe, Adyen, Worldpay, etc.), allowing you to process payments through these providers using these tokens rather than raw card data."
        iconOpacityVal="100"
      />
      {"PSP Tokenisation"->React.string}
    </div>
  }
  let vaultNetworkTokenizationTabElement = {
    <div className="flex gap-2 items-center">
      <ToolTip
        description="Hyperswitch securely replaces card details with network tokens from card networks (Visa, Mastercard, Amex, etc.), allowing you to process payments with enhanced security and authorization rates while reducing processing costs, fraud risk and compliance requirements."
        iconOpacityVal="100"
      />
      {"Network Tokenisation"->React.string}
    </div>
  }
  React.useEffect(() => {
    setShowSideBar(_ => true)
    None
  }, [])

  let getTabName = index => index == 0 ? "PSP Tokenisation" : "Network Tokenisation"

  let tabs: array<Tabs.tab> = React.useMemo(() => {
    open Tabs
    [
      {
        title: "",
        tabElement: vaultPspTokenizationTabElement,
        renderContent: () => {
          <VaultProcessorList isOrchestrationVault />
        },
      },
      {
        title: "",
        tabElement: vaultNetworkTokenizationTabElement,
        renderContent: () => <VaultNetworkTokenisation />,
      },
    ]
  }, [])

  <div className="flex flex-col gap-12">
    <PageUtils.PageHeading
      title="Vault Configuration"
      customTitleStyle={`${heading.lg.semibold}`}
      customHeadingStyle="py-0"
    />
    <div className="flex flex-col gap-4">
      <div className="flex flex-col gap-1">
        <p className="text-xl font-semibold"> {"PCI Vault Configuration"->React.string} </p>
        <p className="text-base text-nd_gray-400">
          {"Apart from tokenizing cards during payments flow, you can also directly tokenize and secure your customers’ card data in our PCI-compliant vault"->React.string}
        </p>
      </div>
      <div className="grid grid-cols-3 gap-8 w-full">
        {VaultHomeUtils.vaultActionArray
        ->Array.map(item =>
          <VaultHomeUtils.VaultActionItem heading=item.heading img=item.imgSrc action=item.action />
        )
        ->React.array}
      </div>
    </div>
    <div className="flex flex-col gap-4">
      <div className="flex flex-col gap-1">
        <p className="text-xl font-semibold"> {"Advanced Vault configuration"->React.string} </p>
        <p className="text-base font-medium text-nd_gray-400">
          {"Apart from storing cards in our PCI vault, you can also tokenize across PSPs and networks:"->React.string}
        </p>
      </div>
      <Tabs
        initialIndex={tabIndex >= 0 ? tabIndex : 0}
        tabs
        showBorder=true
        includeMargin=false
        defaultClasses="!w-max flex flex-auto flex-row items-center justify-center px-6 font-semibold text-body border "
        onTitleClick={indx => {
          setTabIndex(_ => indx)
          setCurrentTabName(_ => getTabName(indx))
        }}
        selectTabBottomBorderColor="bg-primary"
      />
    </div>
  </div>
}
