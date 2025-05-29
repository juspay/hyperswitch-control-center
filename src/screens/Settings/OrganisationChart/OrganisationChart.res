module OrgChartTree = {
  @react.component
  let make = (
    ~selectedOrg,
    ~selectedMerchant,
    ~selectedProfile,
    ~onOrgSelect,
    ~onMerchantSelect,
    ~onProfileSelect,
  ) => {
    open Typography
    let orgList = Recoil.useRecoilValueFromAtom(HyperswitchAtom.orgListAtom)
    let merchantList = Recoil.useRecoilValueFromAtom(HyperswitchAtom.merchantListAtom)
    let profileList = Recoil.useRecoilValueFromAtom(HyperswitchAtom.profileListAtom)

    <div className="grid grid-cols-1 lg:grid-cols-3 gap-8 lg:gap-16 w-full py-8">
      <div className="flex flex-col gap-4">
        <div className={`${body.lg.semibold} mb-2`}> {React.string("Organization")} </div>
        {orgList
        ->Array.mapWithIndex((org, i) => {
          <button
            key={Int.toString(i)}
            className={`rounded-lg border h-10  px-4 py-2 bg-white text-left transition-colors duration-200 ${body.md.medium} ${selectedOrg ==
                org.id
                ? "border-blue-600 bg-blue-50 text-blue-600"
                : "border-gray-200 hover:bg-gray-50 text-gray-600"}`}
            onClick={_ => onOrgSelect(org)}
            id={`org-${org.id}`}>
            {org.name->React.string}
          </button>
        })
        ->React.array}
      </div>
      <div className="flex flex-col gap-4">
        <div className={`${body.lg.semibold} mb-2`}> {React.string("Merchant")} </div>
        {merchantList
        ->Array.map(merchant =>
          <button
            key={merchant.id}
            className={`flex justify-between h-10 items-center bg-white rounded-lg border px-4 py-2 text-left transition-colors duration-200 truncate whitespace-wrap ${body.md.medium} ${selectedMerchant ==
                merchant.id
                ? "border-blue-600 bg-blue-50 text-blue-600"
                : "border-gray-200 hover:bg-gray-50 text-gray-600"}`}
            onClick={_ => onMerchantSelect(merchant)}
            id={`merchant-${merchant.id}`}>
            <span> {merchant.name->React.string} </span>
            {switch merchant.productType {
            | Some(product) =>
              <span
                className={`${body.sm.medium} ml-4 rounded-full bg-gray-100 px-3 py-1 text-gray-500 whitespace-nowrap`}>
                {product->ProductUtils.getProductDisplayName->React.string}
              </span>
            | None => React.null
            }}
          </button>
        )
        ->React.array}
      </div>
      <div className="flex flex-col gap-4">
        <div className={`${body.lg.semibold} mb-2`}> {React.string("Profile")} </div>
        {profileList
        ->Array.map(profile =>
          <button
            key={profile.id}
            className={`rounded-lg h-10  border px-4 py-2 bg-white text-left transition-colors duration-200 ${body.md.medium} ${selectedProfile ==
                profile.id
                ? "border-blue-600 bg-blue-50 text-blue-600"
                : "border-gray-200 hover:bg-gray-50 text-gray-600"}`}
            onClick={_ => onProfileSelect(profile)}
            id={`profile-${profile.id}`}>
            {profile.name->React.string}
          </button>
        )
        ->React.array}
      </div>
    </div>
  }
}

@react.component
let make = () => {
  open Typography
  let internalSwitch = OMPSwitchHooks.useInternalSwitch()
  let {userInfo: {orgId, merchantId, profileId}} = React.useContext(UserInfoProvider.defaultContext)
  let (selectedOrg, setSelectedOrg) = React.useState(() => orgId)
  let (selectedMerchant, setSelectedMerchant) = React.useState(() => merchantId)
  let (selectedProfile, setSelectedProfile) = React.useState(() => profileId)

  let onOrgSelect = (org: OMPSwitchTypes.ompListTypes) => {
    setSelectedOrg(_ => org.id)
    internalSwitch(~expectedOrgId=Some(org.id))->ignore
  }

  let onMerchantSelect = (merchant: OMPSwitchTypes.ompListTypes) => {
    setSelectedMerchant(_ => merchant.id)
    internalSwitch(~expectedMerchantId=Some(merchant.id))->ignore
  }

  let onProfileSelect = (profile: OMPSwitchTypes.ompListTypes) => {
    setSelectedProfile(_ => profile.id)
    internalSwitch(~expectedProfileId=Some(profile.id))->ignore
  }
  <div className="flex flex-col px-4 lg:px-10 gap-8">
    <div className="flex flex-col">
      <PageUtils.PageHeading
        title="Organization Chart"
        subTitle="Review your configured processor details, enabled payment methods and associated settings."
        customSubTitleStyle={` ${body.lg.medium} text-gray-500`}
      />
      <div className="relative w-full min-h-[400px]">
        <OrgChartTree
          selectedOrg selectedMerchant selectedProfile onOrgSelect onMerchantSelect onProfileSelect
        />
        <OrgChartArrows
          selectedOrg={selectedOrg}
          selectedMerchant={selectedMerchant}
          selectedProfile={selectedProfile}
        />
      </div>
    </div>
  </div>
}
