open PaymentMethodBlockingTypes
open PaymentMethodBlockingHelper
open FormRenderer
open Typography

@react.component
let make = () => {
  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let showToast = ToastAdapter.useShowToast()
  let businessProfileRecoilVal = Recoil.useRecoilValueFromAtom(
    HyperswitchAtom.businessProfileFromIdAtomInterface,
  )
  let {version} = React.useContext(UserInfoProvider.defaultContext).getCommonSessionDetails()
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let updateBusinessProfile = BusinessProfileHook.useUpdateBusinessProfile(~version)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)

  let onSubmit = async (values, _) => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let _ = await updateBusinessProfile(~body=values, ~shouldTransform=true)
      mixpanelEvent(~eventName="payment_settings_payment_method_blocking")
      showToast(~message=`Details updated`, ~toastType=ToastState.ToastSuccess)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => {
        setScreenState(_ => PageLoaderWrapper.Success)
        showToast(~message=`Failed to update`, ~toastType=ToastState.ToastError)
      }
    }
    Nullable.null
  }

  let wasmOptions = React.useMemo((): wasmOptions => {
    issuingCountry: try {
      Window.getTwoLetterCountryCode()->DeveloperUtils.makeOptionsWithDifferentValues
    } catch {
    | _ => []
    },
    cardTypes: try {
      Window.getCardTypeValues()->DeveloperUtils.makeOptions
    } catch {
    | _ => []
    },
    cardNetworks: try {
      Window.getVariantValues("card_network")->Array.map((value): SelectBox.dropdownOption => {
        label: value->LogicUtils.camelCaseToTitle,
        value,
      })
    } catch {
    | _ => []
    },
    cardSubtypes: try {
      Window.getCardSubtypeValues()->SelectBox.makeOptions
    } catch {
    | _ => []
    },
    fundingSources: try {
      Window.getFundingSourceValues()->Array.map((value): SelectBox.dropdownOption => {
        label: value->String.toLowerCase->LogicUtils.snakeToTitle,
        value,
      })
    } catch {
    | _ => []
    },
    cardSegmentTypes: try {
      Window.getCardSegmentTypeValues()->DeveloperUtils.makeOptions
    } catch {
    | _ => []
    },
  }, [])

  let accordion: array<Accordion.accordion> = [
    #Card,
    #ApplePay,
    #GooglePay,
  ]->Array.map((paymentMethod: paymentMethod) => {
    Accordion.title: (paymentMethod :> string)->LogicUtils.camelCaseToTitle,
    renderContent: (~currentAccordionState as _, ~closeAccordionFn as _) =>
      <BlockingConfigFields paymentMethod wasmOptions />,
    renderContentOnTop: None,
  })

  <PageLoaderWrapper screenState>
    <Form
      onSubmit
      initialValues={businessProfileRecoilVal->Identity.genericTypeToJson}
      validate={values => {
        PaymentSettingsUtils.validateMerchantAccountFormV2(
          ~values,
          ~isLiveMode=featureFlagDetails.isLiveMode,
          ~businessProfileRecoilVal,
        )
      }}>
      <div className="flex flex-col gap-4">
        <p className={`${body.lg.semibold} !text-nd_gray-700 ml-1 mt-6`}>
          {"Payment Method Blocking"->React.string}
        </p>
        <div className="max-w-3xl flex flex-col gap-6">
          <AccordionAdapter
            accordion
            arrowPosition=Accordion.Right
            accordionTopContainerCss="rounded-lg border border-nd_gray-200 bg-white"
            accordionBottomContainerCss="px-5 pb-5"
            contentExpandCss=""
            titleStyle={`${body.lg.semibold} text-nd_gray-700`}
            gapClass="gap-4"
          />
          <div className="flex justify-end">
            <SubmitButton text="Update" buttonType=Button.Primary buttonSize=Button.Medium />
          </div>
        </div>
      </div>
    </Form>
  </PageLoaderWrapper>
}
