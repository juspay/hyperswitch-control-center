@react.component
let make = () => {
  open APIUtils
  open LogicUtils
  open PreLoginTypes
  open HSwitchUtils

  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let updateDetails = useUpdateMethod()
  let textHeadingClass = getTextClass((H2, Optional))
  let textSubHeadingClass = getTextClass((P1, Regular))
  let {setAuthStatus} = React.useContext(AuthInfoProvider.authStatusContext)
  let (acceptedInvites, setAcceptedInvites) = React.useState(_ => [])
  let (pendindInvites, setPendingInvites) = React.useState(_ => [])
  let handleLogout = useHandleLogout()

  let getListOfMerchantIds = async () => {
    try {
      let url = getURL(~entityName=V1(USERS), ~userType=#LIST_INVITATION, ~methodType=Get)
      let listOfMerchants = await fetchDetails(url)
      setPendingInvites(_ =>
        listOfMerchants->getArrayDataFromJson(PreLoginUtils.itemToObjectMapper)
      )
    } catch {
    | _ => setAuthStatus(LoggedOut)
    }
  }

  React.useEffect(() => {
    getListOfMerchantIds()->ignore
    None
  }, [])
  let acceptInviteOnClick = ele => setAcceptedInvites(_ => [...acceptedInvites, ele])

  let checkIfInvitationAccepted = (entityId, entityType: UserInfoTypes.entity) => {
    acceptedInvites->Array.find(value =>
      value.entityId === entityId && value.entityType === entityType
    )
  }

  let onClickLoginToDashboard = async () => {
    open AuthUtils
    try {
      let url = getURL(
        ~entityName=V1(USERS),
        ~userType=#ACCEPT_INVITATION_PRE_LOGIN,
        ~methodType=Post,
      )

      let body =
        acceptedInvites
        ->Array.map(value => {
          let acceptedinvite: acceptInviteRequest = {
            entity_id: value.entityId,
            entity_type: (value.entityType :> string)->String.toLowerCase,
          }

          acceptedinvite
        })
        ->Identity.genericTypeToJson

      let res = await updateDetails(url, body, Post)
      setAuthStatus(PreLogin(getPreLoginInfo(res)))
    } catch {
    | _ => setAcceptedInvites(_ => [])
    }
  }

  <BackgroundImageWrapper>
    <div className="h-full w-full flex flex-col gap-4 items-center justify-center p-6">
      <div className="bg-white h-35-rem w-200 rounded-2xl">
        <div className="p-6 border-b-2">
          <img alt="logo-with-text" src={`assets/Dark/hyperswitchLogoIconWithText.svg`} />
        </div>
        <div className="p-6 flex flex-col gap-2">
          <p className={`${textHeadingClass} text-grey-900`}>
            {"Hey there, welcome to Hyperswitch!"->React.string}
          </p>
          <p className=textSubHeadingClass>
            {"Please accept the your pending invitations"->React.string}
          </p>
        </div>
        <div className="h-[50%] overflow-auto show-scrollbar flex flex-col gap-10 p-8">
          {pendindInvites
          ->Array.mapWithIndex((ele, index) => {
            <div
              key={index->string_of_int}
              className="border-1 flex items-center justify-between rounded-xl">
              <div className="flex items-center gap-5">
                <Icon size=40 name="group-users" />
                <div>
                  {`You've been invited to the Hyperswitch dashboard by `->React.string}
                  <span className="font-bold"> {{ele.entityId}->React.string} </span>
                  {` as `->React.string}
                  <span className="font-bold"> {{ele.roleId}->React.string} </span>
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
                  onClick={_ => acceptInviteOnClick(ele)}
                />
              }}
            </div>
          })
          ->React.array}
        </div>
        <div className="w-full flex items-center justify-center mt-4">
          <Button
            text="Login to Dashboard"
            buttonType={Primary}
            onClick={_ => onClickLoginToDashboard()->ignore}
            buttonState={acceptedInvites->Array.length > 0 ? Normal : Disabled}
          />
        </div>
      </div>
      <div className="text-grey-200 flex gap-2">
        {"Log in with a different account?"->React.string}
        <p
          className="underline cursor-pointer underline-offset-2 hover:text-blue-700"
          onClick={_ => handleLogout()->ignore}>
          {"Click here to log out."->React.string}
        </p>
      </div>
    </div>
  </BackgroundImageWrapper>
}
