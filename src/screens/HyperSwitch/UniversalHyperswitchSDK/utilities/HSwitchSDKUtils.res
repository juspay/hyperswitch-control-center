external objToJson: {..} => Js.Json.t = "%identity"
@val @scope("window") external hyper: string => HSwitchTypes.hyperPromise = "Hyper"

let loadHyper = str => {
  Js.Promise.make((~resolve, ~reject) => {
    let scriptURL = "https://beta.hyperswitch.io/v1/HyperLoader.js"
    let script = Window.createElement("script")
    script->Window.elementSrc(scriptURL)
    script->Window.elementOnload(() => resolve(. hyper(str)))
    script->Window.elementOnerror(err => {
      reject(. err)
    })
    Window.body->Window.appendChild(script)
  })
}

let getCurrencyFromCustomerLocation = customerLocation => {
  customerLocation->Js.String2.slice(~from=-4, ~to_=-1)
}

let getCountryFromCustomerLocation = customerLocation => {
  switch customerLocation {
  | "Germany (EUR)" => "DE"
  | _ => customerLocation->Js.String2.slice(~from=-4, ~to_=-2)
  }
}

type themeColor = {
  backgroundColor: string,
  color: string,
  hyperswitchHeaderColor: string,
  payHeaderColor: string,
  boxShadowClassForSDK: string,
  textSecondaryColor: string,
  tabLabelColor: string,
  checkoutButtonClass: string,
  checkoutButtonShimmerClass: string,
  amountColor: string,
  backgroundSecondaryClass: string,
  modalBackgroundColor: string,
  counterButtonClass: string,
  plusIcon: string,
  inputClass: string,
  productBorderClass: string,
  productDividerClass: string,
}

let defaultThemeColor = {
  backgroundColor: "#fff",
  color: "#000",
  hyperswitchHeaderColor: "rgba(26,26,26,0.9)",
  payHeaderColor: "rgba(26,26,26,0.6)",
  boxShadowClassForSDK: "before:shadow-defaultBoxShadowClassForSDKShadow",
  textSecondaryColor: "rgba(26,26,26,0.5)",
  tabLabelColor: "",
  checkoutButtonClass: "text-white border-none bg-[rgb(0,109,249)]",
  checkoutButtonShimmerClass: "bg-default_theme_button_shimmer",
  amountColor: "",
  backgroundSecondaryClass: "bg-[rgba(26,26,26,0.05)]",
  modalBackgroundColor: "#fff",
  counterButtonClass: "bg-[rgba(0,0,0,0.03)] text-[rgba(26,26,26,0.6)]",
  plusIcon: "plus",
  inputClass: "border-none shadow-defaultModalInputShadow focus:border focus:border-solid focus:border-[#006df9] focus:shadow-defaultModalInputFocusShadow",
  productBorderClass: "border-b-[rgba(26,26,26,0.1)]",
  productDividerClass: "bg-[rgb(230,230,230)]",
}

let getThemeColorsFromTheme = theme => {
  switch theme {
  | "Default" => defaultThemeColor
  | "Brutal" => {
      ...defaultThemeColor,
      hyperswitchHeaderColor: "rgba(0,0,0,0.9)",
      payHeaderColor: "rgba(0,0,0,0.6)",
      textSecondaryColor: "rgba(0,0,0,0.5)",
      backgroundColor: "rgba(124,255,112,0.54)",
      tabLabelColor: "#000000",
      checkoutButtonClass: "shadow-brutalButtonShadow text-[#000000] border-[0.17em] border-solid border-black bg-[#f5fb1f] active:translate-x-[0.05em] active:translate-y-[0.05em] active:shadow-brutalButtonActiveShadow",
      checkoutButtonShimmerClass: "bg-brutal_theme_button_shimmer",
      backgroundSecondaryClass: "shadow-brutalButtonShadow border-[0.17em] border-solid border-black bg-white active:translate-x-[0.05em] active:translate-y-[0.05em] active:shadow-brutalButtonActiveShadow",
      counterButtonClass: "border-[0.17em] border-solid border-black shadow-brutalButtonShadow text-black active:translate-x-[0.05em] active:translate-y-[0.05em] active:shadow-brutalButtonActiveShadow",
      plusIcon: "plusBlack",
      inputClass: "shadow-brutalModalInputShadow border-[0.1em] border-solid border-black focus:translate-x-[0.05em] focus:translate-y-[0.05em] focus:shadow-brutalModalInputFocusShadow",
      productDividerClass: "bg-[rgb(86,97,134)]",
    }
  | "Midnight" => {
      backgroundColor: "rgb(26, 31, 54)",
      color: "#fff",
      hyperswitchHeaderColor: "rgba(229,229,229,0.9)",
      payHeaderColor: "rgba(229,229,229,0.6)",
      boxShadowClassForSDK: "before:shadow-midnightBoxShadowClassForSDKShadow",
      textSecondaryColor: "rgba(229,229,229,0.5)",
      tabLabelColor: "#000000",
      checkoutButtonClass: "bg-[#85d996]",
      checkoutButtonShimmerClass: "bg-midnight_theme_button_shimmer",
      amountColor: "#85d996",
      backgroundSecondaryClass: "bg-[rgba(229,229,229,0.05)]",
      modalBackgroundColor: "#30313d",
      counterButtonClass: "bg-[rgba(255,255,255,0.03)] text-[rgb(229,229,229)]",
      plusIcon: "plusWhite",
      inputClass: "border border-solid border-[#424353] text-white bg-[rgb(48,49,61)] shadow-midnightModalInputShadow focus-visible:border focus-visible:border-solid focus-visible:border-[#85d996] focus-visible:shadow-midnightModalInputFocusShadow",
      productBorderClass: "border-b-[rgba(229,229,229,0.1)]",
      productDividerClass: "bg-[rgb(66,67,83)]",
    }
  | "Soft" => {
      ...defaultThemeColor,
      color: "rgb(224,224,224)",
      hyperswitchHeaderColor: "rgba(224,224,224,0.9)",
      payHeaderColor: "rgba(224,224,224,0.6)",
      textSecondaryColor: "rgba(224,224,224,0.5)",
      boxShadowClassForSDK: "before:shadow-midnightBoxShadowClassForSDKShadow",
      backgroundColor: "rgb(62, 62, 62)",
      checkoutButtonClass: "shadow-softButtonShadow text-[rgb(125,143,255)]",
      checkoutButtonShimmerClass: "bg-soft_theme_button_shimmer",
      amountColor: "#7d8fff",
      backgroundSecondaryClass: "shadow-softButtonShadow",
      modalBackgroundColor: "rgb(62, 62, 62)",
      counterButtonClass: "shadow-softButtonShadow",
      inputClass: "bg-[rgb(60,61,62)] text-[#e0e0e0] shadow-softModalInputShadow",
      plusIcon: "plusWhite",
      productDividerClass: "bg-[rgb(86,97,134)]",
    }
  | "Charcoal" => {
      ...defaultThemeColor,
      backgroundColor: "rgba(221, 216, 216, 0.07)",
      checkoutButtonClass: "bg-black text-white",
      checkoutButtonShimmerClass: "bg-charcoal_theme_button_shimmer",
      inputClass: "border-none shadow-charcoalModalInputShadow focus:border focus:border-solid focus:border-black focus:shadow-charcoalModalInputFocusShadow",
      productDividerClass: "bg-black",
    }
  | _ => defaultThemeColor
  }
}

let getTextColorFromTheme = theme => {
  switch theme {
  | "Default" => "#000"
  | "Brutal" => "#000"
  | "Midnight" => "rgb(255, 255, 255)"
  | "Soft"
  | "Charcoal" => "rgba(221, 216, 216, 0.07)"
  | _ => "#fff"
  }
}

let getIsDesktop = size => {
  size === "Desktop"
}

let getSizeIconFromSize = size => {
  if getIsDesktop(size) {
    "desktop"
  } else {
    "desktop"
  }
}

let redirectUrl = "https://hyperswitch-demo-store.netlify.app"

let hyperswitchDocsUrl = "https://hyperswitch.io/docs"
let hyperswitchRegisterUrl = "https://app.hyperswitch.io/register"
let hyperswitchTermsOfServiceUrl = "https://hyperswitch.io/terms-of-services"
let hyperswitchPrivacyPolicyUrl = "https://hyperswitch.io/privacyPolicy"

let successTestCardNumber = "4242424242424242"
let authenticationTestCardNumber = "4000000000003220"
let declineTestCardNumber = "4000000000000002"

let testCardsInfo = "Click to copy the card number. Use any future expiration date and three-number CVC."

let customerLocationExtraTitle = "Every country pays differently"
let customerLocationExtraDesc = "The Payment Element supports 135+ currencies. Only a sample is shown here. Hyperswitch automatically reorders payment methods to increase potential conversion."
let themeExtraTitle = "Customize it"
let themeExtraDesc = "Create a theme to match your brand with the Appearance API."

let websiteDomain = "checkout.hyperswitch.io"

let successPaymentMsg = "After a successful payment, the customer returns to your website"
let failurePaymentMsg = "After a failed payment, the customer returns to your website"
let processingPaymentMsg = "If the payment status is processing, the customer will be redirected to your website and you will receive webhooks on the payment status"

let getDefaultPayload = (amount, currency, country, countryCode) =>
  {
    "amount": amount->Belt.Int.fromString->Belt.Option.getWithDefault(20000),
    "currency": currency,
    "shipping": {
      "address": {
        "country": country,
        "state": "test",
        "zip": "571201",
        "line1": "test line 1",
        "city": "test city",
        "first_name": "Bopanna",
        "last_name": "MJ",
      },
      "phone": {
        "number": "+918105528927",
        "counrty_code": countryCode,
      },
    },
    "order_details": [
      {
        "product_name": "Apple iphone 15",
        "quantity": 1,
        "amount": amount->Belt.Int.fromString->Belt.Option.getWithDefault(20000),
      },
    ],
    "billing": {
      "address": {
        "country": country,
      },
    },
    "authentication_type": "no_three_ds",
    "customer_id": "Bopanna17",
  }->objToJson

let defaultAPIKey = ""
let defaultPublishableKey = ""

let getOptions = (clientSecret, theme) => {
  {
    "clientSecret": clientSecret,
    "appearance": {
      "theme": theme,
    },
    "fonts": [
      {
        "cssSrc": "https://fonts.googleapis.com/css2?family=Orbitron:wght@400;500;600;700&display=swap",
      },
      {
        "cssSrc": "https://fonts.googleapis.com/css2?family=Quicksand:wght@400;500;600;700&family=Qwitcher+Grypen:wght@400;700&display=swap",
      },
      {
        "cssSrc": "https://fonts.googleapis.com/css2?family=Combo&display=swap",
      },
    ],
    "locale": "",
    "loader": "always",
  }
}

let backendEndpointUrl = "https://sandbox.hyperswitch.io/payments"

let getLayoutPayload = layout => {
  {
    "type": layout === "spaced" ? "accordion" : layout,
    "defaultCollapsed": false,
    "radios": true,
    "spacedAccordionItems": layout === "spaced",
  }
}

let getOptionsPayload = (customerPaymentMethods, layout, theme) => {
  {
    "customerPaymentMethods": customerPaymentMethods,
    "layout": getLayoutPayload(layout),
    "wallets": {
      "walletReturnUrl": redirectUrl,
      "applePay": "auto",
      "googlePay": "auto",
      "style": {
        "theme": switch theme {
        | "Default"
        | "Charcoal" => "dark"
        | _ => "light"
        },
      },
    },
  }->objToJson
}

type viewType = DemoApp | SdkPreview
type sizeType = Mobile | Desktop

let getTotalAmountFloat = (~shirtQuantity, ~capQuantity) => {
  65.00 *. shirtQuantity->Belt.Int.toFloat +. 32.00 *. capQuantity->Belt.Int.toFloat
}

let getTotalAmount = (~shirtQuantity, ~capQuantity) => {
  getTotalAmountFloat(~shirtQuantity, ~capQuantity)->Js.Float.toFixedWithPrecision(~digits=2)
}

let getTaxAmountFloat = (~shirtQuantity, ~capQuantity) => {
  getTotalAmountFloat(~shirtQuantity, ~capQuantity) *. 0.1
}

let getTaxAmount = (~shirtQuantity, ~capQuantity) => {
  getTaxAmountFloat(~shirtQuantity, ~capQuantity)->Js.Float.toFixedWithPrecision(~digits=2)
}

let amountToDisplay = (~shirtQuantity, ~capQuantity) => {
  (getTotalAmountFloat(~shirtQuantity, ~capQuantity) +.
  getTaxAmountFloat(~shirtQuantity, ~capQuantity))->Js.Float.toFixedWithPrecision(~digits=2)
}
