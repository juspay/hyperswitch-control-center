open Typography

module SurchargeFields = {
  @react.component
  let make = () => {
    open FormRenderer
    open HSwitchUtils
    open PaymentSettingsRevampedHelper

    let surchargeConnectorsList = ConnectorListInterface.useFilteredConnectorList(
      ~retainInList=SurchargeProcessor,
    )

    <DesktopRow wrapperClass="pt-4 flex !flex-col gap-4" itemWrapperClass="mx-1">
      <FieldRenderer
        field={surchargeConnectorsList
        ->Array.map((item): SelectBox.dropdownOption => {
          value: item.id,
          label: `${item.connector_label} - ${item.id}`,
        })
        ->surchargeConnectors}
        errorClass
        labelClass={`text-nd_gray-700 ${body.md.semibold}`}
        fieldWrapperClass="max-w-sm"
      />
    </DesktopRow>
  }
}

@react.component
let make = () => {
  open FormRenderer
  open LogicUtils

  let showToast = ToastAdapter.useShowToast()
  let businessProfileRecoilVal = Recoil.useRecoilValueFromAtom(
    HyperswitchAtom.businessProfileFromIdAtomInterface,
  )
  let {version} = React.useContext(UserInfoProvider.defaultContext).getCommonSessionDetails()
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)
  let updateBusinessProfile = BusinessProfileHook.useUpdateBusinessProfile(~version)

  let onSubmit = async (values, _) => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let surchargeConnectorId =
        values
        ->getDictFromJsonObject
        ->getDictfromDict("surcharge_connector_details")
        ->getString("surcharge_connector_id", "")

      let body =
        [
          (
            "surcharge_connector_details",
            [("surcharge_connector_id", surchargeConnectorId->JSON.Encode.string)]
            ->Dict.fromArray
            ->JSON.Encode.object,
          ),
        ]
        ->Dict.fromArray
        ->JSON.Encode.object
      let _ = await updateBusinessProfile(~body)
      mixpanelEvent(~eventName="payment_settings_surcharge")
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

  let validate = values => {
    let errors = Dict.make()
    let surchargeConnectorId =
      values
      ->getDictFromJsonObject
      ->getDictfromDict("surcharge_connector_details")
      ->getString("surcharge_connector_id", "")
      ->getNonEmptyString
    if surchargeConnectorId == None {
      Dict.set(
        errors,
        "surcharge_connector_id",
        "Please select a surcharge connector"->JSON.Encode.string,
      )
    }
    errors->JSON.Encode.object
  }

  <PageLoaderWrapper screenState>
    <Form onSubmit initialValues={businessProfileRecoilVal->Identity.genericTypeToJson} validate>
      <SurchargeFields />
      <DesktopRow wrapperClass="mt-8" itemWrapperClass="mx-1">
        <div className="flex justify-end w-full gap-2">
          <SubmitButton text="Update" buttonType=Button.Primary buttonSize=Button.Medium />
        </div>
      </DesktopRow>
    </Form>
  </PageLoaderWrapper>
}
