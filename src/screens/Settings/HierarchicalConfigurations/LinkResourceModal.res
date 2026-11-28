open Typography

@react.component
let make = (
  ~showModal,
  ~setShowModal,
  ~resource: option<HierarchicalConfigTypes.resourceSummary>,
  ~resourceType,
) => {
  open APIUtils
  open LogicUtils
  open HierarchicalConfigTypes
  open HierarchicalConfigUtils

  let getURL = useGetURL()
  let fetchScopedList = useUpdateMethod(~showErrorToast=false)
  let linkResource = useUpdateMethod(~showErrorToast=false)
  let showToast = ToastAdapter.useShowToast()
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let {getResolvedUserInfo} = React.useContext(UserInfoProvider.defaultContext)
  let {merchantId, profileId} = getResolvedUserInfo()
  let profileList = Recoil.useRecoilValueFromAtom(HyperswitchAtom.profileListAtom)

  let (scope, setScope) = React.useState(_ => None)
  let (selectedProfileId, setSelectedProfileId) = React.useState(_ => profileId)
  let (linkedResourceId, setLinkedResourceId) = React.useState(_ => None)
  let (isFetchingLinked, setIsFetchingLinked) = React.useState(_ => false)
  let (isLinking, setIsLinking) = React.useState(_ => false)
  let (errorMessage, setErrorMessage) = React.useState(_ => None)

  let resourceId = resource->Option.mapOr("", resource => resource.id)
  let requestorType = scope->Option.map(getRequestorTypeFromLinkScope)
  let requestorId =
    requestorType->Option.mapOr("", requestorType =>
      getResourceRequestorId(requestorType, ~merchantId, ~profileId=selectedProfileId)
    )
  let credentialName = resourceType->getCredentialName

  React.useEffect(() => {
    setScope(_ => None)
    setSelectedProfileId(_ => profileId)
    setLinkedResourceId(_ => None)
    setErrorMessage(_ => None)
    setIsLinking(_ => false)
    None
  }, (showModal, resourceId, merchantId, profileId))

  let fetchLinkedResource = async () => {
    switch requestorType {
    | Some(requestorType) if requestorId->isNonEmptyString =>
      try {
        setIsFetchingLinked(_ => true)
        let url = getURL(~entityName=V1(RESOURCES_LIST), ~methodType=Post)
        let payload = getListPayload(
          ~resourceType,
          ~scope=Some((requestorType->resourceRequestorTypeToString, requestorId)),
        )
        let response = await fetchScopedList(url, payload, Post)
        let linked =
          response
          ->getResourcesFromResponse
          ->Array.find(item => item.isLinked)
          ->Option.map(item => item.id)
        setLinkedResourceId(_ => linked)
      } catch {
      | Exn.Error(e) =>
        setLinkedResourceId(_ => None)
        setErrorMessage(_ => Some(
          getApiErrorMessage(~error=e, ~fallback=`Failed to fetch the current ${credentialName}`),
        ))
      }
      setIsFetchingLinked(_ => false)
    | _ => ()
    }
  }

  React.useEffect(() => {
    if showModal && resourceId->isNonEmptyString {
      setErrorMessage(_ => None)
      fetchLinkedResource()->ignore
    }
    None
  }, (showModal, resourceId, scope, selectedProfileId))

  let onLink = async () => {
    switch (scope, requestorType) {
    | (Some(scope), Some(requestorType))
      if !isLinking && resourceId->isNonEmptyString && requestorId->isNonEmptyString =>
      try {
        setIsLinking(_ => true)
        setErrorMessage(_ => None)
        let url = getURL(~entityName=V1(RESOURCES_LINK), ~methodType=Post, ~id=Some(resourceId))
        let _ = await linkResource(url, getLinkPayload(~requestorType, ~requestorId), Post)
        mixpanelEvent(
          ~eventName=`hierarchical_config_${(resourceType :> string)}_link_${requestorType->resourceRequestorTypeToString}_success`,
        )
        showToast(
          ~message=`${credentialName->capitalizeString} linked to ${scope
            ->getLinkScopeLabel
            ->String.toLowerCase} successfully`,
          ~toastType=ToastSuccess,
        )
        await fetchLinkedResource()
      } catch {
      | Exn.Error(e) =>
        setErrorMessage(_ => Some(
          getApiErrorMessage(~error=e, ~fallback=`Failed to link ${credentialName}`),
        ))
      }
      setIsLinking(_ => false)
    | _ => ()
    }
  }

  let profileOptions: array<SelectBox.dropdownOption> = profileList->Array.map(profile => {
    let option: SelectBox.dropdownOption = {
      label: profile.name->isNonEmptyString ? `${profile.name} (${profile.id})` : profile.id,
      value: profile.id,
    }
    option
  })

  let profileInput: ReactFinalForm.fieldRenderPropsInput = {
    name: "profile_id",
    onBlur: _ => (),
    onFocus: _ => (),
    onChange: ev => setSelectedProfileId(_ => ev->Identity.formReactEventToString),
    value: selectedProfileId->JSON.Encode.string,
    checked: false,
  }

  let isAlreadyLinked = linkedResourceId == Some(resourceId)
  let linkButtonState: Button.buttonState = if isLinking {
    Loading
  } else if (
    scope->Option.isNone || isFetchingLinked || isAlreadyLinked || requestorId->isEmptyString
  ) {
    Disabled
  } else {
    Normal
  }

  let linkedText = if isFetchingLinked {
    "Loading..."
  } else {
    switch linkedResourceId {
    | Some(id) if id == resourceId => `This ${credentialName} (${id})`
    | Some(id) => id
    | None => "None"
    }
  }

  let closeModalUnlessLinking = update =>
    if !isLinking {
      setShowModal(update)
    }

  let profileSelector =
    <div className="flex flex-col gap-1">
      <span className={`${body.sm.medium} text-nd_gray-600`}> {"Profile"->React.string} </span>
      <SelectBox.BaseDropdown
        allowMultiSelect=false
        hideMultiSelectButtons=true
        buttonText="Select profile"
        options=profileOptions
        input=profileInput
        searchable={profileOptions->Array.length > 5}
        fullLength=true
        dropdownCustomWidth="w-full"
        disableSelect=isLinking
      />
    </div>

  let linkedResourcePanel = (~showFallbackHint) =>
    <div className="flex flex-col gap-1 p-3 rounded-lg bg-nd_gray-25 border border-nd_gray-150">
      <span className={`${body.sm.medium} text-nd_gray-500`}>
        {`Current linked ${credentialName}`->React.string}
      </span>
      <span className={`${body.md.regular} text-nd_gray-800 break-all`}>
        {linkedText->React.string}
      </span>
      <RenderIf condition=showFallbackHint>
        <span className={`${body.sm.regular} text-nd_gray-500`}>
          {"A profile without its own configuration falls back to the merchant default."->React.string}
        </span>
      </RenderIf>
    </div>

  <Modal
    showModal
    setShowModal=closeModalUnlessLinking
    modalHeading={`Link ${resourceType->getResourceTypeLabel} ${credentialName}`}
    modalHeadingDescription={`Resource ID: ${resourceId}`}
    modalDescriptionClass={`${body.md.regular} text-nd_gray-500 mt-1`}
    childClass="p-6"
    borderBottom=true
    modalClass="w-full max-w-xl mx-auto my-auto dark:!bg-nd_gray-800"
    alignModal="items-center justify-center"
    closeOnOutsideClick=true>
    <div className="flex flex-col gap-5">
      {switch errorMessage {
      | Some(message) =>
        <AlertV2Binding
          alertType=Error
          slot={{slot: <Icon name="nd-cross" size=20 className="text-nd_red-500" />}}
          heading="Something went wrong"
          description=message
        />
      | None => React.null
      }}
      <div className="flex flex-col gap-3">
        {[Merchant, Profile]
        ->Array.map(option => {
          let isSelected = scope == Some(option)
          <div key={option->getLinkScopeLabel} className="flex flex-col gap-3">
            <HierarchicalConfigHelper.RadioCard
              title={option->getLinkScopeTitle(~merchantId)}
              description={option->getLinkScopeDescription}
              isSelected
              isDisabled=isLinking
              onClick={() => {
                setErrorMessage(_ => None)
                setLinkedResourceId(_ => None)
                setScope(_ => Some(option))
              }}
            />
            <RenderIf condition=isSelected>
              <div className="flex flex-col gap-3 pl-4">
                <RenderIf condition={option == Profile}> {profileSelector} </RenderIf>
                {linkedResourcePanel(~showFallbackHint=option == Profile)}
              </div>
            </RenderIf>
          </div>
        })
        ->React.array}
      </div>
      <div className="flex justify-end gap-2 w-full">
        <Button
          text="Close"
          buttonType=Secondary
          onClick={_ => setShowModal(_ => false)}
          buttonState={isLinking ? Disabled : Normal}
        />
        <Button
          text={isAlreadyLinked ? "Linked" : "Link"}
          buttonType=Primary
          onClick={_ => onLink()->ignore}
          buttonState=linkButtonState
        />
      </div>
    </div>
  </Modal>
}
