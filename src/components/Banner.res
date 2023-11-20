type actionBtn = {
  btnText: string,
  onClick: unit => unit,
  customBtnStyle: string,
}

@react.component
let make = (
  ~mainText,
  ~subText,
  ~wrapperStyle="p-5 mb-5 text-white font-medium text-xl ",
  ~bgColor="bg-blue-900",
  ~mainTextStyle="font-bold",
  ~subTextStyle="",
  ~actions: array<actionBtn>=[],
) => {
  <div className={`flex items-center justify-between w-full  ${wrapperStyle} ${bgColor}`}>
    <div className="flex gap-4 items-center">
      <span> %raw(`String.fromCodePoint(0x1F389)`) </span>
      <div className=mainTextStyle> {mainText->React.string} </div>
      <div className=subTextStyle> {subText->React.string} </div>
      {actions
      ->Js.Array2.mapi((btn, i) => {
        <div
          onClick={e => btn.onClick()}
          className={`py-1 px-3 border-2 rounded text-base cursor-pointer hover:bg-white hover:text-blue-900 font-bold ${btn.customBtnStyle}`}
          key={i->Belt.Int.toString}>
          {btn.btnText->React.string}
        </div>
      })
      ->React.array}
    </div>
    <div className="cursor-pointer mr-1">
      <Icon name="close" size=14 className="fill-white" />
    </div>
  </div>
}
