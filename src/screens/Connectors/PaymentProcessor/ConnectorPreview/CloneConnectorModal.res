open LogicUtils
open Typography
open CloneConnectorModalUtils

@react.component
let make = (~connectorInfo: ConnectorTypes.connectorPayload) => {
  open APIUtils
  let updateDetails = useUpdateMethod(~showErrorToast=false)
  let showToast = ToastAdapter.useShowToast()
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let getURL = useGetURL()
  let featureFlag = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let connectorCloneAllowList =
    HyperswitchAtom.connectorCloneAllowListAtom->Recoil.useRecoilValueFromAtom
  let {isEmbeddableSession} = React.useContext(UserInfoProvider.defaultContext)
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let fetchProfileList = ProfileListHook.useFetchProfileList()
  let businessProfile = HyperswitchAtom.businessProfileFromIdAtom->Recoil.useRecoilValueFromAtom
  let (showModal, setShowModal) = React.useState(_ => false)
  let profileList = Recoil.useRecoilValueFromAtom(HyperswitchAtom.profileListAtom)

  let sourceProfileName =
    businessProfile.profile_name->isNonEmptyString
      ? businessProfile.profile_name
      : OMPSwitchUtils.currentOMPName(profileList, connectorInfo.profile_id)

  let isCloneable =
    featureFlag.connectorClone &&
    connectorCloneAllowList->Array.includes(connectorInfo.connector_name->String.toLowerCase)
  let showCloneButton = isCloneable && !isEmbeddableSession()

  let destinationProfileOptions = getDestinationOptions(
    profileList,
    ~sourceProfileId=connectorInfo.profile_id,
  )

  let labelField = FormRenderer.makeFieldInfo(
    ~label="New connector label",
    ~name="connector_label",
    ~placeholder="Enter connector label",
    ~isRequired=true,
  )

  let openModal = _ => {
    mixpanelEvent(~eventName=`processor_clone_${connectorInfo.connector_name}`)
    fetchProfileList()->ignore
    setShowModal(_ => true)
  }

  let validateForm = (values: JSON.t) => {
    let errors = Dict.make()
    let valuesDict = values->getDictFromJsonObject
    if valuesDict->getString("destination_profile_id", "")->isEmptyString {
      Dict.set(errors, "destination_profile_id", "Select a destination profile"->JSON.Encode.string)
    }
    if valuesDict->getString("connector_label", "")->String.trim->isEmptyString {
      Dict.set(errors, "connector_label", "Enter a connector label"->JSON.Encode.string)
    }
    errors->JSON.Encode.object
  }

  let onSubmit = async (values, _) => {
    try {
      let url = getURL(~entityName=V1(USERS), ~userType=#CLONE_CONNECTOR, ~methodType=Post)
      let body = getCloneConnectorPayload(values, connectorInfo)
      let _ = await updateDetails(url, body, Post)
      setShowModal(_ => false)
      showToast(~message="Connector cloned successfully.", ~toastType=ToastSuccess)
      Nullable.null
    } catch {
    | Exn.Error(e) =>
      let err = Exn.message(e)->Option.getOr("Failed to clone connector")
      let errorCode =
        err
        ->safeParse
        ->getDictFromJsonObject
        ->getString("code", "")
        ->CommonAuthUtils.errorSubCodeMapper
      let message = errorCode->getCloneErrorMessage
      showToast(~message, ~toastType=ToastError)
      switch errorCode {
      | UR_59 =>
        let errors = Dict.make()
        Dict.set(errors, "connector_label", message->JSON.Encode.string)
        errors->JSON.Encode.object->Nullable.make
      | _ => Nullable.null
      }
    }
  }

  <RenderIf condition={showCloneButton}>
    <ACLButton
      text="Clone connector"
      authorization={userHasAccess(~groupAccess=CloneConnectorManage)}
      buttonType=Secondary
      buttonSize=Medium
      leftIcon={CustomIcon(<Icon name="nd-copy" size=16 className="text-nd_gray-600" />)}
      textWeight={body.md.semibold}
      customButtonStyle="!w-fit !rounded-lg"
      onClick={openModal}
    />
    <RenderIf condition={showModal}>
      <Modal
        modalHeading="Clone connector"
        modalHeadingDescription="Copy this configuration into another profile."
        modalDescriptionClass={`${body.md.regular} text-nd_gray-500 mt-1`}
        showModal
        setShowModal
        modalClass="w-full max-w-lg mx-auto my-auto dark:!bg-jp-gray-lightgray_background"
        childClass="p-6"
        borderBottom=true>
        <Form key="clone-connector" onSubmit validate={validateForm}>
          <div className="flex flex-col gap-5">
            <CloneConnectorModalHelper.ConnectorSourceDestination
              connectorInfo sourceProfileName destinationProfileOptions
            />
            <FormRenderer.FieldRenderer
              field={labelField}
              fieldWrapperClass="flex flex-col gap-2"
              labelPadding="pb-0"
              labelTextStyleClass={`${body.sm.semibold} text-nd_gray-700`}
            />
            <hr className="border-nd_gray-150" />
            <CloneConnectorModalHelper.CloneScopeSummary />
            <div className="flex justify-end gap-3">
              <Button
                text="Cancel"
                buttonType=Secondary
                buttonSize=Medium
                customButtonStyle="!w-fit"
                onClick={_ => setShowModal(_ => false)}
              />
              <FormRenderer.SubmitButton
                text="Clone connector"
                buttonType=Primary
                buttonSize=Medium
                customSubmitButtonStyle="!w-fit"
              />
            </div>
          </div>
        </Form>
      </Modal>
    </RenderIf>
  </RenderIf>
}
