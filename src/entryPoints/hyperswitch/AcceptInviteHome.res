@react.component
let make = () => {
  open APIUtils
  let updateDetails = useUpdateMethod()
  let showToast = ToastState.useShowToast()
  let (showModal, setShowModal) = React.useState(_ => false)
  let switchMerchantListValue = Recoil.useRecoilValueFromAtom(
    HyperswitchAtom.switchMerchantListAtom,
  )
  let (merchantListValue, setMerchantListValue) = React.useState(_ => [])
  let (acceptedMerchantId, setAcceptedMerchantId) = React.useState(_ => [])

  React.useEffect1(() => {
    let filteredSwitchMerchantList = switchMerchantListValue->Array.filter(ele => !ele.is_active)
    setMerchantListValue(_ => filteredSwitchMerchantList)
    setAcceptedMerchantId(_ => Array.make(~length=filteredSwitchMerchantList->Array.length, false))
    None
  }, [switchMerchantListValue])

  let acceptInvite = async _ => {
    try {
      let url = getURL(~entityName=USERS, ~userType=#ACCEPT_INVITE, ~methodType=Post, ())
      let merchantIds = acceptedMerchantId->Array.reduceWithIndex([], (acc, ele, index) => {
        ele
          ? acc->Array.push(
              (
                merchantListValue->Array.get(index)->Option.getOr(SwitchMerchantUtils.defaultValue)
              ).merchant_id->JSON.Encode.string,
            )
          : ()
        acc
      })

      let body =
        [
          ("merchant_ids", merchantIds->JSON.Encode.array),
          ("need_dashboard_entry_response", false->JSON.Encode.bool),
        ]->LogicUtils.getJsonFromArrayOfJson
      let _ = await updateDetails(url, body, Post, ())
      showToast(~toastType=ToastSuccess, ~message="Invite Accepted Successfully", ())
    } catch {
    | _ => ()
    }
    setShowModal(_ => false)
  }

  switch merchantListValue->Array.length {
  | 0 => React.null
  | 1 => {
      let merchantValue =
        merchantListValue->Array.get(0)->Option.getOr(SwitchMerchantUtils.defaultValue)
      let listOfMerchantId = [merchantValue.merchant_id->JSON.Encode.string]

      <div className="w-full bg-white px-6 py-3 flex items-center justify-between">
        <div className="flex items-center gap-3">
          <Icon size=40 name="group-users-without-circle" />
          <div>
            {`You've been invited to the Hyperswitch dashboard by `->React.string}
            <span className="font-bold"> {merchantValue.merchant_name->React.string} </span>
          </div>
        </div>
        <Button
          text="Accept"
          buttonType={PrimaryOutline}
          customButtonStyle="!p-2"
          onClick={_ => acceptInvite(listOfMerchantId)->ignore}
        />
      </div>
    }
  | _ =>
    <div className="w-full bg-white px-6 py-3 flex items-center justify-between">
      <div className="flex items-center gap-3">
        <Icon size=40 name="group-users-without-circle" />
        <div>
          {`You have `->React.string}
          <span className="font-bold"> {merchantListValue->Array.length->React.int} </span>
          <span> {` Pending Invites`->React.string} </span>
        </div>
      </div>
      <Button
        text="View Invitations"
        buttonType=SecondaryFilled
        customButtonStyle="!p-2"
        onClick={_ => setShowModal(_ => true)}
      />
      <Modal
        showModal
        setShowModal
        paddingClass=""
        closeOnOutsideClick=true
        modalHeading="Pending Invitations"
        modalHeadingDescription="Please accept your pending merchant invitations"
        modalClass="w-1/2 m-auto !bg-white"
        childClass="my-5 mx-4 overflow-scroll !h-[35%]">
        <div className="flex flex-col gap-4">
          <div className="flex flex-col gap-10">
            {merchantListValue
            ->Array.mapWithIndex((ele, index) => {
              <div
                className="w-full bg-white p-6 flex items-center justify-between border-2 rounded-xl">
                <div className="flex items-center gap-3">
                  <Icon size=40 name="group-users-without-circle" />
                  <div>
                    {`You've been invited to the Hyperswitch dashboard by `->React.string}
                    <span className="font-bold"> {ele.merchant_name->React.string} </span>
                  </div>
                </div>
                <UIUtils.RenderIf
                  condition={!(acceptedMerchantId->Array.get(index)->Option.getOr(false))}>
                  <Button
                    text="Accept"
                    buttonType={PrimaryOutline}
                    customButtonStyle="!p-2"
                    onClick={_ =>
                      setAcceptedMerchantId(_ =>
                        acceptedMerchantId->Array.mapWithIndex((ele, i) => index === i ? true : ele)
                      )}
                  />
                </UIUtils.RenderIf>
                <UIUtils.RenderIf
                  condition={acceptedMerchantId->Array.get(index)->Option.getOr(false)}>
                  <div className="flex items-center gap-1 text-green-accepted_green_800">
                    <Icon name="green-tick-without-background" />
                    {"Accepted"->React.string}
                  </div>
                </UIUtils.RenderIf>
              </div>
            })
            ->React.array}
          </div>
          <div className="flex items-center justify-center">
            <Button
              text="Accept Invites"
              buttonType={Primary}
              customButtonStyle="!w-fit"
              onClick={_ => acceptInvite()->ignore}
              buttonState={acceptedMerchantId->Array.find(ele => ele)->Option.getOr(false)
                ? Normal
                : Disabled}
            />
          </div>
        </div>
      </Modal>
    </div>
  }
}
