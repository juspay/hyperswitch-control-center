let h3Leading2Style = HSwitchUtils.getTextClass(~textVariant=H3, ~h3TextVariant=Leading_2, ())
external toJson: 'a => Js.Json.t = "%identity"

module SDKConfiguarationFields = {
  open HSwitchMerchantAccountUtils
  @react.component
  let make = (~initialValues: SDKPaymentTypes.paymentType) => {
    let businessProfiles = Recoil.useRecoilValueFromAtom(HyperswitchAtom.businessProfilesAtom)
    let arrayOfBusinessProfile = businessProfiles->getArrayOfBusinessProfile
    let disableSelectionForProfile = arrayOfBusinessProfile->HomeUtils.isDefaultBusinessProfile

    let dropDownOptions = HomeUtils.countries->Js.Array2.map((item): SelectBox.dropdownOption => {
      {
        label: `${item.countryName} (${item.currency})`,
        value: `${item.countryName}-${item.currency}`,
      }
    })

    let selectProfileField = FormRenderer.makeFieldInfo(
      ~label="Business profile",
      ~name="profile_id",
      ~placeholder="",
      ~customInput=InputFields.selectInput(
        ~deselectDisable=true,
        ~options={arrayOfBusinessProfile->businessProfileNameDropDownOption},
        ~buttonText="Select Profile",
        ~disableSelect=disableSelectionForProfile,
        ~fullLength=true,
        (),
      ),
      (),
    )
    let selectProfileId = FormRenderer.makeFieldInfo(
      ~label="Profile Id",
      ~name="profile_id",
      ~placeholder="",
      ~customInput=InputFields.selectInput(
        ~deselectDisable=true,
        ~options=arrayOfBusinessProfile->businessProfileIdDropDownOption,
        ~buttonText="Select Profile Id",
        ~disableSelect=disableSelectionForProfile,
        ~fullLength=true,
        (),
      ),
      (),
    )
    let selectCurrencyField = FormRenderer.makeFieldInfo(
      ~label="Currency",
      ~name="currency",
      ~placeholder="",
      ~customInput=InputFields.selectInput(
        ~options=dropDownOptions,
        ~buttonText="Select Currency",
        ~deselectDisable=true,
        ~fullLength=true,
        (),
      ),
      (),
    )
    let enterAmountField = FormRenderer.makeFieldInfo(
      ~label="Enter amount",
      ~name="amount",
      ~placeholder="Enter amount",
      ~customInput=InputFields.numericTextInput(~isDisabled=false, ~customStyle="w-full", ()),
      (),
    )

    <>
      <FormRenderer.FieldRenderer field=selectProfileField fieldWrapperClass="!w-full" />
      <FormRenderer.FieldRenderer field=selectProfileId fieldWrapperClass="!w-full" />
      <FormRenderer.FieldRenderer field=selectCurrencyField fieldWrapperClass="!w-full" />
      <FormRenderer.FieldRenderer field=enterAmountField fieldWrapperClass="!w-full" />
      <FormRenderer.SubmitButton
        text="Show preview" disabledParamter={!(initialValues.profile_id->Js.String2.length > 0)}
      />
    </>
  }
}

@react.component
let make = () => {
  open HSwitchMerchantAccountUtils
  let hyperswitchMixPanel = HSMixPanel.useSendEvent()
  let url = RescriptReactRouter.useUrl()
  let filtersFromUrl = url.search->LogicUtils.getDictFromUrlSearchParams
  let (isSDKOpen, setIsSDKOpen) = React.useState(_ => false)
  let (key, setKey) = React.useState(_ => "")
  let businessProfiles = Recoil.useRecoilValueFromAtom(HyperswitchAtom.businessProfilesAtom)
  let defaultBusinessProfile = businessProfiles->getValueFromBusinessProfile
  let (initialValues, setInitialValues) = React.useState(_ =>
    defaultBusinessProfile->SDKPaymentUtils.initialValueForForm
  )
  React.useEffect1(() => {
    let paymentIntentOptional = filtersFromUrl->Js.Dict.get("payment_intent_client_secret")
    if paymentIntentOptional->Belt.Option.isSome {
      setIsSDKOpen(_ => true)
    }
    None
  }, [filtersFromUrl])

  React.useEffect1(() => {
    setInitialValues(_ => defaultBusinessProfile->SDKPaymentUtils.initialValueForForm)
    None
  }, [defaultBusinessProfile.profile_id->Js.String2.length])

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

  let onSubmit = (values, _) => {
    setKey(_ => Js.Date.now()->Js.Float.toString)
    setInitialValues(_ => values->SDKPaymentUtils.getTypedValueForPayment)
    setIsSDKOpen(_ => true)
    RescriptReactRouter.push("/sdk")
    hyperswitchMixPanel(
      ~pageName=url.path->LogicUtils.getListHead,
      ~contextName="sdk",
      ~actionName="proceed",
      (),
    )
    Js.Nullable.null->Promise.resolve
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
        <div className="p-7 flex flex-col gap-16">
          <Form
            initialValues={initialValues->toJson}
            formClass="grid grid-cols-2 gap-x-8 gap-y-4"
            onSubmit>
            <SDKConfiguarationFields initialValues />
          </Form>
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
              returnUrl={`${HSwitchGlobalVars.hyperSwitchFEPrefix}/sdk`}
              onProceed
              sdkWidth="!w-[100%]"
              isTestCredsNeeded=false
              customWidth="!w-full !h-full"
              paymentStatusStyles=""
              successButtonText="Go to Payment"
              keyValue={key}
              initialValues
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
