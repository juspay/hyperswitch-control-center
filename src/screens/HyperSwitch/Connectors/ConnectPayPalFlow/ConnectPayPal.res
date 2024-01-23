let h3Leading2TextClass = `${HSwitchUtils.getTextClass(
    ~textVariant=H3,
    ~h3TextVariant=Leading_2,
    (),
  )} text-grey-700`
let p1RegularTextClass = `${HSwitchUtils.getTextClass(
    ~textVariant=P1,
    ~paragraphTextVariant=Regular,
    (),
  )} text-grey-700 opacity-50`

let p1MediumTextClass = `${HSwitchUtils.getTextClass(
    ~textVariant=P1,
    ~paragraphTextVariant=Medium,
    (),
  )} text-grey-700`
let p2RedularTextClass = `${HSwitchUtils.getTextClass(
    ~textVariant=P2,
    ~paragraphTextVariant=Regular,
    (),
  )} text-grey-700 opacity-50`

let preRequisiteList = [
  "You need to grant all the permissions to create and receive payments",
  "Confirm your email id once PayPal sends you the mail",
]

module PayPalCreateNewAccountModal = {
  @react.component
  let make = (~butttonDisplayText, ~actionUrl, ~setScreenState) => {
    let initializePayPalWindow = () => {
      try {
        Window.payPalCreateAccountWindow()
      } catch {
      | Js.Exn.Error(e) =>
        switch Js.Exn.message(e) {
        | Some(message) => setScreenState(_ => PageLoaderWrapper.Error(message))
        | None => setScreenState(_ => PageLoaderWrapper.Error("Failed to load paypal window!"))
        }
      }
    }

    React.useEffect0(() => {
      initializePayPalWindow()
      None
    })

    <button
      className="!w-fit rounded-md bg-blue-700 text-white px-4  h-fit border py-3 flex items-center justify-center gap-2"
      onClick={e => {
        e->ReactEvent.Mouse.stopPropagation
      }}>
      <AddDataAttributes attributes=[("data-paypal-button", "true")]>
        <a href={`${actionUrl}&displayMode=minibrowser`} target="PPFrame">
          {butttonDisplayText->React.string}
        </a>
      </AddDataAttributes>
      <Icon name="thin-right-arrow" size=20 />
    </button>
  }
}
module ManualSetupScreen = {
  @react.component
  let make = (
    ~connector,
    ~connectorAccountFields,
    ~selectedConnector,
    ~connectorMetaDataFields,
    ~connectorWebHookDetails,
    ~connectorLabelDetailField,
  ) => {
    <div className="flex flex-col gap-8">
      <ConnectorAccountDetailsHelper.ConnectorConfigurationFields
        connector={connector->ConnectorUtils.getConnectorNameTypeFromString}
        connectorAccountFields
        selectedConnector
        connectorMetaDataFields
        connectorWebHookDetails
        connectorLabelDetailField
      />
    </div>
  }
}

module LandingScreen = {
  @react.component
  let make = (~configuartionType, ~setConfigurationType) => {
    let getBlockColor = value =>
      configuartionType === value ? "border border-blue-700 bg-blue-700 bg-opacity-10 " : "border"

    <div className="flex flex-col gap-10">
      <div className="flex flex-col gap-4">
        <p className=h3Leading2TextClass>
          {"Do you have a PayPal business account?"->React.string}
        </p>
        <div className="grid grid-cols-1 gap-4 md:grid-cols-2 md:gap-8">
          {PayPalFlowUtils.listChoices
          ->Array.mapWithIndex((items, index) => {
            <div
              key={index->string_of_int}
              className={`p-6 flex flex-col gap-4 rounded-md cursor-pointer ${items.variantType->getBlockColor} rounded-md`}
              onClick={_ => setConfigurationType(_ => items.variantType)}>
              <div className="flex justify-between items-center">
                <div className="flex gap-2 items-center ">
                  <p className=p1MediumTextClass> {items.displayText->React.string} </p>
                </div>
                <Icon
                  name={configuartionType === items.variantType ? "selected" : "nonselected"}
                  size=20
                  className="cursor-pointer !text-blue-800"
                />
              </div>
              <div className="flex gap-2 items-center ">
                <p className=p1RegularTextClass> {items.choiceDescription->React.string} </p>
              </div>
            </div>
          })
          ->React.array}
        </div>
      </div>
    </div>
  }
}
module RedirectionToPayPalFlow = {
  @react.component
  let make = (~actionUrl, ~setActionUrl, ~connectorId, ~getStatus) => {
    open APIUtils

    let url = RescriptReactRouter.useUrl()
    let path = url.path->Belt.List.toArray->Array.joinWith("/")
    let updateDetails = useUpdateMethod(~showErrorToast=false, ())
    let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)

    let getRedirectPaypalWindowUrl = async _ => {
      open LogicUtils
      try {
        setScreenState(_ => PageLoaderWrapper.Loading)
        let returnURL = `${HSwitchGlobalVars.hyperSwitchFEPrefix}/${path}?${url.search}&is_back=true&is_simplified_paypal=true`

        let body = PayPalFlowUtils.generatePayPalBody(
          ~connectorId={connectorId},
          ~returnUrl=Some(returnURL),
          (),
        )
        let url = `${getURL(~entityName=PAYPAL_ONBOARDING, ~methodType=Post, ())}/action_url`

        let response = await updateDetails(url, body, Post)
        let actionURL =
          response->getDictFromJsonObject->getDictfromDict("paypal")->getString("action_url", "")
        setActionUrl(_ => actionURL)
        setScreenState(_ => PageLoaderWrapper.Success)
      } catch {
      | _ => setScreenState(_ => PageLoaderWrapper.Error(""))
      }
    }

    React.useEffect0(() => {
      getRedirectPaypalWindowUrl()->ignore
      None
    })
    <PageLoaderWrapper screenState>
      <div className="flex flex-col gap-6">
        <p className=h3Leading2TextClass>
          {"Sign in / Sign up to auto-configure your credentials & webhooks"->React.string}
        </p>
        <div className="flex flex-col gap-2">
          <p className={`${p1RegularTextClass} !opacity-100`}>
            {"Things to keep in mind while signing up"->React.string}
          </p>
          {preRequisiteList
          ->Array.mapWithIndex((item, index) =>
            <p className=p1RegularTextClass>
              {`${(index + 1)->string_of_int}. ${item}`->React.string}
            </p>
          )
          ->React.array}
        </div>
        <div className="flex gap-4 items-center">
          <PayPalCreateNewAccountModal
            actionUrl butttonDisplayText="Sign in / Sign up on PayPal" setScreenState
          />
          <Button
            text="Refresh status "
            buttonType={Secondary}
            buttonSize=Small
            onClick={_ => getStatus()->ignore}
          />
        </div>
      </div>
    </PageLoaderWrapper>
  }
}

module ErrorPage = {
  @react.component
  let make = (~setupAccountStatus, ~actionUrl, ~getStatus, ~setActionUrl, ~connectorId) => {
    open APIUtils
    let url = RescriptReactRouter.useUrl()
    let updateDetails = useUpdateMethod(~showErrorToast=false, ())
    let path = url.path->Belt.List.toArray->Array.joinWith("/")
    let errorPageDetails = setupAccountStatus->PayPalFlowUtils.getPageDetailsForAutomatic
    let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)

    let getRedirectPaypalWindowUrl = async _ => {
      open LogicUtils
      try {
        setScreenState(_ => PageLoaderWrapper.Loading)
        let returnURL = `${HSwitchGlobalVars.hyperSwitchFEPrefix}/${path}?${url.search}&is_back=true&is_simplified_paypal=true`

        let body = PayPalFlowUtils.generatePayPalBody(
          ~connectorId={connectorId},
          ~returnUrl=Some(returnURL),
          (),
        )
        let url = `${getURL(~entityName=PAYPAL_ONBOARDING, ~methodType=Post, ())}/action_url`

        let response = await updateDetails(url, body, Post)
        let actionURL =
          response->getDictFromJsonObject->getDictfromDict("paypal")->getString("action_url", "")
        setActionUrl(_ => actionURL)
        setScreenState(_ => PageLoaderWrapper.Success)
      } catch {
      | _ => setScreenState(_ => PageLoaderWrapper.Error(""))
      }
    }

    React.useEffect0(() => {
      getRedirectPaypalWindowUrl()->ignore
      None
    })
    <PageLoaderWrapper screenState>
      <div className="flex flex-col gap-6">
        <div className="flex flex-col gap-6 p-8 bg-jp-gray-light_gray_bg">
          <Icon name="error-icon" size=24 />
          <div className="flex flex-col gap-2">
            <UIUtils.RenderIf condition={errorPageDetails.headerText->Js.String2.length > 0}>
              <p className={`${p1RegularTextClass} !opacity-100`}>
                {errorPageDetails.headerText->React.string}
              </p>
            </UIUtils.RenderIf>
            <UIUtils.RenderIf condition={errorPageDetails.subText->Js.String2.length > 0}>
              <p className=p1RegularTextClass> {errorPageDetails.subText->React.string} </p>
            </UIUtils.RenderIf>
          </div>
          <div className="flex gap-4 items-center">
            <PayPalCreateNewAccountModal
              actionUrl butttonDisplayText="Sign in / Sign up on PayPal" setScreenState
            />
            <Button
              text="Refresh status"
              buttonType={Secondary}
              buttonSize=Small
              onClick={_ => getStatus()->ignore}
            />
          </div>
          <UIUtils.RenderIf condition={errorPageDetails.buttonText->Belt.Option.isSome}>
            <PayPalCreateNewAccountModal
              butttonDisplayText={errorPageDetails.buttonText->Belt.Option.getWithDefault("")}
              actionUrl
              setScreenState
            />
          </UIUtils.RenderIf>
        </div>
      </div>
    </PageLoaderWrapper>
  }
}

@react.component
let make = (~connector, ~isUpdateFlow, ~setInitialValues, ~initialValues, ~setCurrentStep) => {
  open APIUtils
  open LogicUtils
  let url = RescriptReactRouter.useUrl()
  let showToast = ToastState.useShowToast()

  let connectorValue = isUpdateFlow
    ? url.path->Belt.List.toArray->Belt.Array.get(1)->Belt.Option.getWithDefault("")
    : url.search
      ->getDictFromUrlSearchParams
      ->Dict.get("connectorId")
      ->Belt.Option.getWithDefault("")

  let (connectorId, setConnectorId) = React.useState(_ => connectorValue)
  let updateDetails = useUpdateMethod(~showErrorToast=false, ())
  let updateConnector = PayPalFlowUtils.useDeleteConnectorCredentials()
  let deleteTrackingDetails = PayPalFlowUtils.useDeleteTrackingDetails()
  let isRedirectedFromPaypalModal =
    url.search
    ->getDictFromUrlSearchParams
    ->Dict.get("is_back")
    ->Belt.Option.getWithDefault("")
    ->getBoolFromString(false)

  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)
  let (configuartionType, setConfigurationType) = React.useState(_ => PayPalFlowTypes.NotSelected)
  let (actionUrl, setActionUrl) = React.useState(_ => "")

  let (setupAccountStatus, setSetupAccountStatus) = Recoil.useRecoilState(
    HyperswitchAtom.paypalAccountStatusAtom,
  )
  let selectedConnector =
    connector->ConnectorUtils.getConnectorNameTypeFromString->ConnectorUtils.getConnectorInfo
  let defaultBusinessProfile = Recoil.useRecoilValueFromAtom(HyperswitchAtom.businessProfilesAtom)

  let activeBusinessProfile =
    defaultBusinessProfile->MerchantAccountUtils.getValueFromBusinessProfile

  let updatedInitialVal = React.useMemo1(() => {
    let initialValuesToDict = initialValues->LogicUtils.getDictFromJsonObject
    if !isUpdateFlow {
      initialValuesToDict->Dict.set(
        "connector_label",
        initialValues
        ->LogicUtils.getDictFromJsonObject
        ->LogicUtils.getString("connector_label", "paypal_default")
        ->Js.Json.string,
      )
      initialValuesToDict->Dict.set("profile_id", activeBusinessProfile.profile_id->Js.Json.string)

      setInitialValues(_ => initialValuesToDict->Js.Json.object_)
      initialValuesToDict->Js.Json.object_
    } else {
      initialValues
    }
  }, [connector])

  let onSubmitMain = async values => {
    open ConnectorUtils
    try {
      setScreenState(_ => Loading)
      let res = await updateConnector(values, connectorId, connector, isUpdateFlow)

      setInitialValues(_ => res)
      let connectorId = res->getDictFromJsonObject->getString("merchant_connector_id", "")
      setConnectorId(_ => connectorId)
      setScreenState(_ => Success)
      if !isUpdateFlow {
        RescriptReactRouter.push(`/connectors/new?name=paypal&connectorId=${connectorId}`)
      }
      setSetupAccountStatus(._ => Redirecting_to_paypal)
    } catch {
    | Js.Exn.Error(e) => {
        switch Js.Exn.message(e) {
        | Some(message) => {
            let errMsg = message->parseIntoMyData
            if errMsg.code->Belt.Option.getWithDefault("")->Js.String2.includes("HE_01") {
              showToast(
                ~message="This configuration already exists for the connector. Please try with a different country or label under advanced settings.",
                ~toastType=ToastState.ToastError,
                (),
              )
              setCurrentStep(_ => ConnectorTypes.AutomaticFlow)
              setSetupAccountStatus(._ => Connect_paypal_landing)
              setScreenState(_ => Success)
            } else {
              showToast(
                ~message="Failed to Save the Configuration!",
                ~toastType=ToastState.ToastError,
                (),
              )
              setScreenState(_ => Error(message))
            }
          }

        | None => setScreenState(_ => Error("Failed to Fetch!"))
        }
        Js.Exn.raiseError("Failed to Fetch!")
      }
    }
  }

  let handleStateToNextPage = () => {
    setCurrentStep(_ => ConnectorTypes.PaymentMethods)
  }
  let getStatus = async () => {
    open PayPalFlowUtils
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let profileId = initialValues->getDictFromJsonObject->getString("profile_id", "")
      let paypalBody = generatePayPalBody(
        ~connectorId={connectorId},
        ~profileId=Some(profileId),
        (),
      )
      let url = `${getURL(~entityName=PAYPAL_ONBOARDING, ~methodType=Post, ())}/sync`
      let responseValue = await updateDetails(url, paypalBody, Fetch.Post)
      let paypalDict = responseValue->getDictFromJsonObject->getJsonObjectFromDict("paypal")

      switch paypalDict->Js.Json.classify {
      | JSONString(str) => setSetupAccountStatus(._ => str->stringToVariantMapper)
      | JSONObject(dict) =>
        handleObjectResponse(
          ~dict,
          ~setSetupAccountStatus,
          ~setInitialValues,
          ~connector,
          ~handleStateToNextPage,
        )
      | _ => ()
      }
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error(""))
    }
  }

  React.useEffect0(() => {
    if isRedirectedFromPaypalModal {
      getStatus()->ignore
    }
    if !isUpdateFlow {
      RescriptReactRouter.replace("/connectors/new?name=paypal")
      setSetupAccountStatus(._ => Connect_paypal_landing)
    }
    None
  })

  let validateMandatoryFieldForPaypal = values => {
    let errors = Dict.make()
    let valuesFlattenJson = values->JsonFlattenUtils.flattenObject(true)
    let profileId = valuesFlattenJson->getString("profile_id", "")
    if profileId->Js.String2.length === 0 {
      Dict.set(errors, "Profile Id", `Please select your business profile`->Js.Json.string)
    }
    errors->Js.Json.object_
  }

  let handleConnector = async values => {
    try {
      await onSubmitMain(values)
    } catch {
    | Js.Exn.Error(_e) => ()
    }
  }

  let setConnectorAsActive = values => {
    // setting the status and diabled as false and active when clicking proceed button of manual flow
    let dictOfInitialValues = values->getDictFromJsonObject
    dictOfInitialValues->Dict.set("disabled", false->Js.Json.boolean)
    dictOfInitialValues->Dict.set("status", "active"->Js.Json.string)
    setInitialValues(_ => dictOfInitialValues->Js.Json.object_)
  }

  let handleOnSubmit = async (values, _) => {
    if setupAccountStatus === Connect_paypal_landing {
      let authType =
        initialValues
        ->getDictFromJsonObject
        ->getDictfromDict("connector_account_details")
        ->getString("auth_type", "")
        ->Js.String2.toLowerCase
        ->ConnectorUtils.mapAuthType

      // delete tracking  details and updating the mca if the currnet and the next auth types are not same
      if (
        isUpdateFlow &&
        authType !==
          PayPalFlowUtils.getBodyType(isUpdateFlow, configuartionType)
          ->String.toLowerCase
          ->ConnectorUtils.mapAuthType
      ) {
        let _ = await deleteTrackingDetails(connectorId, connector)
        let dictOfInitialValues = values->getDictFromJsonObject
        let temporaryAuthDict =
          [("auth_type", "TemporaryAuth"->Js.Json.string)]->getJsonFromArrayOfJson
        dictOfInitialValues->Dict.set("connector_account_details", temporaryAuthDict)
        setInitialValues(_ => dictOfInitialValues->Js.Json.object_)
        let res = await updateConnector(
          dictOfInitialValues->Js.Json.object_,
          connectorId,
          connector,
          isUpdateFlow,
        )
        setInitialValues(_ => res)
      }

      // handling the proceed button
      switch configuartionType {
      | Automatic => {
          setInitialValues(_ => values)
          handleConnector(values)->ignore
        }
      | Manual | _ => {
          setConnectorAsActive(values)
          setInitialValues(_ => values)
          setCurrentStep(_ => ConnectorTypes.IntegFields)
        }
      }
    }
    Js.Nullable.null
  }

  let proceedButton = switch setupAccountStatus {
  | Redirecting_to_paypal
  | Account_not_found
  | Payments_not_receivable
  | Ppcp_custom_denied
  | More_permissions_needed
  | Email_not_verified =>
    <Button
      text="Change configuration"
      buttonType={Primary}
      onClick={_ => setSetupAccountStatus(._ => Connect_paypal_landing)}
    />
  | _ =>
    <FormRenderer.SubmitButton
      loadingText="Processing..."
      text="Proceed"
      disabledParamter={configuartionType === NotSelected}
    />
  }

  <div className="w-full h-full flex flex-col justify-between">
    <PageLoaderWrapper screenState>
      <Form
        initialValues={updatedInitialVal}
        validate={validateMandatoryFieldForPaypal}
        onSubmit={handleOnSubmit}>
        <div>
          <ConnectorAccountDetailsHelper.ConnectorHeaderWrapper
            connector
            headerButton={proceedButton}
            // setShowModal
            conditionForIntegrationSteps={!(
              PayPalFlowUtils.conditionForIntegrationSteps->Array.includes(setupAccountStatus)
            )}>
            <div className="flex flex-col gap-2 p-2 md:p-10">
              {switch setupAccountStatus {
              | Connect_paypal_landing =>
                <div className="flex flex-col gap-2">
                  <div className="w-1/3">
                    <ConnectorAccountDetailsHelper.RenderConnectorInputFields
                      details={ConnectorUtils.connectorLabelDetailField}
                      name={"connector_label"}
                      keysToIgnore=ConnectorAccountDetailsHelper.metaDataInputKeysToIgnore
                      checkRequiredFields={ConnectorUtils.getMetaDataRequiredFields}
                      connector={connector->ConnectorUtils.getConnectorNameTypeFromString}
                      selectedConnector
                      isLabelNested=false
                      disabled={isUpdateFlow ? true : false}
                      description="This is an unique label you can generate and pass in order to identify this connector account on your Hyperswitch dashboard and reports. Eg: if your profile label is 'default', connector label can be 'stripe_default'"
                    />
                  </div>
                  <ConnectorAccountDetailsHelper.BusinessProfileRender
                    isUpdateFlow selectedConnector={connector}
                  />
                  <LandingScreen configuartionType setConfigurationType />
                </div>
              | Redirecting_to_paypal =>
                <RedirectionToPayPalFlow actionUrl setActionUrl connectorId getStatus />
              | Manual_setup_flow => React.null

              | Account_not_found
              | Payments_not_receivable
              | Ppcp_custom_denied
              | More_permissions_needed
              | Email_not_verified =>
                <ErrorPage setupAccountStatus actionUrl getStatus setActionUrl connectorId />
              | _ => React.null
              }}
            </div>
            <FormValuesSpy />
          </ConnectorAccountDetailsHelper.ConnectorHeaderWrapper>
        </div>
      </Form>
      <div className="bg-jp-gray-light_gray_bg flex py-4 px-10 gap-2">
        <img src="/assets/PayPalFullLogo.svg" />
        <p className=p2RedularTextClass>
          {"| Hyperswitch is PayPal's trusted partner, your credentials are secure & never stored with us."->React.string}
        </p>
      </div>
    </PageLoaderWrapper>
  </div>
}
