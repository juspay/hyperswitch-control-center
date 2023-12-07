module ProdIntentForm = {
  @react.component
  let make = () => {
    open ProdVerifyModalUtils

    <div className="flex flex-col gap-12 h-full w-full">
      <FormRenderer.DesktopRow>
        <div className="grid grid-cols-2 gap-5">
          {formFields
          ->Array.mapWithIndex((column, index) =>
            <FormRenderer.FieldRenderer
              key={index->string_of_int}
              fieldWrapperClass="w-full"
              field={column->getFormField}
              errorClass
              labelClass="!text-black font-medium !-ml-[0.5px]"
            />
          )
          ->React.array}
        </div>
      </FormRenderer.DesktopRow>
    </div>
  }
}

@react.component
let make = (~goLive) => {
  open QuickStartTypes
  open APIUtils
  open ProdVerifyModalUtils
  let fetchDetails = useGetMethod()
  let updateDetails = useUpdateMethod()
  let email = HSLocalStorage.getFromMerchantDetails("email")
  let (initialValues, setInitialValues) = React.useState(_ => Js.Dict.empty())
  let {isProdIntentCompleted} = React.useContext(GlobalProvider.defaultContext)
  let (isSubmitBtnDisabled, setIsSubmitBtnDisabled) = React.useState(_ => false)
  let {
    dashboardPageState,
    integrationDetails,
    setIntegrationDetails,
    setIsProdIntentCompleted,
    setQuickStartPageState,
    setDashboardPageState,
  } = React.useContext(GlobalProvider.defaultContext)

  let markAsDone = async () => {
    try {
      let url = getURL(~entityName=INTEGRATION_DETAILS, ~methodType=Post, ())
      let body = HSwitchUtils.constructOnboardingBody(
        ~dashboardPageState,
        ~integrationDetails,
        ~is_done=true,
        (),
      )
      let _ = await updateDetails(url, body, Post)
      setIntegrationDetails(_ => body->ProviderHelper.getIntegrationDetails)
      setQuickStartPageState(_ => FinalLandingPage)
    } catch {
    | _ => ()
    }
  }

  let getProdVerifyDetails = async () => {
    open LogicUtils
    try {
      let url = getURL(~entityName=PROD_VERIFY, ~methodType=Fetch.Get, ())
      let res = await fetchDetails(url)
      let valueDict = res->getDictFromJsonObject->getDictfromDict("response")
      let hideHeader = valueDict->getBool(IsCompleted->getStringFromVariant, false)
      setIsProdIntentCompleted(_ => hideHeader)
      if !hideHeader {
        valueDict->Js.Dict.set(POCemail->getStringFromVariant, email->Js.Json.string)
      } else if !integrationDetails.account_activation.is_done {
        markAsDone()->ignore
      }
      setInitialValues(_ => valueDict)
    } catch {
    | _ => ()
    }
  }

  let updateProdDetails = async values => {
    try {
      let url = getURL(~entityName=PROD_VERIFY, ~methodType=Fetch.Post, ())
      let body = values->getBody->Js.Json.object_
      let _ = await updateDetails(url, body, Post)
      getProdVerifyDetails()->ignore
      markAsDone()->ignore
    } catch {
    | _ => ()
    }
    Js.Nullable.null
  }

  let onSubmit = (values, _) => {
    updateProdDetails(values)
  }

  let landingButtonGroup = {
    <div className="flex flex-col gap-4 w-full">
      <UIUtils.RenderIf condition={!isProdIntentCompleted}>
        <Button
          text="Get Production Access"
          buttonType={Primary}
          onClick={_ => setQuickStartPageState(_ => GoLive(GO_LIVE))}
        />
      </UIUtils.RenderIf>
      <Button
        text="Go to Home"
        buttonType={Secondary}
        onClick={_ => {
          setDashboardPageState(_ => #HOME)
          RescriptReactRouter.replace("/home")
        }}
      />
    </div>
  }
  <div className="w-full h-full flex ">
    <div className="w-full h-full flex items-center justify-center">
      {switch goLive {
      | LANDING =>
        <QuickStartUIUtils.StepCompletedPage
          headerText="You have successfully completed Integration (Test Mode)"
          buttonGroup={landingButtonGroup}
        />
      | GO_LIVE =>
        <Form
          key="go-live-prod-intent-form"
          initialValues={initialValues->Js.Json.object_}
          validate={values =>
            values->validateForm(
              ~fieldsToValidate=formFields,
              ~setIsDisabled=setIsSubmitBtnDisabled,
            )}
          onSubmit>
          <QuickStartUIUtils.BaseComponent
            headerText="Provide Business Details"
            headerLeftIcon="hyperswitch-logo-short"
            nextButton={<FormRenderer.SubmitButton
              disabledParamter=isSubmitBtnDisabled text="Submit" buttonSize={Small}
            />}
            backButton={<Button
              buttonType={PrimaryOutline}
              text="Exit to Homepage"
              onClick={_ => {
                setDashboardPageState(_ => #HOME)
                RescriptReactRouter.replace("/home")
              }}
              buttonSize=Small
            />}>
            <div className="flex flex-col justify-center gap-8">
              <div className="mx-4 text-grey-50 w-2/3 leading-6">
                {"We require some information to verify your business. Once verified, you'll be able to access production environment and go live!"->React.string}
              </div>
              <ProdIntentForm />
            </div>
          </QuickStartUIUtils.BaseComponent>
        </Form>
      }}
    </div>
  </div>
}
