open LogicUtils
open ReconEngineAuditLogDrawerTypes

let parseAccountData = (json: JSON.t): accountData => {
  let dict = json->getDictFromJsonObject
  {
    account_id: dict->getString("account_id", ""),
    account_name: dict->getString("account_name", ""),
  }
}

let getEventTypeFromJson = (json: JSON.t): auditEvent => {
  let dict = json->getDictFromJsonObject
  let eventType = dict->getString("event_type", "")

  switch eventType {
  | "file_uploaded" =>
    FileUploaded({
      account: dict->getObj("account", Dict.make())->JSON.Encode.object->parseAccountData,
      ingestion_id: dict->getString("ingestion_id", ""),
      file_name: dict->getString("file_name", ""),
      timestamp: dict->getString("timestamp", ""),
    })

  | "ingestions_failed" =>
    IngestionsFailed({
      account: dict->getObj("account", Dict.make())->JSON.Encode.object->parseAccountData,
      count: dict->getInt("count", 0),
      last_failed_at: dict->getString("last_failed_at", ""),
    })

  | "staging_entries_created" =>
    StagingEntriesCreated({
      account: dict->getObj("account", Dict.make())->JSON.Encode.object->parseAccountData,
      count: dict->getInt("count", 0),
      timestamp: dict->getString("timestamp", ""),
    })

  | "staging_entry_needs_manual_review" =>
    StagingEntryNeedsManualReview({
      account: dict->getObj("account", Dict.make())->JSON.Encode.object->parseAccountData,
      count: dict->getInt("count", 0),
      timestamp: dict->getString("timestamp", ""),
    })
  | "expectations_created" =>
    ExpectationsCreated({
      accounts: dict
      ->getArrayFromDict("accounts", [])
      ->Array.map(parseAccountData),
      count: dict->getInt("count", 0),
      timestamp: dict->getString("timestamp", ""),
    })
  | "transactions_reconciled" =>
    TransactionsReconciled({
      accounts: dict
      ->getArrayFromDict("accounts", [])
      ->Array.map(parseAccountData),
      count: dict->getInt("count", 0),
      timestamp: dict->getString("timestamp", ""),
    })
  | "transactions_mismatched" =>
    TransactionsMismatched({
      accounts: dict
      ->getArrayFromDict("accounts", [])
      ->Array.map(parseAccountData),
      count: dict->getInt("count", 0),
      timestamp: dict->getString("timestamp", ""),
    })
  | _ => NoAuditEvent
  }
}

let getEventMetadata = (event: auditEvent): eventMetadata => {
  switch event {
  | FileUploaded({account, file_name, _}) => {
      eventType: EventInfo,
      color: "bg-blue-500",
      title: "File Uploaded",
      description: `${file_name} \u2022 ${account.account_name}`,
    }
  | IngestionsFailed({account, count, _}) => {
      eventType: EventError,
      color: "bg-red-500",
      title: count === 1 ? "1 Ingestion Failed" : `${count->Int.toString} Ingestions Failed`,
      description: account.account_name,
    }
  | StagingEntriesCreated({account, count, _}) => {
      eventType: EventInfo,
      color: "bg-blue-500",
      title: count === 1
        ? "1 Transformed Entry Created"
        : `${count->Int.toString} Transformed Entries Created`,
      description: account.account_name,
    }
  | StagingEntryNeedsManualReview({account, count, _}) => {
      eventType: EventWarning,
      color: "bg-yellow-500",
      title: count === 1
        ? "1 Transformed Entry Needs Manual Review"
        : `${count->Int.toString} Transformed Entries Need Manual Review`,
      description: account.account_name,
    }
  | ExpectationsCreated({accounts, count, _}) => {
      eventType: EventSuccess,
      color: "bg-green-500",
      title: count === 1 ? "1 Expectation Created" : `${count->Int.toString} Expectations Created`,
      description: {
        let accountNames =
          accounts
          ->Array.map(acc => acc.account_name)
          ->Array.joinWith(", ")
        accountNames
      },
    }
  | TransactionsReconciled({accounts, count, _}) => {
      eventType: EventSuccess,
      color: "bg-green-500",
      title: count === 1
        ? "1 Transaction Reconciled"
        : `${count->Int.toString} Transactions Reconciled`,
      description: {
        let accountNames =
          accounts
          ->Array.map(acc => acc.account_name)
          ->Array.joinWith(", ")
        accountNames
      },
    }
  | TransactionsMismatched({accounts, count, _}) => {
      eventType: EventError,
      color: "bg-red-500",
      title: count === 1
        ? "1 Transaction Mismatched"
        : `${count->Int.toString} Transactions Mismatched`,
      description: {
        let accountNames =
          accounts
          ->Array.map(acc => acc.account_name)
          ->Array.joinWith(", ")
        accountNames
      },
    }
  | NoAuditEvent => {
      eventType: EventNone,
      color: "bg-gray-500",
      title: "No Event",
      description: "No audit event available",
    }
  }
}

let getTimestamp = (event: auditEvent): string => {
  switch event {
  | FileUploaded({timestamp, _})
  | StagingEntriesCreated({timestamp, _})
  | StagingEntryNeedsManualReview({timestamp, _})
  | ExpectationsCreated({timestamp, _})
  | TransactionsReconciled({timestamp, _})
  | TransactionsMismatched({timestamp, _}) => timestamp
  | IngestionsFailed({last_failed_at, _}) => last_failed_at
  | NoAuditEvent => ""
  }
}

let sortByTimeStamp = (a: auditEvent, b: auditEvent) => {
  compareLogic(a->getTimestamp, b->getTimestamp)
}
