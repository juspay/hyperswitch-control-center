@react.component
let make = (~isLoading, ~clientSecretKey, ~themeInitialValues) => {
  open ReactHyperJs
  open LogicUtils

  let merchantDetails = Recoil.useRecoilValueFromAtom(HyperswitchAtom.merchantDetailsValueAtom)

  let themeDict = themeInitialValues->getDictFromJsonObject

  let layoutType = themeDict->getString("layout", "tabs")
  let isSpacedLayout = layoutType == "spaced"

  let elementOptions: optionsForElements = {
    clientSecret: clientSecretKey,
    appearance: {
      theme: themeDict->getString("theme", "brutal"),
      labels: themeDict->getString("labels", "above"),
      variables: {
        colorPrimary: themeDict->getString("primary_color", "#fd1717"),
      },
    },
    locale: themeDict->getString("locale", "en-GB"),
  }

  let paymentElementOptions: checkoutElementOptions = {
    layout: {
      \"type": isSpacedLayout ? "accordion" : layoutType,
      defaultCollapsed: false,
      radios: true,
      spacedAccordionItems: isSpacedLayout,
    },
  }

  let hyper = loadHyper(merchantDetails.publishable_key)

  <div className="w-3/4 flex flex-col p-5 overflow-auto bg-[rgba(124,255,112,0.54)]">
    {switch (isLoading, clientSecretKey) {
    | (true, "") =>
      <img alt="blurry-sdk" src="/assets/BlurrySDK.svg" height="500px" width="400px" />
    | _ =>
      <HyperElements options=elementOptions hyper>
        <PaymentElement id="paymentElement" options=paymentElementOptions />
      </HyperElements>
    }}
  </div>
}
