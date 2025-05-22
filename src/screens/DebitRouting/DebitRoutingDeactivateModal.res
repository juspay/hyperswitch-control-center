@react.component
let make = (~showModal, ~setShowModal) => {
  open Typography
  open APIUtils
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let showToast = ToastState.useShowToast()
  let businessProfileRecoilVal =
    HyperswitchAtom.businessProfileFromIdAtom->Recoil.useRecoilValueFromAtom
  let setBusinessProfile = HyperswitchAtom.businessProfileFromIdAtom->Recoil.useSetRecoilState
  let updateBusinessProfileDetails = async () => {
    try {
      let url = getURL(
        ~entityName=V1(BUSINESS_PROFILE),
        ~methodType=Post,
        ~id=Some(businessProfileRecoilVal.profile_id),
      )
      let body = Dict.make()
      body->Dict.set("is_debit_routing_enabled", false->JSON.Encode.bool)
      let _ = await updateDetails(url, body->Identity.genericTypeToJson, Post)
      showToast(
        ~message=`Successfully deactivated configuration`,
        ~toastType=ToastState.ToastSuccess,
      )
      setShowModal(_ => false)
      setBusinessProfile(prev => {...prev, is_debit_routing_enabled: Some(false)})
    } catch {
    | _ =>
      showToast(~message=`Failed to deactivate configuration`, ~toastType=ToastState.ToastError)
    }
  }
  <Modal
    showModal
    setShowModal
    modalHeading="Disable Least Cost Routing Configuration"
    modalHeadingClass={`${heading.sm.semibold}`}
    modalClass="w-1/3 m-auto"
    childClass="p-0"
    modalHeadingDescriptionElement={<div className={`${body.md.medium} text-nd_gray-400 mt-2`}>
      {"Optimize processing fees on debit payments by routing traffic to the cheapest network"->React.string}
    </div>}
    borderBottom=true>
    <div className="flex flex-col h-full w-full p-3 m-3">
      <div className={`${body.md.medium} text-sm text-nd_gray-600`}>
        {"Are you sure you want to deactivate the Least Cost Routing configuration?"->React.string}
      </div>
      <div className="flex justify-end gap-4 p-4 mt-4 bg-white ">
        <Button
          text="Cancel"
          buttonType=Secondary
          onClick={_ => setShowModal(_ => false)}
          buttonSize=Small
        />
        <Button
          text="Deactivate Configuration"
          buttonType=Primary
          onClick={_ => updateBusinessProfileDetails()->ignore}
          buttonSize=Small
        />
      </div>
    </div>
  </Modal>
}
