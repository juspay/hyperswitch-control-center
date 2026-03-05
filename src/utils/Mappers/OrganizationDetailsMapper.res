open HSwitchSettingTypes
open LogicUtils

let getOrganizationDetails = (values: JSON.t) => {
  let values = values->getDictFromJsonObject
  {
    organization_id: values->getString("org_id", ""),
    organization_name: values->getString("org_name", ""),
    organization_type: values->getString("org_type", "")->OMPSwitchUtils.ompTypeMapper,
  }
}
