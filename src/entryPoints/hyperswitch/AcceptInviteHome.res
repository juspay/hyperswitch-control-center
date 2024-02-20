@react.component
let make = () => {
  open APIUtils
  open UIUtils
  let updateDetails = useUpdateMethod()
  let showToast = ToastState.useShowToast()
  let fetchSwitchMerchantList = SwitchMerchantListHook.useFetchSwitchMerchantList()
  let (showModal, setShowModal) = React.useState(_ => false)
  let switchMerchantListValue = Recoil.useRecoilValueFromAtom(
    HyperswitchAtom.switchMerchantListAtom,
  )
  let (merchantListValue, setMerchantListValue) = React.useState(_ => [])
  let (acceptedMerchantId, setAcceptedMerchantId) = React.useState(_ => [])

  let merchantValueatZeroIndex =
    merchantListValue->Array.get(0)->Option.getOr(SwitchMerchantUtils.defaultValue)

  React.useEffect1(() => {
    let filteredSwitchMerchantList = switchMerchantListValue->Array.filter(ele => !ele.is_active)
    setMerchantListValue(_ => filteredSwitchMerchantList)
    setAcceptedMerchantId(_ => Array.make(~length=filteredSwitchMerchantList->Array.length, false))
    None
  }, [switchMerchantListValue])

  let acceptInvite = async _ => {
    try {
      let url = getURL(~entityName=USERS, ~userType=#ACCEPT_INVITE, ~methodType=Post, ())
      let merchantIds = if merchantListValue->Array.length === 1 {
        [merchantValueatZeroIndex.merchant_id->JSON.Encode.string]
      } else {
        acceptedMerchantId->Array.reduceWithIndex([], (acc, ele, index) => {
          ele
            ? acc->Array.push(
                (
                  merchantListValue
                  ->Array.get(index)
                  ->Option.getOr(SwitchMerchantUtils.defaultValue)
                ).merchant_id->JSON.Encode.string,
              )
            : ()
          acc
        })
      }

      let body =
        [
          ("merchant_ids", merchantIds->JSON.Encode.array),
          ("need_dashboard_entry_response", false->JSON.Encode.bool),
        ]->LogicUtils.getJsonFromArrayOfJson
      let _ = await updateDetails(url, body, Post, ())
      let _ = await fetchSwitchMerchantList()
      showToast(~toastType=ToastSuccess, ~message="Invite Accepted Successfully", ())
      setAcceptedMerchantId(_ => Array.make(~length=merchantListValue->Array.length, false))
    } catch {
    | _ => ()
    }
    setShowModal(_ => false)
  }

  <RenderIf condition={merchantListValue->Array.length !== 0}>
    <RenderIf condition={merchantListValue->Array.length === 1}>
      <div className="w-full bg-white px-6 py-3 flex items-center justify-between">
        <div className="flex items-center gap-3">
          <Icon size=40 name="group-users-without-circle" />
          <div>
            {`You've been invited to the Hyperswitch dashboard by `->React.string}
            <span className="font-bold">
              {merchantValueatZeroIndex.merchant_name->React.string}
            </span>
          </div>
        </div>
        <Button
          text="Accept"
          buttonType={PrimaryOutline}
          customButtonStyle="!p-2"
          onClick={_ => acceptInvite()->ignore}
        />
      </div>
    </RenderIf>
    <RenderIf condition={merchantListValue->Array.length > 1}>
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
          onCloseClickCustomFun={_ =>
            setAcceptedMerchantId(_ => Array.make(~length=merchantListValue->Array.length, false))}
          modalHeading="Pending Invitations"
          modalHeadingDescription="Please accept your pending merchant invitations"
          modalClass="w-1/2 m-auto !bg-white"
          childClass="my-5 mx-4 overflow-scroll !h-[35%]">
          <div className="flex flex-col gap-4">
            <div className="flex flex-col gap-10">
              {merchantListValue
              ->Array.mapWithIndex((ele, index) => {
                <div
                  className="w-full bg-white p-6 flex items-center justify-between border-1 rounded-xl !shadow-[0_2px_4px_0_rgba(0,0,0,_0.05)]">
                  <div className="flex items-center gap-3">
                    <Icon size=40 name="group-users-without-circle" />
                    <div>
                      {`You've been invited to the Hyperswitch dashboard by `->React.string}
                      <span className="font-bold"> {ele.merchant_name->React.string} </span>
                    </div>
                  </div>
                  <RenderIf
                    condition={!(acceptedMerchantId->Array.get(index)->Option.getOr(false))}>
                    <Button
                      text="Accept"
                      buttonType={PrimaryOutline}
                      customButtonStyle="!p-2"
                      onClick={_ =>
                        setAcceptedMerchantId(prev =>
                          prev->Array.mapWithIndex((ele, i) => index === i ? true : ele)
                        )}
                    />
                  </RenderIf>
                  <RenderIf condition={acceptedMerchantId->Array.get(index)->Option.getOr(false)}>
                    <div className="flex items-center gap-1 text-green-accepted_green_800">
                      <Icon name="green-tick-without-background" />
                      {"Accepted"->React.string}
                    </div>
                  </RenderIf>
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
    </RenderIf>
  </RenderIf>
}
