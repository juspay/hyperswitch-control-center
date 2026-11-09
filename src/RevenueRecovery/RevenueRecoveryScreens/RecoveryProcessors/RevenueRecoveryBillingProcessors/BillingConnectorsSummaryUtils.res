open RevenueRecoveryProfileHelper
open Typography

// No connector to show or configure on the external model, so it only has profile level settings
let getExternalModelTabs = (
  ~recoveryProfile: option<RevenueRecoveryProfileTypes.recoveryProfile>,
  ~onProfileSaved,
): array<Tabs.tab> => [
  {
    title: "API Keys",
    renderContent: () => {
      <div className="flex flex-col gap-20 mt-10">
        <RecoveryApiKeysTable />
      </div>
    },
  },
  {
    title: "Retries Configuration",
    renderContent: () => {
      <div className="flex flex-col gap-20 mt-10">
        <ProfileRetriesConfiguration
          retryConfig={recoveryProfile->Option.flatMap(profile => profile.retryConfig)}
          onProfileSaved
        />
      </div>
    },
  },
  {
    title: "Webhooks",
    renderContent: () => {
      <p className={`${body.md.regular} text-nd_gray-500 mt-10 px-2`}>
        {"Webhooks are not enabled yet."->React.string}
      </p>
    },
  },
]
