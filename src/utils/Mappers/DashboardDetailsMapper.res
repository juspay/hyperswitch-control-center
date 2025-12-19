open LogicUtils
open ReconUtils

let getDashboardDetails = (
  values: JSON.t,
  ~version=UserInfoTypes.V1,
): HyperswitchAtom.dashboardDetails => {
  let valuesDict = values->getDictFromJsonObject

  {
    recon_status: getString(valuesDict, "recon_status", "")->mapStringToReconStatus,
    product_type: getString(
      valuesDict,
      "product_type",
      "",
    )->ProductUtils.getProductVariantFromString(~version),
  }
}
