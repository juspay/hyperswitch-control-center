module WarningArea = {
  @react.component
  let make = (~warningText) => {
    <h1 className="text-orange-950 bg-orange-100 border w-full py-2 px-4 rounded-md ">
      <span className="text-orange-950 font-bold text-fs-14 mr-2"> {"NOTE:"->React.string} </span>
      {warningText->React.string}
    </h1>
  }
}
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
    let initialValues =
      [
        ("profile_name", `default${list->Array.length->string_of_int}`->Js.Json.string),
      ]->Dict.fromArray
    let modalBody =
      <div>
        {switch modalState {
        | Loading => <Loader />
        | Edit =>
          <Form
            key="country-currency"
            initialValues={initialValues->Js.Json.object_}
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
            <WarningArea
              warningText="Warning! Now that you've configured more than one profile, you must mandatorily pass 'profile_id' in payments API request every time"
            />
            <p className="text-grey-700">
              {"Business Profile successfully created! Set up your payments settings like webhooks, return url for your new profile before trying a payment."->React.string}
            </p>
            <Button
              text={"Configure payment settings"}
              buttonType=Primary
              onClick={_ => {
                if updatedProfileId->String.length > 0 {
                  RescriptReactRouter.replace(`/payment-settings/${updatedProfileId}`)
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
      <UIUtils.RenderIf condition=isFromSettings>
        <Button
          text="Add"
          buttonSize=Small
          buttonType={Primary}
          rightIcon={FontAwesome("plus")}
          onClick={_ => {
            setModalState(_ => Edit)
            setShowModal(_ => true)
          }}
        />
      </UIUtils.RenderIf>
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
  ~setShowModalFromOtherScreen=_bool => (),
) => {
  open APIUtils
  open BusinessMappingUtils
  open BusinessMappingEntity
  let showToast = ToastState.useShowToast()
  let updateDetails = useUpdateMethod()
  let (offset, setOffset) = React.useState(_ => 0)
  let (showModal, setShowModal) = React.useState(_ => false)
  let (modalState, setModalState) = React.useState(_ => Edit)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)
  let (updatedProfileId, setUpdatedProfileId) = React.useState(_ => "")

  let businessProfileValues =
    HyperswitchAtom.businessProfilesAtom
    ->Recoil.useRecoilValueFromAtom
    ->MerchantAccountUtils.getArrayOfBusinessProfile

  let fetchBusinessProfiles = MerchantAccountUtils.useFetchBusinessProfiles()

  let updateMerchantDetails = async body => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let url = getURL(~entityName=BUSINESS_PROFILE, ~methodType=Post, ())
      let response = await updateDetails(url, body, Post)
      setUpdatedProfileId(_ =>
        response->LogicUtils.getDictFromJsonObject->LogicUtils.getString("profile_id", "")
      )
      fetchBusinessProfiles()->ignore
      showToast(~message="Your Entry added successfully", ~toastType=ToastState.ToastSuccess, ())
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error(""))
    }

    if !isFromSettings {
      setShowModalFromOtherScreen(_ => false)
    }
    setModalState(_ => Successful)

    Js.Nullable.null
  }

  let onSubmit = async (values, _) => {
    updateMerchantDetails(values)->ignore
    Js.Nullable.null
  }

  <PageLoaderWrapper screenState>
    <UIUtils.RenderIf condition=isFromSettings>
      <div className="relative h-full">
        <div className="flex flex-col-reverse md:flex-col gap-2">
          <PageUtils.PageHeading
            title="Business Profiles"
            subTitle="Add and manage profiles to represent different businesses across countries."
          />
          <UIUtils.RenderIf condition={businessProfileValues->Array.length > 1}>
            <WarningArea
              warningText="Warning! Now that you've configured more than one profile, you must mandatorily pass 'profile_id' in payments API request every time"
            />
          </UIUtils.RenderIf>
          <LoadedTable
            title="Business profiles"
            hideTitle=true
            resultsPerPage=7
            visibleColumns
            entity={businessProfileTableEntity}
            showSerialNumber=true
            actualData={businessProfileValues->Array.map(Js.Nullable.return)}
            totalResults={businessProfileValues->Array.length}
            offset
            setOffset
            currrentFetchCount={businessProfileValues->Array.length}
          />
          <div className="absolute right-0 -top-3">
            <AddEntryBtn
              onSubmit
              modalState
              showModal
              setShowModal
              list={businessProfileValues}
              updatedProfileId
              setModalState
            />
          </div>
        </div>
      </div>
    </UIUtils.RenderIf>
    <UIUtils.RenderIf condition={!isFromSettings}>
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
    </UIUtils.RenderIf>
  </PageLoaderWrapper>
}
