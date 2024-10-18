open HSwitchSettingTypes
open BusinessMappingUtils

module OrganizationActions = {
  @react.component
  let make = (~defaultOrganizationName, ~profileId) => {
    open APIUtils
    let getURL = useGetURL()
    let updateDetails = useUpdateMethod()
    let showToast = ToastState.useShowToast()
    let (showModal, setShowModal) = React.useState(_ => false)
    let (businessOrganizations, setBusinessOrganizations) = Recoil.useRecoilState(
      HyperswitchAtom.orgListAtom,
    )
    let initialValues =
      [("profile_name", defaultOrganizationName->JSON.Encode.string)]->Dict.fromArray

    let onSubmit = async (values, _) => {
      try {
        let url = getURL(~entityName=BUSINESS_PROFILE, ~methodType=Post, ~id=Some(profileId))
        let res = await updateDetails(url, values, Post)
        let filteredOrganizationList =
          businessOrganizations
          ->Array.filter(businessOrganization => businessOrganization.id !== profileId)
          ->Array.concat([res->BusinessProfileMapper.businessProfileTypeMapper])

        setBusinessOrganizations(_ => filteredOrganizationList)
        showToast(~message="Updated profile name!", ~toastType=ToastSuccess)
      } catch {
      | _ => showToast(~message="Failed to update profile name!", ~toastType=ToastError)
      }
      setShowModal(_ => false)
      Nullable.null
    }

    let businessName = FormRenderer.makeFieldInfo(
      ~label="Organization Name",
      ~name="profile_name",
      ~placeholder=`Eg: Hyperswitch`,
      ~customInput=InputFields.textInput(),
      ~isRequired=true,
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
            showToast(~message="Copied to Clipboard!", ~toastType=ToastSuccess)
          }}
        />}
        toolTipPosition=ToolTip.Top
        contentAlign={Left}
      />
      <Modal
        key=defaultOrganizationName
        modalHeading="Edit Organization name"
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
  | OrganizationName
  | OrganizationId
  | Action

let visibleColumns = [OrganizationId, OrganizationName, Action]

let defaultColumns = [OrganizationId, OrganizationName, Action]

let allColumns = [OrganizationId, OrganizationName, Action]

let getHeading = colType => {
  switch colType {
  | OrganizationId => Table.makeHeaderInfo(~key="id", ~title="Organization Id")
  | OrganizationName => Table.makeHeaderInfo(~key="profile_name", ~title="Organization Name")
  | Action => Table.makeHeaderInfo(~key="action", ~title="Action")
  }
}

let getCell = (item: profileEntity, colType): Table.cell => {
  switch colType {
  | OrganizationId => Text(item.id)
  | OrganizationName => Text(item.profile_name)
  | Action =>
    CustomCell(
      <OrganizationActions defaultOrganizationName={item.profile_name} profileId={item.id} />,
      "",
    )
  }
}

let itemToObjMapper = dict => {
  open LogicUtils
  {
    id: getString(dict, "id", ""),
    profile_name: getString(dict, OrganizationName->getStringFromVariant, ""),
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
    always_collect_shipping_details_from_wallet_connector: dict->getOptionBool(
      "always_collect_shipping_details_from_wallet_connector",
    ),
    collect_billing_details_from_wallet_connector: dict->getOptionBool(
      "collect_billing_details_from_wallet_connector",
    ),
    always_collect_billing_details_from_wallet_connector: dict->getOptionBool(
      "always_collect_billing_details_from_wallet_connector",
    ),
    outgoing_webhook_custom_http_headers: None,
    is_connector_agnostic_mit_enabled: None,
    is_auto_retries_enabled: dict->getOptionBool("is_auto_retries_enabled"),
    max_auto_retries_enabled: dict->getOptionInt("max_auto_retries_enabled"),
  }
}

let getItems: JSON.t => array<profileEntity> = json => {
  LogicUtils.getArrayDataFromJson(json, itemToObjMapper)
}

let businessOrganizationTableEntity = EntityType.makeEntity(
  ~uri="",
  ~getObjects=getItems,
  ~defaultColumns,
  ~allColumns,
  ~getHeading,
  ~dataKey="",
  ~getCell,
)
