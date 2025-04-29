open ReactHyperJs

let getOptionReturnUrl = (~themeDict, ~returnUrl) => {
  let layoutType = themeDict->LogicUtils.getString("layout", "tabs")
  let isSpacedLayout = layoutType == "spaced"

  {
    showCardFormByDefault: false,
    wallets: {
      walletReturnUrl: returnUrl,
      applePay: "auto",
      googlePay: "auto",
      style: {
        theme: "dark",
        type_: "default",
        height: 48,
      },
    },
    layout: {
      \"type": isSpacedLayout ? "accordion" : layoutType,
      defaultCollapsed: false,
      radios: true,
      spacedAccordionItems: isSpacedLayout,
    },
  }
}

let getOption = clientSecret => {
  {
    clientSecret: clientSecret->Option.getOr(""),
    appearance: {
      theme: "charcoal",
      variables: {
        colorPrimary: "#006DF9",
      },
    },
    locale: "en",
    loader: "always",
  }
}
