module AddEntryBtn = {
  @react.component
  let make = (~onSubmit, ~modalState, ~showModal, ~setShowModal, ~list, ~isFromSettings=true) => {
    open HSwitchUtils
    open BusinessMappingUtils
    let initialValues = [("profile_name", "Default"->Js.Json.string)]->Js.Dict.fromArray
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
        }}
      </div>

    <div>
      <UIUtils.RenderIf condition=isFromSettings>
        <Button
          text="Add"
          buttonSize=Small
          buttonType={Primary}
          rightIcon={FontAwesome("plus")}
          onClick={_ => setShowModal(_ => true)}
        />
      </UIUtils.RenderIf>
      <Modal
        showModal
        modalHeading="Add Business Profile Name"
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
  let hyperswitchMixPanel = HSMixPanel.useSendEvent()
  let showToast = ToastState.useShowToast()
  let updateDetails = useUpdateMethod()
  let (offset, setOffset) = React.useState(_ => 0)
  let (showModal, setShowModal) = React.useState(_ => false)
  let (modalState, setModalState) = React.useState(_ => Edit)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)

  let businessProfileValues =
    HyperswitchAtom.businessProfilesAtom
    ->Recoil.useRecoilValueFromAtom
    ->MerchantAccountUtils.getArrayOfBusinessProfile

  let fetchBusinessProfiles = MerchantAccountUtils.useFetchBusinessProfiles()

  let updateMerchantDetails = async body => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let url = getURL(~entityName=BUSINESS_PROFILE, ~methodType=Post, ())
      let _ = await updateDetails(url, body, Post)
      fetchBusinessProfiles()->ignore
      showToast(~message="Your Entry added successfully", ~toastType=ToastState.ToastSuccess, ())
      if !isFromSettings {
        hyperswitchMixPanel(~eventName=Some(`connectors_add_business_profile`), ())
      }
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error(""))
    }
    isFromSettings ? setShowModal(_ => false) : setShowModalFromOtherScreen(_ => false)
    setModalState(_ => Edit)
    setShowModal(_ => false)
    Js.Nullable.null
  }

  let onSubmit = async (values, _) => {
    updateMerchantDetails(values)->ignore
    Js.Nullable.null
  }

  <PageLoaderWrapper screenState>
    <UIUtils.RenderIf condition=isFromSettings>
      <div className="relative h-full">
        <div className="flex flex-col-reverse md:flex-col">
          <PageUtils.PageHeading
            title="Business Profiles"
            subTitle="Add and manage profiles to represent different businesses across countries."
          />
          <LoadedTable
            title="Business profiles"
            hideTitle=true
            resultsPerPage=7
            visibleColumns
            entity={businessProfileTableEntity}
            showSerialNumber=true
            actualData={businessProfileValues->Js.Array2.map(Js.Nullable.return)}
            totalResults={businessProfileValues->Js.Array2.length}
            offset
            setOffset
            currrentFetchCount={businessProfileValues->Js.Array2.length}
          />
          <div className="absolute right-0 -top-3">
            <AddEntryBtn onSubmit modalState showModal setShowModal list={businessProfileValues} />
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
      />
    </UIUtils.RenderIf>
  </PageLoaderWrapper>
}
