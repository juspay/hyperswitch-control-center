open HyperSwitch
open HyperSwitchTypes
open Promise

@val external window: 'a = "window"
@val @scope("window") external parent: 'a = "parent"

type configElements = {
  appearanceElement: Js.Json.t,
  paymentElement: Js.Json.t,
}

type configData = {
  publishableKey: string,
  config: string,
}

module CheckoutForm = {
  @react.component
  let make = (
    ~clientSecret,
    ~sdkType: sdkType,
    ~paymentStatus,
    ~currency,
    ~setPaymentStatus,
    ~paymentElementOptions,
    ~theme="",
    ~primaryColor="",
    ~bgColor="",
    ~fontFamily="",
    ~fontSizeBase="",
    ~layout="",
    ~methodsOrder=[],
    ~returnUrl,
    ~saveViewToSdk=false,
    ~publishableKey,
    ~isSpaceAccordion=false,
    ~amount,
    ~setClientSecret,
  ) => {
    let (error, setError) = React.useState(_ => None)
    let (btnState, setBtnState) = React.useState(_ => Button.Normal)
    let hyper = useHyper()
    let elements = useElements()
    let (appearanceElem, setAppearanceElem) = React.useState(() => Js.Json.null)
    let (paymentElem, setPaymentElem) = React.useState(() => Js.Json.null)

    let fetchApi = AuthHooks.useApiFetcher()
    React.useEffect2(() => {
      let val = {
        publishableKey,
        config: {
          appearanceElement: appearanceElem,
          paymentElement: paymentElem,
        }
        ->Js.Json.stringifyAny
        ->Belt.Option.getWithDefault(""),
      }
      setError(_ => None)

      if saveViewToSdk {
        fetchApi(
          "https://4gla4dnvbg.execute-api.ap-south-1.amazonaws.com/default/hyperConfig",
          ~bodyStr=val->Js.Json.stringifyAny->Belt.Option.getWithDefault(""),
          ~headers=[("Access-Control-Allow-Origin", "*")]->Js.Dict.fromArray,
          ~method_=Fetch.Post,
          (),
        )
        ->then(Fetch.Response.json)
        ->then(json => {
          json->resolve
        })
        ->catch(_e => {
          Js.Dict.empty()->Js.Json.object_->resolve
        })
        ->ignore
      }

      None
    }, (saveViewToSdk, clientSecret))

    React.useEffect6(() => {
      let appearanceVal = {
        appearance: {
          variables: {
            fontFamily,
            fontSizeBase,
            colorPrimary: primaryColor,
            colorBackground: bgColor,
          },
          rules: {
            ".Tab": {
              "borderRadius": "0px",
              "display": "flex",
              "gap": "8px",
              "height": "52px",
              "flexDirection": "row",
              "justifyContent": "center",
              "borderRadius": "5px",
              "alignItems": "center",
              "fontSize": "100%",
            },
            ".Tab--selected": {
              "display": "flex",
              "gap": "8px",
              "flexDirection": "row",
              "justifyContent": "center",
              "alignItems": "center",
              "padding": "15px 32px",
              "borderRadius": "5px",
              "fontWeight": "700",
            },
            ".TabLabel": {
              "overflowWrap": "break-word",
            },
            ".Tab--selected:hover": {
              "display": "flex",
              "gap": "8px",
              "flexDirection": "row",
              "justifyContent": "center",
              "alignItems": "center",
              "padding": "15px 32px",
              "borderRadius": "5px",
              "fontWeight": "700",
            },
            ".Tab:hover": {
              "display": "flex",
              "gap": "8px",
              "flexDirection": "row",
              "justifyContent": "center",
              "alignItems": "center",
              "padding": "15px 32px",
              "borderRadius": "5px",
              "fontWeight": "700",
            }->Identity.genericTypeToJson,
          }->Identity.genericTypeToJson,
          theme,
        },
      }->Identity.genericTypeToJson
      setAppearanceElem(_ => appearanceVal)
      elements.update(appearanceVal)
      None
    }, (elements, theme, primaryColor, bgColor, fontFamily, fontSizeBase))

    React.useEffect3(() => {
      let paymentElement = elements.getElement("payment")
      switch paymentElement->Js.Nullable.toOption {
      | Some(ele) =>
        let paymentVal = {
          "layout": {
            \"type": layout == "spaced Accordion" ? "accordion" : layout,
            defaultCollapsed: layout == "spaced Accordion" || layout == "accordion",
            radios: true,
            spacedAccordionItems: isSpaceAccordion,
          },
          "paymentMethodOrder": methodsOrder,
        }->Identity.genericTypeToJson
        setPaymentElem(_ => paymentVal)
        ele.update(paymentVal)
      | None => ()
      }
      None
    }, (layout, elements, methodsOrder))

    let handleSubmit = () => {
      let confirmParams =
        [
          (
            "confirmParams",
            [("return_url", returnUrl->Js.Json.string)]->Js.Dict.fromArray->Js.Json.object_,
          ),
          ("redirect", "always"->Js.Json.string),
        ]
        ->Js.Dict.fromArray
        ->Js.Json.object_
      hyper.confirmPayment(confirmParams)
      ->then(val => {
        let resDict = val->Js.Json.decodeObject->Belt.Option.getWithDefault(Js.Dict.empty())
        let errorDict =
          resDict
          ->Js.Dict.get("error")
          ->Belt.Option.flatMap(Js.Json.decodeObject)
          ->Belt.Option.getWithDefault(Js.Dict.empty())

        let errorMsg = errorDict->Js.Dict.get("message")

        switch errorMsg {
        | Some(val) => {
            let str =
              val
              ->LogicUtils.getStringFromJson("")
              ->Js.String2.replace("\"", "")
              ->Js.String2.replace("\"", "")
            if str == "Something went wrong" {
              setPaymentStatus(_ => CUSTOMSTATE)
              setError(_ => None)
            } else {
              setPaymentStatus(_ => FAILED(val->LogicUtils.getStringFromJson("")))
              setError(_ => errorMsg)
            }
          }

        | _ => ()
        }
        setClientSecret(_ => None)

        setError(_ => errorMsg)
        setBtnState(_ => Button.Normal)

        resolve()
      })
      ->ignore
    }
    React.useEffect1(() => {
      hyper.retrievePaymentIntent(clientSecret)
      ->then(_ => {
        resolve()
      })
      ->ignore

      None
    }, [hyper])

    <div>
      {switch paymentStatus {
      | LOADING => <Loader />
      | INCOMPLETE =>
        <div className="grid grid-row-2 gap-5">
          <div className="row-span-1 bg-white rounded-lg py-6 px-10 flex-1">
            {switch sdkType {
            | ELEMENT => <PaymentElement id="payment-element" options={paymentElementOptions} />
            | WIDGET => <CardWidget id="card-widget" options={paymentElementOptions} />
            }}
            <Button
              text={`Pay ${currency} ${(amount / 100)->Belt.Int.toString}`}
              loadingText="Please wait..."
              buttonState=btnState
              buttonType={Primary}
              customButtonStyle={`p-1 mt-2 w-full rounded-md ${primaryColor}`}
              onClick={_ => {
                setBtnState(_ => Button.Loading)
                handleSubmit()
              }}
            />
          </div>
          {switch error {
          | Some(val) =>
            <div className="text-red-500">
              {val
              ->Js.Json.stringifyAny
              ->Belt.Option.getWithDefault("")
              ->Js.String2.replace("\"", "")
              ->Js.String2.replace("\"", "")
              ->React.string}
            </div>
          | None => React.null
          }}
        </div>
      | _ => React.null
      }}
    </div>
  }
}

@react.component
let make = (
  ~clientSecret,
  ~publishableKey,
  ~sdkType: sdkType,
  ~paymentStatus,
  ~currency,
  ~setPaymentStatus,
  ~elementOptions,
  ~theme="",
  ~primaryColor="",
  ~bgColor="",
  ~fontFamily="",
  ~fontSizeBase="",
  ~paymentElementOptions,
  ~returnUrl,
  ~layout="",
  ~methodsOrder=[],
  ~saveViewToSdk=false,
  ~isSpaceAccordion=false,
  ~amount=65400,
  ~setClientSecret,
) => {
  let hyperPromise = Js.Promise.make((~resolve, ~reject as _) => {
    resolve(. Window.loadHyper(publishableKey))
  })

  <div>
    <Elements options={elementOptions} stripe={hyperPromise}>
      <CheckoutForm
        clientSecret
        sdkType
        paymentStatus
        currency
        setPaymentStatus
        paymentElementOptions
        theme
        primaryColor
        bgColor
        fontFamily
        fontSizeBase
        methodsOrder
        layout
        returnUrl
        saveViewToSdk
        publishableKey
        isSpaceAccordion
        amount
        setClientSecret
      />
    </Elements>
  </div>
}
