module ThreeDsRequestorUrl = {
  @react.component
  let make = () => {
    open FormRenderer
    open HSwitchUtils

    let formState = ReactFinalForm.useFormState(
      ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
    )

    <FieldRenderer
      field={FormRenderer.makeFieldInfo(
        ~label="3DS Requestor URL",
        ~name="authentication_connector_details.three_ds_requestor_url",
        ~placeholder="Enter 3DS Requestor URL",
        ~customInput=InputFields.textInput(
          ~autoComplete="off",
          ~customStyle="rounded-xl",
          ~isDisabled=PaymentSettingsV2Utils.isAuthConnectorArrayEmpty(formState.values),
        ),
        ~isRequired=false,
      )}
      errorClass
      labelClass="!text-fs-15 !text-grey-700 font-semibold"
      fieldWrapperClass="max-w-xl"
    />
  }
}
module ThreeDsAppUrl = {
  @react.component
  let make = () => {
    open FormRenderer
    open HSwitchUtils

    let formState = ReactFinalForm.useFormState(
      ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
    )

    <FieldRenderer
      field={FormRenderer.makeFieldInfo(
        ~label="3DS Requestor App URL",
        ~name="authentication_connector_details.three_ds_requestor_app_url",
        ~placeholder="Enter 3DS Requestor App URL",
        ~customInput=InputFields.textInput(
          ~autoComplete="off",
          ~customStyle="rounded-xl",
          ~isDisabled=PaymentSettingsV2Utils.isAuthConnectorArrayEmpty(formState.values),
        ),
        ~isRequired=false,
      )}
      errorClass
      labelClass="!text-fs-15 !text-grey-700 font-semibold"
      fieldWrapperClass="max-w-xl"
    />
  }
}
@react.component
let make = () => {
  open PaymentSettingsV2Helper
  open HSwitchUtils
  open FormRenderer
  open Typography

  let threedsConnectorList = ConnectorListInterface.useFilteredConnectorList(
    ~retainInList=AuthenticationProcessor,
  )
  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let showToast = ToastState.useShowToast()
  let businessProfileRecoilVal = Recoil.useRecoilValueFromAtom(
    HyperswitchAtom.businessProfileFromIdAtomInterface,
  )
  let {userInfo: {profileId, version}} = React.useContext(UserInfoProvider.defaultContext)

  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)
  let isBusinessProfileHasThreeds =
    threedsConnectorList->Array.some(item => item.profile_id == profileId)
  let updateBusinessProfile = BusinessProfileHook.useUpdateBusinessProfile(~version)

  let onSubmit = async (values, _) => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let _ = await updateBusinessProfile(~body=values, ~shouldTransform=true)

      showToast(~message=`Details updated`, ~toastType=ToastState.ToastSuccess)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => {
        setScreenState(_ => PageLoaderWrapper.Success)
        showToast(~message=`Failed to updated`, ~toastType=ToastState.ToastError)
      }
    }
    Nullable.null
  }
  <PageLoaderWrapper screenState>
    <Form
      onSubmit
      initialValues={businessProfileRecoilVal->Identity.genericTypeToJson}
      validate={values => {
        PaymentSettingsV2Utils.validateMerchantAccountFormV2(
          ~values,
          ~isLiveMode=featureFlagDetails.isLiveMode,
          ~businessProfileRecoilVal,
        )
      }}>
      <RenderIfVersion visibleForVersion=V1>
        <DesktopRow itemWrapperClass="mx-1">
          <FieldRenderer
            labelClass={`!${body.lg.semibold} !text-nd_gray-700`}
            fieldWrapperClass="w-full flex justify-between items-center border-gray-200 pt-8 pb-4"
            field={makeFieldInfo(
              ~name="force_3ds_challenge",
              ~label="Force 3DS Challenge",
              ~customInput=InputFields.boolInput(
                ~isDisabled=false,
                ~boolCustomClass="rounded-lg ",
                ~toggleEnableColor="bg-nd_primary_blue-450",
              ),
            )}
          />
        </DesktopRow>
      </RenderIfVersion>
      <RenderIf condition={isBusinessProfileHasThreeds}>
        <DesktopRow wrapperClass="pt-4 flex !flex-col gap-4" itemWrapperClass="mx-1">
          <FieldRenderer
            field={threedsConnectorList
            ->Array.map(item => item.connector_name)
            ->authenticationConnectors}
            errorClass
            labelClass={`!${body.lg.semibold} !text-nd_gray-700`}
            fieldWrapperClass="max-w-sm  "
          />
          <ThreeDsRequestorUrl />
          <ThreeDsAppUrl />
        </DesktopRow>
      </RenderIf>
      <DesktopRow wrapperClass="mt-8" itemWrapperClass="mx-1">
        <div className="flex justify-end w-full gap-2">
          <SubmitButton text="Update" buttonType=Button.Primary buttonSize=Button.Medium />
        </div>
      </DesktopRow>
    </Form>
    <RenderIf condition={featureFlagDetails.acquirerConfigSettings && version == V1}>
      <AcquirerConfigSettingsRevamp />
    </RenderIf>
  </PageLoaderWrapper>
}
