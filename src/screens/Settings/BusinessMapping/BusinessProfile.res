module AddEntryBtn = {
  @react.component
  let make = (
    ~onSubmit,
    ~modalState,
    ~showModal,
    ~setShowModal,
    ~list,
    ~isFromSettings=true,
    ~updatedProfileId,
    ~setModalState,
  ) => {
    open HSwitchUtils
    open BusinessMappingUtils
    let mixpanelEvent = MixpanelHook.useSendEvent()
    let initialValues =
      [
        ("profile_name", `default${list->Array.length->Int.toString}`->JSON.Encode.string),
      ]->Dict.fromArray
    let {userHasAccess, hasAnyGroupAccess} = GroupACLHooks.useUserGroupACLHook()
    let modalBody =
      <div>
        {switch modalState {
        | Loading => <Loader />
        | Edit =>
          <Form
            key="country-currency"
            initialValues={initialValues->JSON.Encode.object}
            validate={values => values->validateForm(~fieldsToValidate=[ProfileName], ~list)}
            onSubmit>
            <LabelVisibilityContext showLabel=false>
              <div className="flex flex-col gap-3 h-full w-full">
                <FormRenderer.DesktopRow>
                  <TextFieldRow label={labelField.label} labelWidth="w-32" isRequired=false>
                    <FormRenderer.FieldRenderer
                      fieldWrapperClass="w-96" field=labelField errorClass=HSwitchUtils.errorClass
                    />
                  </TextFieldRow>
                </FormRenderer.DesktopRow>
                <FormRenderer.DesktopRow>
                  <div className="flex justify-end gap-5 mt-5 mb-1 -mr-2">
                    <Button
                      text="Cancel"
                      onClick={_ => setShowModal(_ => false)}
                      buttonType={Secondary}
                      buttonSize={Small}
                    />
                    <FormRenderer.SubmitButton text="Add" buttonSize={Small} />
                  </div>
                </FormRenderer.DesktopRow>
              </div>
            </LabelVisibilityContext>
          </Form>
        | Successful =>
          <div className="flex flex-col gap-6 justify-center items-end mx-4">
            <AlertBanner
              bannerText="Now that you've configured more than one profile, you must pass 'profile_id' in payments API request every time"
              bannerType=Warning
            />
            <p className="text-grey-700">
              {"Business Profile successfully created! Set up your payments settings like webhooks, return url for your new profile before trying a payment."->React.string}
            </p>
            <Button
              text={"Configure payment settings"}
              buttonType=Primary
              onClick={_ => {
                if updatedProfileId->LogicUtils.isNonEmptyString {
                  mixpanelEvent(~eventName="business_profiles_configure_payment_settings")
                  RescriptReactRouter.replace(
                    GlobalVars.appendDashboardPath(~url=`/payment-settings/${updatedProfileId}`),
                  )
                  setModalState(_ => Edit)
                }
              }}
              customButtonStyle="!w-1/3 mt-6"
            />
          </div>
        }}
      </div>

    let modalHeaderText = switch modalState {
    | Edit | Loading => "Add Business Profile Name"
    | Successful => "Configure payment settings"
    }

    <div>
      <RenderIf condition=isFromSettings>
        <ACLButton
          text="Add"
          // TODO: Remove `MerchantDetailsManage` permission in future
          authorization={hasAnyGroupAccess(
            userHasAccess(~groupAccess=MerchantDetailsManage),
            userHasAccess(~groupAccess=AccountManage),
          )}
          buttonSize=Small
          buttonType={Primary}
          onClick={_ => {
            setModalState(_ => Edit)
            setShowModal(_ => true)
          }}
        />
      </RenderIf>
      <Modal
        showModal
        modalHeading=modalHeaderText
        setShowModal
        closeOnOutsideClick=true
        modalClass="w-full max-w-2xl m-auto !bg-white dark:!bg-jp-gray-lightgray_background">
        modalBody
      </Modal>
    </div>
  }
}

@react.component
let make = (
  ~isFromSettings=true,
  ~showModalFromOtherScreen=false,
  ~setShowModalFromOtherScreen=_ => (),
) => {
  open APIUtils
  open BusinessMappingUtils
  open BusinessMappingEntity
  let getURL = useGetURL()
  let showToast = ToastState.useShowToast()
  let updateDetails = useUpdateMethod()
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let (offset, setOffset) = React.useState(_ => 0)
  let (modalState, setModalState) = React.useState(_ => Edit)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)
  let (updatedProfileId, setUpdatedProfileId) = React.useState(_ => "")

  let businessProfileValues = HyperswitchAtom.businessProfilesAtom->Recoil.useRecoilValueFromAtom

  let fetchBusinessProfiles = BusinessProfileHook.useFetchBusinessProfiles()

  let updateMerchantDetails = async body => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let url = getURL(~entityName=V1(BUSINESS_PROFILE), ~methodType=Post)
      mixpanelEvent(~eventName="create_new_profile", ~metadata=body)
      let response = await updateDetails(url, body, Post)
      setUpdatedProfileId(_ =>
        response->LogicUtils.getDictFromJsonObject->LogicUtils.getString("profile_id", "")
      )
      fetchBusinessProfiles()->ignore
      showToast(~message="Your Entry added successfully", ~toastType=ToastState.ToastSuccess)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error(""))
    }

    if !isFromSettings {
      setShowModalFromOtherScreen(_ => false)
    }
    setModalState(_ => Successful)

    Nullable.null
  }

  let onSubmit = async (values, _) => {
    updateMerchantDetails(values)->ignore
    Nullable.null
  }

  <PageLoaderWrapper screenState>
    <RenderIf condition=isFromSettings>
      <div className="relative h-full">
        <div className="flex flex-col-reverse md:flex-col gap-2">
          <PageUtils.PageHeading
            title="Business Profiles"
            subTitle="Add and manage profiles to represent different businesses across countries."
          />
          <RenderIf condition={businessProfileValues->Array.length > 1}>
            <HSwitchUtils.AlertBanner
              bannerText="Now that you've configured more than one profile, you must pass 'profile_id' in payments API request every time"
              bannerType=Warning
            />
          </RenderIf>
          <LoadedTable
            title="Business profiles"
            hideTitle=true
            resultsPerPage=7
            visibleColumns
            entity={businessProfileTableEntity}
            showSerialNumber=true
            actualData={businessProfileValues->Array.map(Nullable.make)}
            totalResults={businessProfileValues->Array.length}
            offset
            setOffset
            currrentFetchCount={businessProfileValues->Array.length}
            showPagination=false
          />
        </div>
      </div>
    </RenderIf>
    <RenderIf condition={!isFromSettings}>
      <AddEntryBtn
        isFromSettings
        onSubmit
        modalState
        showModal={showModalFromOtherScreen}
        setShowModal={setShowModalFromOtherScreen}
        list={businessProfileValues}
        updatedProfileId
        setModalState
      />
    </RenderIf>
  </PageLoaderWrapper>
}
