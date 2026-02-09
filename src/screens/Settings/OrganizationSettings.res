open Typography
open LogicUtils
open OrganizationSettingsHelper

@react.component
let make = () => {
  open APIUtils

  let {checkUserEntity} = React.useContext(UserInfoProvider.defaultContext)
  let isLiveMode = (HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom).isLiveMode
  let orgList = Recoil.useRecoilValueFromAtom(HyperswitchAtom.orgListAtom)
  let {id: orgId, name: orgName} =
    HyperswitchAtom.organizationDetailsValueAtom->Recoil.useRecoilValueFromAtom
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let showToast = ToastState.useShowToast()
  let {userHasAccess, hasAnyGroupAccess} = GroupACLHooks.useUserGroupACLHook()
  let (_, isCurrentOrganizationPlatform) = OMPSwitchHooks.useOMPType()
  let fetchOrganizationList = OrganizationHooks.useFetchOrganizationList()
  let (showModal, setShowModal) = React.useState(_ => false)
  let (showInfoModal, setShowInfoModal) = React.useState(_ => false)
  let (isUnderEdit, setIsUnderEdit) = React.useState(_ => false)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)

  let getOrgList = async () => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let _ = await fetchOrganizationList()
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => {
        showToast(~message="Failed to fetch organization list!", ~toastType=ToastError)
        setScreenState(_ => PageLoaderWrapper.Error(""))
      }
    }
  }

  React.useEffect(() => {
    if orgList->Array.length === 0 {
      getOrgList()->ignore
    }
    None
  }, [])

  let validateInput = (organizationName: string) => {
    let errors = Dict.make()
    let regexForOrganizationName = "^([a-z]|[A-Z]|[0-9]|_|\\s)+$"
    let errorMessage = if organizationName->isEmptyString {
      "Organization name cannot be empty"
    } else if organizationName->String.length > 64 {
      "Organization name cannot exceed 64 characters"
    } else if !RegExp.test(RegExp.fromString(regexForOrganizationName), organizationName) {
      "Organization name should not contain special characters"
    } else {
      ""
    }

    if errorMessage->isNonEmptyString {
      errors->Dict.set("organizationName", errorMessage->JSON.Encode.string)
    }
    errors
  }

  let onSubmit = async (values: string) => {
    try {
      let url = getURL(~entityName=V1(ORGANIZATION_RETRIEVE), ~methodType=Put, ~id=Some(orgId))
      let dict = Dict.make()
      Dict.set(dict, "organization_name", values->JSON.Encode.string)
      let _ = await updateDetails(url, dict->JSON.Encode.object, Put)
      let _ = await fetchOrganizationList()
      showToast(~message="Updated organization name!", ~toastType=ToastSuccess)
    } catch {
    | _ => showToast(~message="Failed to update organization name!", ~toastType=ToastError)
    }
  }

  let handleEdit = (selectedEditId: option<int>) => {
    setIsUnderEdit(_ => selectedEditId->Option.isSome)
  }

  let showEditIcon =
    hasAnyGroupAccess(
      userHasAccess(~groupAccess=OrganizationManage),
      userHasAccess(~groupAccess=AccountManage),
    ) === Access && checkUserEntity([#Organization])

  let contactUsBanner =
    <HSwitchUtils.AlertBanner
      bannerContent={<p className={`${body.sm.regular}`}>
        {"Contact us for further assistance on "->React.string}
        <a
          href="https://hyperswitch-io.slack.com/?redir=%2Fssb%2Fredirect"
          className="text-primary hover:cursor-pointer hover:underline"
          target="_blank">
          {"Slack"->React.string}
        </a>
      </p>}
      bannerType=Info
    />

  <PageLoaderWrapper screenState>
    <PageUtils.PageHeading
      title="Organization Settings" subTitle="Manage organization configuration and settings"
    />
    <div>
      <p className={`text-nd_gray-800 ${body.lg.semibold} mb-6`}>
        {"Organization Details"->React.string}
      </p>
      <div className="flex flex-col gap-4">
        <div className="flex flex-col gap-2">
          <p className={`text-nd_gray-500 ${body.md.medium}`}>
            {"Organization ID"->React.string}
          </p>
          <div className="flex items-center">
            <p className={`text-nd_gray-600 ${body.md.regular}`}> {orgId->React.string} </p>
            <ToolTip
              description="Copy Organization ID"
              customStyle="!whitespace-nowrap"
              toolTipFor={<div className="cursor-pointer">
                <HelperComponents.CopyTextCustomComp
                  customIconCss="text-nd_gray-500" displayValue=Some("") copyValue=Some(orgId)
                />
              </div>}
              toolTipPosition=ToolTip.Right
            />
          </div>
        </div>
        <div className="flex flex-col gap-2">
          <p className={`text-nd_gray-500 ${body.md.medium}`}>
            {"Organization Name"->React.string}
          </p>
          <InlineEditInput
            index=0
            labelText={orgName}
            subText=""
            customStyle="!p-0"
            showEditIconOnHover=false
            customInputStyle={`text-nd_gray-600 ${body.md.regular}`}
            showEditIcon
            handleEdit
            isUnderEdit
            displayHoverOnEdit={!isUnderEdit}
            validateInput
            labelTextCustomStyle={`text-nd_gray-600 ${body.md.regular}`}
            customWidth="max-w-48"
            customIconStyle="text-nd_gray-500"
            onSubmit
            toolTipPosition=BottomRight
          />
        </div>
      </div>
    </div>
    <RenderIf condition={!isCurrentOrganizationPlatform}>
      <div className="flex flex-col gap-6">
        <div className="p-6 bg-white border border-nd_br_gray-200 rounded-lg">
          <div className="flex flex-col gap-4">
            <div className="flex items-center gap-2">
              <p className={`text-nd_gray-800 ${body.lg.semibold}`}>
                {"Create New Platform Organization"->React.string}
              </p>
            </div>
            <p className={`text-nd_gray-600 ${body.md.regular}`}>
              {"Create a new platform organization to manage multiple connected merchants and enable platform-level features."->React.string}
            </p>
            <div className="flex gap-4">
              <Button
                text="Learn More"
                buttonType=Secondary
                buttonSize=Small
                onClick={_ => setShowInfoModal(_ => true)}
              />
              <RenderIf condition={!isLiveMode}>
                <Button
                  text="Create Platform Organization"
                  leftIcon={CustomIcon(<Icon name="nd-plus" size=15 className="text-white" />)}
                  buttonType=Primary
                  buttonSize=Small
                  onClick={_ => setShowModal(_ => true)}
                />
              </RenderIf>
            </div>
            <RenderIf condition={isLiveMode}> {contactUsBanner} </RenderIf>
          </div>
        </div>
        <div className="p-6 bg-white border border-nd_br_gray-200 rounded-lg">
          <div className="flex flex-col gap-4">
            <div className="flex items-center gap-2">
              <p className={`text-nd_gray-800 ${body.lg.semibold}`}>
                {"Convert to Platform Organization"->React.string}
              </p>
            </div>
            <p className={`text-nd_gray-600 ${body.md.regular}`}>
              {"To convert your existing organization to a platform organization, please contact your administrator. This action requires elevated permissions and cannot be performed directly."->React.string}
            </p>
            {contactUsBanner}
          </div>
        </div>
      </div>
    </RenderIf>
    <RenderIf condition={isCurrentOrganizationPlatform}>
      <div className="p-6 bg-white border border-nd_br_gray-200 rounded-lg">
        <div className="flex flex-col gap-4">
          <div className="flex items-center gap-2">
            <Icon name="check-circle" size=20 className="text-nd_green-600" />
            <p className={`text-nd_gray-800 ${body.lg.semibold}`}>
              {"Platform Organization Active"->React.string}
            </p>
          </div>
          <p className={`text-nd_gray-600 ${body.md.regular}`}>
            {"Your organization is already configured as a platform organization."->React.string}
          </p>
        </div>
      </div>
    </RenderIf>
    <NewPlatformCreationModal setShowModal showModal />
    <PlatformInfoModal setShowModal={setShowInfoModal} showModal={showInfoModal} />
  </PageLoaderWrapper>
}
