open ReconEngineSelfServeTypes
open ReconEngineSelfServeUtils

@react.component
let make = () => {
  let {merchantId, profileId} = React.useContext(
    UserInfoProvider.defaultContext,
  ).getCommonSessionDetails()

  let (mode, setMode) = React.useState(_ => None)
  let (currentStep, setCurrentStep) = React.useState(_ => AccountSetup)
  let (state, setState) = React.useState(_ => emptySelfServeState)

  let onAccountCreated = (account: createdAccount) => {
    setState(prev => {
      ...prev,
      accounts: Array.concat(prev.accounts, [account]),
    })
  }

  let onIngestionCreated = (ingestion: createdIngestion) => {
    setState(prev => {
      ...prev,
      ingestions: Array.concat(prev.ingestions, [ingestion]),
    })
  }

  let onTransformationCreated = (transformation: createdTransformation) => {
    setState(prev => {
      ...prev,
      transformations: Array.concat(prev.transformations, [transformation]),
    })
  }

  let goToNext = () => {
    switch currentStep->getNextStep {
    | Some(next) => setCurrentStep(_ => next)
    | None => ()
    }
  }

  let goToPrev = () => {
    switch currentStep->getPrevStep {
    | Some(prev) => setCurrentStep(_ => prev)
    | None => ()
    }
  }

  switch mode {
  | None => <ReconEngineSelfServeLanding onSelectMode={m => setMode(_ => Some(m))} />
  | Some(GuidedSetup) =>
    <div className="flex gap-8 p-6 min-h-[70vh]">
      // Left: Step indicator
      <ReconEngineSelfServeStepIndicator
        currentStep state onStepClick={step => setCurrentStep(_ => step)}
      />
      // Right: Step content
      <div className="flex-1 pl-2">
        {switch currentStep {
        | AccountSetup =>
          <ReconEngineSelfServeAccountStep state onAccountCreated onNext={goToNext} />
        | IngestionSetup =>
          <ReconEngineSelfServeIngestionStep
            state
            merchantId
            profileId
            onIngestionCreated
            onNext={goToNext}
            onBack={goToPrev}
          />
        | TransformationSetup =>
          <ReconEngineSelfServeTransformationStep
            state
            merchantId
            profileId
            onTransformationCreated
            onNext={goToNext}
            onBack={goToPrev}
          />
        | RuleSetup =>
          <ReconEngineSelfServeRuleStep state onNext={goToNext} onBack={goToPrev} />
        | Complete => <ReconEngineSelfServeComplete state />
        }}
      </div>
    </div>
  | Some(ExpertSetup) =>
    // Expert mode: Tabbed interface with all forms accessible independently
    <div className="p-6">
      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 className="text-xl font-semibold text-gray-900">
            {"Reconciliation Setup"->React.string}
          </h1>
          <p className="text-sm text-gray-500">
            {"Configure each component independently."->React.string}
          </p>
        </div>
        <button
          type_="button"
          onClick={_ => setMode(_ => None)}
          className="text-sm text-gray-500 hover:text-gray-700">
          {`\u{2190} Back to start`->React.string}
        </button>
      </div>
      // Tab navigation
      <div className="flex border-b border-gray-200 mb-6">
        {[
          (AccountSetup, "Accounts"),
          (IngestionSetup, "Ingestion"),
          (TransformationSetup, "Transformation"),
          (RuleSetup, "Rules"),
        ]
        ->Array.map(((step, label)) =>
          <button
            key={label}
            type_="button"
            className={`px-4 py-3 text-sm font-medium border-b-2 transition-colors ${currentStep === step
                ? "border-blue-600 text-blue-600"
                : "border-transparent text-gray-500 hover:text-gray-700"}`}
            onClick={_ => setCurrentStep(_ => step)}>
            {label->React.string}
            {if step->isStepComplete(state) {
              <span className="ml-1.5 text-green-600"> {`\u{2713}`->React.string} </span>
            } else {
              React.null
            }}
          </button>
        )
        ->React.array}
      </div>
      // Content
      <div className="max-w-2xl">
        {switch currentStep {
        | AccountSetup =>
          <ReconEngineSelfServeAccountStep
            state onAccountCreated onNext={() => setCurrentStep(_ => IngestionSetup)}
          />
        | IngestionSetup =>
          <ReconEngineSelfServeIngestionStep
            state
            merchantId
            profileId
            onIngestionCreated
            onNext={() => setCurrentStep(_ => TransformationSetup)}
            onBack={() => setCurrentStep(_ => AccountSetup)}
          />
        | TransformationSetup =>
          <ReconEngineSelfServeTransformationStep
            state
            merchantId
            profileId
            onTransformationCreated
            onNext={() => setCurrentStep(_ => RuleSetup)}
            onBack={() => setCurrentStep(_ => IngestionSetup)}
          />
        | RuleSetup =>
          <ReconEngineSelfServeRuleStep
            state
            onNext={() => setCurrentStep(_ => Complete)}
            onBack={() => setCurrentStep(_ => TransformationSetup)}
          />
        | Complete => <ReconEngineSelfServeComplete state />
        }}
      </div>
    </div>
  }
}
