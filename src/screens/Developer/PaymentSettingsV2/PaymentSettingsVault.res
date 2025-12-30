open Typography

module VaultFields = {
  @react.component
  let make = () => {
    open FormRenderer
    open HSwitchUtils
    open PaymentSettingsV2Helper
    open LogicUtils
    open PaymentSettingsV2Utils

    let vaultConnectorsList = ConnectorListInterface.useFilteredConnectorList(
      ~retainInList=VaultProcessor,
    )
    let formState = ReactFinalForm.useFormState(
      ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
    )
    let form = ReactFinalForm.useForm()
    let isExternalVaultEnabled =
      formState.values
      ->getDictFromJsonObject
      ->getString("is_external_vault_enabled", "")
      ->vaultStatusFromString
      ->Option.mapOr(false, isVaultEnabled)

    <>
      <DesktopRow itemWrapperClass="mx-1">
        <FieldRenderer
          labelClass="!text-fs-15 !text-grey-700 font-semibold"
          fieldWrapperClass="w-full flex justify-between items-center border-gray-200 pt-8 pb-4"
          field={makeFieldInfo(
            ~name="is_external_vault_enabled",
            ~label="Enable External Vault",
            ~customInput=(~input, ~placeholder) =>
              customExternalVaultEnabled(~input, ~placeholder, ~form),
          )}
        />
      </DesktopRow>
      <RenderIf condition={isExternalVaultEnabled}>
        <DesktopRow wrapperClass="pt-4 flex !flex-col gap-4" itemWrapperClass="mx-1">
          <FieldRenderer
            field={vaultConnectorsList
            ->Array.map((item): SelectBox.dropdownOption => {
              value: item.id,
              label: `${item.connector_label} - ${item.id}`,
            })
            ->vaultConnectors}
            errorClass
            labelClass={`text-nd_gray-700 ${body.md.semibold}`}
            fieldWrapperClass="max-w-sm"
          />
        </DesktopRow>
        <DesktopRow wrapperClass="pt-4 flex !flex-col gap-4" itemWrapperClass="mx-1">
          <FieldRenderer
            field={vaultTokenList}
            errorClass
            labelClass={`text-nd_gray-700 ${body.md.semibold}`}
            fieldWrapperClass="max-w-sm"
          />
        </DesktopRow>
      </RenderIf>
    </>
  }
}

@react.component
let make = () => {
  open FormRenderer

  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let showToast = ToastState.useShowToast()
  let businessProfileRecoilVal = Recoil.useRecoilValueFromAtom(
    HyperswitchAtom.businessProfileFromIdAtomInterface,
  )
  let {version} = React.useContext(UserInfoProvider.defaultContext).getCommonTokenDetails()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)
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
      <VaultFields />
      <DesktopRow wrapperClass="mt-8" itemWrapperClass="mx-1">
        <div className="flex justify-end w-full gap-2">
          <SubmitButton text="Update" buttonType=Button.Primary buttonSize=Button.Medium />
        </div>
      </DesktopRow>
    </Form>
  </PageLoaderWrapper>
}
