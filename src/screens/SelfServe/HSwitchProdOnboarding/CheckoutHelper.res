open ReactHyperJs

let getOptionReturnUrl = (~themeConfig, ~returnUrl, ~showSavedCards) => {
  let layoutType = themeConfig->LogicUtils.getString("layout", "tabs")
  let isSpacedLayout = layoutType == "spaced"

  {
    displaySavedPaymentMethods: showSavedCards,
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
