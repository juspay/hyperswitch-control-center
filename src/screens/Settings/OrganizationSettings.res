open Typography
open LogicUtils

module NewPlatformCreationModal = {
  @react.component
  let make = (~setShowModal, ~showModal) => {
    open APIUtils
    let getURL = useGetURL()
    let updateDetails = useUpdateMethod()
    let showToast = ToastState.useShowToast()
    let fetchOrganizationList = OrganizationHooks.useFetchOrganizationList()

    let createNewPlatform = async values => {
      try {
        let url = getURL(~entityName=V1(USERS), ~userType=#CREATE_PLATFORM, ~methodType=Post)

        let dict = values->getDictFromJsonObject
        let orgNameTrimmed = dict->getString("organization_name", "")->String.trim
        Dict.set(dict, "organization_name", orgNameTrimmed->JSON.Encode.string)

        let _ = await updateDetails(url, dict->JSON.Encode.object, Post)
        let _ = await fetchOrganizationList()
        showToast(
          ~toastType=ToastSuccess,
          ~message="Platform Organization Created Successfully!",
          ~autoClose=true,
        )
      } catch {
      | _ =>
        showToast(
          ~toastType=ToastError,
          ~message="Platform Organization Creation Failed",
          ~autoClose=true,
        )
      }

      setShowModal(_ => false)
      Nullable.null
    }

    let onSubmit = (values, _) => {
      createNewPlatform(values)
    }

    let organizationName = FormRenderer.makeFieldInfo(
      ~label="Organization Name",
      ~name="organization_name",
      ~customInput=(~input, ~placeholder as _) =>
        InputFields.textInput()(
          ~input={
            ...input,
            onChange: event =>
              ReactEvent.Form.target(event)["value"]
              ->String.trimStart
              ->Identity.stringToFormReactEvent
              ->input.onChange,
          },
          ~placeholder="Eg: My Platform Organization",
        ),
      ~isRequired=true,
    )

    let validateForm = (values: JSON.t) => {
      let errors = Dict.make()
      let valuesDict = values->getDictFromJsonObject
      let orgName = valuesDict->getString("organization_name", "")->String.trim
      let regexForOrgName = "^([a-z]|[A-Z]|[0-9]|_|\\s)+$"
      let errorMessage = if orgName->isEmptyString {
        "Organization name cannot be empty"
      } else if orgName->String.length > 64 {
        "Organization name cannot exceed 64 characters"
      } else if !RegExp.test(RegExp.fromString(regexForOrgName), orgName) {
        "Organization name should not contain special characters"
      } else {
        ""
      }

      if errorMessage->isNonEmptyString {
        Dict.set(errors, "organization_name", errorMessage->JSON.Encode.string)
      }

      errors->JSON.Encode.object
    }

    let modalBody = {
      <div className="">
        <div className="pt-3 m-3 flex justify-between">
          <CardUtils.CardHeader
            heading="Create New Platform Organization"
            subHeading=""
            customSubHeadingStyle="w-full !max-w-none pr-10"
          />
          <div className="h-fit" onClick={_ => setShowModal(_ => false)}>
            <Icon name="modal-close-icon" className="cursor-pointer" size=30 />
          </div>
        </div>
        <hr />
        <Form key="new-platform-creation" onSubmit validate={validateForm}>
          <div className="flex flex-col h-full w-full">
            <div className="py-10">
              <FormRenderer.DesktopRow>
                <FormRenderer.FieldRenderer
                  fieldWrapperClass="w-full"
                  field={organizationName}
                  showErrorOnChange=true
                  errorClass={ProdVerifyModalUtils.errorClass}
                  labelClass="!text-black font-medium !-ml-[0.5px]"
                />
              </FormRenderer.DesktopRow>
            </div>
            <hr className="mt-4" />
            <div className="flex justify-end w-full p-3">
              <FormRenderer.SubmitButton text="Create Platform" buttonSize=Small />
            </div>
          </div>
        </Form>
      </div>
    }

    <Modal
      showModal
      closeOnOutsideClick=true
      setShowModal
      childClass="p-0"
      borderBottom=true
      modalClass="w-full max-w-xl mx-auto my-auto dark:!bg-jp-gray-lightgray_background">
      modalBody
    </Modal>
  }
}

module PlatformInfoModal = {
  @react.component
  let make = (~setShowModal, ~showModal) => {
    let modalBody = {
      <div className="">
        <div className="pt-3 m-3 flex justify-between">
          <CardUtils.CardHeader
            heading="About Platform Organizations"
            subHeading=""
            customSubHeadingStyle="w-full !max-w-none pr-10"
          />
          <div className="h-fit" onClick={_ => setShowModal(_ => false)}>
            <Icon name="modal-close-icon" className="cursor-pointer" size=30 />
          </div>
        </div>
        <hr />
        <div className="p-6 flex flex-col gap-6">
          <div className="flex flex-col gap-3">
            <p className={`text-nd_gray-800 ${body.md.semibold}`}>
              {"What is a Platform Organization?"->React.string}
            </p>
            <p className={`text-nd_gray-600 ${body.md.regular}`}>
              {"A Platform Organisation is built for Vertical SaaS use cases, where a single platform manages payments for multiple merchants. It includes a Platform Merchant Account that centrally controls API keys, integrations, and payment flows on behalf of connected merchants. This setup enables scalable onboarding while keeping platform and merchant responsibilities clearly separated."->React.string}
            </p>
          </div>
          <div className="flex flex-col gap-3">
            <p className={`text-nd_gray-800 ${body.md.semibold}`}>
              {"Key Features"->React.string}
            </p>
            <ul
              className={`list-disc list-inside text-nd_gray-600 flex flex-col gap-2 ${body.md.regular}`}>
              <li> {"Contains one Platform Merchant Account"->React.string} </li>
              <li> {"Onboard and manage multiple connected merchants"->React.string} </li>
              <li> {"Acts as the control layer for all connected merchants"->React.string} </li>
              <li> {"Generate and manage API keys"->React.string} </li>
              <li> {"Initiate payments on behalf of connected merchants"->React.string} </li>
              <li>
                {"Platform merchant holds permissions that standard merchants do not have"->React.string}
              </li>
            </ul>
          </div>
          <div className="flex flex-col gap-3">
            <p className={`text-nd_gray-800 ${body.md.semibold}`}> {"Use Cases"->React.string} </p>
            <ul
              className={`list-disc list-inside text-nd_gray-600 flex flex-col gap-2 ${body.md.regular}`}>
              <li> {"Marketplaces managing multiple sellers"->React.string} </li>
              <li> {"SaaS platforms with serving businesses"->React.string} </li>
              <li> {"Payment facilitators (PayFacs)"->React.string} </li>
              <li> {"Franchise or multi-location businesses"->React.string} </li>
            </ul>
          </div>
          <HSwitchUtils.AlertBanner
            bannerContent={<p className={`${body.sm.regular}`}>
              {"Creating a new platform organization will set up a separate entity. Your existing organization will remain unchanged."->React.string}
            </p>}
            bannerType=Info
          />
        </div>
      </div>
    }

    <Modal
      showModal
      closeOnOutsideClick=true
      setShowModal
      childClass="p-0"
      borderBottom=true
      modalClass="w-full max-w-2xl mx-auto my-auto dark:!bg-jp-gray-lightgray_background">
      modalBody
    </Modal>
  }
}

@react.component
let make = () => {
  open APIUtils

  let {checkUserEntity} = React.useContext(UserInfoProvider.defaultContext)
  let isLiveMode = (HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom).isLiveMode
  let orgList = Recoil.useRecoilValueFromAtom(HyperswitchAtom.orgListAtom)
  let {organization_id: orgId, organization_name: orgName} =
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

  // Js.log2("organizationDetails", organizationDetails)

  React.useEffect(() => {
    if orgList->Array.length === 0 {
      fetchOrganizationList()->ignore
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

  <>
    <PageUtils.PageHeading
      title="Organization Settings" subTitle="Manage organization configuration and settings"
    />
    <div className="">
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
            customInputStyle="text-fs-14 text-nd_gray-600"
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
    <RenderIf condition={showModal}>
      <NewPlatformCreationModal setShowModal showModal />
    </RenderIf>
    <RenderIf condition={showInfoModal}>
      <PlatformInfoModal setShowModal={setShowInfoModal} showModal={showInfoModal} />
    </RenderIf>
  </>
}
