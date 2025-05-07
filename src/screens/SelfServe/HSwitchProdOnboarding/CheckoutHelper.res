let getOptionReturnUrl = (returnUrl: string): ReactHyperJs.checkoutElementOptions => {
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
}

let getOption = (clientSecret: option<string>): ReactHyperJs.optionsForElements => {
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
