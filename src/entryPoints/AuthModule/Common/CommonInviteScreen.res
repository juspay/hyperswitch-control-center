@react.component
let make = (~merchantData, ~acceptInviteOnClick, ~onClickLoginToDashboard) => {
  open HSwitchUtils
  open LogicUtils

  let textHeadingClass = getTextClass((H2, Optional))
  let textSubHeadingClass = getTextClass((P1, Regular))

  let isAtleastOneAccept = React.useMemo1(() => {
    merchantData
    ->Array.find(ele => {
      let merchantDataDict = ele->getDictFromJsonObject
      merchantDataDict->getBool("is_active", false) === true
    })
    ->Option.getOr(JSON.Encode.null)
    ->getDictFromJsonObject
    ->getBool("is_active", false)
  }, [merchantData])

  <BackgroundImageWrapper>
    <div className="h-full w-full flex items-center justify-center p-6">
      <div className="bg-white h-35-rem w-200 rounded-2xl">
        <div className="p-6 border-b-2">
          <img src={`assets/Dark/hyperswitchLogoIconWithText.svg`} />
        </div>
        <div className="p-6 flex flex-col gap-2">
          <p className={`${textHeadingClass} text-grey-900`}>
            {"Hey there, welcome to Hyperswitch!"->React.string}
          </p>
          <p className=textSubHeadingClass>
            {"Please accept the your pending invitations"->React.string}
          </p>
        </div>
        <div className="h-[50%] overflow-auto show-scrollbar">
          {merchantData
          ->Array.mapWithIndex((ele, index) => {
            let merchantId = ele->getDictFromJsonObject->getString("merchant_id", "")
            let merchantName = ele->getDictFromJsonObject->getString("merchant_name", "")
            let isActive = ele->getDictFromJsonObject->getBool("is_active", false)

            <div
              key={index->string_of_int}
              className="border-1 m-6 p-5 flex items-center justify-between rounded-xl">
              <div className="flex items-center gap-5">
                <Icon size=40 name="group-users" />
                <div>
                  {`You've been invited to the Hyperswitch dashboard by `->React.string}
                  <span className="font-bold">
                    {{merchantName->String.length > 0 ? merchantName : merchantId}->React.string}
                  </span>
                </div>
              </div>
              <UIUtils.RenderIf condition={!isActive}>
                <Button
                  text="Accept"
                  buttonType={PrimaryOutline}
                  customButtonStyle="!p-2"
                  onClick={_ => acceptInviteOnClick(index)}
                />
              </UIUtils.RenderIf>
              <UIUtils.RenderIf condition={isActive}>
                <div className="flex items-center gap-1 text-green-accepted_green_800">
                  <Icon name="green-tick-without-background" />
                  {"Accepted"->React.string}
                </div>
              </UIUtils.RenderIf>
            </div>
          })
          ->React.array}
        </div>
        <div className="w-full flex items-center justify-center mt-4">
          <Button
            text="Login to Dashboard"
            buttonType={Primary}
            onClick={_ => onClickLoginToDashboard()->ignore}
            buttonState={isAtleastOneAccept ? Normal : Disabled}
          />
        </div>
      </div>
    </div>
  </BackgroundImageWrapper>
}
