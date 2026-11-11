open RevenueRecoveryProfileHelper

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
      <div className="flex flex-col gap-20 mt-10">
        <ProfileWebhooksConfiguration
          webhookDetails={recoveryProfile->Option.flatMap(profile => profile.webhookDetails)}
          paymentResponseHashKey={recoveryProfile->Option.mapOr("", profile =>
            profile.paymentResponseHashKey
          )}
          onProfileSaved
        />
      </div>
    },
  },
]

let getConfigurationTabs = (
  ~recoveryProfile: option<RevenueRecoveryProfileTypes.recoveryProfile>,
  ~onProfileSaved,
  ~connectorTabs: array<Tabs.tab>,
) =>
  recoveryProfile->RevenueRecoveryProfileUtils.isExternalModel
    ? getExternalModelTabs(~recoveryProfile, ~onProfileSaved)
    : connectorTabs
