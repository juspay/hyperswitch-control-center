@react.component
let make = (
  ~infoText,
  ~buttonText="",
  ~onClickElement=React.null,
  ~onClickUrl="",
  ~paymentModal=false,
  ~setPaymentModal=_ => (),
  ~moduleName,
  ~moduleSubtitle=?,
  ~showRedirectCTA=true,
  ~headerRightButton=React.null,
) => {
  let dummyTableValueDict =
    [
      ("payment_id", "##############"->JSON.Encode.string),
      ("merchant_id", "####"->JSON.Encode.string),
      ("status", "####"->JSON.Encode.string),
      ("amount", "####"->JSON.Encode.string),
      ("amount_capturable", "####"->JSON.Encode.string),
    ]->Dict.fromArray

  let dummyTableValue = Array.make(~length=5, dummyTableValueDict)

  let subTitle = moduleSubtitle->Option.isSome ? moduleSubtitle->Option.getOr("") : ""

  <div className="relative flex flex-col gap-8">
    <div className="flex items-center justify-between ">
      <PageUtils.PageHeading title=moduleName subTitle />
      <div> {headerRightButton} </div>
    </div>
    <div className="blur bg-white p-8">
      {dummyTableValue
      ->Array.mapWithIndex((value, index) => {
        <div className="flex gap-8 my-10 justify-between" key={index->Int.toString}>
          {value
          ->Dict.keysToArray
          ->Array.mapWithIndex((tableVal, ind) =>
            <div className="flex justify-center text-grey-700 opacity-50" key={ind->Int.toString}>
              {value->LogicUtils.getString(tableVal, "")->React.string}
            </div>
          )
          ->React.array}
        </div>
      })
      ->React.array}
    </div>
    <div
      className="absolute top-0 right-0 left-0 bottom-0 h-fit w-1/5 m-auto flex flex-col gap-6 items-center">
      <p className="text-center text-grey-700 font-medium opacity-50"> {infoText->React.string} </p>
      <RenderIf condition={showRedirectCTA}>
        <Button
          text=buttonText
          buttonType={Primary}
          onClick={_ => {
            onClickUrl->LogicUtils.isNonEmptyString
              ? RescriptReactRouter.push(GlobalVars.appendDashboardPath(~url=onClickUrl))
              : setPaymentModal(_ => true)
          }}
        />
      </RenderIf>
    </div>
    <RenderIf condition={paymentModal}> {onClickElement} </RenderIf>
  </div>
}
