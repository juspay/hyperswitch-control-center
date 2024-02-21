open UserOnboardingTypes

let migrateStripfrontEndLang: array<languages> = [#ReactJs, #HTML]
let migrateStripBackEndLang: array<languages> = [#Node, #Python, #Go, #Ruby, #Java, #Net, #Php]

let integrateFromScratchfrontEndLang: array<languages> = [#ReactJs, #HTML]
let integrateFromScratchBackEndlang: array<languages> = [
  #Node,
  #Python,
  #Go,
  #Ruby,
  #Java,
  #Net,
  #Php,
]

let platforms: array<platforms> = [#Web, #IOS, #Android, #BigCommerce, #ReactNative]
let requestOnlyPlatforms: array<platforms> = [#BigCommerce, #IOS, #Android, #ReactNative]

let getContentBasedOnIndex = (~currentRoute, ~tabIndex) =>
  switch currentRoute {
  | MigrateFromStripe =>
    switch tabIndex {
    | 0 => "Start by downloading your Test API Key and keeping it handy."
    | 1 => "Install Hyperswitch's SDK and server side dependencies from npm.This is to add Hyperswitch dependencies to your application, along with your existing Stripe dependencies."
    | 2 => "Replace the Stripe API key with Hyperswitch API key on the server side and modify the endpoint for the payment intent API.So, the Payment Intent API call previously being made to Stripe server will now be routed to Hyperswitch server."
    | 3 => "Reconfigure checkout form to import from Hyperswitch.This will import the Hyperswitch Unified checkout dependencies."
    | 4 => "Call loadHyper() with you Hyperswitch publishable key to configure the SDK library, from your website.This will load and invoke the Hyperswitch Checkout experience instead of the Stripe UI Elements."
    | _ => ""
    }
  | IntegrateFromScratch =>
    switch tabIndex {
    | 0 => "Start by downloading your Test API Key and keeping it handy."
    | 1 => "Once your customer is ready to pay, create a payment from your server to establish the intent of the customer to start payment."
    | 2 => "Open the Hyperswitch checkout for your user inside an iFrame to display the payment methods."
    | 3 => "Handle the response and display the thank you page to the user."
    | _ => ""
    }
  | WooCommercePlugin =>
    switch tabIndex {
    | 0 => "Start by downloading the Hyperswitch Checkout Plugin, and installing it on your WordPress Admin Dashboard. Activate the Plugin post installation."
    | 1 => "Step 1. Navigate to Woocommerce > Settings section in the dashboard. Click on the \"Payments\" tab and you should be able to find Hyperswitch listed in the Payment Methods table. Click on \"Hyperswitch\" to land on the Hyperswitch Plugin Settings page."
    | 2 => "Step 2. Generate an API Key and paste it in your WooCommerce Plugin Settings."
    | 3 => "Step 3. Copy your Publishable Key and paste it in your WooCommerce Plugin Settings."
    | 4 => "Step 4. Copy your Payment Response Hash Key and paste it in your WooCommerce Plugin Settings."
    | 5 => "Step 5. Configure your Webhook URL. You can find the Webhook URL on your Plugin Settings page under \"Enable Webhook\" Section."
    | 6 => "Step 6. Save the changes"
    | 7 => "Step 1. Configure connector(s) and start accepting payments."
    | 8 => "Step 2. Configure a Routing Configuration to route payments to optimise your payment traffic across the various configured processors (only if you want to support multiple processors)"
    | 9 => "Step 3. View and Manage your WooCommerce Order Payments on the Hyperswitch Dashboard."
    | _ => ""
    }
  | _ => ""
  }

let getLangauge = (str): languages => {
  switch str->String.toLowerCase {
  | "reactjs" => #ReactJs
  | "node" => #Node
  | "ruby" => #Ruby
  | "java" => #Java
  | "net" => #Net
  | "rust" => #Rust
  | "php" => #Php
  | "shell" => #Shell
  | "python" => #Python
  | "html" => #HTML
  | "go" => #Go
  | "next" => #Next
  | _ => #ChooseLanguage
  }
}
let getPlatform = (str): platforms => {
  switch str->String.toLowerCase {
  | "web" => #Web
  | "ios" => #IOS
  | "android" => #Android
  | "bigcommerce" => #BigCommerce
  | "reactnative" => #ReactNative
  | _ => #Web
  }
}

let getMigrateFromStripeDX = (frontendlang: languages, backendlang: languages): string => {
  open CodeSnippets
  switch (frontendlang, backendlang) {
  | (#ReactJs, #Node) => nodeMigrateFromStripeDXForReact
  | (#HTML, #Node) => nodeMigrateFromStripeDXForHTML
  | _ => ""
  }
}

let getInstallDependencies = (lang: languages): string => {
  open CodeSnippets
  switch lang {
  | #ReactJs => reactInstallDependencies
  | #Node => nodeInstallDependencies
  | _ => ""
  }
}

let getImports = (lang: languages): string => {
  open CodeSnippets
  switch lang {
  | #ReactJs => reactImports
  | _ => ""
  }
}

let getLoad = (lang: languages): string => {
  open CodeSnippets
  switch lang {
  | #ReactJs => reactLoad
  | #HTML => htmlLoad
  | _ => ""
  }
}

let getInitialize = (lang: languages): string => {
  open CodeSnippets
  switch lang {
  | #ReactJs => reactInitialize
  | #HTML => htmlInitialize
  | _ => ""
  }
}

let getCheckoutFormForDisplayCheckoutPage = (lang: languages): string => {
  open CodeSnippets
  switch lang {
  | #ReactJs => reactCheckoutFormDisplayCheckoutPage
  | _ => ""
  }
}

let getHandleEvents = (lang: languages): string => {
  open CodeSnippets
  switch lang {
  | #ReactJs => reactHandleEvent
  | #HTML => htmlHandleEvents
  | _ => ""
  }
}

let getDisplayConformation = (lang: languages): string => {
  open CodeSnippets
  switch lang {
  | #ReactJs => reactDisplayConfirmation
  | #HTML => htmlDisplayConfirmation
  | _ => ""
  }
}

let getReplaceAPIkeys = (lang: languages) => {
  open CodeSnippets
  switch lang {
  | #Node => nodeReplaceApiKey
  | _ => {from: "", to: ""}
  }
}

let getCheckoutForm = (lang: languages) => {
  open CodeSnippets
  switch lang {
  | #ReactJs => reactCheckoutForm
  | #HTML => htmlCheckoutForm
  | _ => {from: "", to: ""}
  }
}

let getHyperswitchCheckout = (lang: languages) => {
  open CodeSnippets
  switch lang {
  | #ReactJs => reactHyperSwitchCheckout
  | #HTML => htmlHyperSwitchCheckout
  | _ => {from: "", to: ""}
  }
}

let getCreateAPayment = (lang: languages): string => {
  open CodeSnippets
  switch lang {
  | #Node => nodeCreateAPayment
  | #Ruby => rubyRequestPayment
  | #Java => javaRequestPayment
  | #Python => pythonRequestPayment
  | #Net => netRequestPayment
  | #Rust => rustRequestPayment
  | #Shell => shellRequestPayment
  | #Go => goRequestPayment
  | #Php => phpRequestPayment
  | _ => ""
  }
}

let getMainPageText = currentRoute =>
  switch currentRoute {
  | MigrateFromStripe => "Migrate from Stripe"
  | IntegrateFromScratch => "Let's start integrating from Scratch"
  | WooCommercePlugin => "Let's start your WooCommerce Integration"
  | _ => "Explore, Build and Integrate"
  }

let getLanguages = currentRoute =>
  switch currentRoute {
  | MigrateFromStripe => (migrateStripfrontEndLang, migrateStripBackEndLang)
  | IntegrateFromScratch => (integrateFromScratchfrontEndLang, integrateFromScratchBackEndlang)
  | SampleProjects => (integrateFromScratchfrontEndLang, integrateFromScratchBackEndlang)
  | _ => ([], [])
  }

// To be refactored
let getFilteredList = (
  frontEndLang: languages,
  backEndLang: languages,
  githubcodespaces: array<sectionContentType>,
) => {
  let felang = Some((frontEndLang :> string)->String.toLowerCase)
  let belang = Some((backEndLang :> string)->String.toLowerCase)
  if felang === Some("chooselanguage") && belang === Some("chooselanguage") {
    githubcodespaces
  } else {
    let filteredList = githubcodespaces->Array.filter(value => {
      if felang === Some("chooselanguage") {
        value.backEndLang === belang
      } else if belang === Some("chooselanguage") {
        value.frontEndLang == felang
      } else {
        value.frontEndLang == felang && value.backEndLang === belang
      }
    })
    filteredList
  }
}

let variantToTextMapperForBuildHS = currentRoute => {
  switch currentRoute {
  | MigrateFromStripe => "migrateFromStripe"
  | IntegrateFromScratch => "integrateFromScratch"
  | WooCommercePlugin => "wooCommercePlugin"
  | _ => "onboarding"
  }
}

let githubCodespaces: array<UserOnboardingTypes.sectionContentType> = [
  {
    headerIcon: "github",
    buttonText: "View Docs",
    customIconCss: "",
    url: "https://github.com/juspay/hyperswitch-html-node",
    frontEndLang: "html",
    backEndLang: "node",
    displayFrontendLang: "HTML",
    displayBackendLang: "Node",
  },
  {
    headerIcon: "github",
    buttonText: "View Docs",
    customIconCss: "",
    url: "https://github.com/juspay/hyperswitch-html-python",
    frontEndLang: "html",
    backEndLang: "python",
    displayFrontendLang: "HTML",
    displayBackendLang: "Python",
  },
  {
    headerIcon: "github",
    buttonText: "View Docs",
    customIconCss: "",
    url: "https://github.com/juspay/hyperswitch-html-php",
    frontEndLang: "html",
    backEndLang: "php",
    displayFrontendLang: "HTML",
    displayBackendLang: "PHP",
  },
  {
    headerIcon: "github",
    buttonText: "View Docs",
    customIconCss: "",
    url: "https://github.com/juspay/hyperswitch-html-go",
    frontEndLang: "html",
    backEndLang: "go",
    displayFrontendLang: "HTML",
    displayBackendLang: "Go",
  },
  {
    headerIcon: "github",
    buttonText: "View Docs",
    customIconCss: "",
    url: "https://github.com/juspay/hyperswitch-html-java",
    frontEndLang: "html",
    backEndLang: "java",
    displayFrontendLang: "HTML",
    displayBackendLang: "Java",
  },
  {
    headerIcon: "github",
    buttonText: "View Docs",
    customIconCss: "",
    url: "https://github.com/juspay/hyperswitch-html-ruby",
    frontEndLang: "html",
    backEndLang: "ruby",
    displayFrontendLang: "HTML",
    displayBackendLang: "Ruby",
  },
  {
    headerIcon: "github",
    buttonText: "View Docs",
    customIconCss: "",
    url: "https://github.com/juspay/hyperswitch-html-dotnet",
    frontEndLang: "html",
    backEndLang: "net",
    displayFrontendLang: "HTML",
    displayBackendLang: ".Net",
  },
  {
    headerIcon: "github",
    buttonText: "View Docs",
    customIconCss: "",
    url: "https://github.com/juspay/hyperswitch-react-node",
    frontEndLang: "reactjs",
    backEndLang: "node",
    displayFrontendLang: "React-Js",
    displayBackendLang: "Node",
  },
  {
    headerIcon: "github",
    buttonText: "View Docs",
    customIconCss: "",
    url: "https://github.com/juspay/hyperswitch-next-node",
    frontEndLang: "next",
    backEndLang: "node",
    displayFrontendLang: "Next-React-Ts",
    displayBackendLang: "Node",
  },
  {
    headerIcon: "github",
    buttonText: "View Docs",
    customIconCss: "",
    url: "https://github.com/juspay/hyperswitch-react-dotnet",
    frontEndLang: "reactjs",
    backEndLang: "net",
    displayFrontendLang: "React-Js",
    displayBackendLang: ".Net",
  },
  {
    headerIcon: "github",
    buttonText: "View Docs",
    customIconCss: "",
    url: "https://github.com/juspay/hyperswitch-react-ruby",
    frontEndLang: "reactjs",
    backEndLang: "ruby",
    displayFrontendLang: "React-Js",
    displayBackendLang: "Ruby",
  },
  {
    headerIcon: "github",
    buttonText: "View Docs",
    customIconCss: "",
    url: "https://github.com/juspay/hyperswitch-react-java",
    frontEndLang: "reactjs",
    backEndLang: "java",
    displayFrontendLang: "React-Js",
    displayBackendLang: "Java",
  },
  {
    headerIcon: "github",
    buttonText: "View Docs",
    customIconCss: "",
    url: "https://github.com/juspay/hyperswitch-react-python",
    frontEndLang: "reactjs",
    backEndLang: "python",
    displayFrontendLang: "React-Js",
    displayBackendLang: "Python",
  },
  {
    headerIcon: "github",
    buttonText: "View Docs",
    customIconCss: "",
    url: "https://github.com/juspay/hyperswitch-react-php",
    frontEndLang: "reactjs",
    backEndLang: "php",
    displayFrontendLang: "React-Js",
    displayBackendLang: "PHP",
  },
  {
    headerIcon: "github",
    buttonText: "View Docs",
    customIconCss: "",
    url: "https://github.com/juspay/hyperswitch-react-go",
    frontEndLang: "reactjs",
    backEndLang: "go",
    displayFrontendLang: "React-Js",
    displayBackendLang: "Go",
  },
]
