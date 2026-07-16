let getEntityButtonStyles = isSelected => {
  isSelected
    ? "border-nd_primary_blue-600 bg-nd_primary_blue-50 text-nd_primary_blue-600"
    : "border-nd_gray-200 hover:bg-nd_gray-50 text-nd_gray-600"
}

module MerchantButton = {
  @react.component
  let make = (
    ~merchant: OMPSwitchTypes.ompListTypes,
    ~isSelected: bool,
    ~onSelect: OMPSwitchTypes.ompListTypes => promise<unit>,
  ) => {
    open Typography

    <button
      key={merchant.id}
      className={`flex justify-between cursor-pointer h-10 items-center bg-white rounded-lg border px-4 py-2 text-left transition-colors duration-200 ${body.md.medium} ${getEntityButtonStyles(
          isSelected,
        )}`}
      onClick={_ => onSelect(merchant)->ignore}
      id={merchant.id}>
      <span className="truncate whitespace-wrap "> {merchant.name->React.string} </span>
      {switch merchant.productType {
      | Some(product) =>
        <span
          className={`${body.sm.medium} ml-4 rounded-full bg-nd_gray-100 px-3 py-1 text-nd_gray-500 whitespace-nowrap`}>
          {product->ProductUtils.getProductDisplayName->React.string}
        </span>
      | None => React.null
      }}
    </button>
  }
}

module MerchantGroup = {
  @react.component
  let make = (
    ~title: string,
    ~merchants: array<OMPSwitchTypes.ompListTypes>,
    ~selectedMerchant: string,
    ~onMerchantSelect: OMPSwitchTypes.ompListTypes => promise<unit>,
  ) => {
    open Typography

    <RenderIf condition={merchants->LogicUtils.isNonEmptyArray}>
      <div className="flex flex-col gap-3 rounded-xl border border-nd_gray-200 bg-nd_gray-25 p-3">
        <div className={`${body.sm.semibold} text-nd_gray-500`}> {title->React.string} </div>
        {merchants
        ->Array.map(merchant =>
          <MerchantButton
            key={merchant.id}
            merchant
            isSelected={selectedMerchant == merchant.id}
            onSelect=onMerchantSelect
          />
        )
        ->React.array}
      </div>
    </RenderIf>
  }
}

module OrgChartTree = {
  @react.component
  let make = (
    ~selectedOrg: string,
    ~selectedMerchant: string,
    ~selectedProfile: string,
    ~onOrgSelect: OMPSwitchTypes.ompListTypes => promise<unit>,
    ~onMerchantSelect: OMPSwitchTypes.ompListTypes => promise<unit>,
    ~onProfileSelect: OMPSwitchTypes.ompListTypes => promise<unit>,
  ) => {
    open Typography

    let orgList = Recoil.useRecoilValueFromAtom(HyperswitchAtom.orgListAtom)
    let merchantList = Recoil.useRecoilValueFromAtom(HyperswitchAtom.merchantListAtom)
    let profileList = Recoil.useRecoilValueFromAtom(HyperswitchAtom.profileListAtom)
    let isPlatformOrg =
      orgList
      ->Array.find(org => org.id == selectedOrg)
      ->Option.map(org => org.type_->Option.getOr(#standard) === #platform)
      ->Option.getOr(false)
    let platformMerchants =
      merchantList->Array.filter(merchant => merchant.type_->Option.getOr(#standard) === #platform)
    let connectedMerchants =
      merchantList->Array.filter(merchant => merchant.type_->Option.getOr(#standard) === #connected)
    let standardMerchants =
      merchantList->Array.filter(merchant => merchant.type_->Option.getOr(#standard) === #standard)
    <div className="grid grid-cols-1 lg:grid-cols-3 gap-8 lg:gap-16 w-full py-8">
      <div className="flex flex-col gap-4">
        <div className={`${body.lg.semibold} mb-2`}> {React.string("Organization")} </div>
        {orgList
        ->Array.map(org => {
          <button
            key=org.id
            className={`rounded-lg border cursor-pointer h-10 px-4 py-2 bg-white text-left transition-colors duration-200 ${body.md.medium} ${getEntityButtonStyles(
                selectedOrg == org.id,
              )}`}
            onClick={_ => onOrgSelect(org)->ignore}
            id={org.id}>
            {org.name->React.string}
          </button>
        })
        ->React.array}
      </div>
      <div className="flex flex-col gap-4">
        <div className={`${body.lg.semibold} mb-2`}> {React.string("Merchant")} </div>
        {if isPlatformOrg {
          <div className="flex flex-col gap-4">
            <MerchantGroup
              title={#platform->OMPSwitchUtils.ompTypeHeading}
              merchants=platformMerchants
              selectedMerchant
              onMerchantSelect
            />
            <MerchantGroup
              title={#connected->OMPSwitchUtils.ompTypeHeading}
              merchants=connectedMerchants
              selectedMerchant
              onMerchantSelect
            />
            <MerchantGroup
              title={#standard->OMPSwitchUtils.ompTypeHeading}
              merchants=standardMerchants
              selectedMerchant
              onMerchantSelect
            />
          </div>
        } else {
          merchantList
          ->Array.map(merchant =>
            <MerchantButton
              key={merchant.id}
              merchant
              isSelected={selectedMerchant == merchant.id}
              onSelect=onMerchantSelect
            />
          )
          ->React.array
        }}
      </div>
      <div className="flex flex-col gap-4">
        <div className={`${body.lg.semibold} mb-2`}> {React.string("Profile")} </div>
        {profileList
        ->Array.map(profile =>
          <button
            key={profile.id}
            className={`rounded-lg h-10 cursor-pointer truncate whitespace-wrap border px-4 py-2 bg-white text-left transition-colors duration-200 ${body.md.medium} ${getEntityButtonStyles(
                selectedProfile == profile.id,
              )}`}
            onClick={_ => onProfileSelect(profile)->ignore}
            id={profile.id}>
            {profile.name->React.string}
          </button>
        )
        ->React.array}
      </div>
    </div>
  }
}

module BranchConnector = {
  @react.component
  let make = (~extraBranch=false) => {
    let barWidth = extraBranch ? "w-2/3" : "w-1/2"
    <div className="flex flex-col items-center w-full">
      <div className="w-px h-4 bg-nd_gray-200" />
      <div className={`${barWidth} h-px bg-nd_gray-200`} />
      <div className="flex w-full">
        <div className="flex-1 flex justify-center">
          <div className="w-px h-4 bg-nd_gray-200" />
        </div>
        <div className="flex-1 flex justify-center">
          <div className="w-px h-4 bg-nd_gray-200" />
        </div>
        <RenderIf condition=extraBranch>
          <div className="flex-1 flex justify-center">
            <div className="w-px h-4 bg-nd_gray-200" />
          </div>
        </RenderIf>
      </div>
    </div>
  }
}

module HierarchyCard = {
  @react.component
  let make = (~iconName, ~title, ~items=[], ~highlight=false) => {
    open Typography

    let accentColor = highlight ? "text-nd_primary_blue-500" : "text-nd_gray-700"
    let iconColor = highlight ? "text-nd_primary_blue-500" : "text-nd_gray-500"

    <div
      className="bg-white border border-nd_gray-150 shadow-sm flex w-max items-start gap-2.5 rounded-2xl px-4 py-3">
      <Icon name=iconName className=iconColor />
      <div className="flex flex-col gap-1">
        <span className={`${body.md.semibold} ${accentColor} whitespace-nowrap`}>
          {title->React.string}
        </span>
        <RenderIf condition={items->LogicUtils.isNonEmptyArray}>
          <ul className="list-disc list-inside flex flex-col gap-0.5">
            {items
            ->Array.map(item =>
              <li key=item className={`${body.sm.regular} text-nd_gray-500 whitespace-nowrap`}>
                {item->React.string}
              </li>
            )
            ->React.array}
          </ul>
        </RenderIf>
      </div>
    </div>
  }
}

module PlatformOrgDiagram = {
  @react.component
  let make = () => {
    open Typography

    let profileItems = ["Connector configuration", "Routing", "Transactions", "Users"]

    <div className="bg-nd_gray-25 rounded-2xl w-full overflow-x-auto p-6">
      <div className="flex flex-col items-center min-w-max mx-auto">
        <div className={`${body.md.semibold} text-nd_gray-700`}>
          {"Organization"->React.string}
        </div>
        <div className="h-3" />
        <HierarchyCard
          iconName="organization-entity"
          title="Platform Organization"
          highlight=true
          items=["Users"]
        />
        <div className="w-px h-4 bg-nd_gray-200" />
        <div className={`${body.md.semibold} text-nd_gray-700`}> {"Merchants"->React.string} </div>
        <BranchConnector extraBranch=true />
        <div className="flex w-full items-start">
          <div className="flex-1 flex flex-col items-center">
            <HierarchyCard
              iconName="nd-user"
              title="Platform Merchant Account"
              highlight=true
              items=["API keys & integrations", "Can act on behalf of connected merchants", "Users"]
            />
          </div>
          <div className="flex-1 flex flex-col items-center">
            <HierarchyCard
              iconName="group-users"
              title="Connected Merchant Accounts"
              items=[
                "Managed by the platform merchant",
                "Shared customers & payment methods",
                "Users",
              ]
            />
            <div className="w-px h-4 bg-nd_gray-200" />
            <HierarchyCard
              iconName="profile-entity" title="Connected Profiles" items=profileItems
            />
          </div>
          <div className="flex-1 flex flex-col items-center">
            <HierarchyCard
              iconName="key"
              title="Standard Merchant Account"
              items=[
                "Independent within the organization",
                "Platform can generate its API keys",
                "Users",
              ]
            />
            <div className="w-px h-4 bg-nd_gray-200" />
            <HierarchyCard iconName="profile-entity" title="Profiles" items=profileItems />
          </div>
        </div>
      </div>
    </div>
  }
}

module StandardOrgDiagram = {
  @react.component
  let make = () => {
    open Typography

    let apiKeyItems = ["API keys", "Publishable key", "Users"]
    let profileItems = ["Connector configuration", "Routing", "Transactions", "Users"]

    <div className="bg-nd_gray-25 rounded-2xl w-full overflow-x-auto p-8">
      <div className="flex flex-col items-center min-w-max mx-auto">
        <div className={`${body.md.semibold} text-nd_gray-700`}>
          {"Organization"->React.string}
        </div>
        <div className="h-3" />
        <HierarchyCard
          iconName="organization-entity"
          title="Standard Organization"
          highlight=true
          items=["Users"]
        />
        <div className="w-px h-4 bg-nd_gray-200" />
        <div className={`${body.md.semibold} text-nd_gray-700`}> {"Merchants"->React.string} </div>
        <BranchConnector />
        <div className="flex w-full items-start">
          <div className="flex-1 flex flex-col items-center">
            <HierarchyCard
              iconName="key" title="Merchant Account 1" highlight=true items=apiKeyItems
            />
            <div className="w-px h-4 bg-nd_gray-200" />
            <HierarchyCard
              iconName="profile-entity" title="Profiles" highlight=true items=profileItems
            />
          </div>
          <div className="flex-1 flex flex-col items-center">
            <HierarchyCard iconName="key" title="Merchant Account 2" items=apiKeyItems />
            <div className="w-px h-4 bg-nd_gray-200" />
            <HierarchyCard iconName="profile-entity" title="Profiles" items=profileItems />
          </div>
        </div>
      </div>
    </div>
  }
}

module OrgChartInfoModal = {
  @react.component
  let make = (~showModal, ~setShowModal) => {
    let tabs: array<Tabs.tab> = [
      {title: "Standard Organizations", renderContent: () => <StandardOrgDiagram />},
      {title: "Platform Organizations", renderContent: () => <PlatformOrgDiagram />},
    ]

    <Modal
      showModal
      setShowModal
      closeOnOutsideClick=true
      modalHeading="How the hierarchy works"
      modalHeadingDescription="How Organization, Merchant, and Profile levels nest across platform and standard setups."
      modalClass="w-full max-w-5xl max-h-85-vh overflow-auto m-auto"
      childClass="p-6"
      alignModal="items-center justify-center">
      <div className="flex flex-col gap-4">
        <Tabs tabs />
      </div>
    </Modal>
  }
}
