module RequestPage = {
  @react.component
  let make = (~requestedPlatform, ~currentRoute) => {
    open UserOnboardingTypes
    open UserOnboardingUtils
    open APIUtils

    let requestedValue =
      requestedPlatform->Belt.Option.getWithDefault("")->LogicUtils.capitalizeString
    let (isSubmitButtonEnabled, setIsSubmitButtonEnabled) = React.useState(_ => true)
    let showToast = ToastState.useShowToast()
    let updateDetails = useUpdateMethod()

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
      className="border bg-jp-gray-light_gray_bg h-full rounded-md p-6 overflow-scroll flex flex-col justify-center items-center gap-6">
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
  ~markAsDone=?,
  ~languageSelection=true,
) => {
  open UserOnboardingUtils
  open UserOnboardingTypes
  let (tabIndex, setTabIndex) = React.useState(_ => 0)
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

  open Tabs
  let tabs = UserOnboardingUIUtils.getTabsForIntegration(
    ~currentRoute,
    ~tabIndex,
    ~frontEndLang,
    ~theme,
    ~backEndLang,
    ~publishablekeyMerchant,
  )

  let handleMarkAsDone = () => {
    switch markAsDone {
    | Some(fun) => fun()->ignore
    | _ => ()->ignore
    }
  }
  let handleDeveloperDocs = () => {
    switch currentRoute {
    | MigrateFromStripe => Window._open("https://hyperswitch.io/docs/migrateFromStripe")
    | IntegrateFromScratch => Window._open("https://hyperswitch.io/docs/quickstart")
    | WooCommercePlugin =>
      Window._open(
        "https://hyperswitch.io/docs/sdkIntegrations/wooCommercePlugin/wooCommercePluginSetup",
      )
    | _ => Window._open("https://hyperswitch.io/docs/")
    }
  }
  let getRequestedPlatforms = () => {
    if requestOnlyPlatforms->Array.includes(platform) {
      Some((platform :> string))
    } else if !([#Node]->Array.includes(backEndLang)) && currentRoute === MigrateFromStripe {
      Some((backEndLang :> string))
    } else {
      None
    }
  }

  let buttonStyle =
    tabIndex === tabs->Array.length - 1
      ? "!border !border-blue-700 !rounded-md bg-white !text-blue-700"
      : "!rounded-md"
  let requestedPlatform = getRequestedPlatforms()
  <div className="w-full h-full flex flex-col bg-white">
    <UserOnboardingUIUtils.ProgressBar tabs tabIndex />
    <div className="flex flex-col w-full h-full p-6 gap-4 ">
      <div
        className={`flex ${languageSelection ? "justify-between" : "justify-end"} flex-wrap gap-2`}>
        <UIUtils.RenderIf condition=languageSelection>
          <UserOnboardingUIUtils.BackendFrontendPlatformLangDropDown
            frontEndLang
            setFrontEndLang
            backEndLang
            setBackEndLang
            currentRoute
            platform
            setPlatform
          />
        </UIUtils.RenderIf>
        <UIUtils.RenderIf condition={!isFromOnboardingChecklist}>
          <Button
            text={"Mark as done"}
            customButtonStyle=buttonStyle
            buttonType={Secondary}
            buttonSize={Small}
            buttonState={tabIndex === tabs->Array.length - 1 ? Normal : Disabled}
            onClick={_ => handleMarkAsDone()}
          />
        </UIUtils.RenderIf>
      </div>
      {if requestedPlatform->Belt.Option.isSome {
        <RequestPage requestedPlatform currentRoute />
      } else {
        <div className="flex flex-col my-4">
          <Tabs
            initialIndex={tabIndex}
            tabs
            showBorder=false
            includeMargin=false
            lightThemeColor="black"
            renderedTabClassName="!h-full"
            gapBetweenTabs="gap-0"
            borderSelectionStyle="border-l-1 border-r-1 border-t-1 !p-4 !border-grey-600 !w-full"
            borderDefaultStyle="border-b-1 !p-4 !border-grey-600 "
            showBottomBorder=false
            defaultClasses="w-max flex flex-auto flex-row items-center justify-center px-6  font-semibold text-body"
            onTitleClick={indx => {
              setTabIndex(_ => indx)
            }}
          />
          <UIUtils.RenderIf condition={tabIndex !== tabs->Array.length - 1}>
            <div className="flex my-4 w-full justify-end">
              <Button
                text={"Next Step"}
                customButtonStyle=buttonStyle
                rightIcon={CustomIcon(
                  <Icon
                    name="arrow-right"
                    size=15
                    className="mr-1 jp-gray-900 fill-opacity-50 dark:jp-gray-text_darktheme"
                  />,
                )}
                buttonType={Secondary}
                buttonSize={Small}
                onClick={_ => {
                  setTabIndex(indx => indx + 1)
                }}
              />
            </div>
          </UIUtils.RenderIf>
          <div className="flex gap-1 flex-wrap pb-5 justify-between ">
            <div className="flex gap-2">
              <p className="text-base font-normal text-grey-700">
                {"Explore our detailed developer documentation on our"->React.string}
              </p>
              <p
                className="text-base font-semibold text-blue-700 cursor-pointer underline"
                onClick={_ => handleDeveloperDocs()}>
                {"Developer Docs"->React.string}
              </p>
            </div>
          </div>
        </div>
      }}
    </div>
  </div>
}
