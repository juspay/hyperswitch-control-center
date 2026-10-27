open BlocklistTypes
open BlocklistHelper

@react.component
let make = (~transactionType: blocklistTransactionType, ~onExportStarted) => {
  let transactionLabel = (transactionType :> string)

  let checkOrUnblockTabs: array<Tabs.tab> = [
    {
      title: "Check",
      renderContent: () =>
        <div className="pt-4">
          <BlocklistLookupCard transactionType />
        </div>,
    },
    {
      title: "Unblock",
      renderContent: () =>
        <div className="pt-4">
          <BlocklistEntryCard
            operation=DeleteBlocklistEntry
            transactionType
            title="Unblock a single entry"
            description="Transactions using this card BIN or fingerprint will no longer be declined by this blocklist."
            buttonText="Unblock"
            eventName="blocklist_delete_entry"
          />
        </div>,
    },
  ]

  <div className="flex flex-col gap-8 mt-6">
    <BlocklistCountSummary transactionType />
    <div className="max-w-3xl flex flex-col">
      <Step
        stepNumber=1
        title="Add an entry"
        description={`Blocks a single card BIN or fingerprint in the ${transactionLabel} blocklist. To add many at once, use Bulk upload below.`}>
        <BlocklistEntryCard
          operation=AddBlocklistEntry
          transactionType
          title="Block a single entry"
          description="Best for a few entries. Blocked immediately."
          buttonText="Block"
          eventName="blocklist_add_entry"
        />
      </Step>
      <Step
        stepNumber=2
        title="Check or unblock"
        description="Confirm whether a value is blocked, or remove an entry you no longer want to block.">
        <Tabs tabs=checkOrUnblockTabs variant=Boxed size=Md fitContent=true />
      </Step>
      <Step
        stepNumber=3
        title="Export"
        description={`Download this profile's ${transactionLabel} blocklist.`}
        isLast=true>
        <BlocklistExportCard transactionType onExportStarted />
      </Step>
    </div>
  </div>
}
