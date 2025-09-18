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
  open APIUtils
  open HSwitchUtils
  open FormRenderer

  let threedsConnectorList = ConnectorListInterface.useFilteredConnectorList(
    ~retainInList=AuthenticationProcessor,
  )
  let getURL = useGetURL()
  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let showToast = ToastState.useShowToast()
  let updateDetails = useUpdateMethod()
  let fetchBusinessProfileFromId = BusinessProfileHook.useFetchBusinessProfileFromId()
  let businessProfileRecoilVal =
    HyperswitchAtom.businessProfileFromIdAtom->Recoil.useRecoilValueFromAtom
  let {userInfo: {profileId}} = React.useContext(UserInfoProvider.defaultContext)

  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)
  let isBusinessProfileHasThreeds =
    threedsConnectorList->Array.some(item => item.profile_id == profileId)

  let onSubmit = async (values, _) => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let url = getURL(~entityName=V1(BUSINESS_PROFILE), ~methodType=Post, ~id=Some(profileId))
      let _ = await updateDetails(url, values, Post)
      let _ = await fetchBusinessProfileFromId(~profileId=Some(profileId))

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
      initialValues={businessProfileRecoilVal
      ->PaymentSettingsV2Utils.parseBusinessProfileForThreeDS
      ->Identity.genericTypeToJson}
      validate={values => {
        PaymentSettingsV2Utils.validateMerchantAccountFormV2(
          ~values,
          ~isLiveMode=featureFlagDetails.isLiveMode,
          ~businessProfileRecoilVal,
        )
      }}>
      <DesktopRow itemWrapperClass="mx-1">
        <FieldRenderer
          labelClass="!text-fs-15 !text-grey-700 font-semibold"
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
      <RenderIf condition={isBusinessProfileHasThreeds}>
        <DesktopRow wrapperClass="pt-4 flex !flex-col gap-4" itemWrapperClass="mx-1">
          <FieldRenderer
            field={threedsConnectorList
            ->Array.map(item => item.connector_name)
            ->authenticationConnectors}
            errorClass
            labelClass="!text-fs-15 !text-grey-700 font-semibold  "
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
    <RenderIf condition={featureFlagDetails.acquirerConfigSettings}>
      <AcquirerConfigSettingsRevamp />
    </RenderIf>
  </PageLoaderWrapper>
}
