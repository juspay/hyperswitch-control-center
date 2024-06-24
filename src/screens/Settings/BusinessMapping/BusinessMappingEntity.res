open HSwitchSettingTypes
open BusinessMappingUtils

module ProfileActions = {
  @react.component
  let make = (~defaultProfileName, ~profileId) => {
    open APIUtils
    let getURL = useGetURL()
    let updateDetails = useUpdateMethod()
    let showToast = ToastState.useShowToast()
    let (showModal, setShowModal) = React.useState(_ => false)
    let (businessProfiles, setBusinessProfiles) = Recoil.useRecoilState(
      HyperswitchAtom.businessProfilesAtom,
    )
    let initialValues = [("profile_name", defaultProfileName->JSON.Encode.string)]->Dict.fromArray

    let onSubmit = async (values, _) => {
      try {
        let url = getURL(~entityName=BUSINESS_PROFILE, ~methodType=Post, ~id=Some(profileId), ())
        let res = await updateDetails(url, values, Post, ())
        let filteredProfileList =
          businessProfiles
          ->Array.filter(businessProfile => businessProfile.profile_id !== profileId)
          ->Array.concat([res->BusinessProfileMapper.businessProfileTypeMapper])

        setBusinessProfiles(._ => filteredProfileList)
        showToast(~message="Updated profile name!", ~toastType=ToastSuccess, ())
      } catch {
      | _ => showToast(~message="Failed to update profile name!", ~toastType=ToastError, ())
      }
      setShowModal(_ => false)
      Nullable.null
    }

    let businessName = FormRenderer.makeFieldInfo(
      ~label="Profile Name",
      ~name="profile_name",
      ~placeholder=`Eg: Hyperswitch`,
      ~customInput=InputFields.textInput(),
      ~isRequired=true,
      (),
    )

    <div className="flex gap-4 items-center">
      <ToolTip
        description="Edit profile name"
        toolTipFor={<Icon
          name="pencil-alt"
          size=14
          className="cursor-pointer"
          onClick={_ => setShowModal(_ => true)}
        />}
        toolTipPosition=ToolTip.Top
        contentAlign={Left}
      />
      <ToolTip
        description="Copy profile Id"
        toolTipFor={<Icon
          name="copy-code"
          size=20
          className="cursor-pointer"
          onClick={_ => {
            Clipboard.writeText(profileId)
            showToast(~message="Copied to Clipboard!", ~toastType=ToastSuccess, ())
          }}
        />}
        toolTipPosition=ToolTip.Top
        contentAlign={Left}
      />
      <Modal
        key=defaultProfileName
        modalHeading="Edit Profile name"
        showModal
        setShowModal
        modalClass="w-1/4 m-auto">
        <Form initialValues={initialValues->JSON.Encode.object} onSubmit>
          <div className="flex flex-col gap-12 h-full w-full">
            <FormRenderer.DesktopRow>
              <FormRenderer.FieldRenderer
                fieldWrapperClass="w-full"
                field={businessName}
                labelClass="!text-black font-medium !-ml-[0.5px]"
              />
            </FormRenderer.DesktopRow>
            <div className="flex justify-end w-full pr-5 pb-3">
              <FormRenderer.SubmitButton text="Submit changes" buttonSize={Small} />
            </div>
          </div>
        </Form>
      </Modal>
    </div>
  }
}

type columns =
  | ProfileName
  | ProfileId
  | Action

let visibleColumns = [ProfileId, ProfileName, Action]

let defaultColumns = [ProfileId, ProfileName, Action]

let allColumns = [ProfileId, ProfileName, Action]

let getHeading = colType => {
  switch colType {
  | ProfileId => Table.makeHeaderInfo(~key="profile_id", ~title="Profile Id", ~showSort=true, ())
  | ProfileName =>
    Table.makeHeaderInfo(~key="profile_name", ~title="Profile Name", ~showSort=true, ())
  | Action => Table.makeHeaderInfo(~key="action", ~title="Action", ~showSort=false, ())
  }
}

let getCell = (item: profileEntity, colType): Table.cell => {
  switch colType {
  | ProfileId => Text(item.profile_id)
  | ProfileName => Text(item.profile_name)
  | Action =>
    CustomCell(
      <ProfileActions defaultProfileName={item.profile_name} profileId={item.profile_id} />,
      "",
    )
  }
}

let itemToObjMapper = dict => {
  open LogicUtils
  {
    profile_id: getString(dict, "profile_id", ""),
    profile_name: getString(dict, ProfileName->getStringFromVariant, ""),
    merchant_id: getString(dict, "merchant_id", ""),
    return_url: getOptionString(dict, "return_url"),
    payment_response_hash_key: getOptionString(dict, "payment_response_hash_key"),
    webhook_details: dict
    ->getObj("webhook_details", Dict.make())
    ->BusinessProfileMapper.constructWebhookDetailsObject,
    authentication_connector_details: dict
    ->getObj("webhook_details", Dict.make())
    ->BusinessProfileMapper.constructAuthConnectorObject,
    collect_shipping_details_from_wallet_connector: getOptionBool(
      dict,
      "collect_shipping_details_from_wallet_connector",
    ),
  }
}

let getItems: JSON.t => array<profileEntity> = json => {
  LogicUtils.getArrayDataFromJson(json, itemToObjMapper)
}

let businessProfileTableEntity = EntityType.makeEntity(
  ~uri="",
  ~getObjects=getItems,
  ~defaultColumns,
  ~allColumns,
  ~getHeading,
  ~dataKey="",
  ~getCell,
  (),
)
