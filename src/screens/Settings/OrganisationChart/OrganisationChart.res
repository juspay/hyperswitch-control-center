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

    <div className="flex flex-row gap-8 w-full justify-between py-8">
      <div className="flex flex-col gap-4 w-full">
        <div className={`${body.lg.semibold} mb-2`}> {React.string("Organization")} </div>
        {orgList
        ->Array.mapWithIndex((org, i) => {
          <button
            key={Int.toString(i)}
            className={`rounded-lg border px-4 py-2 text-left ${body.md.medium} ${selectedOrg ==
                org.id
                ? `border-primary bg-gray-50 text-primary`
                : `border-gray-200 hover:bg-gray-50 text-nd_gray-600`}`}
            onClick={_ => onOrgSelect(org)}>
            {org.name->React.string}
          </button>
        })
        ->React.array}
      </div>
      <div className="flex flex-col gap-4 w-full ">
        <div className={`${body.lg.semibold} mb-2`}> {React.string("Merchant")} </div>
        {merchantList
        ->Array.map(merchant =>
          <button
            key={merchant.id}
            className={`flex justify-between items-center rounded-lg border px-4 py-2 text-left ${body.md.medium} ${selectedMerchant ==
                merchant.id
                ? `border-primary bg-gray-50 text-primary`
                : `border-gray-200 hover:bg-gray-50 text-nd_gray-600`}`}
            onClick={_ => onMerchantSelect(merchant)}>
            <span> {merchant.name->React.string} </span>
            {switch merchant.productType {
            | Some(product) =>
              <span
                className={`${body.sm.medium} ml-4 rounded-full bg-gray-100 px-4 py-1 text-gray-500`}>
                {product->ProductUtils.getProductDisplayName->React.string}
              </span>
            | None => React.null
            }}
          </button>
        )
        ->React.array}
      </div>
      <div className="flex flex-col gap-4 w-full">
        <div className={`${body.lg.semibold} mb-2`}> {React.string("Profile")} </div>
        {profileList
        ->Array.map(profile =>
          <button
            key={profile.id}
            className={`rounded-lg border px-4 py-2 text-left ${body.md.medium} ${selectedProfile ==
                profile.id
                ? `border-primary bg-gray-50 text-primary`
                : `border-gray-200 hover:bg-gray-50 text-nd_gray-600`}`}
            onClick={_ => onProfileSelect(profile)}>
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
    // setSelectedMerchant(_ => )
    // setSelectedProfile(_ => None)
    internalSwitch(~expectedOrgId=Some(org.id))->ignore
  }
  let onMerchantSelect = (merchant: OMPSwitchTypes.ompListTypes) => {
    setSelectedMerchant(_ => merchant.id)
    // setSelectedProfile(_ => None)
    internalSwitch(~expectedMerchantId=Some(merchant.id))->ignore
  }
  let onProfileSelect = (profile: OMPSwitchTypes.ompListTypes) => {
    setSelectedProfile(_ => profile.id)
    internalSwitch(~expectedProfileId=Some(profile.id))->ignore
  }
  <div className="flex flex-col px-10 gap-8">
    <div className="flex flex-col ">
      <PageUtils.PageHeading
        title="Organization Chart"
        subTitle="Review your configured processor details, enabled payment methods and associated settings."
        customSubTitleStyle={` ${body.lg.medium} text-nd_gray-500`}
      />
      <OrgChartTree
        selectedOrg selectedMerchant selectedProfile onOrgSelect onMerchantSelect onProfileSelect
      />
    </div>
  </div>
}
