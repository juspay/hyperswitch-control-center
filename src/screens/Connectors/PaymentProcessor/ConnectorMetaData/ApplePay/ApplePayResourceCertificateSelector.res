open Typography

@react.component
let make = (~connector) => {
  open LogicUtils
  open APIUtils
  open HierarchicalConfigUtils
  open ReactFinalForm
  open ApplePayResourceCertificateSelectorUtils

  let getURL = useGetURL()
  let fetchList = useUpdateMethod(~showErrorToast=false)
  let linkResource = useUpdateMethod(~showErrorToast=false)
  let showToast = ToastAdapter.useShowToast()
  let {getCommonSessionDetails, getResolvedUserInfo} = React.useContext(
    UserInfoProvider.defaultContext,
  )
  let {merchantId, profileId} = getCommonSessionDetails()
  let {transactionEntity} = getResolvedUserInfo()
  let form = useForm()
  let formState: formState = useFormState(useFormSubscription(["values"])->Nullable.make)
  let (resources, setResources) = React.useState(_ => [])
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (isLinking, setIsLinking) = React.useState(_ => false)
  let (linkedResourceId, setLinkedResourceId) = React.useState(_ => "")

  let resourceIdFieldName = getResourceIdFieldName(~connector)
  let resourceLinkedFieldName = getResourceLinkedFieldName(~connector)

  let isLoading = screenState == Loading
  let hasFetchError = switch screenState {
  | Error(_) => true
  | _ => false
  }

  let sessionTokenDict =
    formState.values
    ->getDictFromJsonObject
    ->getDictFromNestedDict("metadata", "apple_pay_combined")
    ->getDictFromNestedDict("manual", "session_token_data")
  let selectedResourceId = sessionTokenDict->getString("resource_id", "")

  let fetchResources = async () => {
    try {
      setScreenState(_ => Loading)
      let requestUrl = getURL(~entityName=V1(RESOURCES_LIST), ~methodType=Post)
      let payload = [("type", applePayCertificateResourceType->JSON.Encode.string)]->Dict.fromArray
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
        form.change(resourceIdFieldName, linkedResource.id->JSON.Encode.string)
        form.change(resourceLinkedFieldName, true->JSON.Encode.bool)
        setLinkedResourceId(_ => linkedResource.id)
      | None => ()
      }
      setScreenState(_ => Success)
    } catch {
    | _ =>
      let message = "Failed to fetch certificates"
      setScreenState(_ => Error(message))
      showToast(~message, ~toastType=ToastError)
    }
  }

  React.useEffect(() => {
    fetchResources()->ignore
    None
  }, [])

  let linkSelectedResource = async () => {
    if selectedResourceId->isNonEmptyString {
      try {
        setIsLinking(_ => true)
        let requestUrl = getURL(
          ~entityName=V1(RESOURCES_LINK),
          ~methodType=Post,
          ~id=Some(selectedResourceId),
        )
        let requestorType = transactionEntity->getResourceRequestorTypeFromEntity
        let payload = [
          ("requestor_type", requestorType->resourceRequestorTypeToString->JSON.Encode.string),
          (
            "requestor_id",
            requestorType
            ->getResourceRequestorId(~merchantId, ~profileId)
            ->JSON.Encode.string,
          ),
        ]->Dict.fromArray
        let _ = await linkResource(requestUrl, payload->JSON.Encode.object, Post)
        form.change(resourceLinkedFieldName, true->JSON.Encode.bool)
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

  <div className="flex flex-col gap-2">
    <div className="flex items-end gap-2">
      <div className="flex-1">
        <FormRenderer.FieldRenderer
          labelClass={body.md.semibold}
          field={CommonConnectorHelper.selectInput(
            ~field=resourceField,
            ~formName=resourceIdFieldName,
            ~opt=Some(resources->getDropdownOptions),
            ~onItemChange={_ => form.change(resourceLinkedFieldName, false->JSON.Encode.bool)},
          )}
        />
      </div>
      <Button
        text="Link"
        buttonType=Secondary
        onClick={_ => linkSelectedResource()->ignore}
        buttonState={getButtonState(~isLoading, ~selectedResourceId, ~linkedResourceId, ~isLinking)}
      />
    </div>
    <RenderIf condition={!isLoading && !hasFetchError && resources->isEmptyArray}>
      <p className={`${body.sm.regular} text-nd_gray-500 pl-2`}>
        {"No certificates available. Add one from Settings > Hierarchical Configurations."->React.string}
      </p>
    </RenderIf>
  </div>
}
