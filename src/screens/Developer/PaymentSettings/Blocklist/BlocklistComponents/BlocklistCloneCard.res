open BlocklistUtils
open LogicUtils
open APIUtils
open Typography

@react.component
let make = (~onCloneStarted) => {
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod(~showErrorToast=false)
  let showToast = ToastAdapter.useShowToast()
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let fetchProfileList = ProfileListHook.useFetchProfileList()
  let {profileId} = React.useContext(UserInfoProvider.defaultContext).getCommonSessionDetails()
  let profileList = Recoil.useRecoilValueFromAtom(HyperswitchAtom.profileListAtom)
  let (showModal, setShowModal) = React.useState(_ => false)
  let (selectedProfileIds, setSelectedProfileIds) = React.useState(_ => [])
  let (cloneButtonState, setCloneButtonState) = React.useState(_ => Button.Normal)

  let targetProfileOptions = profileList->getCloneTargetProfileOptions(~sourceProfileId=profileId)
  let sourceProfileName = OMPSwitchUtils.currentOMPName(profileList, profileId)

  let openModal = _ => {
    fetchProfileList()->ignore
    setSelectedProfileIds(_ => [])
    setShowModal(_ => true)
  }

  let targetProfilesInput: ReactFinalForm.fieldRenderPropsInput = {
    name: "blocklist-clone-target-profiles",
    onBlur: _ => (),
    onChange: ev => setSelectedProfileIds(_ => ev->Identity.formReactEventToArrayOfString),
    onFocus: _ => (),
    value: selectedProfileIds->getJsonFromArrayOfString,
    checked: true,
  }

  let cloneBlocklist = async () => {
    try {
      setCloneButtonState(_ => Button.Loading)
      let url = getURL(~entityName=V1(BLOCKLIST_CLONE), ~methodType=Post)
      let body =
        [
          ("target_profile_ids", selectedProfileIds->getJsonFromArrayOfString),
        ]->getJsonFromArrayOfJson
      let response = await updateDetails(url, body, Post)
      let jobId = response->getDictFromJsonObject->getString("job_id", "")
      let message =
        jobId->isNonEmptyString
          ? `Blocklist clone started. Job ID: ${jobId}`
          : "Blocklist clone started."
      showToast(~message, ~toastType=ToastSuccess)
      setShowModal(_ => false)
      onCloneStarted()
    } catch {
    | Exn.Error(e) =>
      let errorMessage =
        Exn.message(e)
        ->Option.getOr("Failed to clone blocklist")
        ->parseBlocklistErrorMessage
      showToast(~message=errorMessage, ~toastType=ToastError)
    }
    setCloneButtonState(_ => Button.Normal)
  }

  let onCloneClick = _ => {
    mixpanelEvent(~eventName="blocklist_clone")
    cloneBlocklist()->ignore
  }

  <RenderIf condition={targetProfileOptions->isNonEmptyArray}>
    <section
      className="max-w-3xl border border-nd_gray-200 rounded-lg bg-white p-5 flex flex-col gap-4">
      <div className="flex items-start justify-between gap-4">
        <div>
          <h2 className={`text-nd_gray-700 ${body.lg.semibold}`}>
            {"Clone to Other Profiles"->React.string}
          </h2>
          <p className={`text-nd_gray-500 mt-1 ${body.md.medium}`}>
            {"Copy this profile's blocklist to other profiles. Entries already on those profiles are kept."->React.string}
          </p>
        </div>
        <ACLButton
          text="Clone Blocklist"
          buttonType=Primary
          onClick=openModal
          authorization={userHasAccess(~groupAccess=AccountManage)}
        />
      </div>
    </section>
    <RenderIf condition={showModal}>
      <Modal
        modalHeading="Clone blocklist"
        modalHeadingDescription="Runs in the background. Track progress in the jobs table."
        modalDescriptionClass={`${body.md.regular} text-nd_gray-500 mt-1`}
        showModal
        setShowModal
        modalClass="w-full max-w-lg mx-auto my-auto dark:!bg-jp-gray-lightgray_background"
        childClass="p-6"
        borderBottom=true>
        <div className="flex flex-col gap-5">
          <div className="flex flex-col gap-2">
            <p className={`${body.sm.semibold} text-nd_gray-700`}>
              {"Source profile"->React.string}
            </p>
            <p
              className={`border border-nd_gray-150 bg-nd_gray-50 rounded-lg px-3 py-2.5 truncate ${body.md.medium} text-nd_gray-700`}>
              {sourceProfileName->React.string}
            </p>
          </div>
          <div className="flex flex-col gap-2">
            <p className={`${body.sm.semibold} text-nd_gray-700`}>
              {"Target profiles"->React.string}
            </p>
            <SelectBoxAdapter.BaseDropdown
              buttonText="Select profiles"
              allowMultiSelect=true
              input=targetProfilesInput
              options=targetProfileOptions
              hideMultiSelectButtons=true
              showSelectAll=true
              fullLength=true
              customButtonStyle="!rounded-lg"
            />
          </div>
          <div className="flex justify-end gap-3">
            <Button
              text="Cancel"
              buttonType=Secondary
              buttonSize=Medium
              customButtonStyle="!w-fit"
              onClick={_ => setShowModal(_ => false)}
            />
            <Button
              text="Clone"
              buttonType=Primary
              buttonSize=Medium
              customButtonStyle="!w-fit"
              onClick=onCloneClick
              buttonState={selectedProfileIds->isEmptyArray ? Disabled : cloneButtonState}
            />
          </div>
        </div>
      </Modal>
    </RenderIf>
  </RenderIf>
}
