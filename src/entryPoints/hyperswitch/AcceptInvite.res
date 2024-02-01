@react.component
let make = () => {
  open HSwitchUtils

  let merchants = [
    {
      "merchant_id": "merchant_id1",
      "company_name": "Amazon",
      "is_active": false,
    },
    {
      "merchant_id": "merchant_id2",
      "company_name": "Microsoft",
      "is_active": false,
    },
  ]

  let textHeadingClass = getTextClass(~textVariant=H2, ())
  let textSubHeadingClass = getTextClass(~textVariant=P1, ~paragraphTextVariant=Regular, ())

  <BackgroundImageWrapper>
    <div className="h-full w-full flex items-center justify-center">
      <div className="bg-white h-[492px] w-[900px]">
        <div className="p-6 border-b-2">
          <img src={`assets/Dark/hyperswitchLogoIconWithText.svg`} />
        </div>
        <div className="p-6 flex flex-col gap-2">
          <p className={`${textHeadingClass} text-grey-900`}>
            {"Hey there, welcome to Hyperswitch!"->React.string}
          </p>
          <p className={`${textSubHeadingClass}`}>
            {"Please accept the your pending invitations"->React.string}
          </p>
        </div>
        {merchants
        ->Array.mapWithIndex((ele, index) => {
          <div
            key={index->string_of_int}
            className="border-1 m-6 p-5 flex items-center justify-between">
            <div className="flex items-center gap-5">
              <Icon size=40 name="group-users" />
              <div>
                {`You've been invited to the Hyperswitch dashboard by `->React.string}
                <span className="font-bold"> {ele["company_name"]->React.string} </span>
              </div>
            </div>
            <Button text="Accept" buttonType={PrimaryOutline} customButtonStyle="!p-2" />
          </div>
        })
        ->React.array}
      </div>
    </div>
  </BackgroundImageWrapper>
}
