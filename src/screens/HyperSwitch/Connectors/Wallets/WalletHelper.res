module Heading = {
  @react.component
  let make = () => {
    <>
      <div className="flex gap-3 p-2 m-2">
        <Icon name={"applepay"} size=56 />
        <div>
          <div className="flex items-center gap-4">
            <div className="leading-tight font-semibold  font-semibold text-fs-18">
              {"Apple Pay"->React.string}
            </div>
            <div
              className={`flex items-center gap-1 text-sm text-grey-700 font-semibold border  rounded-full px-2 py-1 bg-orange-600/80 border-orange-500`}>
              <div>
                <Icon name={"ellipse-black"} size=4 />
              </div>
              <div> {"Test Mode"->React.string} </div>
            </div>
          </div>
          <div className={`opacity-50 mt-2 text-sm text-hyperswitch_black opacity-50  font-normal`}>
            {"Choose Configuration Method"->React.string}
          </div>
        </div>
      </div>
      <hr className="w-full mt-4" />
    </>
  }
}

module CustomTag = {
  @react.component
  let make = (~tagText="", ~tagSize=5, ~tagLeftIcon=None, ~tagCustomStyle="") => {
    <div
      className={`flex items-center gap-1 shadow shadow-connectorTagShadow border rounded-full px-2 py-1 ${tagCustomStyle}`}>
      {switch tagLeftIcon {
      | Some(icon) =>
        <div>
          <Icon name={icon} size={tagSize} />
        </div>
      | None => React.null
      }}
      <div className={"text-hyperswitch_black text-sm font-medium text-green-960"}>
        {tagText->React.string}
      </div>
    </div>
  }
}

module InfoCard = {
  @react.component
  let make = (~children, ~customInfoStyle="") => {
    <div
      className={`rounded border bg-blue-970 border-blue-960 dark:border-blue-960 relative flex w-full p-6 `}>
      <Icon className=customInfoStyle name="info-circle-unfilled" size=16 />
      <div> {children} </div>
    </div>
  }
}

module Card = {
  @react.component
  let make = (~heading="", ~isSelected=false, ~children: React.element) => {
    <>
      <div
        className={`relative w-full p-6 rounded flex flex-col justify-between border ${isSelected
            ? "bg-light_blue_bg border-blue-800 dark:border-blue-800"
            : ""}`}>
        <div className="flex justify-between">
          <div
            className={`leading-tight font-semibold text-fs-18 ${isSelected
                ? "text-blue-800"
                : "text-hyperswitch_black"} `}>
            {heading->React.string}
          </div>
          <div>
            <RadioIcon isSelected fill="#006DF9" />
          </div>
        </div>
        {children}
      </div>
    </>
  }
}

module CustomSubText = {
  @react.component
  let make = () => {
    <>
      <p> {"Enable Apple Pay for iOS app with the following details:"->React.string} </p>
      <ol className="list-decimal list-inside mt-1">
        <li> {"Payment Processing Certificate from the processor"->React.string} </li>
        <li> {" Apple Pay Merchant ID"->React.string} </li>
        <li> {"Merchant Private Key"->React.string} </li>
      </ol>
    </>
  }
}

module SimplifiedHelper = {
  @react.component
  let make = (
    ~customElement: option<React.element>,
    ~heading="",
    ~stepNumber="1",
    ~subText=None,
  ) => {
    let bgColor = "bg-white"
    let stepColor = "bg-blue-700 text-white py-px px-2"

    <div className={`flex flex-col py-8 px-6 gap-3 ${bgColor} cursor-pointer`}>
      <div className={"flex justify-between "}>
        <div className="flex gap-4">
          <div>
            <p className={`${stepColor} font-medium`}> {stepNumber->React.string} </p>
          </div>
          <div>
            <p className={"font-medium text-base text-blue-800"}> {heading->React.string} </p>
            <UIUtils.RenderIf condition={subText->Belt.Option.isSome}>
              <p
                className={`opacity-50 mt-2 text-base text-hyperswitch_black opacity-50 font-normal`}>
                {subText->Belt.Option.getWithDefault("")->React.string}
              </p>
            </UIUtils.RenderIf>
            {switch customElement {
            | Some(element) => element
            | _ => React.null
            }}
          </div>
        </div>
      </div>
    </div>
  }
}
