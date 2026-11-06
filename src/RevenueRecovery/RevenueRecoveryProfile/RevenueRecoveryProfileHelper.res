open RevenueRecoveryProfileTypes
open RevenueRecoveryProfileUtils
open Typography

module SelectionCard = {
  @react.component
  let make = (~title, ~description, ~isSelected, ~onClick) => {
    let borderClass = isSelected ? "border-primary bg-primary bg-opacity-5" : "border-nd_gray-200"
    <button
      type_="button"
      onClick={_ => onClick()}
      className={`flex flex-1 flex-col gap-2 p-5 text-left border rounded-xl ${borderClass}`}>
      <p className={`${body.md.semibold} text-nd_gray-700`}> {title->React.string} </p>
      <p className={`${body.sm.regular} text-nd_gray-500`}> {description->React.string} </p>
    </button>
  }
}

// Matches the Live Mode badge in the app header
module Chip = {
  @react.component
  let make = (~text) => {
    <div
      className="flex items-center w-fit px-2 py-3 whitespace-nowrap cursor-default h-8 bg-white border rounded-lg text-sm font-semibold text-nd_gray-500 border-nd_gray-300">
      {text->React.string}
    </div>
  }
}

// Sits in the app header, so it has to check the product itself: the atom keeps its value after
// switching away from Recovery. A mode only exists once a model is in use, so nothing shows
// before onboarding, when the model would just be the backend's default.
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

// Profiles without a mode are treated as monitoring, as the backend does when a billing connector
// is added
let useSavedRetryMode = () =>
  HyperswitchAtom.recoveryProfileAtom
  ->Recoil.useRecoilValueFromAtom
  ->Option.flatMap(profile => profile.retryAlgorithm)
  ->Option.getOr(Monitoring)

// Changing the mode starts or stops retries on real invoices
let useConfirmModeChange = () => {
  let showPopUp = PopUpState.useShowPopUp()
  (~mode, ~onConfirm) =>
    showPopUp({
      popUpType: (Warning, WithIcon),
      heading: `Switch to ${mode->getRetryAlgorithmLabel}?`,
      description: switch mode {
      | Smart => "We'll start working out retry times for failed invoices."
      | _ => "Failed invoices will be recorded and no retries will be scheduled."
      }->React.string,
      handleConfirm: {
        text: "Switch",
        onClick: _ => onConfirm(),
      },
      handleCancel: {text: "Cancel"},
    })
}

let retryGridClass = "grid grid-cols-2 gap-x-10 gap-y-5 max-w-3xl"

let totalRetriesHint = "The total number of retries that should be done within the grace period"
let startOfRecoveryHint = "After how many of your own retries the recovery process should start"
let hardDeclineRetriesHint = "The number of retries allowed on an invoice after a hard decline"
let partialAuthorizationHint = "Allow partial authorization for recovered payments. A value sent in the recovery API request takes priority over this"
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
      <div className="flex gap-1 p-0.5 w-fit bg-white border rounded-lg border-nd_gray-300">
        {[Monitoring, Smart]
        ->Array.map(mode => {
          let selectedClass = switch (mode == selectedMode, isDisabled) {
          | (true, true) => "bg-nd_gray-100 text-nd_gray-600 cursor-not-allowed"
          | (true, false) => "bg-primary bg-opacity-10 text-primary"
          | (false, true) => "text-nd_gray-400 cursor-not-allowed"
          | (false, false) => "text-nd_gray-500 hover:bg-nd_gray-50"
          }
          <button
            key={mode->getRetryAlgorithmValue}
            type_="button"
            disabled=isDisabled
            onClick={_ => onChange(mode)}
            className={`px-3 h-7 rounded-md text-sm font-semibold whitespace-nowrap ${selectedClass}`}>
            {mode->getRetryAlgorithmLabel->React.string}
          </button>
        })
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
      // Lines up with the padding the form fields have around them
      <div className="px-2 pt-1"> {children} </div>
    </div>
  }
}
