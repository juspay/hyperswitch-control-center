module InviteForMultipleInvitation = {
  @react.component
  let make = (
    ~pendingInvites: array<PreLoginTypes.invitationResponseType>,
    ~acceptInvite,
    ~acceptInviteOnClick,
    ~acceptedInvites: array<PreLoginTypes.invitationResponseType>,
    ~showModal,
    ~setShowModal,
  ) => {
    let checkIfInvitationAccepted = (entityId, entityType: UserInfoTypes.entity) => {
      acceptedInvites->Array.find(value =>
        value.entityId === entityId && value.entityType === entityType
      )
    }

    <div className="w-full bg-white px-6 py-3 flex items-center justify-between">
      <div className="flex items-center gap-3">
        <Icon size=40 name="group-users-without-circle" />
        <div>
          {`You have `->React.string}
          <span className="font-bold"> {pendingInvites->Array.length->React.int} </span>
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
        onCloseClickCustomFun={_ => ()}
        modalHeading="Pending Invitations"
        modalHeadingDescription="Please accept your pending merchant invitations"
        modalClass="w-1/2 m-auto !bg-white"
        childClass="my-5 mx-4 overflow-scroll !h-[35%]">
        <div className="flex flex-col gap-4">
          <div className="flex flex-col gap-10">
            {pendingInvites
            ->Array.mapWithIndex((ele, index) => {
              <div
                className="w-full bg-white p-6 flex items-center justify-between border-1 rounded-xl !shadow-[0_2px_4px_0_rgba(0,0,0,_0.05)]"
                key={index->Int.toString}>
                <div className="flex items-center justify-between w-full">
                  <div className="flex items-center gap-3">
                    <Icon size=40 name="group-users-without-circle" />
                    <div>
                      {`You've been invited to the Hyperswitch dashboard by `->React.string}
                      <span className="font-bold"> {ele.entityId->React.string} </span>
                    </div>
                  </div>
                  {switch checkIfInvitationAccepted(ele.entityId, ele.entityType) {
                  | Some(_) =>
                    <div className="flex items-center gap-1 text-green-accepted_green_800">
                      <Icon name="green-tick-without-background" />
                      {"Accepted"->React.string}
                    </div>
                  | None =>
                    <Button
                      text="Accept"
                      buttonType={PrimaryOutline}
                      customButtonStyle="!p-2"
                      onClick={_ => acceptInviteOnClick(ele)->ignore}
                    />
                  }}
                </div>
              </div>
            })
            ->React.array}
          </div>
          <div className="flex items-center justify-center">
            <Button
              text="Accept Invites"
              buttonType={Primary}
              customButtonStyle="!w-fit"
              onClick={_ => {
                acceptInvite(acceptedInvites)->ignore
              }}
              buttonState={acceptedInvites->Array.length > 0 ? Normal : Disabled}
            />
          </div>
        </div>
      </Modal>
    </div>
  }
}

module InviteForSingleInvitation = {
  @react.component
  let make = (~pendingInvites, ~acceptInvite, ~acceptInviteOnClick) => {
    open LogicUtils

    let inviteValue =
      pendingInvites->getValueFromArray(0, Dict.make()->PreLoginUtils.itemToObjectMapper)

    let onAccptClick = async () => {
      let acceptedInvitesArray = acceptInviteOnClick(inviteValue)
      acceptInvite(acceptedInvitesArray)->ignore
    }

    <div className="w-full bg-white px-6 py-3 flex items-center justify-between">
      <div className="flex items-center gap-3">
        <Icon size=40 name="group-users-without-circle" />
        <div>
          {`You've been invited to the Hyperswitch dashboard by `->React.string}
          <span className="font-bold"> {inviteValue.entityId->React.string} </span>
          {` as `->React.string}
          <span className="font-bold"> {inviteValue.roleId->React.string} </span>
        </div>
      </div>
      <Button
        text="Accept"
        buttonType={PrimaryOutline}
        customButtonStyle="!p-2"
        onClick={_ => onAccptClick()->ignore}
      />
    </div>
  }
}
@react.component
let make = () => {
  open APIUtils
  open LogicUtils
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let (showModal, setShowModal) = React.useState(_ => false)
  let showToast = ToastState.useShowToast()
  let fetchDetails = useGetMethod()
  let (pendingInvites, setPendingInvites) = React.useState(_ => [])
  let (acceptedInvites, setAcceptedInvites) = React.useState(_ => [])

  let getListOfMerchantIds = async () => {
    try {
      let url = getURL(~entityName=USERS, ~userType=#LIST_INVITATION, ~methodType=Get)
      let listOfMerchants = await fetchDetails(url)
      setPendingInvites(_ =>
        listOfMerchants->getArrayDataFromJson(PreLoginUtils.itemToObjectMapper)
      )
    } catch {
    | _ => showToast(~message="Failed to fetch pending invitations!", ~toastType=ToastError)
    }
  }

  let acceptInvite = async acceptedInvitesArray => {
    try {
      let url = getURL(~entityName=USERS, ~userType=#ACCEPT_INVITATION_HOME, ~methodType=Post)

      let body =
        acceptedInvitesArray
        ->Array.map((value: PreLoginTypes.invitationResponseType) => {
          let acceptedinvite: PreLoginTypes.acceptInviteRequest = {
            entity_id: value.entityId,
            entity_type: (value.entityType :> string)->String.toLowerCase,
          }

          acceptedinvite
        })
        ->Identity.genericTypeToJson

      let _ = await updateDetails(url, body, Post)
      setShowModal(_ => false)
      let _ = await getListOfMerchantIds()
    } catch {
    | _ => ()
    }
  }

  let acceptInviteOnClick = ele => {
    let acceptedInvitesArray = [...acceptedInvites, ele]
    setAcceptedInvites(_ => acceptedInvitesArray)
    acceptedInvitesArray
  }

  React.useEffect(() => {
    getListOfMerchantIds()->ignore
    None
  }, [])

  <RenderIf condition={pendingInvites->Array.length !== 0}>
    <RenderIf condition={pendingInvites->Array.length === 1}>
      <InviteForSingleInvitation pendingInvites acceptInvite acceptInviteOnClick />
    </RenderIf>
    <RenderIf condition={pendingInvites->Array.length > 1}>
      <InviteForMultipleInvitation
        pendingInvites acceptInvite acceptInviteOnClick acceptedInvites showModal setShowModal
      />
    </RenderIf>
  </RenderIf>
}
