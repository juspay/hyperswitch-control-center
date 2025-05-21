module BulletItem = {
  @react.component
  let make = (~number, ~textElement) => {
    open Typography
    <div className="flex gap-4 items-center ">
      <div
        className={`${body.md.semibold} text-nd_gray-600 bg-nd_gray-150 rounded-full w-6 h-6 flex items-center justify-center flex-shrink-0`}>
        {number->React.string}
      </div>
      textElement
    </div>
  }
}

@react.component
let make = (~showModal, ~setShowModal) => {
  open Typography
  open APIUtils
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let showToast = ToastState.useShowToast()
  let businessProfileRecoilVal =
    HyperswitchAtom.businessProfileFromIdAtom->Recoil.useRecoilValueFromAtom

  let updateBusinessProfileDetails = async () => {
    try {
      let url = getURL(
        ~entityName=V1(BUSINESS_PROFILE),
        ~methodType=Post,
        ~id=Some(businessProfileRecoilVal.profile_id),
      )
      let body = Dict.make()
      body->Dict.set("is_debit_routing_enabled", true->JSON.Encode.bool)
      let _ = await updateDetails(url, body->Identity.genericTypeToJson, Post)
      setShowModal(_ => false)
      showToast(~message=`Successfully added configuration`, ~toastType=ToastState.ToastSuccess)
      await HyperSwitchUtils.delay(1000)
      Window.Location.hardReload(true)
    } catch {
    | _ => showToast(~message=`Failed to add configuration`, ~toastType=ToastState.ToastError)
    }
  }

  <Modal
    showModal
    setShowModal
    modalHeading="Enable Least Cost Routing Configuration"
    modalHeadingClass={`${heading.sm.semibold}`}
    modalClass="w-1/3 m-auto"
    childClass="p-0"
    modalHeadingDescriptionElement={<div className={`${body.md.medium} text-nd_gray-400 mt-2`}>
      {"Optimize processing fees on debit payments by routing traffic to the cheapest network"->React.string}
    </div>}
    borderBottom=true>
    <div className="flex flex-col h-full w-full p-3 m-3">
      <span className={`${body.md.medium} text-nd_gray-500 mb-4`}>
        {"Before you proceed, please ensure the following are in place:"->React.string}
      </span>
      <div className="flex flex-col gap-4">
        <BulletItem
          number="1"
          textElement={<div className={`${body.md.medium} text-nd_gray-600`}>
            <span className={body.md.semibold}> {"Adyen"->React.string} </span>
            {" is added as one of your payment processors."->React.string}
          </div>}
        />
        <BulletItem
          number="2"
          textElement={<div className={`${body.md.medium} text-nd_gray-600`}>
            <span className={body.md.semibold}> {"Debit card"->React.string} </span>
            {" is enabled in your Adyen configuration."->React.string}
          </div>}
        />
        <BulletItem
          number="3"
          textElement={<div className={`${body.md.medium} text-nd_gray-600`}>
            <span className={body.md.semibold}> {"Local networks"->React.string} </span>
            {" are configured under the debit card settings."->React.string}
          </div>}
        />
      </div>
      <div className="flex justify-end gap-4 p-4 mt-4 bg-white ">
        <Button
          text="Cancel"
          buttonType=Secondary
          onClick={_ => setShowModal(_ => false)}
          buttonSize=Small
        />
        <Button
          text="Enable"
          buttonType=Primary
          onClick={_ => updateBusinessProfileDetails()->ignore}
          buttonSize=Small
        />
      </div>
    </div>
  </Modal>
}
