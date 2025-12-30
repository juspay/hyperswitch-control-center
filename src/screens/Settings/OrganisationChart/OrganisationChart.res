type switchingEntity =
  | Switching(string)
  | None

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
    let getButtonStyles = isSelected => {
      isSelected
        ? "border-blue-600 bg-blue-50 text-blue-600"
        : "border-gray-200 hover:bg-gray-50 text-gray-600"
    }
    <div className="grid grid-cols-1 lg:grid-cols-3 gap-8 lg:gap-16 w-full py-8">
      <div className="flex flex-col gap-4">
        <div className={`${body.lg.semibold} mb-2`}> {React.string("Organization")} </div>
        {orgList
        ->Array.map(org => {
          <button
            key=org.id
            className={`rounded-lg border cursor-pointer h-10 px-4 py-2 bg-white text-left transition-colors duration-200 ${body.md.medium} ${getButtonStyles(
                selectedOrg == org.id,
              )}`}
            onClick={_ => onOrgSelect(org)->ignore}
            id={`${org.id}`}>
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
            className={`flex justify-between cursor-pointer  h-10 items-center bg-white rounded-lg border px-4 py-2 text-left transition-colors duration-200 ${body.md.medium} ${getButtonStyles(
                selectedMerchant == merchant.id,
              )}`}
            onClick={_ => onMerchantSelect(merchant)->ignore}
            id={`${merchant.id}`}>
            <span className="truncate whitespace-wrap "> {merchant.name->React.string} </span>
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
            className={`rounded-lg h-10 cursor-pointer truncate whitespace-wrap border px-4 py-2 bg-white text-left transition-colors duration-200 ${body.md.medium} ${getButtonStyles(
                selectedProfile == profile.id,
              )}`}
            onClick={_ => onProfileSelect(profile)->ignore}
            id={`${profile.id}`}>
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
  let {setActiveProductValue} = React.useContext(ProductSelectionProvider.defaultContext)
  let internalSwitch = OMPSwitchHooks.useInternalSwitch(~setActiveProductValue)
  let {orgId, merchantId, profileId} = React.useContext(
    UserInfoProvider.defaultContext,
  ).getCommonTokenDetails()
  let (selectedOrg, setSelectedOrg) = React.useState(() => orgId)
  let (selectedMerchant, setSelectedMerchant) = React.useState(() => merchantId)
  let (selectedProfile, setSelectedProfile) = React.useState(() => profileId)
  let (switching, setSwitching) = React.useState(() => None)
  let showToast = ToastState.useShowToast()
  let merchantList = Recoil.useRecoilValueFromAtom(HyperswitchAtom.merchantListAtom)
  let onOrgSelect = async (org: OMPSwitchTypes.ompListTypes) => {
    try {
      setSwitching(_ => Switching("organization"))
      setSelectedOrg(_ => org.id)
      let _ = await internalSwitch(~expectedOrgId=Some(org.id))
      setSwitching(_ => None)
    } catch {
    | _ => {
        setSelectedOrg(_ => orgId)
        showToast(~message="Failed to switch organization", ~toastType=ToastError)
        setSwitching(_ => None)
      }
    }
  }
  let onMerchantSelect = async (merchant: OMPSwitchTypes.ompListTypes) =>
    try {
      setSwitching(_ => Switching("merchant"))
      setSelectedMerchant(_ => merchant.id)
      let merchantData =
        merchantList
        ->Array.find(m => m.id == merchant.id)
        ->Option.getOr(merchant)
      let version = merchantData.version->Option.getOr(UserInfoTypes.V1)
      let _ = await internalSwitch(~expectedMerchantId=Some(merchant.id), ~version)
      setSwitching(_ => None)
    } catch {
    | _ => {
        setSelectedMerchant(_ => merchantId)
        showToast(~message="Failed to switch merchant", ~toastType=ToastError)
        setSwitching(_ => None)
      }
    }
  let onProfileSelect = async (profile: OMPSwitchTypes.ompListTypes) =>
    try {
      setSwitching(_ => Switching("profile"))
      setSelectedProfile(_ => profile.id)
      let _ = await internalSwitch(~expectedProfileId=Some(profile.id))
      setSwitching(_ => None)
    } catch {
    | _ => {
        setSelectedProfile(_ => profileId)
        showToast(~message="Failed to switch profile", ~toastType=ToastError)
        setSwitching(_ => None)
      }
    }
  <div className="flex flex-col px-4 lg:px-10 gap-8">
    <div className="flex flex-col">
      <PageUtils.PageHeading
        title="Organization Chart"
        subTitle="An entity-level overview enabling navigation and transitions across your organization based on access permissions."
        customSubTitleStyle={`${body.lg.medium} text-gray-500`}
      />
      <div className="relative w-full">
        <OrgChartTree
          selectedOrg selectedMerchant selectedProfile onOrgSelect onMerchantSelect onProfileSelect
        />
        <OrganisationChartArrows
          selectedOrg={selectedOrg}
          selectedMerchant={selectedMerchant}
          selectedProfile={selectedProfile}
        />
      </div>
    </div>
    <LoaderModal
      showModal={switching != None}
      setShowModal={_ => setSwitching(_ => None)}
      text={switch switching {
      | Switching(entityType) => `Switching ${entityType}...`
      | None => ""
      }}
    />
  </div>
}
