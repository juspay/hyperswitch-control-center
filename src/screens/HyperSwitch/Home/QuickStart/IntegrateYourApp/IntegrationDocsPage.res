module RequestPage = {
  @react.component
  let make = (~requestedPlatform, ~currentRoute) => {
    open UserOnboardingTypes
    open UserOnboardingUtils
    open APIUtils

    let updateDetails = useUpdateMethod()
    let showToast = ToastState.useShowToast()
    let requestedValue = requestedPlatform->LogicUtils.capitalizeString
    let (isSubmitButtonEnabled, setIsSubmitButtonEnabled) = React.useState(_ => true)

    let handleSubmitRequest = async () => {
      try {
        let url = getURL(~entityName=USERS, ~userType=#USER_DATA, ~methodType=Post, ())
        let requestedBody =
          [
            ("rating", 5.0->Js.Json.number),
            ("category", "Platform Request"->Js.Json.string),
            ("feedbacks", `Request for ${requestedValue}`->Js.Json.string),
          ]
          ->LogicUtils.getJsonFromArrayOfJson
          ->HSwitchUtils.getBodyForFeedBack()
          ->Js.Json.object_

        let body = [("Feedback", requestedBody)]->LogicUtils.getJsonFromArrayOfJson
        let _ = await updateDetails(url, body, Post)
        showToast(
          ~toastType=ToastSuccess,
          ~message="Request submitted successfully!",
          ~autoClose=false,
          (),
        )
        setIsSubmitButtonEnabled(_ => false)
      } catch {
      | _ => ()
      }
    }

    React.useEffect1(() => {
      setIsSubmitButtonEnabled(_ => true)
      None
    }, [requestedValue])

    let handleButtonClick = () => {
      switch currentRoute {
      | MigrateFromStripe =>
        switch requestedValue->getPlatform {
        | #IOS => Window._open("https://hyperswitch.io/docs/migrateFromStripe/migrateFromStripeIos")
        | #Android =>
          Window._open("https://hyperswitch.io/docs/migrateFromStripe/migrateFromStripeAndroid")
        | #ReactNative =>
          Window._open("https://hyperswitch.io/docs/migrateFromStripe/migrateFromStripeRN")
        | _ => handleSubmitRequest()->ignore
        }
      | _ => handleSubmitRequest()->ignore
      }
    }

    let buttonText = () => {
      switch currentRoute {
      | MigrateFromStripe =>
        switch requestedValue->getPlatform {
        | #IOS | #Android | #ReactNative => "Go to Developers Docs"
        | _ => "I'm Interested"
        }
      | _ => "I'm Interested"
      }
    }

    let subText = () => {
      switch currentRoute {
      | MigrateFromStripe =>
        switch requestedValue->getPlatform {
        | #IOS | #Android | #ReactNative =>
          `You can access the Integration docs for ${requestedValue} plugin on our Developer docs, we will be updating it here shortly.`
        | _ => "Our team is currently working to make this available for you soon.Please reach out to us on our Slack for any queries."
        }
      | _ => "Our team is currently working to make this available for you soon.Please reach out to us on our Slack for any queries."
      }
    }

    <div
      className="border bg-jp-gray-light_gray_bg rounded-md p-6 overflow-scroll flex flex-col justify-center items-center gap-6">
      <Icon name={requestedValue->String.toLowerCase} size=180 className="!scale-200" />
      <div className="flex flex-col gap-2 items-center justify-center">
        <p className="text-2xl font-semibold text-grey-700">
          {`${requestedValue} (Coming Soon)`->React.string}
        </p>
        <p className="text-base font-semibold text-grey-700 opacity-50 w-1/2 text-center">
          {subText()->React.string}
        </p>
      </div>
      <Button
        text={buttonText()}
        buttonType={Primary}
        onClick={_ => handleButtonClick()}
        buttonState={isSubmitButtonEnabled ? Normal : Disabled}
        customButtonStyle="!rounded-md"
      />
    </div>
  }
}
@react.component
let make = (
  ~currentRoute,
  ~isFromOnboardingChecklist=false,
  ~markAsDone,
  ~languageSelection=true,
) => {
  open UserOnboardingUtils
  open UserOnboardingTypes

  let (frontEndLang, setFrontEndLang) = React.useState(_ =>
    currentRoute === SampleProjects ? #ChooseLanguage : #ReactJs
  )
  let (backEndLang, setBackEndLang) = React.useState(_ =>
    currentRoute === SampleProjects ? #ChooseLanguage : #Node
  )
  let (platform, setPlatform) = React.useState(_ => #Web)
  let merchantDetails =
    Recoil.useRecoilValueFromAtom(HyperswitchAtom.merchantDetailsValueAtom)
    ->LogicUtils.safeParse
    ->LogicUtils.getDictFromJsonObject
  let publishablekeyMerchant = merchantDetails->LogicUtils.getString("publishable_key", "")
  let theme = switch ThemeProvider.useTheme() {
  | Dark => "vs-dark"
  | Light => "light"
  }

  let _ = UserOnboardingUIUtils.getTabsForIntegration(
    ~currentRoute,
    ~tabIndex=0,
    ~frontEndLang,
    ~theme,
    ~backEndLang,
    ~publishablekeyMerchant,
  )

  // let handleDeveloperDocs = () => {
  //   let contextName = `${currentRoute->variantToTextMapperForBuildHS}_${tabIndex->currentTabName}`
  //   hyperswitchMixPanel(
  //     ~pageName=`${url.path->LogicUtils.getListHead}`,
  //     ~contextName,
  //     ~actionName="developerdocs",
  //     (),
  //   )
  //   switch currentRoute {
  //   | MigrateFromStripe => Window._open("https://hyperswitch.io/docs/migrateFromStripe")
  //   | IntegrateFromScratch => Window._open("https://hyperswitch.io/docs/quickstart")
  //   | WooCommercePlugin =>
  //     Window._open(
  //       "https://hyperswitch.io/docs/sdkIntegrations/wooCommercePlugin/wooCommercePluginSetup",
  //     )
  //   | _ => Window._open("https://hyperswitch.io/docs/")
  //   }
  // }
  let getRequestedPlatforms = () => {
    if requestOnlyPlatforms->Array.includes(platform) {
      Some((platform :> string))
    } else if !([#Node]->Array.includes(backEndLang)) && currentRoute === MigrateFromStripe {
      Some((backEndLang :> string))
    } else {
      None
    }
  }

  let requestedPlatform = getRequestedPlatforms()

  {
    switch requestedPlatform {
    | Some(platformStr) =>
      <div className="flex flex-col gap-2">
        <UserOnboardingUIUtils.BackendFrontendPlatformLangDropDown
          frontEndLang setFrontEndLang backEndLang setBackEndLang currentRoute platform setPlatform
        />
        <RequestPage requestedPlatform=platformStr currentRoute />
      </div>
    | None =>
      switch currentRoute {
      | MigrateFromStripe =>
        <MigrateFromStripe
          currentRoute
          frontEndLang
          setFrontEndLang
          backEndLang
          setBackEndLang
          platform
          setPlatform
          markAsDone
        />
      | IntegrateFromScratch =>
        <IntegrateFromScratch
          currentRoute
          frontEndLang
          setFrontEndLang
          backEndLang
          setBackEndLang
          platform
          setPlatform
          markAsDone
        />
      | _ => <> </>
      }
    }
  }
}
