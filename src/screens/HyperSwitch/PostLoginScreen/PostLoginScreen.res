open PostLoginUtils
type cardFlowDirection = LEFT | RIGHT
module SurveyComponent = {
  @react.component
  let make = (~currentStep, ~setCurrentStep, ~currentQuestionDict, ~setCarouselDirection) => {
    let currentQuestionValue =
      ReactFinalForm.useField(currentQuestionDict.key).input.value->LogicUtils.getStringFromJson("")
    let isNextButtonEnabled = currentQuestionValue->String.length > 0

    <div className="flex flex-col gap-2 h-full ">
      <div className="flex flex-col gap-2">
        <p className="text-fs-12 text-jp-grey-700 opacity-50">
          {`${(currentStep + 1)->string_of_int} of 3`->React.string}
        </p>
        <div className="flex gap-2">
          <p className="text-fs-20 text-jp-grey-700 font-semibold">
            {currentQuestionDict.question->React.string}
          </p>
          <span className="text-red-950"> {React.string("*")} </span>
        </div>
      </div>
      <FormRenderer.FieldRenderer
        field={FormRenderer.makeFieldInfo(
          ~label="",
          ~name=currentQuestionDict.key,
          ~customInput=InputFields.radioInput(
            ~options=currentQuestionDict.options,
            ~buttonText="options",
            ~customStyle="p-2.5 border rounded-md text-fs-18 w-11/12 flex gap-2 !overflow-visible",
            ~baseComponentCustomStyle="flex flex-col gap-4 md:!min-h-[30rem]",
            ~customSelectStyle="bg-blue-700 bg-opacity-5 border-blue-700",
            ~fill="#006DF9",
            (),
          ),
          (),
        )}
      />
      <div className="flex gap-4 w-full mt-4">
        <Button
          text={"Go Back"}
          buttonType={Secondary}
          customButtonStyle="!rounded-md w-full"
          onClick={_ => {
            setCarouselDirection(_ => LEFT)
            setCurrentStep(_ => currentStep - 1)
          }}
          buttonState={currentStep === 0 ? Disabled : Normal}
        />
        {if currentStep == 2 {
          <FormRenderer.SubmitButton
            text="Submit"
            customSumbitButtonStyle="!rounded-md w-full"
            disabledParamter={currentQuestionValue->String.length > 0 ? false : true}
          />
        } else {
          <Button
            text={"Continue"}
            buttonType={Primary}
            customButtonStyle="!rounded-md w-full"
            onClick={_ => {
              setCarouselDirection(_ => RIGHT)
              setCurrentStep(_ => currentStep + 1)
            }}
            buttonState={isNextButtonEnabled ? Normal : Disabled}
          />
        }}
      </div>
    </div>
  }
}

@react.component
let make = () => {
  open APIUtils
  let showToast = ToastState.useShowToast()
  let userName = HSLocalStorage.getFromUserDetails("name")
  let (currentStep, setCurrentStep) = React.useState(_ => 0)
  let (carouselDirection, setCarouselDirection) = React.useState(_ => RIGHT)
  let (_, setAuthStatus) = React.useContext(AuthInfoProvider.authStatusContext)
  let {setDashboardPageState} = React.useContext(GlobalProvider.defaultContext)
  let updateDetails = useUpdateMethod(~showErrorToast=false, ())
  let isPostLoginQuestionnairePending =
    HSLocalStorage.getFromUserDetails("is_metadata_filled")->LogicUtils.getBoolFromString(true)

  React.useEffect1(() => {
    if !isPostLoginQuestionnairePending {
      RescriptReactRouter.push("/post-login-questionare")
    }
    None
  }, [isPostLoginQuestionnairePending])

  let onSubmit = async (values, _) => {
    try {
      let postLoginSurveyUrl = getURL(
        ~entityName=USERS,
        ~userType=#SET_METADATA,
        ~methodType=Post,
        (),
      )

      let _ = await updateDetails(
        postLoginSurveyUrl,
        values->generateSurveyJson->Js.Json.object_,
        Post,
      )
      HSwitchUtils.setUserDetails("is_metadata_filled", "true"->Js.Json.string)
      setDashboardPageState(_ => #AUTO_CONNECTOR_INTEGRATION)
    } catch {
    | Js.Exn.Error(e) =>
      let err = Js.Exn.message(e)->Belt.Option.getWithDefault("Failed to Fetch!")
      if err->String.includes("UR_19") {
        showToast(~toastType=ToastWarning, ~message="Please login again!", ~autoClose=false, ())
        setAuthStatus(LoggedOut)
      }
    }
    Js.Nullable.null
  }
  let xPositionBasedOnDirection = carouselDirection === RIGHT ? 100 : -100
  <HSwitchUtils.BackgroundImageWrapper>
    <div
      className="h-full w-full md:w-pageWidth11 mx-auto py-10 px-20 overflow-y-scroll grid grid-col-1 md:grid-rows-[8rem,1fr] md:grid-cols-[10rem,1fr] grid-flow-row md:grid-flow-col place-items-center md:place-items-start">
      <div className="row-span-2">
        <Icon
          name="hyperswitch-text-icon"
          size=24
          className="cursor-pointer w-36"
          parentClass="flex flex-col justify-center items-center"
        />
      </div>
      <div className="w-full col-span-1 flex flex-col gap-2 items-center justify-center">
        <div className=" flex flex-col md:flex-row items-center justify-center">
          <div className="flex flex-row">
            <p className="text-fs-20 font-medium">
              {`Hey ${userName->LogicUtils.capitalizeString}`->React.string}
            </p>
            <img className="h-8 w-8 mx-3" src={`/images/hyperswitchImages/WavingHandImage.svg`} />
          </div>
          <p className="text-fs-20 font-medium "> {`Welcome to Hyperswitch`->React.string} </p>
        </div>
        <p className="text-fs-12 text-jp-grey-700 opacity-50 ">
          {`Help us know you better in 3 simple steps`->React.string}
        </p>
      </div>
      <div className="w-full flex row-span-1 col-span-1 justify-center items-center ">
        <div className="flex flex-col gap-10 h-full items-center w-full sm:w-133 ">
          <FramerMotion.AnimatePresence initial={false} custom={currentStep}>
            <Form onSubmit initialValues={initialValueDict} formClass="!w-full">
              <FramerMotion.Motion.Div
                key={currentStep->string_of_int}
                initial={{opacity: 0, x: xPositionBasedOnDirection}}
                animate={{opacity: 1, x: 0}}
                exit={{opacity: 0, x: -100}}
                transition={{duration: 0.3}}
                className="flex flex-col flex-wrap bg-white p-8 !rounded-md !shadow-[0_4px_9px_0_rgba(0,0,0,_0.12)] carousel-item">
                <SurveyComponent
                  currentStep
                  setCurrentStep
                  setCarouselDirection
                  currentQuestionDict={questionForSurvey
                  ->Belt.Array.get(currentStep)
                  ->Belt.Option.getWithDefault(defaultValueForQuestions)}
                />
              </FramerMotion.Motion.Div>
            </Form>
          </FramerMotion.AnimatePresence>
        </div>
      </div>
    </div>
  </HSwitchUtils.BackgroundImageWrapper>
}
