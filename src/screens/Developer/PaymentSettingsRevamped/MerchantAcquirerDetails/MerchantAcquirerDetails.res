open MerchantAcquirerDetailsTypes
open MerchantAcquirerDetailsModals
open APIUtilsTypes
open APIUtils
open Typography

@react.component
let make = () => {
  let businessProfileRecoilVal =
    HyperswitchAtom.businessProfileFromIdAtomInterface->Recoil.useRecoilValueFromAtom

  let showToast = ToastState.useShowToast()
  let {profileId} = React.useContext(UserInfoProvider.defaultContext).getCommonSessionDetails()
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let fetchBusinessProfileFromId = BusinessProfileHook.useFetchBusinessProfileFromId()

  let acquirerConfigGroups = MerchantAcquirerDetailsUtils.parseAcquirerConfigBucket(
    businessProfileRecoilVal.acquirer_config_bucket,
  )

  let (showAddAcquirer, setShowAddAcquirer) = React.useState(_ => false)
  let (isSelectionMode, setIsSelectionMode) = React.useState(_ => false)

  let currentDefaultId =
    acquirerConfigGroups->Array.find(b => b.is_default)->Option.mapOr("", b => b.id)

  let (selectedDefaultId, setSelectedDefaultId) = React.useState(_ => currentDefaultId)
  let (isSaving, setIsSaving) = React.useState(_ => false)

  let handleSaveDefault = async () => {
    setIsSaving(_ => true)
    try {
      let body = [("is_default", true->JSON.Encode.bool)]->Dict.fromArray
      let url = getURL(
        ~entityName=V1(ACQUIRER_CONFIG_SETTINGS),
        ~methodType=Post,
        ~id=Some(selectedDefaultId),
      )
      let _ = await updateDetails(url, body->JSON.Encode.object, Post)
      showToast(~message="Default acquirer updated", ~toastType=ToastState.ToastSuccess)
      setIsSelectionMode(_ => false)
      let _ = await fetchBusinessProfileFromId(~profileId=Some(profileId))
    } catch {
    | _ => showToast(~message="Failed to update default acquirer", ~toastType=ToastState.ToastError)
    }
    setIsSaving(_ => false)
  }

  let accordionItems: array<
    AccordionAdapter.accordion,
  > = acquirerConfigGroups->Array.map(acquirerConfigGroup => {
    let item: AccordionAdapter.accordion = {
      title: acquirerConfigGroup.merchant_name,
      renderContentOnTop: Some(
        () =>
          <MerchantAcquirerDetailsHelper.AccordionTitle
            bucket=acquirerConfigGroup
            isSelectionMode
            isSelected={isSelectionMode && selectedDefaultId === acquirerConfigGroup.id}
            onSelect={() => setSelectedDefaultId(_ => acquirerConfigGroup.id)}
          />,
      ),
      renderContent: (~currentAccordionState as _, ~closeAccordionFn as _) =>
        <MerchantAcquirerDetailsHelper.BucketBody bucket=acquirerConfigGroup />,
    }
    item
  })

  let isEmpty = acquirerConfigGroups->Array.length === 0

  <div className="flex flex-col gap-4 mt-8">
    <div className="flex items-center justify-between">
      <span className={`${body.lg.bold} text-nd_gray-700`}>
        {"Acquirer Config Settings"->React.string}
      </span>
      <RenderIf condition={!isEmpty}>
        <div className="flex items-center gap-3">
          <RenderIf condition={acquirerConfigGroups->Array.length > 1}>
            <Button
              buttonType={isSelectionMode ? Primary : Secondary}
              text={isSelectionMode ? "Save as Default" : "Change Default"}
              leftIcon={isSelectionMode
                ? NoIcon
                : CustomIcon(<Icon name="nd-swap-arrow-horizontal" size=16 />)}
              buttonState={if isSaving {
                Loading
              } else if isSelectionMode && selectedDefaultId === currentDefaultId {
                Disabled
              } else {
                Normal
              }}
              onClick={_ =>
                if !isSelectionMode {
                  setIsSelectionMode(_ => true)
                } else if selectedDefaultId !== currentDefaultId {
                  handleSaveDefault()->ignore
                }}
            />
          </RenderIf>
          <Button
            buttonType=Secondary
            onClick={_ => setShowAddAcquirer(_ => true)}
            text="Acquirer config group"
            leftIcon={FontAwesome("plus")}
            customIconSize=16
            customIconMargin="!pr-0"
          />
        </div>
      </RenderIf>
    </div>
    <RenderIf condition={!isEmpty}>
      <AccordionAdapter
        accordion=accordionItems
        accordionTopContainerCss="border border-nd_gray-200 rounded-xl "
        accordionBottomContainerCss="py-4 px-6 !bg-nd_gray-25"
        gapClass="flex flex-col gap-4"
      />
    </RenderIf>
    <RenderIf condition={isEmpty}>
      <div
        className="border border-nd_gray-200 rounded-xl px-6 py-10 flex flex-col items-center gap-3">
        <span className={`${body.md.regular} text-nd_gray-500`}>
          {"No acquirer configurations yet"->React.string}
        </span>
        <Button
          buttonType=Primary
          onClick={_ => setShowAddAcquirer(_ => true)}
          text="Acquirer config group"
          leftIcon={FontAwesome("plus")}
          customIconSize=16
          customIconMargin="!pr-0"
        />
      </div>
    </RenderIf>
    <AddAcquirerModal showModal=showAddAcquirer setShowModal=setShowAddAcquirer />
  </div>
}
