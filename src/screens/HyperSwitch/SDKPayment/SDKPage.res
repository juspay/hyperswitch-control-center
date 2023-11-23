let h3Leading2Style = HSwitchUtils.getTextClass(~textVariant=H3, ~h3TextVariant=Leading_2, ())
@react.component
let make = () => {
  open HSwitchMerchantAccountUtils
  open HomeUtils
  let hyperswitchMixPanel = HSMixPanel.useSendEvent()
  let url = RescriptReactRouter.useUrl()
  let filtersFromUrl = url.search->LogicUtils.getDictFromUrlSearchParams
  let (currency, setCurrency) = React.useState(() => "USD")
  let (isSDKOpen, setIsSDKOpen) = React.useState(_ => false)
  let (key, setKey) = React.useState(_ => "")
  let businessProfiles = Recoil.useRecoilValueFromAtom(HyperswitchAtom.businessProfilesAtom)
  let defaultBusinessProfile = businessProfiles->getValueFromBusinessProfile
  let arrayOfBusinessProfile = businessProfiles->getArrayOfBusinessProfile

  let (profile, setProfile) = React.useState(_ => defaultBusinessProfile.profile_id)
  let (amount, setAmount) = React.useState(() => 10000)

  let dropDownOptions = countries->Js.Array2.map((item): SelectBox.dropdownOption => {
    {
      label: `${item.countryName} (${item.currency})`,
      value: item.currency,
    }
  })

  let inputCurrency: ReactFinalForm.fieldRenderPropsInput = {
    name: `input`,
    onBlur: _ev => (),
    onChange: ev => {
      let value = ev->formEventToStr
      setCurrency(_ => value)
    },
    onFocus: _ev => (),
    value: {currency->Js.Json.string},
    checked: true,
  }

  let inputProfileId: ReactFinalForm.fieldRenderPropsInput = {
    name: `input`,
    onBlur: _ev => (),
    onChange: ev => {
      let value = ev->formEventToStr
      setProfile(_ => value)
    },
    onFocus: _ev => (),
    value: {profile->Js.Json.string},
    checked: true,
  }

  let inputProfileName: ReactFinalForm.fieldRenderPropsInput = {
    name: `input`,
    onBlur: _ev => (),
    onChange: ev => {
      let value = ev->formEventToStr
      setProfile(_ => value)
    },
    onFocus: _ev => (),
    value: {profile->Js.Json.string},
    checked: true,
  }

  let disableSelectionForProfile = arrayOfBusinessProfile->isDefaultBusinessProfile

  React.useEffect1(() => {
    let paymentIntentOptional = filtersFromUrl->Js.Dict.get("payment_intent_client_secret")
    if paymentIntentOptional->Belt.Option.isSome {
      setIsSDKOpen(_ => true)
    }
    None
  }, [filtersFromUrl])

  let onProceed = async (~paymentId as _) => {
    let paymentId =
      filtersFromUrl
      ->Js.Dict.get("payment_intent_client_secret")
      ->Belt.Option.getWithDefault("")
      ->Js.String2.split("_")

    let id = `${paymentId->Belt.Array.get(0)->Belt.Option.getWithDefault("")}_${paymentId
      ->Belt.Array.get(1)
      ->Belt.Option.getWithDefault("")}`

    RescriptReactRouter.replace(`/payments/${id}`)
  }

  let customTryAgain = () => {
    RescriptReactRouter.replace("/sdk")
    setIsSDKOpen(_ => false)
  }

  <>
    <BreadCrumbNavigation
      path=[{title: "Home", link: `/home`}] currentPageTitle="Explore Demo Checkout Experience"
    />
    <div className="w-full flex border rounded-md bg-white">
      <div className="flex flex-col w-1/2 border">
        <div className="p-6 border-b-1 border-[#E6E6E6]">
          <p className=h3Leading2Style> {"Setup test checkout"->React.string} </p>
        </div>
        <div className="m-7 !w-128 flex flex-col justify-between h-5/6 gap-16">
          <div className="flex flex-col gap-5">
            <div className="grid grid-cols-2 gap-8">
              <div>
                <div className="font-medium text-base text-gray-500 dark:text-gray-300">
                  {"Select Profile"->React.string}
                </div>
                <SelectBox
                  options={arrayOfBusinessProfile->businessProfileNameDropDownOption}
                  input=inputProfileName
                  deselectDisable=true
                  searchable=true
                  buttonText="Profile Name"
                  disableSelect={disableSelectionForProfile}
                  allowButtonTextMinWidth=true
                  ellipsisOnly=true
                  customButtonStyle={"!w-58 !px-2"}
                />
              </div>
              <div>
                <div className="font-medium text-base text-gray-500 dark:text-gray-300">
                  {"Select Profile Id"->React.string}
                </div>
                <SelectBox
                  options={arrayOfBusinessProfile->businessProfileIdDropDownOption}
                  input=inputProfileId
                  deselectDisable=true
                  searchable=true
                  buttonText="Profile Id"
                  disableSelect={disableSelectionForProfile}
                  allowButtonTextMinWidth=true
                  ellipsisOnly=true
                  customButtonStyle={"!w-58 !px-2"}
                />
              </div>
              <div>
                <div className="font-medium text-base text-gray-500 dark:text-gray-300">
                  {"Select Currency"->React.string}
                </div>
                <SelectBox
                  options={dropDownOptions}
                  input=inputCurrency
                  deselectDisable=true
                  searchable=true
                  buttonText="United States (US)"
                  allowButtonTextMinWidth=true
                  ellipsisOnly=true
                  customButtonStyle={"!w-58 !px-2"}
                />
              </div>
              <div>
                <div className="font-medium text-base text-gray-500 dark:text-gray-300">
                  {"Enter amount"->React.string}
                </div>
                <InputText setAmount />
              </div>
            </div>
            <Button
              text="See Preview"
              buttonType={Primary}
              buttonSize={Small}
              customButtonStyle={"!p-2 !w-fit"}
              buttonState={amount <= 0 ? Disabled : Normal}
              onClick={_ => {
                setKey(_ => `${amount->string_of_int}_${currency}_${profile}`)
                setIsSDKOpen(_ => true)
                hyperswitchMixPanel(
                  ~pageName=url.path->LogicUtils.getListHead,
                  ~contextName="sdk",
                  ~actionName="proceed",
                  (),
                )
              }}
            />
          </div>
          <TestCredentials />
        </div>
      </div>
      <div className="flex flex-col flex-1">
        <div className="p-6 border-l-1 border-b-1 border-[#E6E6E6]">
          <p className=h3Leading2Style> {"Preview"->React.string} </p>
        </div>
        {if isSDKOpen {
          <div className="p-7 h-full bg-sidebar-blue">
            <TestPayment
              key
              amount
              returnUrl={`${HSwitchGlobalVars.hyperSwitchFEPrefix}/sdk`}
              currency
              onProceed
              profileId=profile
              sdkWidth="!w-[100%]"
              isTestCredsNeeded=false
              customTryAgain
              customWidth="!w-full !h-full"
              paymentStatusStyles=""
              successButtonText="Go to Payment"
            />
          </div>
        } else {
          <div className="bg-sidebar-blue flex items-center justify-center h-full">
            <img src={`/assets/BlurrySDK.svg`} />
          </div>
        }}
      </div>
    </div>
  </>
}
