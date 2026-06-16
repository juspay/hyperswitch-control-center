open APIUtils
open LogicUtils
open Typography

@react.component
let make = (~connectorInfo: ConnectorTypes.connectorPayload) => {
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod(~showErrorToast=false)
  let fetchDetails = useGetMethod()
  let showToast = ToastState.useShowToast()
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let featureFlag = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let {getCommonSessionDetails, isEmbeddableSession} = React.useContext(
    UserInfoProvider.defaultContext,
  )
  let {version} = getCommonSessionDetails()
  let hasCloneAccess = OMPCreateAccessHook.useOMPCreateAccessHook([#org_admin, #merchant_admin])
  let businessProfile = HyperswitchAtom.businessProfileFromIdAtom->Recoil.useRecoilValueFromAtom
  let (showModal, setShowModal) = React.useState(_ => false)
  let (profileList, setProfileList) = Recoil.useRecoilState(HyperswitchAtom.profileListAtom)

  let sourceProfileName =
    businessProfile.profile_name->isNonEmptyString
      ? businessProfile.profile_name
      : OMPSwitchUtils.currentOMPName(profileList, connectorInfo.profile_id)

  let isCloneable =
    featureFlag.connectorCloneAllowList->Array.includes(
      connectorInfo.connector_name->String.toLowerCase,
    )
  let isEligible = isCloneable && hasCloneAccess === Access && !isEmbeddableSession()

  let getProfileList = async () => {
    try {
      let response = switch version {
      | UserInfoTypes.V2 =>
        await fetchDetails(
          getURL(~entityName=V2(USERS), ~userType=#LIST_PROFILE, ~methodType=Get),
          ~version=V2,
        )
      | V1 =>
        await fetchDetails(
          getURL(~entityName=V1(USERS), ~userType=#LIST_PROFILE, ~methodType=Get),
          ~version=V1,
        )
      }
      setProfileList(_ => response->getArrayDataFromJson(OMPSwitchUtils.profileItemToObjMapper))
    } catch {
    | _ => showToast(~message="Failed to fetch profile list", ~toastType=ToastError)
    }
  }

  let destinationOptions: array<SelectBox.dropdownOption> =
    profileList
    ->Array.filter(profile => profile.id != connectorInfo.profile_id)
    ->Array.map((profile): SelectBox.dropdownOption => {
      label: profile.name,
      value: profile.id,
    })

  let labelField = FormRenderer.makeFieldInfo(
    ~label="New connector label",
    ~name="connector_label",
    ~placeholder="Enter connector label",
    ~isRequired=true,
  )

  let openModal = _ => {
    mixpanelEvent(~eventName=`processor_clone_${connectorInfo.connector_name}`)
    getProfileList()->ignore
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
    let valuesDict = values->getDictFromJsonObject
    try {
      let url = getURL(~entityName=V1(USERS), ~userType=#CLONE_CONNECTOR, ~methodType=Post)
      let body =
        [
          ("source_mca_id", connectorInfo.merchant_connector_id->JSON.Encode.string),
          ("source_profile_id", connectorInfo.profile_id->JSON.Encode.string),
          (
            "destination_profile_id",
            valuesDict->getString("destination_profile_id", "")->JSON.Encode.string,
          ),
          (
            "connector_label",
            valuesDict->getString("connector_label", "")->String.trim->JSON.Encode.string,
          ),
        ]->getJsonFromArrayOfJson
      let _ = await updateDetails(url, body, Post)
      setShowModal(_ => false)
      showToast(~message="Connector cloned successfully.", ~toastType=ToastSuccess)
    } catch {
    | Exn.Error(e) =>
      let err = Exn.message(e)->Option.getOr("Failed to clone connector")
      let errorCode = err->safeParse->getDictFromJsonObject->getString("code", "")
      let message =
        errorCode === "HE_01"
          ? "A connector with this label already exists in the destination profile. Try a different label."
          : "Failed to clone connector. Please try again."
      showToast(~message, ~toastType=ToastError)
    }
    Nullable.null
  }

  <RenderIf condition={isEligible}>
    <Button
      text="Clone connector"
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
            <div className="flex flex-col gap-2">
              <div className="flex items-center gap-3">
                <p className={`flex-1 min-w-0 ${body.sm.semibold} text-nd_gray-400 tracking-wide`}>
                  {"SOURCE"->React.string}
                </p>
                <span className="w-4 shrink-0" />
                <p className={`flex-1 min-w-0 ${body.sm.semibold} text-nd_gray-400 tracking-wide`}>
                  {"DESTINATION"->React.string}
                </p>
              </div>
              <div className="flex items-stretch gap-3">
                <div
                  className="flex-1 min-w-0 flex items-center gap-2.5 border border-nd_gray-150 bg-nd_gray-50 rounded-lg px-3">
                  <GatewayIcon
                    gateway={connectorInfo.connector_name->String.toUpperCase}
                    className="w-6 h-6 shrink-0"
                  />
                  <p className="truncate min-w-0">
                    <span className={`${body.sm.semibold} text-nd_gray-700`}>
                      {ConnectorUtils.getDisplayNameForConnector(
                        connectorInfo.connector_name,
                      )->React.string}
                    </span>
                    <span className={`${body.sm.regular} text-nd_gray-400`}>
                      {` · ${sourceProfileName}`->React.string}
                    </span>
                  </p>
                </div>
                <div className="w-4 shrink-0 self-center flex justify-center">
                  <Icon name="nd-arrow-right" size=16 className="text-nd_gray-400" />
                </div>
                <div className="flex-1 min-w-0">
                  <ReactFinalForm.Field
                    name="destination_profile_id"
                    render={({input}) =>
                      <SelectBoxAdapter
                        input
                        options=destinationOptions
                        buttonText="Select a profile"
                        allowMultiSelect=false
                        deselectDisable=true
                        fullLength=true
                        buttonSize=Button.Medium
                      />}
                  />
                </div>
              </div>
            </div>
            <FormRenderer.FieldRenderer
              field={labelField}
              fieldWrapperClass="flex flex-col gap-2"
              labelPadding="pb-0"
              labelTextStyleClass={`${body.sm.semibold} text-nd_gray-700`}
            />
            <hr className="border-nd_gray-150" />
            <div className="flex flex-col gap-3">
              <p className={`${body.sm.semibold} text-nd_gray-400 tracking-wide`}>
                {"INCLUDED IN THE CLONE"->React.string}
              </p>
              <div className="flex flex-wrap gap-2">
                {["Credentials", "Webhook", "Payment methods", "Label"]
                ->Array.map(item =>
                  <TagBinding
                    key=item
                    text=item
                    variant=Subtle
                    color=Success
                    shape=Squarical
                    size=Xs
                    leftSlot={<Icon name="nd-check" size=12 className="text-nd_green-600" />}
                  />
                )
                ->React.array}
              </div>
              <p className={`${body.sm.regular} text-nd_gray-500`}>
                {"Not copied: "->React.string}
                <span className={`${body.sm.semibold} text-nd_gray-600`}>
                  {"wallet, FRM & external auth"->React.string}
                </span>
                {". Review after cloning"->React.string}
              </p>
            </div>
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
