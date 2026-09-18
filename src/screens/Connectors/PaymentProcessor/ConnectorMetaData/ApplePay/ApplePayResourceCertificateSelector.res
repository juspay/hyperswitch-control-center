open Typography

@react.component
let make = (~merchantConnectorId) => {
  open LogicUtils
  open APIUtils
  open HierarchicalConfigTypes
  open HierarchicalConfigUtils
  open ApplePayResourceCertificateSelectorUtils

  let getURL = useGetURL()
  let fetchList = useUpdateMethod(~showErrorToast=false)
  let linkResource = useUpdateMethod(~showErrorToast=false)
  let showToast = ToastAdapter.useShowToast()
  let mixpanelEvent = MixpanelHook.useSendEvent()

  let (resources, setResources) = React.useState(_ => [])
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (isLinking, setIsLinking) = React.useState(_ => false)
  let (linkedResourceId, setLinkedResourceId) = React.useState(_ => "")
  let (selectedResourceId, setSelectedResourceId) = React.useState(_ => "")

  let scopeType = #MerchantConnectorAccount->resourceRequestorTypeToString

  let isLoading = screenState == PageLoaderWrapper.Loading
  let hasFetchError = switch screenState {
  | PageLoaderWrapper.Error(_) => true
  | _ => false
  }

  let fetchResources = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let requestUrl = getURL(~entityName=V1(RESOURCES_LIST), ~methodType=Post)
      let payload =
        [
          ("type", applePayCertificateResourceType->JSON.Encode.string),
          ("scope_type", scopeType->JSON.Encode.string),
          ("scope_id", merchantConnectorId->JSON.Encode.string),
        ]->Dict.fromArray
      let response = await fetchList(requestUrl, payload->JSON.Encode.object, Post)
      let resourceList =
        response
        ->getDictFromJsonObject
        ->getArrayFromDict("resources", [])
        ->Array.filterMap(JSON.Decode.object)
        ->Array.map(itemToObjectMapper)
      setResources(_ => resourceList)

      switch resourceList->Array.find(resource => resource.isLinked) {
      | Some(linkedResource) =>
        setLinkedResourceId(_ => linkedResource.id)
        setSelectedResourceId(_ => linkedResource.id)
      | None => ()
      }
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ =>
      let message = "Failed to fetch certificates"
      setScreenState(_ => PageLoaderWrapper.Error(message))
      showToast(~message, ~toastType=ToastError)
    }
  }

  React.useEffect(() => {
    fetchResources()->ignore
    None
  }, [merchantConnectorId])

  let linkSelectedResource = async () => {
    if selectedResourceId->isNonEmptyString {
      try {
        setIsLinking(_ => true)
        let requestUrl = getURL(
          ~entityName=V1(RESOURCES_LINK),
          ~methodType=Post,
          ~id=Some(selectedResourceId),
        )
        let payload =
          [
            ("requestor_type", scopeType->JSON.Encode.string),
            ("requestor_id", merchantConnectorId->JSON.Encode.string),
          ]->Dict.fromArray
        let _ = await linkResource(requestUrl, payload->JSON.Encode.object, Post)
        setLinkedResourceId(_ => selectedResourceId)
        showToast(~message="Certificate linked successfully", ~toastType=ToastSuccess)
      } catch {
      | Exn.Error(e) =>
        let message =
          Exn.message(e)
          ->Option.getOr("")
          ->safeParse
          ->getDictFromJsonObject
          ->getString("message", "")
        showToast(
          ~message=getErrorMessage(~message, ~error="", ~fallback="Failed to link certificate"),
          ~toastType=ToastError,
        )
      }
      setIsLinking(_ => false)
    }
  }

  let options = resources->getDropdownOptions
  let selectedLabel =
    options
    ->Array.find(option => option.value === selectedResourceId)
    ->Option.mapOr("Select certificate", option => option.label)

  let input: ReactFinalForm.fieldRenderPropsInput = {
    name: "resource_id",
    onBlur: _ => (),
    onFocus: _ => (),
    onChange: ev => setSelectedResourceId(_ => ev->Identity.formReactEventToString),
    value: selectedResourceId->JSON.Encode.string,
    checked: false,
  }

  let baseComponentMethod = isOpen =>
    <div
      className={`flex items-center justify-between w-full h-10 px-4 border border-nd_gray-300 rounded bg-white cursor-pointer hover:border-nd_gray-400 overflow-hidden ${body.md.regular}`}>
      <span
        className={`truncate ${selectedResourceId->isEmptyString
            ? "text-nd_gray-400"
            : "text-nd_gray-800"}`}>
        {selectedLabel->React.string}
      </span>
      <Icon
        name="chevron-down"
        size=14
        className={`text-nd_gray-400 flex-shrink-0 ml-2 transition duration-[250ms] ${isOpen
            ? "rotate-180"
            : "rotate-0"}`}
      />
    </div>

  <div className="flex flex-col gap-2 w-full">
    <div className="flex items-center gap-2">
      <div className="flex-1">
        <SelectBox.BaseDropdown
          allowMultiSelect=false
          hideMultiSelectButtons=true
          buttonText="Select certificate"
          options
          input
          searchable=false
          fullLength=true
          dropdownCustomWidth="w-full"
          baseComponentMethod
        />
      </div>
      <Button
        text="Link"
        buttonType=Secondary
        onClick={_ => {
          mixpanelEvent(~eventName="hierarchical_config_link_certificate_clicked")
          linkSelectedResource()->ignore
        }}
        buttonState={getButtonState(~isLoading, ~selectedResourceId, ~linkedResourceId, ~isLinking)}
      />
    </div>
    <RenderIf condition={!isLoading && !hasFetchError && resources->isEmptyArray}>
      <p className={`${body.sm.regular} text-nd_gray-500`}>
        {"No certificates available. Add one from Settings > Hierarchical Configurations."->React.string}
      </p>
    </RenderIf>
  </div>
}
