module CopyTextCustomComp = {
  @react.component
  let make = (
    ~displayValue,
    ~copyValue=None,
    ~customTextCss="",
    ~customParentClass="flex items-center",
    ~customOnCopyClick=() => (),
  ) => {
    let showToast = ToastState.useShowToast()

    let copyVal = switch copyValue {
    | Some(val) => val
    | None => displayValue
    }
    let onCopyClick = ev => {
      ev->ReactEvent.Mouse.stopPropagation
      Clipboard.writeText(copyVal)
      customOnCopyClick()
      showToast(~message="Copied to Clipboard!", ~toastType=ToastSuccess, ())
    }

    if displayValue->String.length > 0 {
      <div className=customParentClass>
        <div className=customTextCss> {displayValue->React.string} </div>
        <img
          src={`/assets/CopyToClipboard.svg`}
          className="cursor-pointer"
          onClick={ev => {
            onCopyClick(ev)
          }}
        />
      </div>
    } else {
      "NA"->React.string
    }
  }
}

module BluredTableComponent = {
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
        ("payment_id", "##############"->Js.Json.string),
        ("merchant_id", "####"->Js.Json.string),
        ("status", "####"->Js.Json.string),
        ("amount", "####"->Js.Json.string),
        ("amount_capturable", "####"->Js.Json.string),
      ]->Dict.fromArray

    let dummyTableValue = Belt.Array.make(5, dummyTableValueDict)

    let subTitle =
      moduleSubtitle->Belt.Option.isSome ? moduleSubtitle->Belt.Option.getWithDefault("") : ""

    <div className="relative flex flex-col gap-8">
      <div className="flex items-center justify-between ">
        <PageUtils.PageHeading title=moduleName subTitle />
        <div> {headerRightButton} </div>
      </div>
      <div className="blur bg-white p-8">
        {dummyTableValue
        ->Array.mapWithIndex((value, index) => {
          <div className="flex gap-8 my-10 justify-between" key={index->string_of_int}>
            {value
            ->Dict.keysToArray
            ->Array.mapWithIndex((tableVal, ind) =>
              <div
                className="flex justify-center text-grey-700 opacity-50" key={ind->string_of_int}>
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
        <p className="text-center text-grey-700 font-medium opacity-50">
          {infoText->React.string}
        </p>
        <UIUtils.RenderIf condition={showRedirectCTA}>
          <Button
            text=buttonText
            buttonType={Primary}
            onClick={_ => {
              onClickUrl->String.length > 0
                ? RescriptReactRouter.push(onClickUrl)
                : setPaymentModal(_ => true)
            }}
          />
        </UIUtils.RenderIf>
      </div>
      <UIUtils.RenderIf condition={paymentModal}> {onClickElement} </UIUtils.RenderIf>
    </div>
  }
}

module KeyAndCopyArea = {
  @react.component
  let make = (~copyValue, ~shadowClass="") => {
    let showToast = ToastState.useShowToast()

    <div className={`flex gap-4 border rounded-md py-2 px-4 items-center bg-white ${shadowClass}`}>
      <p className="text-base text-grey-700 opacity-70 col-span-2 truncate">
        {copyValue->React.string}
      </p>
      <div
        className="px-2 py-1 border rounded-md flex gap-2 items-center cursor-pointer"
        onClick={_ => {
          Clipboard.writeText(copyValue)
          showToast(~message="Copied to Clipboard!", ~toastType=ToastSuccess, ())
        }}>
        <Icon name="copy" customIconColor="rgb(156 163 175)" />
        <p className="text-grey-700 opacity-50"> {"Copy"->React.string} </p>
      </div>
    </div>
  }
}
