open RevenueRecoveryProfileTypes
open RevenueRecoveryProfileUtils
open Typography

module SelectionCard = {
  @react.component
  let make = (~title, ~description, ~isSelected, ~onClick) => {
    let borderClass = isSelected ? "border-primary bg-primary bg-opacity-5" : "border-nd_gray-200"
    <div
      className={`flex flex-1 flex-col gap-2 p-5 border rounded-xl cursor-pointer ${borderClass}`}
      onClick={_ => onClick()}>
      <p className={`${body.md.semibold} text-nd_gray-700`}> {title->React.string} </p>
      <p className={`${body.sm.regular} text-nd_gray-500`}> {description->React.string} </p>
    </div>
  }
}

module Chip = {
  @react.component
  let make = (~text) => {
    <div
      className="flex items-center w-fit px-2 py-3 whitespace-nowrap cursor-default h-8 bg-white border rounded-lg text-sm font-semibold text-nd_gray-500 border-nd_gray-300">
      {text->React.string}
    </div>
  }
}

module ModelChip = {
  @react.component
  let make = () => {
    let {activeProduct} = React.useContext(ProductSelectionProvider.defaultContext)
    let recoveryProfile = HyperswitchAtom.recoveryProfileAtom->Recoil.useRecoilValueFromAtom

    switch (activeProduct, recoveryProfile) {
    | (Recovery, Some({triggerModel, retryAlgorithm: Some(_)})) =>
      <Chip text={triggerModel->getTriggerModelLabel} />
    | _ => React.null
    }
  }
}

let retryGridClass = "grid grid-cols-2 gap-x-10 gap-y-5 max-w-3xl"

let totalRetriesHint = "The total number of retries that should be done within the grace period"
let startOfRecoveryHint = "After how many of your own retries the recovery process should start"
let hardDeclineRetriesHint = "The number of retries allowed on an invoice after a hard decline"
let partialAuthorizationHint = "Allow partial authorization for recovered payments. A value sent in the recovery API request takes priority over this"
let webhookUrlHint = "We send the next retry time of each invoice to this URL"
let retryModeHint = "Monitoring records failed invoices and schedules no retries. Smart works out the best time for each retry."

module InfoHint = {
  @react.component
  let make = (~description) =>
    <ToolTip
      toolTipPosition=Top description toolTipFor={<Icon name="info-circle-unfilled" size=14 />}
    />
}

module RetryModeSelector = {
  @react.component
  let make = (~selectedMode, ~onChange, ~isDisabled=false) => {
    <div className="flex flex-col gap-2">
      <div className="flex gap-2 items-center">
        <h4 className={`text-nd_gray-400 ${body.md.regular}`}> {"Mode"->React.string} </h4>
        <InfoHint description=retryModeHint />
      </div>
      <div className="flex gap-2">
        {[Monitoring, Smart]
        ->Array.map(mode =>
          <Button
            key={(mode :> string)}
            text={mode->getRetryAlgorithmLabel}
            buttonType={mode == selectedMode ? Primary : Secondary}
            buttonState={isDisabled ? Disabled : Normal}
            buttonSize=Small
            onClick={_ => onChange(mode)}
            customButtonStyle="w-fit"
          />
        )
        ->React.array}
      </div>
    </div>
  }
}

module RetryConfigFields = {
  @react.component
  let make = (~children=React.null) => {
    let infoIcon = description => <InfoHint description />

    let renderField = (~label, ~key, ~placeholder, ~description=?) =>
      <FormRenderer.FieldRenderer
        labelClass={`!text-nd_gray-400 ${body.md.regular}`}
        field={FormRenderer.makeFieldInfo(
          ~label,
          ~customLabelIcon=?description->Option.map(infoIcon),
          ~name=key->getRetryConfigFieldName,
          ~placeholder,
          ~customInput=InputFields.numericTextInput(~customStyle="rounded-xl"),
          ~isRequired=true,
        )}
      />

    <div className={retryGridClass}>
      {renderField(
        ~label="Start of recovery",
        ~key=retryThresholdKey,
        ~placeholder="ex 3",
        ~description=startOfRecoveryHint,
      )}
      {renderField(
        ~label="Total retries",
        ~key=maxRetryCountKey,
        ~placeholder="ex 15",
        ~description=totalRetriesHint,
      )}
      {renderField(
        ~label="Total retries for hard declines",
        ~key=maxHardDeclineRetriesKey,
        ~placeholder="ex 0",
        ~description=hardDeclineRetriesHint,
      )}
      {renderField(~label="Grace Period (days)", ~key=gracePeriodDaysKey, ~placeholder="ex 30")}
      <FormRenderer.FieldRenderer
        labelClass={`!text-nd_gray-400 ${body.md.regular}`}
        field={FormRenderer.makeFieldInfo(
          ~label="Partial Authorization",
          ~customLabelIcon=infoIcon(partialAuthorizationHint),
          ~name=enablePartialAuthorizationKey->getRetryConfigFieldName,
          ~customInput=InputFields.switchInput(~isDisabled=true),
          ~isRequired=false,
        )}
      />
      <div className="px-2 pt-1"> {children} </div>
    </div>
  }
}

module RecoveryApiKeysTable = {
  @react.component
  let make = () => {
    <div className="px-2">
      <KeyManagementHelper.ApiKeysTable
        dataNotFoundComponent={<div className="p-1">
          <div
            className={`h-56 -my-1 -mx-2 border-2 flex justify-center items-center border-dashed opacity-70 rounded-lg p-5 m-7`}>
            {"No API Keys Available"->React.string}
          </div>
        </div>}
      />
    </div>
  }
}

module CancelEditButton = {
  @react.component
  let make = (~initialValues, ~onCancel) => {
    let form = ReactFinalForm.useForm()
    <Button
      text="Cancel"
      onClick={_ => {
        form.reset(initialValues->Nullable.make)
        onCancel()
      }}
      buttonType={Secondary}
      buttonSize={Small}
      customButtonStyle="w-fit"
    />
  }
}

module ProfileRetriesConfiguration = {
  open LogicUtils
  @react.component
  let make = (~retryConfig, ~onProfileSaved) => {
    let updateBusinessProfile = BusinessProfileHook.useUpdateBusinessProfile(~version=V2)
    let showToast = ToastAdapter.useShowToast()
    let (isEditMode, setIsEditMode) = React.useState(_ => false)
    let initialValues = React.useMemo(() => getRetryConfigInitialValues(retryConfig), [retryConfig])
    let savedConfig = retryConfig->Option.getOr(getDefaultRetryConfig())
    let savedMode = RevenueRecoveryHooks.useSavedRetryMode()
    let (selectedMode, setSelectedMode) = React.useState(_ => savedMode)
    let confirmModeChange = RevenueRecoveryHooks.useConfirmModeChange()

    let startEditing = () => {
      setSelectedMode(_ => savedMode)
      setIsEditMode(_ => true)
    }

    let save = async values => {
      try {
        let body = values->getDictFromJsonObject->Dict.copy
        if selectedMode != savedMode {
          body->Dict.set(retryAlgorithmKey, (selectedMode :> string)->JSON.Encode.string)
        }
        let response = await updateBusinessProfile(~body=body->JSON.Encode.object)
        onProfileSaved(response->mapJsonToRecoveryProfile)
        setIsEditMode(_ => false)
        showToast(~message="Retries configuration updated", ~toastType=ToastState.ToastSuccess)
      } catch {
      | _ => ()
      }
    }

    let onSubmit = async (values, _form: ReactFinalForm.formApi) => {
      if selectedMode != savedMode {
        confirmModeChange(~mode=selectedMode, ~onConfirm=() => save(values)->ignore)
      } else {
        await save(values)
      }
      Nullable.null
    }

    let renderValue = (~label, ~value, ~hint="") =>
      <div className="flex flex-col gap-2">
        <div className="flex gap-2 items-center">
          <h4 className="text-nd_gray-400"> {label->React.string} </h4>
          <RenderIf condition={hint->isNonEmptyString}>
            <InfoHint description=hint />
          </RenderIf>
        </div>
        <p> {value->React.string} </p>
      </div>

    <Form onSubmit initialValues validate=validateRetryConfig>
      <div className="flex flex-col gap-7 px-2">
        <div className="flex justify-end">
          <div>
            <RenderIf condition={isEditMode}>
              <div className="flex gap-4">
                <CancelEditButton initialValues onCancel={() => setIsEditMode(_ => false)} />
                <FormRenderer.SubmitButton
                  text="Save" buttonSize={Small} customSubmitButtonStyle="w-fit"
                />
              </div>
            </RenderIf>
            <RenderIf condition={!isEditMode}>
              <div className="flex gap-2 items-center cursor-pointer" onClick={_ => startEditing()}>
                <Icon name="nd-edit" size=14 />
                <a className="text-primary cursor-pointer"> {"Edit"->React.string} </a>
              </div>
            </RenderIf>
          </div>
        </div>
        <RenderIf condition={isEditMode}>
          <RetryConfigFields>
            <RetryModeSelector selectedMode onChange={mode => setSelectedMode(_ => mode)} />
          </RetryConfigFields>
        </RenderIf>
        <RenderIf condition={!isEditMode}>
          <div className={retryGridClass}>
            {renderValue(
              ~label="Start of recovery",
              ~hint=startOfRecoveryHint,
              ~value=savedConfig->getInt(retryThresholdKey, 0)->Int.toString,
            )}
            {renderValue(
              ~label="Total retries",
              ~hint=totalRetriesHint,
              ~value=savedConfig->getInt(maxRetryCountKey, 0)->Int.toString,
            )}
            {renderValue(
              ~label="Total retries for hard declines",
              ~hint=hardDeclineRetriesHint,
              ~value=savedConfig->getInt(maxHardDeclineRetriesKey, 0)->Int.toString,
            )}
            {renderValue(
              ~label="Grace Period",
              ~value=`${savedConfig
                ->getInt(gracePeriodDaysKey, RevenueRecoveryOnboardingUtils.defaultGracePeriodDays)
                ->Int.toString} days`,
            )}
            <div className="flex flex-col gap-2">
              <div className="flex gap-2 items-center">
                <h4 className="text-nd_gray-400"> {"Partial Authorization"->React.string} </h4>
                <InfoHint description=partialAuthorizationHint />
              </div>
              <SwitchAdapter
                isSelected={savedConfig->getBool(enablePartialAuthorizationKey, false)}
                setIsSelected={_ => ()}
                isDisabled=true
                toggleBorder="border-green-950"
                toggleEnableColor="bg-green-950"
              />
            </div>
            <RetryModeSelector selectedMode=savedMode isDisabled=true onChange={_ => ()} />
          </div>
        </RenderIf>
      </div>
    </Form>
  }
}

module WebhookUrlField = {
  @react.component
  let make = () =>
    <FormRenderer.FieldRenderer
      labelClass={`!text-nd_gray-400 ${body.md.regular}`}
      fieldWrapperClass="max-w-xl"
      field={FormRenderer.makeFieldInfo(
        ~label="Webhook URL",
        ~customLabelIcon=<InfoHint description=webhookUrlHint />,
        ~name=webhookUrlFieldName,
        ~placeholder="Enter Webhook URL",
        ~customInput=InputFields.textInput(~autoComplete="off", ~customStyle="rounded-xl"),
        ~isRequired=false,
      )}
    />
}

module PaymentResponseHashKey = {
  @react.component
  let make = (~hashKey) =>
    <div className="flex flex-col gap-2">
      <h4 className="text-nd_gray-400"> {"Payment Response Hash Key"->React.string} </h4>
      <HelperComponents.CopyTextCustomComp
        displayValue={Some(hashKey)}
        customTextCss={`break-all truncate md:whitespace-normal ${body.md.regular} text-nd_gray-800`}
        customParentClass="flex items-center gap-5"
        customIconCss="text-nd_gray-700"
      />
    </div>
}

module ProfileWebhooksConfiguration = {
  @react.component
  let make = (~webhookDetails, ~paymentResponseHashKey, ~onProfileSaved) => {
    let updateBusinessProfile = BusinessProfileHook.useUpdateBusinessProfile(~version=V2)
    let showToast = ToastAdapter.useShowToast()
    let {isLiveMode} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
    let initialValues = React.useMemo(
      () => getWebhookInitialValues(webhookDetails),
      [webhookDetails],
    )

    let onSubmit = async (values, _form: ReactFinalForm.formApi) => {
      try {
        let body =
          [
            (
              webhookDetailsKey,
              getWebhookDetailsBody(~webhookUrl=values->getWebhookUrl, ~webhookDetails),
            ),
          ]
          ->Dict.fromArray
          ->JSON.Encode.object
        let response = await updateBusinessProfile(~body)
        onProfileSaved(response->mapJsonToRecoveryProfile)
        showToast(~message="Webhook URL updated", ~toastType=ToastState.ToastSuccess)
      } catch {
      // The update hook has already shown the error toast
      | _ => ()
      }
      Nullable.null
    }

    let validate = values => {
      let errors = Dict.make()
      errors->validateWebhookUrl(values, ~isLiveMode)
      errors->JSON.Encode.object
    }

    <div className="flex flex-col gap-8 px-2 max-w-xl">
      <Form onSubmit initialValues validate>
        <div className="flex flex-col gap-4">
          <WebhookUrlField />
          <div className="flex justify-end">
            <FormRenderer.SubmitButton
              text="Update" buttonSize={Small} customSubmitButtonStyle="w-fit"
            />
          </div>
        </div>
      </Form>
      <RenderIf condition={paymentResponseHashKey->LogicUtils.isNonEmptyString}>
        <PaymentResponseHashKey hashKey=paymentResponseHashKey />
      </RenderIf>
    </div>
  }
}
