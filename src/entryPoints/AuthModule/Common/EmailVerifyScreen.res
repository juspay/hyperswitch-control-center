@react.component
let make = (~errorMessage, ~onClick, ~trasitionMessage) => {
  <HSwitchUtils.BackgroundImageWrapper customPageCss="font-semibold md:text-3xl p-16">
    {if errorMessage->String.length !== 0 {
      <div className="flex flex-col justify-between gap-32 flex items-center justify-center h-2/3">
        <Icon
          name="hyperswitch-text-icon"
          size=40
          className="cursor-pointer w-60"
          parentClass="flex flex-col justify-center items-center bg-white"
        />
        <div className="flex flex-col justify-between items-center gap-12 ">
          <img src={`/assets/WorkInProgress.svg`} />
          <div
            className={`leading-4 ml-1 mt-2 text-center flex items-center flex-col gap-6 w-full md:w-133 flex-wrap`}>
            <div className="flex gap-2.5 items-center">
              <Icon name="exclamation-circle" size=22 className="fill-red-500 mr-1.5" />
              <p className="text-fs-20 font-bold text-white">
                {React.string("Invalid Link or session expired")}
              </p>
            </div>
            <p className="text-fs-14 text-white opacity-60 font-semibold ">
              {"It appears that the link you were trying to access has expired or is no longer valid. Please try again ."->React.string}
            </p>
          </div>
          <Button
            text="Go back to login"
            buttonType={Primary}
            buttonSize={Small}
            customButtonStyle="cursor-pointer cursor-pointer w-5 rounded-md"
            onClick={_ => onClick()}
          />
        </div>
      </div>
    } else {
      <div className="h-full w-full flex justify-center items-center text-white opacity-90">
        {trasitionMessage->React.string}
      </div>
    }}
  </HSwitchUtils.BackgroundImageWrapper>
}
