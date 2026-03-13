module PaymentLinkDomainFields = {
  @react.component
  let make = (~setAllowEdit, ~allowEdit) => {
    open Typography
    open FormRenderer
    open LogicUtils
    open PaymentSettingsRevampedHelper

    let (showModal, setShowModal) = React.useState(_ => false)
    let (isDisabled, setDisabled) = React.useState(_ => true)
    let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
      ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
    )

    let paymentLinkConfigDict =
      formState.values
      ->getDictFromJsonObject
      ->getDictfromDict("payment_link_config")

    let allowEditConfiguration = () => {
      setDisabled(_ => false)
      setAllowEdit(_ => true)
      setShowModal(_ => false)
    }

    React.useEffect(() => {
      let isEmpty = paymentLinkConfigDict->isEmptyDict
      setDisabled(_ => !isEmpty)
      setAllowEdit(_ => isEmpty)
      None
    }, [])

    <>
      <div className="flex flex-row justify-between items-center gap-6">
        <p className={`!text-nd_gray-700  !${heading.sm.semibold}`}>
          {"Payment Link Domain"->React.string}
        </p>
        <RenderIf condition={!(paymentLinkConfigDict->isEmptyDict) && isDisabled && !allowEdit}>
          <div
            className="flex gap-2 items-center cursor-pointer"
            onClick={_ => setShowModal(_ => true)}>
            <Icon name="nd-edit" size=14 />
            <a className="text-primary cursor-pointer"> {"Edit"->React.string} </a>
          </div>
        </RenderIf>
      </div>
      <div className="flex flex-col gap-2 ">
        <FieldRenderer
          field={domainName(isDisabled)}
          labelClass={`!text-nd_gray-700 ${body.md.semibold}`}
          fieldWrapperClass="max-w-xl"
        />
        <FieldRenderer
          field={allowedDomains(isDisabled)}
          labelClass={`!text-nd_gray-700 ${body.md.semibold}`}
          fieldWrapperClass="max-w-xl"
        />
      </div>
      <Modal
        showModal
        setShowModal
        modalClass="w-full md:w-4/12 mx-auto my-40 border-t-8 border-t-orange-960 rounded-xl">
        <div className="relative flex items-start px-4 pb-10 pt-8 gap-4">
          <Icon
            name="warning-outlined" size=25 className="w-8" onClick={_ => setShowModal(_ => false)}
          />
          <div className="flex flex-col gap-5">
            <p className="font-bold text-2xl"> {"Edit the Current Configuration"->React.string} </p>
            <p className="text-hyperswitch_black opacity-50 font-medium">
              {"Editing the current configuration will override the current active configuration."->React.string}
            </p>
          </div>
          <Icon
            className="absolute top-2 right-2"
            name="hswitch-close"
            size=22
            onClick={_ => setShowModal(_ => false)}
          />
        </div>
        <div className="flex items-end justify-end gap-4">
          <Button
            buttonType=Button.Primary onClick={_ => allowEditConfiguration()} text="Proceed"
          />
          <Button
            buttonType=Button.Secondary onClick={_ => setShowModal(_ => false)} text="Cancel"
          />
        </div>
      </Modal>
    </>
  }
}

@react.component
let make = () => {
  open APIUtils
  open FormRenderer
  open MerchantAccountUtils
  open HSwitchSettingTypes

  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let showToast = ToastState.useShowToast()
  let (allowEdit, setAllowEdit) = React.useState(_ => false)
  let {profileId} = React.useContext(UserInfoProvider.defaultContext).getCommonSessionDetails()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)
  let businessProfileRecoilVal = Recoil.useRecoilValueFromAtom(
    HyperswitchAtom.businessProfileFromIdAtomInterface,
  )
  let fetchBusinessProfileFromId = BusinessProfileHook.useFetchBusinessProfileFromId()

  let onSubmit = async (values, _) => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let url = getURL(~entityName=V1(BUSINESS_PROFILE), ~methodType=Post, ~id=Some(profileId))
      let body = values->getPaymentLinkDomainPayload->JSON.Encode.object
      let _ = await updateDetails(url, body, Post)
      fetchBusinessProfileFromId(~profileId=Some(profileId))->ignore

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
      initialValues={businessProfileRecoilVal->Identity.genericTypeToJson}
      onSubmit
      validate={values => {
        validatePaymentLinkDomainForm(~values, ~fieldsToValidate=[DomainName, AllowedDomains])
      }}
      formClass="flex flex-col gap-4 h-full w-full py-6 px-4">
      <PaymentLinkDomainFields setAllowEdit allowEdit />
      <DesktopRow>
        <div className="flex justify-end w-full gap-2">
          <RenderIf condition=allowEdit>
            <SubmitButton
              text="Update"
              buttonType=Button.Primary
              buttonSize=Button.Medium
              disabledParamter={!allowEdit}
            />
            <Button
              buttonType=Button.Secondary
              onClick={_ =>
                RescriptReactRouter.push(
                  GlobalVars.appendDashboardPath(~url="/payment-settings-new"),
                )}
              text="Cancel"
            />
          </RenderIf>
        </div>
      </DesktopRow>
    </Form>
  </PageLoaderWrapper>
}
