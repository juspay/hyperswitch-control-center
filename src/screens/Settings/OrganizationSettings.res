module PlatformAccountConfirmationModal = {
  @react.component
  let make = (~showModal, ~setShowModal) => {
    open APIUtils
    let getURL = useGetURL()
    let updateDetails = useUpdateMethod()
    let showToast = ToastState.useShowToast()
    let setIsPlatform = Recoil.useSetRecoilState(HyperswitchAtom.isPlatform)

    let createPlatformMerchant = async () => {
      try {
        let url = getURL(~entityName=USERS, ~userType=#CREATE_PLATFORM, ~methodType=Post)
        let _ = await updateDetails(url, JSON.Encode.null, Post)
        setIsPlatform(_ => true)
        showToast(
          ~toastType=ToastSuccess,
          ~message="Converted to Platform Successfully!",
          ~autoClose=true,
        )
      } catch {
      | _ =>
        showToast(~toastType=ToastError, ~message="Platform Conversion Failed", ~autoClose=true)
      }

      setShowModal(_ => false)
      Nullable.null
    }

    let onSubmit = (_, _) => {
      createPlatformMerchant()
    }

    let modalBody =
      <div className="">
        <div className="pt-3 m-3 flex justify-between">
          <CardUtils.CardHeader
            heading="Create Platform Account"
            subHeading=""
            customSubHeadingStyle="w-full !max-w-none pr-10"
          />
          <div className="h-fit" onClick={_ => setShowModal(_ => false)}>
            <Icon name="modal-close-icon" className="cursor-pointer" size=30 />
          </div>
        </div>
        <hr />
        <Form onSubmit>
          <div className="flex flex-col gap-2 h-full w-full p-4 ">
            <HSwitchUtils.AlertBanner
              warningText="Once converted to platform account This change cannot be reverted"
              bannerType={Warning}
            />
            <div className="text-sm leading-7 text-gray-600 p-2">
              <p> {"Choose merchant to make it the platform merchant account"->React.string} </p>
              <MerchantSwitch />
            </div>
          </div>
          <hr className="mt-4" />
          <div className="flex justify-end w-full p-3">
            <FormRenderer.SubmitButton text="Create Platform" buttonSize=Small />
          </div>
        </Form>
      </div>

    <>
      <Modal showModal setShowModal modalClass="w-1/4 m-auto" childClass="p-0"> {modalBody} </Modal>
    </>
  }
}

module MakePlatformAccount = {
  @react.component
  let make = () => {
    let (showEditOrgModal, setShowEditOrgModal) = React.useState(_ => false)

    let convertToPlatform = e => {
      e->ReactEvent.Mouse.stopPropagation
      setShowEditOrgModal(_ => true)
    }

    <>
      <Button text="Convert to Platform" onClick={convertToPlatform} />
      <PlatformAccountConfirmationModal
        showModal={showEditOrgModal} setShowModal={setShowEditOrgModal}
      />
    </>
  }
}

module EditOrgNameButton = {
  @react.component
  let make = () => {
    open APIUtils
    open LogicUtils
    open OMPSwitchUtils

    let getURL = useGetURL()
    let fetchDetails = useGetMethod()
    let showToast = ToastState.useShowToast()
    let (showEditOrgModal, setShowEditOrgModal) = React.useState(_ => false)
    let (orgList, setOrgList) = Recoil.useRecoilState(HyperswitchAtom.orgListAtom)
    let {userInfo: {orgId}} = React.useContext(UserInfoProvider.defaultContext)
    let getOrgList = async () => {
      try {
        let url = getURL(~entityName=USERS, ~userType=#LIST_ORG, ~methodType=Get)
        let response = await fetchDetails(url)
        setOrgList(_ => response->getArrayDataFromJson(orgItemToObjMapper))
      } catch {
      | _ => {
          setOrgList(_ => [HyperswitchAtom.orgDefaultValue])
          showToast(~message="Failed to fetch organisation list", ~toastType=ToastError)
        }
      }
    }

    let editOrgName = _ => {
      setShowEditOrgModal(_ => true)
    }

    <>
      <Button text="Edit Org Name" onClick={editOrgName} buttonSize={XSmall} />
      <OMPSwitchHelper.EditOrgName
        showModal={showEditOrgModal} setShowModal={setShowEditOrgModal} orgList orgId getOrgList
      />
    </>
  }
}

module BasicDetailsSection = {
  @react.component
  let make = () => {
    let {userInfo: {orgId}} = React.useContext(UserInfoProvider.defaultContext)
    let orgList = Recoil.useRecoilValueFromAtom(HyperswitchAtom.orgListAtom)
    let orgName = OMPSwitchUtils.currentOrgName(orgList, orgId)
    let orgId = <HelperComponents.CopyTextCustomComp displayValue=orgId />

    <div>
      <div className="flex flex-col gap-5 bg-white rounded-lg w-full px-6 pt-4 pb-6">
        <div className="flex gap-10 items-center">
          <p className="titleClass"> {"Org Name"->React.string} </p>
          <p className="subTitleClass">
            {(orgName->LogicUtils.isNonEmptyString ? orgName : "--")->React.string}
          </p>
          <EditOrgNameButton />
        </div>
        <hr />
        <div className="flex gap-10 items-center">
          <p className="titleClass"> {"Org Id:"->React.string} </p>
          <p className="subTitleClass"> {orgId} </p>
        </div>
      </div>
    </div>
  }
}

module LearnMoreModal = {
  @react.component
  let make = (~showModal, ~setShowModal) => {
    let sidebarScrollbarCss = `
  @supports (-webkit-appearance: none){
    .sidebar-scrollbar {
        scrollbar-width: auto;
        scrollbar-color: #8a8c8f;
      }
      
      .sidebar-scrollbar::-webkit-scrollbar {
        display: block;
        overflow: scroll;
        height: 4px;
        width: 5px;
      }
      
      .sidebar-scrollbar::-webkit-scrollbar-thumb {
        background-color: #8a8c8f;
        border-radius: 3px;
      }
      
      .sidebar-scrollbar::-webkit-scrollbar-track {
        display: none;
      }
}
  `

    <Modal modalHeading="About Platform Account" showModal setShowModal modalClass="w-1/2 m-auto">
      <div className="flex flex-col gap-12 max-h-96 w-full">
        <style> {React.string(sidebarScrollbarCss)} </style>
        <div className="overflow-scroll">
          <p>
            {"Businesses such as marketplaces and software platforms use Connect to manage and route payments and payouts between sellers, customers, service providers, and other entities.
            Onboarding: Onboard and verify sellers using connected accounts with Stripe-hosted flows, or build your own with our APIs.
            Account management: Enable sellers to manage their account with Stripe-hosted Dashboards, embedded components, or custom interfaces you can build with our APIs.
            Payments: Integrate payments and route funds to sellers on your platform.
            Payouts: Pay out sellers with a variety of payout options. Enable cross-border payouts for global sellers.
            Platform tools: Manage your platform or marketplace with a sophisticated suite of platform tooling for monetization, seller support, risk management, and tax reporting.
            Country availability
             sellers with a variety of payout options. Enable cross-border payouts for global sellers.
            "->React.string}
          </p>
          <br />
          <p>
            {"Businesses such as marketplaces and software platforms use Connect to manage and route payments and payouts between sellers, customers, service providers, and other entities.
            Onboarding: Onboard and verify sellers using connected accounts with Stripe-hosted flows, or build your own with our APIs.
            Account management: Enable sellers to manage their account with Stripe-hosted Dashboards, embedded components, or custom interfaces you can build with our APIs.
            Payments: Integrate payments and route funds to sellers on your platform.
            Payouts: Pay out sellers with a variety of payout options. Enable cross-border payouts for global sellers.
            Platform tools: Manage your platform or marketplace with a sophisticated suite of platform tooling for monetization, seller support, risk management, and tax reporting.
            Country availability Payouts: Pay out sellers with a variety of payout options. Enable cross-border payouts for global sellers.
            "->React.string}
          </p>
          <br />
          <p>
            {"Platform tools: Manage your platform or marketplace with a sophisticated suite of platform tooling for monetization, seller support, risk management, and tax reporting.
            Country availability
            A Connect integration consists of five main components Businesses such as marketplaces and software platforms use Connect to manage and route payments and payouts between 
            sellers, customers, service providers, and other entities. Onboarding: Onboard and verify sellers using connected accounts with Stripe-hosted flows, or build your own with our 
            APIs. Account management: Enable sellers to manage their account with Stripe-hosted Dashboards, embedded components, or custom interfaces you can build with our APIs. Payments:
             Integrate payments and route funds to sellers on your platform. Payouts: Pay out sellers with a variety of payout options. Enable cross-border payouts for global sellers. Platform tools:
              Manage your platform or marketplace with a sophisticated suite of platform tooling for monetization, seller support, risk management, and tax reporting. Country availability Elements of a C
              onnect integration A Connect integration consists of five main components"->React.string}
          </p>
        </div>
      </div>
    </Modal>
  }
}

module PlatformMerchantAccount = {
  @react.component
  let make = () => {
    let isPlatform = Recoil.useRecoilValueFromAtom(HyperswitchAtom.isPlatform)
    let (showModal, setShowModal) = React.useState(_ => false)

    let openLearnMoreModal = _ => {
      setShowModal(_ => true)
    }

    <div>
      <div className="border bg-gray-50 rounded-t-lg w-full px-6 py-6">
        <p className="font-semibold"> {"Platform Merchant Account"->React.string} </p>
      </div>
      <RenderIf condition={!isPlatform}>
        <div
          className="flex flex-col gap-5 bg-white border border-t-0 rounded-b-lg w-full px-6 pt-4 pb-6">
          <div>
            <p>
              {"Convert your account to Platform Merchant Account to start making payments for all the merchant from a single platform merchant account. "->React.string}
            </p>
            <span className="text-blue-400 cursor-pointer underline" onClick={openLearnMoreModal}>
              {"Learn More"->React.string}
            </span>
          </div>
          <LearnMoreModal showModal setShowModal />
          <div>
            <MakePlatformAccount />
          </div>
        </div>
      </RenderIf>
      <RenderIf condition={isPlatform}>
        <div
          className="flex flex-col gap-5 bg-white border border-t-0 rounded-b-lg w-full px-6 pt-4 pb-6">
          <div>
            <p>
              {"This account is Platform Merchant Account. You can enjoy making payments from merchant connected account."->React.string}
            </p>
            <span className="text-blue-400 cursor-pointer" onClick={openLearnMoreModal}>
              {"Learn More"->React.string}
            </span>
          </div>
          <LearnMoreModal showModal setShowModal />
          <div className="flex gap-10 items-center">
            <p className="titleClass"> {"Platform Merchant Name:"->React.string} </p>
            <p className="subTitleClass">
              {("userName"->LogicUtils.isNonEmptyString ? "merchant123" : "--")->React.string}
            </p>
          </div>
          <div className="flex gap-10 items-center">
            <p className="titleClass"> {"Platform Merchant Id:"->React.string} </p>
            <p className="subTitleClass">
              {("userName"->LogicUtils.isNonEmptyString ? "mca_123456789" : "--")->React.string}
            </p>
          </div>
        </div>
      </RenderIf>
    </div>
  }
}

@react.component
let make = () => {
  let {platformAccount} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

  <div className="flex flex-col overflow-scroll gap-8">
    <PageUtils.PageHeading
      title="Organization" subTitle="Manage your organization settings here."
    />
    <div className="flex flex-col flex-wrap  gap-12">
      <BasicDetailsSection />
      <RenderIf condition={platformAccount}>
        <PlatformMerchantAccount />
      </RenderIf>
    </div>
  </div>
}
