open HSwitchSettingTypes
open LogicUtils

let getOrganizationDetails = (values: JSON.t) => {
  let values = values->getDictFromJsonObject
  {
    organization_id: values->getString("organization_id", ""),
    organization_name: values->getOptionString("organization_name"),
    organization_type: values->getString("organization_type", "")->OMPSwitchUtils.ompTypeMapper,
  }
}
