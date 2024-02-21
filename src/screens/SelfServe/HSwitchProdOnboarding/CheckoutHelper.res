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
    showCardFormByDefault: false,
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
