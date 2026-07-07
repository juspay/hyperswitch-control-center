type switchingEntity =
  | Switching(string)
  | None

open OrganisationChartHelper

@react.component
let make = () => {
  open Typography
  let {setActiveProductValue} = React.useContext(ProductSelectionProvider.defaultContext)
  let internalSwitch = OMPSwitchHooks.useInternalSwitch(~setActiveProductValue)
  let {orgId, merchantId, profileId} = React.useContext(
    UserInfoProvider.defaultContext,
  ).getCommonSessionDetails()
  let (selectedOrg, setSelectedOrg) = React.useState(() => orgId)
  let (selectedMerchant, setSelectedMerchant) = React.useState(() => merchantId)
  let (selectedProfile, setSelectedProfile) = React.useState(() => profileId)
  let (switching, setSwitching) = React.useState(() => None)
  let (showInfoModal, setShowInfoModal) = React.useState(() => false)
  let showToast = ToastAdapter.useShowToast()
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
      <div className="flex flex-col gap-4 lg:flex-row lg:items-start lg:justify-between">
        <PageUtils.PageHeading
          title="Organization Chart"
          subTitle="An entity-level overview enabling navigation and transitions across your organization based on access permissions."
          customHeadingStyle="mb-0"
          customSubTitleStyle={`${body.lg.medium} text-gray-500`}
        />
        <Button
          text="Learn More"
          buttonType=Secondary
          buttonSize=Small
          leftIcon={CustomIcon(<Icon name="nd-info-circle" size=16 className="text-nd_gray-600" />)}
          customButtonStyle="shrink-0"
          onClick={_ => setShowInfoModal(_ => true)}
        />
      </div>
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
    <OrgChartInfoModal showModal=showInfoModal setShowModal=setShowInfoModal />
  </div>
}
