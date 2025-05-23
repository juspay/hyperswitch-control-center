open UserOnboardingTypes
open UserOnboardingUtils
open LogicUtils

module ProgressBar = {
  @react.component
  let make = (~tabs, ~tabIndex) => {
    let {globalUIConfig: {primaryColor}} = React.useContext(ThemeProvider.themeContext)
    let defaultStyle = currentIndex => {
      currentIndex < tabIndex + 1
        ? `${primaryColor} h-1.5 w-full`
        : `${primaryColor} opacity-10 h-1.5 w-full`
    }
    <div className="flex w-full">
      {tabs
      ->Array.mapWithIndex((_val, i) =>
        <div key={Int.toString(i)} className={`${i->defaultStyle}`} />
      )
      ->React.array}
    </div>
  }
}

module PublishableKeyArea = {
  @react.component
  let make = () => {
    let merchantDetailsValue = MerchantDetailsHook.useMerchantDetailsValue()
    <HelperComponents.KeyAndCopyArea copyValue={merchantDetailsValue.publishable_key} />
  }
}

module PaymentResponseHashKeyArea = {
  @react.component
  let make = () => {
    let merchantDetailsValue = MerchantDetailsHook.useMerchantDetailsValue()
    <HelperComponents.KeyAndCopyArea
      copyValue={merchantDetailsValue.payment_response_hash_key->Option.getOr("")}
    />
  }
}

module DownloadAPIKeyButton = {
  @react.component
  let make = (
    ~buttonText,
    ~currentRoute=OnboardingDefault,
    ~currentTabName="",
    ~buttonStyle="",
  ) => {
    let getURL = APIUtils.useGetURL()
    let updateDetails = APIUtils.useUpdateMethod(~showErrorToast=false)
    let showToast = ToastState.useShowToast()
    let (showCopyToClipboard, setShowCopyToClipboard) = React.useState(_ => false)

    let apiKeyGeneration = async () => {
      try {
        let url = getURL(~entityName=V1(API_KEYS), ~methodType=Post)
        let body =
          [
            ("name", "DefaultAPIKey"->JSON.Encode.string),
            ("description", "Default Value of the API key"->JSON.Encode.string),
            ("expiration", "never"->JSON.Encode.string),
          ]->Dict.fromArray
        let res = await updateDetails(url, body->JSON.Encode.object, Post)
        let apiKey = res->getDictFromJsonObject->getString("api_key", "")
        DownloadUtils.downloadOld(~fileName=`apiKey.txt`, ~content=apiKey)
        Clipboard.writeText(apiKey)
        await HyperSwitchUtils.delay(1000)
        showToast(
          ~message="Api Key has been generated & Copied to clipboard",
          ~toastType=ToastState.ToastSuccess,
        )
        setShowCopyToClipboard(_ => true)
        await HyperSwitchUtils.delay(2000)
        setShowCopyToClipboard(_ => false)
      } catch {
      | _ => showToast(~message="Api Key Generation Failed", ~toastType=ToastState.ToastError)
      }
    }

    let downloadZip = async () => {
      await HyperSwitchUtils.delay(1500)
      showToast(~message="Plugin file has been downloaded!", ~toastType=ToastState.ToastSuccess)
    }
    let button =
      <div className="flex items-center gap-5">
        <Button
          text=buttonText
          buttonSize={Medium}
          buttonType={Primary}
          customButtonStyle={`!w-1/3 ${buttonStyle}`}
          rightIcon={FontAwesome("download-api-key")}
          onClick={_ => {
            switch currentTabName {
            | "downloadWordpressPlugin" => downloadZip()->ignore
            | _ => apiKeyGeneration()->ignore
            }
          }}
        />
        <RenderIf condition=showCopyToClipboard>
          <div className="text-green-700 text-lg"> {"Copied to clipboard"->React.string} </div>
        </RenderIf>
      </div>
    switch currentRoute {
    | WooCommercePlugin =>
      <a href="https://hyperswitch.io/zip/hyperswitch-checkout.zip"> {button} </a>
    | _ => button
    }
  }
}
module DownloadAPIKey = {
  @react.component
  let make = (~currentRoute, ~currentTabName) => {
    <div className="flex flex-col gap-10">
      <HSwitchUtils.AlertBanner
        bannerText="API key once misplaced cannot be restored. If misplaced, please re-generate a new key from Dashboard > Developers."
        bannerType=Warning
      />
      <div className="p-10 bg-gray-50 border rounded flex flex-col gap-6">
        <div className="flex flex-col gap-2.5">
          <div className="text-base text-grey-900 font-medium">
            {"Test API Key"->React.string}
          </div>
          <p className="text-sm text-grey-50">
            {"Use this key to authenticate all API requests from your application’s server"->React.string}
          </p>
        </div>
        <DownloadAPIKeyButton buttonText="Download API key" currentRoute currentTabName />
      </div>
    </div>
  }
}

module DownloadWordPressPlugin = {
  @react.component
  let make = (~currentRoute, ~currentTabName) => {
    <DownloadAPIKeyButton buttonText="Download Plugin" currentRoute currentTabName />
  }
}

module TabsContentWrapper = {
  @react.component
  let make = (~children, ~tabIndex, ~currentRoute, ~customUi=React.null) => {
    let textClass = switch currentRoute {
    | WooCommercePlugin => "text-lg"
    | _ => "text-base"
    }
    <div className="!h-full !w-full py-5 flex flex-col gap-4">
      <div className="flex justify-between w-full items-center">
        <p className={`${textClass} font-medium py-2`}>
          {getContentBasedOnIndex(~currentRoute, ~tabIndex)->React.string}
        </p>
      </div>
      {customUi}
      <div className="border bg-jp-gray-light_gray_bg h-full rounded-md p-6 overflow-scroll">
        {children}
      </div>
    </div>
  }
}
module HeaderComponentView = {
  @react.component
  let make = (~value, ~headerText, ~langauge: languages) => {
    let showToast = ToastState.useShowToast()
    <div
      className="flex flex-row justify-between items-center flex-wrap border-b px-4 py-6 text-gray-900">
      <p className="font-medium text-base"> {headerText->React.string} </p>
      <div className="flex gap-2">
        <div className="py-1 px-4 border rounded-md flex gap-2 items-center">
          <Icon name={`${(langauge :> string)->String.toLowerCase}`} size=16 />
          <p> {(langauge :> string)->React.string} </p>
        </div>
        <div
          className="py-1 px-4 border rounded-md flex gap-2 items-center cursor-pointer"
          onClick={_ => {
            Clipboard.writeText(value)
            showToast(~message="Copied to Clipboard!", ~toastType=ToastSuccess)
          }}>
          <Icon name="nd-copy" className="cursor-pointer" />
          <p> {"Copy"->React.string} </p>
        </div>
      </div>
    </div>
  }
}

module ShowCodeEditor = {
  @react.component
  let make = (~value, ~theme, ~headerText, ~customHeight="8vh", ~langauge: languages) => {
    <ReactSuspenseWrapper>
      <MonacoEditorLazy
        defaultLanguage="javascript"
        height=customHeight
        width="w-[90vh]"
        theme
        value
        readOnly=true
        minimap=false
        showCopy=false
        headerComponent={<HeaderComponentView value headerText langauge />}
      />
    </ReactSuspenseWrapper>
  }
}
module DiffCodeEditor = {
  @react.component
  let make = (~valueToShow: migratestripecode, ~langauge: languages) => {
    let _oldValue = valueToShow.from
    let newValue = valueToShow.to
    <div
      className="flex flex-col gap-6 border bg-white overflow-x-scroll w-full !shadow-hyperswitch_box_shadow rounded-md">
      <HeaderComponentView value=newValue headerText="Replace" langauge />
      // Add Diff Editior
      <div className="p-4" />
    </div>
  }
}

module BackendFrontendPlatformLangDropDown = {
  @react.component
  let make = (
    ~frontEndLang: languages,
    ~setFrontEndLang,
    ~backEndLang: languages,
    ~setBackEndLang,
    ~isFromLanding=false,
    ~currentRoute,
    ~platform: platforms,
    ~setPlatform,
  ) => {
    let platfromInput: ReactFinalForm.fieldRenderPropsInput = {
      name: "Platform Selecr",
      onBlur: _ => (),
      onChange: ev => {
        let val = ev->Identity.formReactEventToString->getPlatform
        setPlatform(_ => val)
      },
      onFocus: _ => (),
      value: (platform :> string)->JSON.Encode.string,
      checked: true,
    }
    let options = platforms->Array.map((op): SelectBox.dropdownOption => {
      {value: (op :> string), label: (op :> string)}
    })

    let backendLangInput: ReactFinalForm.fieldRenderPropsInput = {
      name: "BackEnd",
      onBlur: _ => (),
      onChange: ev => {
        let val = ev->Identity.formReactEventToString->getLangauge
        setBackEndLang(_ => val)
      },
      onFocus: _ => (),
      value: (backEndLang :> string)->JSON.Encode.string,
      checked: true,
    }
    let frontendLangInput: ReactFinalForm.fieldRenderPropsInput = {
      name: "FrontEnd",
      onBlur: _ => (),
      onChange: ev => {
        let val = ev->Identity.formReactEventToString->getLangauge
        setFrontEndLang(_ => val)
      },
      onFocus: _ => (),
      value: (frontEndLang :> string)->JSON.Encode.string,
      checked: true,
    }
    let (frontendLangauge, backendLangauge) = currentRoute->getLanguages
    let frontendDropdownText = {
      frontEndLang === #ChooseLanguage ? "Choose Frontend" : (frontEndLang :> string)
    }
    let backendDropdownText = {
      backEndLang === #ChooseLanguage ? "Choose Backend" : (backEndLang :> string)
    }

    <Form initialValues={Dict.make()->JSON.Encode.object}>
      <div className="flex flex-row gap-4 flex-wrap">
        <RenderIf condition={!isFromLanding && currentRoute !== SampleProjects}>
          <SelectBox.BaseDropdown
            allowMultiSelect=false
            buttonText="Select Platform"
            input={platfromInput}
            options
            hideMultiSelectButtons=true
            deselectDisable=true
            defaultLeftIcon=CustomIcon(<Icon name="show-filters" size=14 />)
            baseComponent={<Button
              text={(platform :> string)}
              buttonSize=Button.Small
              leftIcon=Button.CustomIcon(
                <Icon size=20 name={`${(platform :> string)->String.toLowerCase}`} />,
              )
              rightIcon=Button.CustomIcon(<Icon className="pl-2 " size=20 name="chevron-down" />)
              ellipsisOnly=true
              customButtonStyle="!bg-white !border"
            />}
          />
        </RenderIf>
        <RenderIf condition={!(requestOnlyPlatforms->Array.includes(platform))}>
          <SelectBox.BaseDropdown
            allowMultiSelect=false
            buttonText="Select Frontend"
            deselectDisable=true
            input={frontendLangInput}
            options={frontendLangauge->Array.map((lang): SelectBox.dropdownOption => {
              {value: (lang :> string), label: (lang :> string)}
            })}
            hideMultiSelectButtons=true
            autoApply=false
            customStyle="!rounded-md"
            baseComponent={<Button
              text=frontendDropdownText
              buttonSize=Button.Small
              leftIcon=Button.CustomIcon(
                <Icon size=20 name={`${(frontEndLang :> string)->String.toLowerCase}`} />,
              )
              rightIcon=Button.CustomIcon(<Icon className="pl-2 " size=20 name="chevron-down" />)
              ellipsisOnly=true
              buttonType=Secondary
            />}
          />
          <SelectBox.BaseDropdown
            allowMultiSelect=false
            buttonText="Select Backend"
            input={backendLangInput}
            deselectDisable=true
            options={backendLangauge->Array.map((lang): SelectBox.dropdownOption => {
              {value: (lang :> string), label: (lang :> string)}
            })}
            hideMultiSelectButtons=true
            baseComponent={<Button
              text=backendDropdownText
              buttonSize=Button.Small
              leftIcon=Button.CustomIcon(
                <Icon size=20 name={`${(backEndLang :> string)->String.toLowerCase}`} />,
              )
              rightIcon=Button.CustomIcon(<Icon className="pl-2 " size=20 name="chevron-down" />)
              ellipsisOnly=true
              buttonType=Secondary
            />}
          />
        </RenderIf>
      </div>
    </Form>
  }
}

module LanguageTag = {
  @react.component
  let make = (~frontendLang="", ~backendLang="") => {
    <RenderIf condition={frontendLang->isNonEmptyString && backendLang->isNonEmptyString}>
      <div className="flex gap-2 items-center">
        <Icon name={`${frontendLang}`} size=25 />
        <Icon name={`${backendLang}`} size=25 />
      </div>
    </RenderIf>
  }
}

let headerTextCss = "font-semibold text-grey-700 text-xl"
let subTextCss = "font-normal text-grey-700 opacity-50 text-base"
module LandingPageTileForIntegrateDocs = {
  @react.component
  let make = (
    ~headerIcon,
    ~headerText,
    ~subText,
    ~buttonText,
    ~customIconCss,
    ~url,
    ~isIconImg,
    ~imagePath,
    ~leftSection,
    ~isFromOnboardingChecklist,
    ~subTextCustomValues,
    ~buttonType: Button.buttonType=Secondary,
    ~isSkipButton=false,
    ~isTileVisible=true,
    ~rightIcon,
    ~customRedirection=?,
  ) => {
    open APIUtils
    let getURL = useGetURL()
    let updateDetails = useUpdateMethod(~showErrorToast=false)
    let {
      integrationDetails,
      setIntegrationDetails,
      dashboardPageState,
      setDashboardPageState,
    } = React.useContext(GlobalProvider.defaultContext)
    let redirect = () => {
      if customRedirection->Option.isSome {
        RescriptReactRouter.replace(
          GlobalVars.appendDashboardPath(
            ~url=`/${customRedirection->Option.getOr("")}?type=${url}`,
          ),
        )
      } else {
        RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url=`/onboarding?type=${url}`))
      }
    }
    let skipAndContinue = async () => {
      try {
        let url = getURL(~entityName=V1(INTEGRATION_DETAILS), ~methodType=Post)
        let metaDataDict = Dict.fromArray([("is_skip", true->JSON.Encode.bool)])->JSON.Encode.object
        let body = HSwitchUtils.constructOnboardingBody(
          ~dashboardPageState,
          ~integrationDetails,
          ~is_done=false,
          ~metadata=metaDataDict,
        )
        let _ = await updateDetails(url, body, Post)
        setIntegrationDetails(_ => body->ProviderHelper.getIntegrationDetails)
      } catch {
      | _ => ()
      }
      setDashboardPageState(_ => #HOME)
    }
    <RenderIf condition={!isFromOnboardingChecklist || isTileVisible}>
      <div
        className="p-8 border rounded-md flex flex-col gap-7 justify-between bg-white w-full md:w-1/3">
        <div className="flex justify-between flex-wrap">
          {if isIconImg {
            <div className="w-30 h-8">
              <img alt="image" src=imagePath />
            </div>
          } else {
            <Icon size=35 name=headerIcon className=customIconCss />
          }}
          <RenderIf condition={rightIcon->Option.isSome}>
            {rightIcon->Option.getOr(React.null)}
          </RenderIf>
          {leftSection}
        </div>
        <div className="flex flex-col gap-2">
          <p className=headerTextCss> {headerText->React.string} </p>
          <RenderIf condition={subText->Option.isSome}>
            <p className=subTextCss> {subText->Option.getOr("")->React.string} </p>
          </RenderIf>
          <div>
            <RenderIf condition={subTextCustomValues->Option.isSome}>
              <div className={`flex flex-col gap-3 mt-4`}>
                {subTextCustomValues
                ->Option.getOr([])
                ->Array.mapWithIndex((val, index) => {
                  <div key={index->Int.toString} className=subTextCss> {val->React.string} </div>
                })
                ->React.array}
              </div>
            </RenderIf>
          </div>
        </div>
        <Button
          text=buttonText
          buttonType
          onClick={_ => isSkipButton ? skipAndContinue()->ignore : redirect()}
        />
      </div>
    </RenderIf>
  }
}

module LandingPageTileForGithub = {
  @react.component
  let make = (~headerIcon, ~customIconCss, ~url, ~displayFrontendLang, ~displayBackendLang) => {
    let redirect = () => {
      Window._open(url)
    }
    <div
      className={`p-5 border rounded-md flex flex-col gap-4 justify-between bg-white cursor-pointer hover:bg-jp-gray-light_gray_bg`}
      onClick={_ => redirect()}>
      <div>
        <div className="flex items-center justify-between">
          <div className="flex items-center">
            <p className=headerTextCss> {displayFrontendLang->React.string} </p>
            <Icon name="small-dot" />
            <p className=headerTextCss> {displayBackendLang->React.string} </p>
          </div>
          <Icon name="open-new-tab" customIconColor="black" />
        </div>
      </div>
      <div className="flex items-center gap-3">
        <Icon size=20 name=headerIcon className=customIconCss />
        <div className="text-md text-grey-600"> {"Web"->React.string} </div>
      </div>
    </div>
  }
}
module Section = {
  @react.component
  let make = (
    ~sectionHeaderText,
    ~sectionSubText,
    ~subSectionArray: array<UserOnboardingTypes.sectionContentType>,
    ~leftSection=<> </>,
    ~isFromOnboardingChecklist=false,
    ~isGithubSection=false,
    ~customRedirection=?,
  ) => {
    <div className="flex flex-col gap-6">
      <div className="flex justify-between items-center flex-wrap">
        <div className="flex flex-col gap-1">
          <p className=headerTextCss> {sectionHeaderText->React.string} </p>
          <p className=subTextCss> {sectionSubText->React.string} </p>
        </div>
        {leftSection}
      </div>
      <div
        className={` ${isGithubSection
            ? "grid grid-cols-1 md:grid-cols-3"
            : "flex md:flex-row flex-col items-center flex-wrap gap-16"} gap-6`}>
        {subSectionArray
        ->Array.mapWithIndex((subSectionValue, index) => {
          isGithubSection
            ? <LandingPageTileForGithub
                key={index->Int.toString}
                headerIcon=subSectionValue.headerIcon
                customIconCss=subSectionValue.customIconCss
                url=subSectionValue.url
                displayFrontendLang={subSectionValue.displayFrontendLang->Option.getOr("")}
                displayBackendLang={subSectionValue.displayBackendLang->Option.getOr("")}
              />
            : <LandingPageTileForIntegrateDocs
                key={index->Int.toString}
                headerIcon=subSectionValue.headerIcon
                headerText={subSectionValue.headerText->Option.getOr("")}
                subText=subSectionValue.subText
                buttonText=subSectionValue.buttonText
                customIconCss=subSectionValue.customIconCss
                url=subSectionValue.url
                isIconImg={subSectionValue.isIconImg->Option.getOr(false)}
                imagePath={subSectionValue.imagePath->Option.getOr("")}
                leftSection={<LanguageTag
                  frontendLang={subSectionValue.frontEndLang->Option.getOr("")}
                  backendLang={subSectionValue.backEndLang->Option.getOr("")}
                />}
                isFromOnboardingChecklist
                subTextCustomValues=subSectionValue.subTextCustomValues
                buttonType={subSectionValue.buttonType->Option.getOr(Secondary)}
                isSkipButton={subSectionValue.isSkipButton->Option.getOr(false)}
                isTileVisible={subSectionValue.isTileVisible->Option.getOr(true)}
                rightIcon={subSectionValue.rightIcon}
                customRedirection={customRedirection->Option.getOr("")}
              />
        })
        ->React.array}
      </div>
    </div>
  }
}

module CreatePayment = {
  @react.component
  let make = (~currentRoute, ~tabIndex, ~defaultEditorStyle, ~backEndLang, ~theme) => {
    let {globalUIConfig: {font: {textColor}}} = React.useContext(ThemeProvider.themeContext)
    <TabsContentWrapper
      currentRoute
      tabIndex
      customUi={<p className="text-base font-normal py-2 flex gap-2">
        {"For the complete API schema, refer "->React.string}
        <p
          className={`${textColor.primaryNormal} underline cursor-pointer`}
          onClick={_ =>
            Window._open(
              "https://api-reference.hyperswitch.io/docs/hyperswitch-api-reference/60bae82472db8-payments-create",
            )}>
          {"API docs"->React.string}
        </p>
      </p>}>
      <div className=defaultEditorStyle>
        <RenderIf condition={backEndLang->getInstallDependencies->isNonEmptyString}>
          <ShowCodeEditor
            value={backEndLang->getInstallDependencies}
            theme
            headerText="Installation"
            langauge=backEndLang
          />
          <div className="w-full h-px bg-jp-gray-700" />
        </RenderIf>
        <ShowCodeEditor
          value={backEndLang->getCreateAPayment}
          theme
          headerText="Request"
          customHeight="25vh"
          langauge=backEndLang
        />
      </div>
    </TabsContentWrapper>
  }
}

let getTabsForIntegration = (
  ~currentRoute,
  ~tabIndex,
  ~frontEndLang,
  ~theme,
  ~backEndLang,
  ~publishablekeyMerchant,
) => {
  open Tabs
  let defaultEditorStyle = "flex flex-col gap-8 bg-white flex flex-col px-6 py-4 border !shadow-hyperswitch_box_shadow rounded-md"
  // let updateDetails = APIUtils.useUpdateMethod(~showErrorToast=false)
  // let {integrationDetails, setIntegrationDetails, dashboardPageState} = React.useContext(
  //   GlobalProvider.defaultContext,
  // )

  switch currentRoute {
  | MigrateFromStripe => [
      {
        title: "1. Download API Key",
        renderContent: () =>
          <TabsContentWrapper currentRoute tabIndex>
            <DownloadAPIKey currentRoute currentTabName="downloadApiKey" />
          </TabsContentWrapper>,
      },
      {
        title: "2. Install Dependencies",
        renderContent: () =>
          <TabsContentWrapper currentRoute tabIndex>
            <div className=defaultEditorStyle>
              <ShowCodeEditor
                value={frontEndLang->getMigrateFromStripeDX(backEndLang)}
                theme
                headerText="Installation"
                langauge=backEndLang
              />
            </div>
          </TabsContentWrapper>,
      },
      {
        title: "3. Replace API Key",
        renderContent: () =>
          <TabsContentWrapper currentRoute tabIndex>
            <DiffCodeEditor valueToShow={backEndLang->getReplaceAPIkeys} langauge=backEndLang />
          </TabsContentWrapper>,
      },
      {
        title: "4. Reconfigure Checkout Form",
        renderContent: () =>
          <TabsContentWrapper currentRoute tabIndex customUi={<PublishableKeyArea />}>
            <DiffCodeEditor valueToShow={frontEndLang->getCheckoutForm} langauge=frontEndLang />
          </TabsContentWrapper>,
      },
      {
        title: "5. Load HyperSwitch Checkout",
        renderContent: () =>
          <TabsContentWrapper currentRoute tabIndex customUi={<PublishableKeyArea />}>
            <DiffCodeEditor
              valueToShow={frontEndLang->getHyperswitchCheckout} langauge=frontEndLang
            />
          </TabsContentWrapper>,
      },
    ]
  | IntegrateFromScratch => [
      {
        title: "1. Download API Key",
        renderContent: () =>
          <TabsContentWrapper currentRoute tabIndex>
            <DownloadAPIKey currentRoute currentTabName="downloadApiKey" />
          </TabsContentWrapper>,
      },
      {
        title: "2. Create a Payment",
        renderContent: () =>
          <CreatePayment currentRoute tabIndex defaultEditorStyle backEndLang theme />,
      },
      {
        title: "3. Display Checkout Page",
        renderContent: () =>
          <TabsContentWrapper currentRoute tabIndex customUi={<PublishableKeyArea />}>
            <div className=defaultEditorStyle>
              <RenderIf condition={frontEndLang->getInstallDependencies->isNonEmptyString}>
                <ShowCodeEditor
                  value={frontEndLang->getInstallDependencies}
                  theme
                  headerText="Installation"
                  langauge=frontEndLang
                />
                <div className="w-full h-px bg-jp-gray-700" />
              </RenderIf>
              <RenderIf condition={frontEndLang->getInstallDependencies->isNonEmptyString}>
                <ShowCodeEditor
                  value={frontEndLang->getImports} theme headerText="Imports" langauge=frontEndLang
                />
                <div className="w-full h-px bg-jp-gray-700" />
              </RenderIf>
              <RenderIf condition={frontEndLang->getLoad->isNonEmptyString}>
                <ShowCodeEditor
                  value={frontEndLang->getLoad} theme headerText="Load" langauge=frontEndLang
                />
                <div className="w-full h-px bg-jp-gray-700" />
              </RenderIf>
              <RenderIf condition={frontEndLang->getInitialize->isNonEmptyString}>
                <ShowCodeEditor
                  value={frontEndLang->getInitialize}
                  theme
                  headerText="Initialize"
                  langauge=frontEndLang
                />
                <div className="w-full h-px bg-jp-gray-700" />
              </RenderIf>
              <RenderIf
                condition={frontEndLang->getCheckoutFormForDisplayCheckoutPage->isNonEmptyString}>
                <ShowCodeEditor
                  value={frontEndLang->getCheckoutFormForDisplayCheckoutPage}
                  theme
                  headerText="Checkout Form"
                  langauge=frontEndLang
                />
              </RenderIf>
            </div>
          </TabsContentWrapper>,
      },
      {
        title: "4. Display Payment Confirmation",
        renderContent: () =>
          <TabsContentWrapper currentRoute tabIndex customUi={<PublishableKeyArea />}>
            <div className=defaultEditorStyle>
              <RenderIf condition={frontEndLang->getHandleEvents->isNonEmptyString}>
                <ShowCodeEditor
                  value={frontEndLang->getHandleEvents}
                  theme
                  headerText="Handle Events"
                  customHeight="20vh"
                  langauge=frontEndLang
                />
                <div className="w-full h-px bg-jp-gray-700" />
              </RenderIf>
              <RenderIf condition={frontEndLang->getDisplayConformation->isNonEmptyString}>
                <ShowCodeEditor
                  value={frontEndLang->getDisplayConformation}
                  theme
                  headerText="Display Payment Confirmation"
                  customHeight="20vh"
                  langauge=frontEndLang
                />
              </RenderIf>
            </div>
          </TabsContentWrapper>,
      },
    ]

  | SampleProjects => [
      {
        title: "1. Download API Key",
        renderContent: () =>
          <TabsContentWrapper currentRoute tabIndex>
            <DownloadAPIKey currentRoute currentTabName="1.downloadaPIkey" />
          </TabsContentWrapper>,
      },
      {
        title: "2. Explore Sample Project",
        renderContent: () =>
          <TabsContentWrapper
            currentRoute
            tabIndex
            customUi={<p className="text-base font-normal py-2 flex gap-2">
              {"Explore Sample Projects, make use of the publishable key wherever needed "->React.string}
            </p>}>
            <div className="flex flex-col gap-5">
              <div className=defaultEditorStyle>
                <HelperComponents.KeyAndCopyArea
                  copyValue=publishablekeyMerchant
                  shadowClass="shadow shadow-hyperswitch_box_shadow md:!w-max"
                />
              </div>
              <div className=defaultEditorStyle>
                <Section
                  sectionHeaderText="Clone a sample project"
                  sectionSubText="Try out your choice of integration by cloning sample project"
                  subSectionArray={getFilteredList(frontEndLang, backEndLang, githubCodespaces)}
                  isGithubSection=true
                />
              </div>
            </div>
          </TabsContentWrapper>,
      },
    ]

  | WooCommercePlugin => [
      {
        title: "1. Connect",
        renderContent: () =>
          <TabsContentWrapper currentRoute tabIndex>
            <div
              className="bg-white p-7 flex flex-col gap-6 border !shadow-hyperswitch_box_shadow rounded-md">
              <DownloadWordPressPlugin currentRoute currentTabName="downloadWordpressPlugin" />
            </div>
          </TabsContentWrapper>,
      },
      {
        title: "2. Configure",
        renderContent: () =>
          <div>
            <TabsContentWrapper currentRoute tabIndex={1}>
              <div
                className="bg-white p-7 flex flex-col gap-6 border !shadow-hyperswitch_box_shadow rounded-md">
                <img
                  alt="wordpress"
                  style={
                    height: "400px",
                    width: "100%",
                    objectFit: "cover",
                    objectPosition: "0% 12%",
                  }
                  src="https://hyperswitch.io/img/site/wordpress_hyperswitch_settings.png"
                />
              </div>
            </TabsContentWrapper>
            <TabsContentWrapper currentRoute tabIndex={2}>
              <DownloadAPIKey currentRoute currentTabName="downloadApiKey" />
            </TabsContentWrapper>
            <TabsContentWrapper currentRoute tabIndex={3}>
              <PublishableKeyArea />
            </TabsContentWrapper>
            <TabsContentWrapper currentRoute tabIndex={4}>
              <PaymentResponseHashKeyArea />
            </TabsContentWrapper>
            <TabsContentWrapper currentRoute tabIndex={5}>
              <div
                className="bg-white p-7 flex flex-col gap-6 border !shadow-hyperswitch_box_shadow rounded-md">
                <img
                  alt="wordpress-settings"
                  style={
                    height: "120px",
                    width: "100%",
                    objectFit: "cover",
                    objectPosition: "0% 52%",
                  }
                  src="https://hyperswitch.io/img/site/wordpress_hyperswitch_settings.png"
                />
              </div>
              <PaymentSettings webhookOnly=true />
            </TabsContentWrapper>
            <TabsContentWrapper currentRoute tabIndex={6}>
              <div
                className="bg-white p-7 flex flex-col gap-6 border !shadow-hyperswitch_box_shadow rounded-md">
                <img
                  alt="wordpress-settings"
                  style={
                    height: "120px",
                    width: "100%",
                    objectFit: "cover",
                    objectPosition: "0% 100%",
                  }
                  src="https://hyperswitch.io/img/site/wordpress_hyperswitch_settings.png"
                />
              </div>
            </TabsContentWrapper>
            <div className="mt-4">
              {React.string(
                "Additionally, you can configure the other settings such as appearance, layout, etc as per your requirements.",
              )}
            </div>
          </div>,
      },
    ]
  | _ => []
  }
}
