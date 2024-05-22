open ReactHyperJs
open Promise

type configElements = {
  appearanceElement: JSON.t,
  paymentElement: JSON.t,
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
    let (appearanceElem, setAppearanceElem) = React.useState(() => JSON.Encode.null)
    let (paymentElem, setPaymentElem) = React.useState(() => JSON.Encode.null)

    let fetchApi = AuthHooks.useApiFetcher()
    React.useEffect2(() => {
      let val = {
        publishableKey,
        config: {
          appearanceElement: appearanceElem,
          paymentElement: paymentElem,
        }
        ->JSON.stringifyAny
        ->Option.getOr(""),
      }
      setError(_ => None)

      if saveViewToSdk {
        fetchApi(
          "https://4gla4dnvbg.execute-api.ap-south-1.amazonaws.com/default/hyperConfig",
          ~bodyStr=val->JSON.stringifyAny->Option.getOr(""),
          ~headers=[("Access-Control-Allow-Origin", "*")]->Dict.fromArray,
          ~method_=Fetch.Post,
          (),
        )
        ->then(Fetch.Response.json)
        ->then(json => {
          json->resolve
        })
        ->catch(_e => {
          Dict.make()->JSON.Encode.object->resolve
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
      switch paymentElement->Nullable.toOption {
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

    let handleSubmit = async () => {
      open LogicUtils
      try {
        let confirmParams =
          [
            (
              "confirmParams",
              [
                ("return_url", returnUrl->JSON.Encode.string),
                ("redirect", "always"->JSON.Encode.string),
              ]
              ->Dict.fromArray
              ->JSON.Encode.object,
            ),
          ]->getJsonFromArrayOfJson
        let res = await hyper.confirmPayment(confirmParams)
        let status = res->getDictFromJsonObject->getOptionString("status")
        switch status {
        | Some(str) =>
          switch str {
          | "failed" => setPaymentStatus(_ => FAILED("Failed"))
          | "succeeded" => setPaymentStatus(_ => SUCCESS)
          | _ => setPaymentStatus(_ => CUSTOMSTATE)
          }
        | None => setPaymentStatus(_ => CUSTOMSTATE)
        }
      } catch {
      | Exn.Error(e) => {
          let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
          let str = err->String.replace("\"", "")->String.replace("\"", "")
          if str == "Something went wrong" {
            setPaymentStatus(_ => CUSTOMSTATE)
            setError(_ => None)
          } else {
            setPaymentStatus(_ => FAILED(err))
            setError(_ => Some(err))
          }
        }
      }
      setClientSecret(_ => None)
      setBtnState(_ => Button.Normal)
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
              text={`Pay ${currency} ${(amount /. 100.00)->Float.toString}`}
              loadingText="Please wait..."
              buttonState=btnState
              buttonType={Primary}
              customButtonStyle={`p-1 mt-2 w-full rounded-md ${primaryColor}`}
              onClick={_ => {
                setBtnState(_ => Button.Loading)
                handleSubmit()->ignore
              }}
            />
          </div>
          {switch error {
          | Some(val) =>
            <div className="text-red-500">
              {val
              ->JSON.stringifyAny
              ->Option.getOr("")
              ->String.replace("\"", "")
              ->String.replace("\"", "")
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
  ~amount=65400.00,
  ~setClientSecret,
) => {
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let loadDOM = async () => {
    try {
      switch Window.env.sdkBaseUrl {
      | Some(url) => {
          let script = DOMUtils.document->DOMUtils.createElement("script")
          script->DOMUtils.setAttribute("src", url)
          DOMUtils.appendChild(script)
          let _ = Some(_ => script->DOMUtils.remove())
          await HyperSwitchUtils.delay(1000)
          setScreenState(_ => PageLoaderWrapper.Success)
        }
      | None => setScreenState(_ => Error("URL Not Configured"))
      }
    } catch {
    | _ => setScreenState(_ => Error(""))
    }
  }
  React.useEffect0(() => {
    loadDOM()->ignore
    None
  })
  let hyperPromise = React.useCallback1(async () => {
    Window.loadHyper(publishableKey)
  }, [publishableKey])
  <PageLoaderWrapper
    screenState={screenState}
    customLoader={<div className="mt-60 w-scrren flex flex-col justify-center items-center">
      <div className={`animate-spin mb-1`}>
        <Icon name="spinner" size=20 />
      </div>
    </div>}
    sectionHeight="!h-screen">
    <div>
      {switch Window.checkLoadHyper {
      | Some(_) =>
        <Elements options={elementOptions} stripe={hyperPromise()}>
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
      | None => React.null
      }}
    </div>
  </PageLoaderWrapper>
}
