open HSwitchSDKTypes
open HSwitchTypes
open Promise

@react.component
let make = (~customerPaymentMethods) => {
  let hyper = useHyper()
  let theme = Recoil.useRecoilValueFromAtom(HSwitchRecoilAtoms.theme)
  let setPaymentStatus = Recoil.useSetRecoilState(HSwitchRecoilAtoms.paymentStatus)
  let amountToShow = Recoil.useRecoilValueFromAtom(HSwitchRecoilAtoms.amount)

  let (isPaymentProcessing, setIsPaymentProcessing) = React.useState(_ => false)
  let (errorMsg, setErrorMsg) = React.useState(_ => None)

  let layout = switch Recoil.useRecoilValueFromAtom(HSwitchRecoilAtoms.layout) {
  | "Tabs" => "tabs"
  | "Accordion" => "accordion"
  | "Spaced Accordion" => "spaced"
  | _ => "tabs"
  }

  let themeColors = HSwitchSDKUtils.getThemeColorsFromTheme(
    Recoil.useRecoilValueFromAtom(HSwitchRecoilAtoms.theme),
  )

  let options = HSwitchSDKUtils.getOptionsPayload(customerPaymentMethods, layout, theme)

  let handleFormSubmit = event => {
    event->ReactEvent.Form.preventDefault
    setIsPaymentProcessing(_ => true)

    let confirmParams =
      [
        (
          "confirmParams",
          [("return_url", HSwitchSDKUtils.redirectUrl->Js.Json.string)]
          ->Js.Dict.fromArray
          ->Js.Json.object_,
        ),
      ]
      ->Js.Dict.fromArray
      ->Js.Json.object_

    hyper.confirmPayment(confirmParams)
    ->then(val => {
      let resDict = val->Js.Json.decodeObject->Belt.Option.getWithDefault(Js.Dict.empty())
      let status =
        resDict
        ->Js.Dict.get("status")
        ->Belt.Option.flatMap(Js.Json.decodeString)
        ->Belt.Option.getWithDefault("")

      setIsPaymentProcessing(_ => false)
      setPaymentStatus(._ => status)

      resolve()
    })
    ->ignore
  }

  let css = `.spinner,
    .spinner:before,
    .spinner:after {
      border-radius: 50%;
    }

    .spinner {
      color: #ffffff;
      font-size: 22px;
      text-indent: -99999px;
      margin: 0px auto;
      position: relative;
      width: 20px;
      height: 20px;
      box-shadow: inset 0 0 0 2px;
      -webkit-transform: translateZ(0);
      -ms-transform: translateZ(0);
      transform: translateZ(0);
    }

    .spinner:before,
    .spinner:after {
      position: absolute;
      content: '';
    }

    .spinner:before {
      width: 10.4px;
      height: 20.4px;
      background: ${"rgb(25,37,82)"};
      border-radius: 20.4px 0 0 20.4px;
      top: -0.2px;
      left: -0.2px;
      -webkit-transform-origin: 10.4px 10.2px;
      transform-origin: 10.4px 10.2px;
      -webkit-animation: loading 2s infinite ease 1.5s;
      animation: loading 2s infinite ease 1.5s;
    }

    .spinner:after {
      width: 10.4px;
      height: 10.2px;
      background: ${"rgb(25,37,82)"};
      border-radius: 0 10.2px 10.2px 0;
      top: -0.1px;
      left: 10.2px;
      -webkit-transform-origin: 0px 10.2px;
      transform-origin: 0px 10.2px;
      -webkit-animation: loading 2s infinite ease;
      animation: loading 2s infinite ease;
    }

    @keyframes loading {
      0% {
        -webkit-transform: rotate(0deg);
        transform: rotate(0deg);
      }
      100% {
        -webkit-transform: rotate(360deg);
        transform: rotate(360deg);
      }
    }`

  let errorDiv = error => {
    <div className="text-[#ff0000] flex justify-center mt-4 text-sm"> {React.string(error)} </div>
  }

  let errorHandlingClass = errorMsg->Belt.Option.isSome ? "mt-1" : "mt-4"

  <div>
    <style> {React.string(css)} </style>
    <form onSubmit={event => handleFormSubmit(event)}>
      <PaymentElement id="paymentElement" options />
      {switch errorMsg {
      | Some(error) => errorDiv(error)
      | None => React.null
      }}
      <button
        type_="submit"
        className={`rounded-md cursor-pointer w-full h-11 font-medium text-center text-base relative overflow-hidden ${themeColors.checkoutButtonClass} ${errorHandlingClass}`}>
        <div
          className={`animate-shimmerMove bottom-0 content-[''] h-full left-0 absolute top-0 w-full ${themeColors.checkoutButtonShimmerClass}`}
        />
        <div
          className="relative flex justify-center"
          style={ReactDOMStyle.make(~color=themeColors.tabLabelColor, ())}>
          <span>
            {React.string(isPaymentProcessing ? "Processing..." : `Pay $${amountToShow}`)}
          </span>
        </div>
      </button>
    </form>
  </div>
}
