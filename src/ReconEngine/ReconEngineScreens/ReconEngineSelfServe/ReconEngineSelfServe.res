open ReconEngineSelfServeTypes

module GuidedMode = {
  @react.component
  let make = () => {
    let (currentStep, setCurrentStep) = React.useState(_ => AccountStep)
    let (wizardState, setWizardState) = React.useState(_ => ReconEngineSelfServeUtils.emptyWizardState)

    let goToStep = step => setCurrentStep(_ => step)

    let onAccountCreated = (account: createdAccount) => {
      setWizardState(prev => {
        ...prev,
        accounts: prev.accounts->Array.concat([account]),
      })
    }

    let onIngestionCreated = (ingestion: createdIngestion) => {
      setWizardState(prev => {
        ...prev,
        ingestions: prev.ingestions->Array.concat([ingestion]),
      })
    }

    let onTransformationCreated = (transformation: createdTransformation) => {
      setWizardState(prev => {
        ...prev,
        transformations: prev.transformations->Array.concat([transformation]),
      })
    }

    let onRuleCreated = (rule: createdRule) => {
      setWizardState(prev => {
        ...prev,
        rules: prev.rules->Array.concat([rule]),
      })
    }

    let onBack = () => {
      let currentIndex = currentStep->ReconEngineSelfServeUtils.stepToIndex
      if currentIndex > 0 {
        setCurrentStep(_ => (currentIndex - 1)->ReconEngineSelfServeUtils.indexToStep)
      } else {
        RescriptReactRouter.replace(
          GlobalVars.appendDashboardPath(~url="/v1/recon-engine/setup"),
        )
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
            wizardState
            onAccountCreated
            onNext={() => goToStep(IngestionStep)}
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
        | CompleteStep =>
          <ReconEngineSelfServeComplete wizardState />
        }}
      </div>
    </div>
  }
}

module ExpertMode = {
  @react.component
  let make = () => {
    let (activeTab, setActiveTab) = React.useState(_ => "account")
    let (wizardState, setWizardState) = React.useState(_ => ReconEngineSelfServeUtils.emptyWizardState)

    let onAccountCreated = (account: createdAccount) => {
      setWizardState(prev => {
        ...prev,
        accounts: prev.accounts->Array.concat([account]),
      })
    }

    let onIngestionCreated = (ingestion: createdIngestion) => {
      setWizardState(prev => {
        ...prev,
        ingestions: prev.ingestions->Array.concat([ingestion]),
      })
    }

    let onTransformationCreated = (transformation: createdTransformation) => {
      setWizardState(prev => {
        ...prev,
        transformations: prev.transformations->Array.concat([transformation]),
      })
    }

    let onRuleCreated = (rule: createdRule) => {
      setWizardState(prev => {
        ...prev,
        rules: prev.rules->Array.concat([rule]),
      })
    }

    let tabs = [
      ("account", "Accounts", wizardState.accounts->Array.length),
      ("ingestion", "Ingestion", wizardState.ingestions->Array.length),
      ("transformation", "Transformation", wizardState.transformations->Array.length),
      ("rule", "Rules", wizardState.rules->Array.length),
    ]

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
        ->Array.map(((key, label, count)) => {
          let isActive = activeTab === key
          let tabStyle = isActive
            ? "border-b-2 border-blue-500 text-blue-600 font-semibold"
            : "text-nd_gray-400 hover:text-nd_gray-600"
          <div
            key
            className={`px-4 py-2.5 text-sm transition-colors cursor-pointer ${tabStyle}`}
            onClick={_ => setActiveTab(_ => key)}>
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
        | "account" =>
          <ReconEngineSelfServeAccountStep
            wizardState
            onAccountCreated
            onNext={() => setActiveTab(_ => "ingestion")}
          />
        | "ingestion" =>
          <ReconEngineSelfServeIngestionStep
            wizardState
            onIngestionCreated
            onNext={() => setActiveTab(_ => "transformation")}
            onBack={() => setActiveTab(_ => "account")}
          />
        | "transformation" =>
          <ReconEngineSelfServeTransformationStep
            wizardState
            onTransformationCreated
            onNext={() => setActiveTab(_ => "rule")}
            onBack={() => setActiveTab(_ => "ingestion")}
          />
        | "rule" =>
          <ReconEngineSelfServeRuleStep
            wizardState
            onRuleCreated
            onNext={() => ()}
            onBack={() => setActiveTab(_ => "transformation")}
          />
        | _ => React.null
        }}
      </div>
    </div>
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
