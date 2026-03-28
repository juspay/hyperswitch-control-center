open ReconEngineSelfServeTypes
open ReconEngineSelfServeUtils

module GuidedMode = {
  @react.component
  let make = () => {
    let (currentStep, setCurrentStep) = React.useState(_ => AccountStep)
    let (
      wizardState,
      _setWizardState,
      onAccountCreated,
      onIngestionCreated,
      onTransformationCreated,
      onRuleCreated,
    ) = useWizardState()

    let goToStep = step => setCurrentStep(_ => step)

    let onBack = () => {
      let currentIndex = currentStep->stepToIndex
      if currentIndex > 0 {
        setCurrentStep(_ => (currentIndex - 1)->indexToStep)
      } else {
        RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url="/v1/recon-engine/setup"))
      }
    }

    <div className="flex h-full">
      <div className="flex flex-col">
        <ReconEngineSelfServeStepIndicator currentStep onBack />
      </div>
      <div className="flex-1 px-10 py-8 overflow-y-auto">
        {switch currentStep {
        | AccountStep =>
          <ReconEngineSelfServeAccountStep
            wizardState onAccountCreated onNext={() => goToStep(IngestionStep)}
          />
        | IngestionStep =>
          <ReconEngineSelfServeIngestionStep
            wizardState
            onIngestionCreated
            onNext={() => goToStep(TransformationStep)}
            onBack={() => goToStep(AccountStep)}
          />
        | TransformationStep =>
          <ReconEngineSelfServeTransformationStep
            wizardState
            onTransformationCreated
            onNext={() => goToStep(RuleStep)}
            onBack={() => goToStep(IngestionStep)}
          />
        | RuleStep =>
          <ReconEngineSelfServeRuleStep
            wizardState
            onRuleCreated
            onNext={() => goToStep(CompleteStep)}
            onBack={() => goToStep(TransformationStep)}
          />
        | CompleteStep => <ReconEngineSelfServeComplete wizardState />
        }}
      </div>
    </div>
  }
}

module ExpertMode = {
  @react.component
  let make = () => {
    let getAccounts = ReconEngineHooks.useGetAccounts()
    let (activeTab, setActiveTab) = React.useState(_ => AccountStep)
    let (showComplete, setShowComplete) = React.useState(_ => false)
    let (isLoadingAccounts, setIsLoadingAccounts) = React.useState(_ => true)
    let (
      wizardState,
      setWizardState,
      onAccountCreated,
      onIngestionCreated,
      onTransformationCreated,
      onRuleCreated,
    ) = useWizardState()

    React.useEffect0(() => {
      let fetchExistingAccounts = async () => {
        try {
          let accounts = await getAccounts()
          let existingAccounts: array<createdAccount> = accounts->Array.map(a => {
            account_id: a.account_id,
            account_name: a.account_name,
            account_type: a.account_type,
          })
          if existingAccounts->Array.length > 0 {
            setWizardState(prev => {...prev, accounts: existingAccounts})
          }
        } catch {
        | _ => Console.error("Failed to fetch existing accounts")
        }
        setIsLoadingAccounts(_ => false)
      }
      fetchExistingAccounts()->ignore
      None
    })

    let tabs: array<(selfServeStep, string, int)> = [
      (AccountStep, "Accounts", wizardState.accounts->Array.length),
      (IngestionStep, "Data Sources", wizardState.ingestions->Array.length),
      (TransformationStep, "Column Mapping", wizardState.transformations->Array.length),
      (RuleStep, "Rules", wizardState.rules->Array.length),
    ]

    if showComplete {
      <ReconEngineSelfServeComplete wizardState />
    } else if isLoadingAccounts {
      <div className="flex items-center justify-center min-h-[40vh]">
        <div className="flex flex-col items-center gap-3">
          <div
            className="w-8 h-8 border-2 border-blue-200 border-t-blue-600 rounded-full animate-spin"
          />
          <p className="text-sm text-nd_gray-400"> {"Loading accounts..."->React.string} </p>
        </div>
      </div>
    } else {
      <div className="flex flex-col gap-6 px-6 py-8">
        // Header
        <div className="flex flex-col gap-1">
          <div className="flex items-center gap-3">
            <Button
              text=""
              leftIcon={CustomIcon(<Icon name="nd-arrow-left" customHeight="16" />)}
              buttonType=Secondary
              onClick={_ =>
                RescriptReactRouter.replace(
                  GlobalVars.appendDashboardPath(~url="/v1/recon-engine/setup"),
                )}
              customButtonStyle="!border-0 !text-nd_gray-400"
            />
            <h1 className="text-xl font-semibold text-nd_gray-800">
              {"Recon Setup — Expert Mode"->React.string}
            </h1>
          </div>
        </div>
        // Tabs
        <div className="flex border-b border-nd_gray-200">
          {tabs
          ->Array.map(((step, label, count)) => {
            let key = step->stepToString
            let isActive = activeTab === step
            let tabStyle = isActive
              ? "border-b-2 border-blue-500 text-blue-600 font-semibold"
              : "text-nd_gray-400 hover:text-nd_gray-600"
            <div
              key
              className={`px-4 py-2.5 text-sm transition-colors cursor-pointer ${tabStyle}`}
              onClick={_ => setActiveTab(_ => step)}>
              <div className="flex items-center gap-2">
                {label->React.string}
                <RenderIf condition={count > 0}>
                  <span className="text-xs px-1.5 py-0.5 rounded-full bg-blue-50 text-blue-600">
                    {count->Int.toString->React.string}
                  </span>
                </RenderIf>
              </div>
            </div>
          })
          ->React.array}
        </div>
        // Tab content
        <div className="max-w-3xl">
          {switch activeTab {
          | AccountStep =>
            <ReconEngineSelfServeAccountStep
              wizardState
              onAccountCreated
              onNext={() => setActiveTab(_ => IngestionStep)}
              isGuidedMode=false
            />
          | IngestionStep =>
            <ReconEngineSelfServeIngestionStep
              wizardState
              onIngestionCreated
              onNext={() => setActiveTab(_ => TransformationStep)}
              onBack={() => setActiveTab(_ => AccountStep)}
              isGuidedMode=false
            />
          | TransformationStep =>
            <ReconEngineSelfServeTransformationStep
              wizardState
              onTransformationCreated
              onNext={() => setActiveTab(_ => RuleStep)}
              onBack={() => setActiveTab(_ => IngestionStep)}
              isGuidedMode=false
            />
          | RuleStep =>
            <ReconEngineSelfServeRuleStep
              wizardState
              onRuleCreated
              onNext={() => setShowComplete(_ => true)}
              onBack={() => setActiveTab(_ => TransformationStep)}
              isGuidedMode=false
            />
          | CompleteStep => React.null
          }}
        </div>
      </div>
    }
  }
}

@react.component
let make = () => {
  let (mode, setMode) = React.useState(_ => None)

  switch mode {
  | None => <ReconEngineSelfServeLanding onSelectMode={m => setMode(_ => Some(m))} />
  | Some(Guided) => <GuidedMode />
  | Some(Expert) => <ExpertMode />
  }
}
