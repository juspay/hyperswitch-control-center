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

module BusinessUnitText = {
  @react.component
  let make = () => {
    <div className="mt-10 border-2 p-8 bg-white bg-opacity-50">
      <div className="text-black font-semibold text-fs-20 mb-3">
        {"How this works?"->React.string}
      </div>
      <ol className="list-decimal flex flex-col gap-5 text-md text-black opacity-50">
        <p>
          {"If you have multiple business units, add them here by providing the country and a label for each unit. We have created a default business unit during your sign up"->React.string}
        </p>
        <p>
          {"For Eg: If you have clothing and shoe business units in both US & GB and the 'US clothing' unit has to be your default business unit, then create the following units:"->React.string}
        </p>
        <ul className="list-disc list-inside">
          <li> {"Country = US, label = default"->React.string} </li>
          <li> {"Country = US, label = shoe"->React.string} </li>
          <li> {"Country = GB, label = clothing"->React.string} </li>
          <li> {"Country = GB, label = shoe"->React.string} </li>
        </ul>
        <p className="font-semibold"> {"Note: "->React.string} </p>
        <ul className="list-disc list-inside">
          <li>
            {"When creating a connector, you need to attach it to a business unit."->React.string}
          </li>
          <li>
            <span>
              {"If you have more than one business unit, you need to send the business_country & business_label fields during"->React.string}
            </span>
            <span
              className="ml-1 cursor-pointer text-blue-800"
              onClick={_ =>
                Window._open(
                  "https://api-reference.hyperswitch.io/docs/hyperswitch-api-reference/60bae82472db8-payments-create",
                )}
              target="_blank">
              {"payments/create API request"->React.string}
            </span>
          </li>
        </ul>
      </ol>
    </div>
  }
}

@react.component
let make = (
  ~isFromSettings=true,
  ~showModalFromOtherScreen=false,
  ~setShowModalFromOtherScreen=_bool => (),
  ~isFromWebhooks=false,
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
    Recoil.useRecoilValueFromAtom(
      HyperswitchAtom.businessProfilesAtom,
    )->HSwitchMerchantAccountUtils.getArrayOfBusinessProfile

  let fetchBusinessProfiles = HSwitchMerchantAccountUtils.useFetchBusinessProfiles()

  let updateMerchantDetails = async body => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let url = getURL(~entityName=BUSINESS_PROFILE, ~methodType=Post, ())
      let _res = await updateDetails(url, body, Post)
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
  let tableHeaderText = isFromWebhooks ? "Webhooks" : "Business profiles"

  <PageLoaderWrapper screenState>
    <UIUtils.RenderIf condition=isFromSettings>
      <div className="relative h-full">
        <div className="flex flex-col-reverse md:flex-col">
          <div className="font-semibold text-fs-20"> {tableHeaderText->React.string} </div>
          <LoadedTable
            title="Business profiles"
            hideTitle=true
            resultsPerPage=7
            visibleColumns
            entity={businessProfileTabelEntity(isFromWebhooks)}
            showSerialNumber=true
            actualData={businessProfileValues->Js.Array2.map(Js.Nullable.return)}
            totalResults={businessProfileValues->Js.Array2.length}
            offset
            setOffset
            currrentFetchCount={businessProfileValues->Js.Array2.length}
          />
          // <BusinessUnitText />
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
