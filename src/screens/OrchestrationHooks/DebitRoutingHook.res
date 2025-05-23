open APIUtils
open ToastState

let useDebitRoutingUpdate = () => {
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let showToast = useShowToast()
  let businessProfileRecoilVal =
    HyperswitchAtom.businessProfileFromIdAtom->Recoil.useRecoilValueFromAtom
  let setBusinessProfile = HyperswitchAtom.businessProfileFromIdAtom->Recoil.useSetRecoilState

  async (~isEnabled) => {
    try {
      let url = getURL(
        ~entityName=V1(BUSINESS_PROFILE),
        ~methodType=Post,
        ~id=Some(businessProfileRecoilVal.profile_id),
      )
      let body =
        [
          ("is_debit_routing_enabled", isEnabled->JSON.Encode.bool),
        ]->LogicUtils.getJsonFromArrayOfJson
      let _ = await updateDetails(url, body, Post)
      showToast(
        ~message=`Successfully ${isEnabled ? "added" : "deactivated"} configuration`,
        ~toastType=ToastSuccess,
      )
      setBusinessProfile(prev => {...prev, is_debit_routing_enabled: Some(isEnabled)})
    } catch {
    | _ =>
      showToast(
        ~message=`Failed to ${isEnabled ? "add" : "deactivate"} configuration`,
        ~toastType=ToastError,
      )
    }
  }
}
