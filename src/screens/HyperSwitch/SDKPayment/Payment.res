open HyperSwitchTypes
open HSwitchGlobalVars

@react.component
let make = (
  ~isConfigureConnector,
  ~setOnboardingModal,
  ~countryCurrency,
  ~profile_id,
  ~merchantDetailsValue,
  ~amount,
) => {
  let countryData = Js.String2.split(countryCurrency, ",")
  let currency = countryData->Belt.Array.get(1)->Belt.Option.getWithDefault("USD")

  let detail = merchantDetailsValue->HSwitchMerchantAccountUtils.getMerchantDetails

  // Needed for Business Unit Label to Business Profile Change
  // let businessProfileValue = Recoil.useRecoilValueFromAtom(HyperswitchAtom.businessProfilesAtom)

  // let activeBusinessProfile =
  //   businessProfileValue->HSwitchMerchantAccountUtils.getValueFromBusinessProfile

  let paymentJson = {
    // "profile_id": activeBusinessProfile.profile_id,
    "amount": amount,
    "currency": currency,
    "capture_method": "automatic",
    "amount_to_capture": amount,
    "customer_id": "hs-dashboard-user",
    "email": "guest@example.com",
    "name": "John Doe",
    "phone": "999999999",
    "phone_country_code": "+65",
    "description": "Its my first payment request",
    "authentication_type": "no_three_ds",
    "return_url": sandboxURL,
    "profile_id": profile_id,
    "shipping": {
      "address": {
        "line1": "1467",
        "line2": "Harrison Street",
        "line3": "Harrison Street",
        "city": "San Fransico",
        "state": "California",
        "zip": "94122",
        "country": countryData->Belt.Array.get(0)->Belt.Option.getWithDefault("US"),
        "first_name": "John",
        "last_name": "Doe",
      },
      "phone": {
        "number": "1234567890",
        "country_code": "+1",
      },
    },
    "billing": {
      "address": {
        "line1": "1467",
        "line2": "Harrison Street",
        "line3": "Harrison Street",
        "city": "San Fransico",
        "state": "California",
        "zip": "94122",
        "country": countryData->Belt.Array.get(0)->Belt.Option.getWithDefault("US"),
        "first_name": "John",
        "last_name": "Doe",
      },
      "phone": {
        "number": "1234567890",
        "country_code": "+1",
      },
    },
    "metadata": {
      "order_details": {
        "product_name": "Apple iphone 15",
        "quantity": 1,
        "amount": amount,
      },
    },
  }
  let showTestMode = !isConfigureConnector

  let defaultPubKey = "pk_snd_f00d7746423c412f9d49627501ddc64b"
  let defualtApiKey = "snd_S1xH1M7RzPBTFzfahUiVLw8F7qFmg0vlnSZVxWFFe9ZAvc7kwldMfRiQw67XXZcV"

  let defaultPubIntegKey = "pk_snd_3cbadca4c57c4abfb8eda333d825fb99"
  let defualtApiIntegKey = "snd_o9l9pF42nJRML0SrFAgZnPw3ybcY6NPnVampRGUEpI1KCAHqlrYUfuZvFRBzpY0Y"

  let publishableKey = if detail.publishable_key->Js.String2.length <= 0 || showTestMode {
    if GlobalVars.isLocalhost {
      defaultPubIntegKey
    } else {
      defaultPubKey
    }
  } else {
    detail.publishable_key
  }

  let apiKey = if detail.publishable_key->Js.String2.length <= 0 || showTestMode {
    if GlobalVars.isLocalhost {
      defualtApiIntegKey
    } else {
      defualtApiKey
    }
  } else {
    ""
  }

  let (clientSecret, setClientSecret) = React.useState(_ => None)
  let fetchApi = AuthHooks.useApiFetcher()
  let url = RescriptReactRouter.useUrl()
  let searchParams = url.search
  let filtersFromUrl = LogicUtils.getDictFromUrlSearchParams(searchParams)
  let (currentPaymentId, setCurrentPaymentId) = React.useState(_ => "")
  let (paymentStatus, setPaymentStatus) = React.useState(_ => INCOMPLETE)
  let getOption = %raw(`
    function (clientSecret) {
     return {
    clientSecret,
    appearance: {
      theme: "charcoal",
      variables: {
        colorPrimary: "#006DF9",
        colorBackground: "transparent",
        spacingUnit: "13px",
      },
      rules: {
        ".Input": {
          borderRadius: "8px",
          border: "1px solid #D6D9E0",
        },
        ".Tab": {
          borderRadius: "0px",
          display: "flex",
          gap: "8px",
          flexDirection: "row",
          justifyContent: "center",
          alignItems: "center",
        },
        ".Tab:hover": {
          display: "flex",
          gap: "8px",
          flexDirection: "row",
          justifyContent: "center",
          alignItems: "center",
          padding: "15px 32px",
          background: "rgba(0, 109, 249, 0.1)",
          border: "1px solid #006DF9",
          borderRadius: "112px",
          color: "#0c0b0b",
          fontWeight: "700",
        },
        ".Tab--selected": {
          display: "flex",
          gap: "8px",
          flexDirection: "row",
          justifyContent: "center",
          alignItems: "center",
          padding: "15px 32px",
          background: "rgba(0, 109, 249, 0.1)",
          border: "1px solid #006DF9",
          borderRadius: "112px",
          color: "#0c0b0b",
          fontWeight: "700",
        },
        ".Label": {
          color: "rgba(45, 50, 65, 0.5)",
          marginBottom: "3px",
        },
        ".CheckboxLabel": {
          color: "rgba(45, 50, 65, 0.5)",
        },
        ".TabLabel": {
          overflowWrap: "break-word",
        },
        ".Tab--selected:hover": {
          display: "flex",
          gap: "8px",
          flexDirection: "row",
          justifyContent: "center",
          alignItems: "center",
          padding: "15px 32px",
          background: "rgba(0, 109, 249, 0.1)",
          border: "1px solid #006DF9",
          borderRadius: "112px",
          color: "#0c0b0b",
          fontWeight: "700",
        },
      },
    },
    fonts: [
      {
        cssSrc:
          "https://fonts.googleapis.com/css2?family=Orbitron:wght@400;500;600;700&display=swap",
      },
      {
        cssSrc:
          "https://fonts.googleapis.com/css2?family=Quicksand:wght@400;500;600;700&family=Qwitcher+Grypen:wght@400;700&display=swap",
      },
      {
        cssSrc: "https://fonts.googleapis.com/css2?family=Combo&display=swap",
      },
      {
        family: "something",
        src: "https://fonts.gstatic.com/s/combo/v21/BXRlvF3Jh_fIhj0lDO5Q82f1.woff2",
        weight: "700",
      },
    ],
    locale: "en",
    loader: "always",
  };}`)
  let getOptionReturnUrl = %raw(`
      function (returnUrl){
  return {
fields: {
        billingDetails: {
          address: {
            country: "auto",
            city: "auto",
          },
        },
      },
     layout: {
        type: "tabs",
        defaultCollapsed: false,
        radios: true,
        spacedAccordionItems: false,
      },
    wallets: {
        walletReturnUrl: returnUrl,
        applePay: "auto",
        googlePay: "auto",
        style: {
          theme: "dark",
          type: "default",
          height: 48,
        },
      },
  }
}
    `)

  let returnUrl = `${hyperSwitchFEPrefix}/sdk`

  let paymentElementOptions = getOptionReturnUrl(returnUrl)

  let elementOptions = getOption(clientSecret)

  React.useEffect0(() => {
    let status =
      filtersFromUrl->Js.Dict.get("status")->Belt.Option.getWithDefault("")->Js.String2.toLowerCase
    let paymentId =
      filtersFromUrl
      ->Js.Dict.get("payment_intent_client_secret")
      ->Belt.Option.getWithDefault("")
      ->Js.String2.split("_secret_")
      ->Belt.Array.get(0)
      ->Belt.Option.getWithDefault("")
    setCurrentPaymentId(_ => paymentId)

    if status === "succeeded" {
      setPaymentStatus(_ => SUCCESS)
    } else if status === "failed" {
      setPaymentStatus(_ => FAILED(""))
    } else if status === "processing" {
      setPaymentStatus(_ => PROCESSING)
    } else {
      setPaymentStatus(_ => INCOMPLETE)
    }

    if status == "" {
      open Promise

      fetchApi(
        `${hyperSwitchApiPrefix}/payments`,
        ~headers=[("Content-Type", "application/json"), ("api-key", apiKey)]->Js.Dict.fromArray, // Need to be refactor
        ~bodyStr=paymentJson->Js.Json.stringifyAny->Belt.Option.getWithDefault(""),
        ~method_=Fetch.Post,
        (),
      )
      ->then(resp => {
        let status = resp->Fetch.Response.status
        if status == 401 || status == 422 || status == 500 {
          setPaymentStatus(_ => CHECKCONFIGURATION)
        }
        Fetch.Response.json(resp)
      })
      ->then(json => {
        // get the client secret
        let resDict = json->Js.Json.decodeObject->Belt.Option.getWithDefault(Js.Dict.empty())
        let cl = resDict->Js.Dict.get("client_secret")->Belt.Option.flatMap(Js.Json.decodeString)
        setClientSecret(_ => cl)

        resolve()
      })
      ->catch(_err => {
        resolve()
      })
      ->ignore
    }
    None
  })
  <div className="flex-1 px-3.75 md:px-11.25 py-5 md:py-10 border-x-1 border-y-1 rounded">
    {switch paymentStatus {
    | SUCCESS =>
      <div className="flex flex-col items-center gap-5 md:gap-10 md:my-14">
        <Icon className="text-green-700" name="check-circle" size=100 />
        <div className="text-xl w-96 text-center">
          {"Your payment has been completed."->React.string}
        </div>
        <div>
          <div>
            <Button
              text={showTestMode ? "Configure a connector to view Payment Details" : "View Payment"}
              buttonType=Primary
              customButtonStyle="p-1 mt-2 w-full"
              onClick={_ => {
                if showTestMode {
                  setOnboardingModal(_ => false)
                  RescriptReactRouter.push("/connectors")
                } else {
                  setOnboardingModal(_ => false)
                  RescriptReactRouter.push(`/payments/${currentPaymentId}`)
                }
              }}
            />
          </div>
        </div>
      </div>
    | FAILED(err) =>
      <div className="flex flex-col items-center gap-10 my-14">
        <Icon className="text-red-700" name="times-circle" size=100 />
        <div className="text-xl w-96 text-center">
          {showTestMode
            ? "For Payments to work you need to configure your first connector"->React.string
            : "Your payment has been failed"->React.string}
        </div>
        <div className="w-full break-all"> {`Error Message - ${err}`->React.string} </div>
      </div>
    | PROCESSING =>
      <div className="flex flex-col items-center gap-10 my-14">
        <Icon name="processing" size=100 />
        <div className="text-xl w-96 text-center">
          {"Your Payment is still pending."->React.string}
        </div>
        <Button
          text={"View Payments List"}
          buttonType=Primary
          customButtonStyle="p-1 mt-2 w-full"
          onClick={_ => {
            RescriptReactRouter.push(`/payments/${currentPaymentId}`)
          }}
        />
      </div>
    | CHECKCONFIGURATION =>
      <div className="flex flex-col items-center gap-10 my-14">
        <Icon className="text-red-700" name="times-circle" size=100 />
        <div className="text-xl w-96 text-center">
          {"Please check your Configurations."->React.string}
        </div>
        <Button
          text={"Go to Connectors"}
          buttonType=Primary
          customButtonStyle="p-1 mt-2 w-full"
          onClick={_ => {
            RescriptReactRouter.push("/connectors")
          }}
        />
      </div>
    | CUSTOMSTATE =>
      <div className="flex flex-col items-center gap-10 my-14">
        <Icon name="processing" size=100 />
        <div>
          <p className="text-xl text-center font-bold"> {"Something Went Wrong."->React.string} </p>
          <p className="text-md text-center text-gray-400 mt-2">
            {"Issue in Connector Configurations"->React.string}
          </p>
        </div>
        <div className="flex flex-1 flex-col">
          <Button
            text={"Contact Our Support team"}
            buttonType={Secondary}
            customButtonStyle="p-1 mt-2 w-full"
            leftIcon={CustomIcon(<Icon name="slack" size=30 />)}
            buttonSize={Small}
            onClick={_ => {
              Window._open("https://hyperswitch-io.slack.com/ssb/redirect")
            }}
          />
        </div>
      </div>
    | _ => React.null
    }}
    {switch clientSecret {
    | Some(val) =>
      <WebSDK
        clientSecret=val
        publishableKey
        sdkType=ELEMENT
        paymentStatus
        currency
        setPaymentStatus
        elementOptions
        paymentElementOptions
        returnUrl
        isConfigureConnector
        amount
        setClientSecret
      />
    | None => React.null
    }}
  </div>
}
