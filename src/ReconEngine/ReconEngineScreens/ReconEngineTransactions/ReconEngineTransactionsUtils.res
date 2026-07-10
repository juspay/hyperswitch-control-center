open LogicUtils
open ReconEngineFilterUtils
open ReconEngineTypes
open ReconEngineUtils
open ReconEngineTransactionsTypes

let searchTypeFromString = str => {
  switch str {
  | "order_id" => OrderId
  | "transaction_id" => TransactionId
  | _ => UnknownTransactionSearchType
  }
}

let searchTypeOptions: array<SearchInput.searchTypeOption> = [TransactionId, OrderId]->Array.map((
  txnType
): SearchInput.searchTypeOption => {
  {
    label: (txnType :> string)->snakeToTitle,
    value: (txnType :> string),
  }
})

let getSortOrder = (sortOb: LoadedTable.sortOb): transactionSortOrder => {
  sortOb.sortKey === "date" && sortOb.sortType === LoadedTable.ASC ? Asc : Desc
}

let transactionCursorFromDict = dict => {
  let cursorValueDict = dict->getDictfromDict("cursor_value")

  {
    sortField: dict->getString("sort_field", "effective_at"),
    cursorValue: Some({
      effectiveAt: cursorValueDict->getString("effective_at", ""),
      cursorId: cursorValueDict->getString("id", ""),
    }),
  }
}

let defaultSortBy: transactionCursor = {sortField: "effective_at", cursorValue: None}

let buildTransactionsV2Body = (
  ~filterValueJson: Dict.t<JSON.t>,
  ~searchType: transactionSearchType,
  ~searchText: string,
  ~ruleId: string,
  ~sortBy: transactionCursor,
  ~direction: cursorDirection,
  ~order: transactionSortOrder=Desc,
  ~limit=4,
  (),
) => {
  let statusFilter = filterValueJson->getArrayFromDict("status", [])
  let finalStatusFilter = getMergedMatchedTransactionStatusFilter(statusFilter)
  let statusValues =
    finalStatusFilter->isEmptyArray
      ? getTransactionStatusValueFromStatusList([
          Expected,
          Missing,
          OverAmount(Mismatch),
          UnderAmount(Mismatch),
          OverAmount(Expected),
          UnderAmount(Expected),
          Posted(Manual),
          Matched(Auto),
          Matched(Manual),
          Matched(WithTolerance),
          Matched(Force),
          Void,
          PartiallyReconciled,
          DataMismatch,
          SplitMismatch,
          CurrencyMismatch,
        ])
      : finalStatusFilter->Array.map(v => v->getStringFromJson(""))

  let startTime = filterValueJson->getString("startTime", "")
  let endTime = filterValueJson->getString("endTime", "")
  let hasTimeRange = startTime->isNonEmptyString && endTime->isNonEmptyString

  let filters =
    [
      ruleId->isNonEmptyString ? Some(("rule_id", ruleId->JSON.Encode.string)) : None,
      Some(("status", statusValues->getJsonFromArrayOfString)),
      hasTimeRange
        ? Some((
            "time_range",
            [
              ("start_time", startTime->JSON.Encode.string),
              ("end_time", endTime->JSON.Encode.string),
            ]->getJsonFromArrayOfJson,
          ))
        : None,
      searchText->isNonEmptyString
        ? Some(((searchType :> string), searchText->String.trim->JSON.Encode.string))
        : None,
    ]
    ->Array.filterMap(entry => entry)
    ->getJsonFromArrayOfJson

  let cursorPayload: transactionsV2CursorPayload = {
    limit,
    direction,
    order,
    sortBy,
  }

  [
    ("filters", filters),
    ("cursor_payload", cursorPayload->Identity.genericTypeToJson),
  ]->getJsonFromArrayOfJson
}

let constructTransactionBulkRequestBody = (
  ~bulkActionType: actionType,
  ~valuesDict,
  ~selectedRows,
) => {
  let postAction =
    [
      (
        "manual_post",
        [
          ("reason", valuesDict->getString("reason", "")->JSON.Encode.string),
        ]->getJsonFromArrayOfJson,
      ),
    ]->getJsonFromArrayOfJson

  let voidAction =
    [
      (
        "void",
        [
          ("reason", valuesDict->getString("reason", "")->JSON.Encode.string),
        ]->getJsonFromArrayOfJson,
      ),
    ]->getJsonFromArrayOfJson

  let action = switch bulkActionType {
  | BulkTransactionPost => postAction
  | BulkTransactionVoid => voidAction
  | UnknownBulkTransactionActionType => JSON.Encode.null
  }

  let selection = [
    ("selection_type", "ids"->JSON.Encode.string),
    (
      "ids",
      selectedRows
      ->Array.map((txn: transactionType) => txn.id->JSON.Encode.string)
      ->JSON.Encode.array,
    ),
  ]->getJsonFromArrayOfJson

  [("action", action), ("selection", selection)]->getJsonFromArrayOfJson
}

let getTransactionBulkActionsCount = (
  ~bulkActionResponses: array<ReconEngineExceptionsTypes.bulkActionResponse>,
) => {
  bulkActionResponses->Array.reduce((0, 0, 0, 0), (acc, response) => {
    let (successCount, failedCount, skippedCount, totalCount) = acc
    switch response.bulk_action_status {
    | BulkActionSuccess => (successCount + 1, failedCount, skippedCount, totalCount + 1)
    | BulkActionFailed => (successCount, failedCount + 1, skippedCount, totalCount + 1)
    | BulkActionInEligible => (successCount, failedCount, skippedCount + 1, totalCount + 1)
    | UnknownBulkActionStatus => (successCount, failedCount, skippedCount, totalCount + 1)
    }
  })
}

let entriesMetadataKeyToString = key => {
  switch key {
  | Amount => "amount"
  | Currency => "currency"
  }
}

let entriesMetadataExcludedKeys = [Amount, Currency]->Array.map(entriesMetadataKeyToString)

let getFilteredMetadataFromEntries = metadata => {
  metadata
  ->getDictFromJsonObject
  ->Dict.toArray
  ->Array.filter(((key, _value)) => {
    !Array.includes(entriesMetadataExcludedKeys, key)
  })
  ->Dict.fromArray
}

let getHeadersForCSV = () => {
  "Order ID,Transaction ID,Payment Gateway,Payment Method,Txn Amount,Settlement Amount,Recon Status,Transaction Date"
}

let getTransactionsPayloadFromDict = dict => {
  dict->transactionItemToObjMapper
}

let transactionsEntryItemToObjMapperFromDict = dict => {
  dict->entryItemToObjMapper
}

let sortByVersion = (c1: transactionType, c2: transactionType) => {
  compareLogic(c1.version, c2.version)
}

let getAccounts = (entries: array<transactionEntryType>, entryType: entryDirectionType): string => {
  let accounts =
    entries
    ->Array.filter(entry => entry.entry_type === entryType)
    ->Array.map(entry => entry.account.account_name)

  let uniqueAccounts = accounts->Array.reduce([], (acc, accountName) => {
    if Array.includes(acc, accountName) {
      acc
    } else {
      Array.concat(acc, [accountName])
    }
  })

  uniqueAccounts->Array.joinWith(", ")
}

let getTransactionFlowType = (
  ~transaction: transactionType,
  ~reconRulesList: array<ReconEngineRulesTypes.rulePayload>,
  ~accountData: array<accountType>,
): transactionFlowType => {
  switch reconRulesList->Array.find(rule => rule.rule_id === transaction.rule.rule_id) {
  | None => UnknownTransactionFlowType
  | Some(rule) =>
    let (_, targetAccounts) = ReconEngineRulesUtils.getSourceAndTargetAccountDetails(rule.strategy)

    let resolvedTargetAccounts =
      targetAccounts->Array.filterMap(targetAccount =>
        accountData->Array.find(account => account.account_id === targetAccount.account_id)
      )

    let netInflowAmount = resolvedTargetAccounts->Array.reduce(0.0, (netAcc, account) => {
      let (creditSum, debitSum) =
        transaction.entries
        ->Array.filter(entry => entry.account.account_id === account.account_id)
        ->Array.reduce((0.0, 0.0), ((creditSum, debitSum), entry) => {
          switch entry.entry_type {
          | Credit => (creditSum +. entry.amount.value, debitSum)
          | Debit => (creditSum, debitSum +. entry.amount.value)
          | UnknownEntryDirectionType => (creditSum, debitSum)
          }
        })
      switch account.account_type {
      | Debit => netAcc +. (debitSum -. creditSum)
      | Credit => netAcc +. (creditSum -. debitSum)
      | UnknownAccountTypeVariant => netAcc
      }
    })
    netInflowAmount > 0.0 ? InFlow : OutFlow
  }
}

let statusDisplayFilters = (): array<EntityType.initialFilters<'t>> => {
  let statusOptions = getGroupedTransactionStatusOptions([
    Posted(Manual),
    Matched(Auto),
    Matched(Manual),
    Matched(WithTolerance),
    OverAmount(Mismatch),
    OverAmount(Expected),
    UnderAmount(Mismatch),
    UnderAmount(Expected),
    DataMismatch,
    CurrencyMismatch,
    SplitMismatch,
    PartiallyReconciled,
    Expected,
    Missing,
    Void,
  ])

  [
    {
      field: FormRenderer.makeFieldInfo(
        ~label="transaction_status",
        ~name="status",
        ~customInput=InputFields.filterMultiSelectInput(
          ~options=statusOptions,
          ~buttonText="Select Transaction Status",
          ~showSelectionAsChips=false,
          ~searchable=true,
          ~showToolTip=true,
          ~showNameAsToolTip=true,
          ~customButtonStyle="bg-none",
          (),
        ),
      ),
      localFilter: Some((_, _) => []->Array.map(Nullable.make)),
    },
  ]
}

let getTransactionStatusLabelColor = (status: domainTransactionStatus): TableUtils.labelColor => {
  switch status {
  | Posted(Manual)
  | Matched(Force)
  | Matched(Manual)
  | Matched(Auto)
  | Matched(WithTolerance) =>
    LabelGreen
  | OverAmount(Mismatch)
  | UnderAmount(Mismatch)
  | DataMismatch
  | CurrencyMismatch
  | SplitMismatch =>
    LabelRed
  | Expected | UnderAmount(Expected) | OverAmount(Expected) => LabelBlue
  | Archived => LabelGray
  | PartiallyReconciled | Missing => LabelOrange
  | Void
  | UnknownDomainTransactionStatus
  | Matched(UnknownDomainTransactionMatchedStatus)
  | OverAmount(UnknownDomainTransactionAmountMismatchStatus)
  | UnderAmount(UnknownDomainTransactionAmountMismatchStatus)
  | Posted(UnknownDomainTransactionPostedStatus) =>
    LabelLightGray
  }
}

let getTransactionsTransformationHistoryPayloadFromDict = dict => {
  dict->transformationHistoryItemToObjMapper
}

let getTransactionsIngestionHistoryPayloadFromDict = dict => {
  dict->ingestionHistoryItemToObjMapper
}

let getTransactionsProcessingEntryPayloadFromDict = dict => {
  dict->processingItemToObjMapper
}

let getLineageSections = (
  ~ingestionHistoryData: ingestionHistoryType,
  ~transformationHistoryData: transformationHistoryType,
  ~processingEntry: processingEntryType,
  ~entry: entryType,
) => [
  {
    lineageSectionTitle: "Source",
    lineageSectionFields: [
      {
        lineageFieldLabel: "File Name",
        lineageFieldValue: ingestionHistoryData.file_name,
        lineageFileCopyable: false,
      },
      {
        lineageFieldLabel: "Ingestion Id",
        lineageFieldValue: ingestionHistoryData.ingestion_id,
        lineageFileCopyable: true,
      },
    ],
  },
  {
    lineageSectionTitle: "Transformation",
    lineageSectionFields: [
      {
        lineageFieldLabel: "Transformation Name",
        lineageFieldValue: transformationHistoryData.transformation_name,
        lineageFileCopyable: false,
      },
      {
        lineageFieldLabel: "Transformation ID",
        lineageFieldValue: transformationHistoryData.transformation_id,
        lineageFileCopyable: true,
      },
    ],
  },
  {
    lineageSectionTitle: "Transformed Entry",
    lineageSectionFields: [
      {
        lineageFieldLabel: "Transformed Entry Id",
        lineageFieldValue: processingEntry.staging_entry_id,
        lineageFileCopyable: true,
      },
    ],
  },
  {
    lineageSectionTitle: "Entry",
    lineageSectionFields: [
      {
        lineageFieldLabel: "Entry Id",
        lineageFieldValue: entry.entry_id,
        lineageFileCopyable: true,
      },
      {
        lineageFieldLabel: "Order Id",
        lineageFieldValue: entry.order_id,
        lineageFileCopyable: true,
      },
    ],
  },
]

let bulkActionPostingModalConfig = (~count: int) => {
  bulkActionModal: {
    modalHeading: "Post Transaction",
    modalDescription: `This will permanently post ${count->Int.toString} transaction${pluralText(
        ~count,
      )} to the ledger. Once posted, these actions cannot be reversed. Are you sure you want to continue?`,
    modalConfirmButtonText: "Post Transaction",
    modalConfirmButtonType: Primary,
    modalLoadingText: `Posting transaction${pluralText(~count)}...`,
  },
}

let bulkActionVoidingModalConfig = (~count: int) => {
  bulkActionModal: {
    modalHeading: "Ignore Transaction",
    modalDescription: `This will permanently ignore ${count->Int.toString} transaction${pluralText(
        ~count,
      )} and exclude them from the ledger. These actions cannot be undone. Are you sure you want to proceed?`,
    modalConfirmButtonText: "Ignore Transaction",
    modalConfirmButtonType: Delete,
    modalLoadingText: `Ignoring transaction${pluralText(~count)}...`,
  },
}

let getBulkActionModalConfig = (~action: actionType, ~count: int): bulkActionModalConfig => {
  switch action {
  | BulkTransactionPost => bulkActionPostingModalConfig(~count)
  | BulkTransactionVoid => bulkActionVoidingModalConfig(~count)
  | UnknownBulkTransactionActionType => {
      bulkActionModal: {
        modalHeading: "",
        modalDescription: "",
        modalConfirmButtonText: "",
        modalConfirmButtonType: Secondary,
        modalLoadingText: "",
      },
    }
  }
}

let bulkActionPostingSuccessModalConfig = (
  ~successCount: int,
  ~failedCount: int,
  ~skippedCount: int,
  ~totalCount: int,
): bulkActionModalConfig => {
  if successCount == totalCount {
    {
      bulkActionModal: {
        modalHeading: "Transactions Posted",
        modalDescription: "All transactions were posted successfully. This summary will be cleared after you close this window. Download the report to retain a record.",
        modalConfirmButtonText: "Download Posting Report",
        modalConfirmButtonType: Primary,
        modalLoadingText: "",
      },
      bulkActionIcon: {
        bulkActionIconName: "nd-check-circle-outline",
        bulkActionIconClass: "text-nd_green-500",
      },
    }
  } else if failedCount + skippedCount == totalCount {
    {
      bulkActionModal: {
        modalHeading: "Posting Failed",
        modalDescription: "Selected transactions could not be posted. This summary will be cleared after you close this window. Download the report to retain a record.",
        modalConfirmButtonText: "Download Posting Report",
        modalConfirmButtonType: Primary,
        modalLoadingText: "",
      },
      bulkActionIcon: {
        bulkActionIconName: "nd-multiple-cross",
        bulkActionIconClass: "text-nd_red-400",
      },
    }
  } else {
    {
      bulkActionModal: {
        modalHeading: "Posting Completed with Errors",
        modalDescription: `${successCount->Int.toString}/${totalCount->Int.toString} transaction${pluralText(
            ~count=successCount,
          )} were posted successfully. This summary will be cleared after you close this window. Download the report to retain a record.`,
        modalConfirmButtonText: "Download Posting Report",
        modalConfirmButtonType: Primary,
        modalLoadingText: "",
      },
      bulkActionIcon: {
        bulkActionIconName: "nd-alert-circle",
        bulkActionIconClass: "text-nd_orange-300",
      },
    }
  }
}

let bulkActionVoidingSuccessModalConfig = (
  ~successCount: int,
  ~failedCount: int,
  ~skippedCount: int,
  ~totalCount: int,
): bulkActionModalConfig => {
  if successCount == totalCount {
    {
      bulkActionModal: {
        modalHeading: `Transaction${pluralText(~count=successCount)} Ignored`,
        modalDescription: "All transactions were ignored successfully. This summary will be cleared after you close this window. Download the report to retain a record.",
        modalConfirmButtonText: "Download Ignoring Report",
        modalConfirmButtonType: Primary,
        modalLoadingText: "",
      },
      bulkActionIcon: {
        bulkActionIconName: "nd-check-circle-outline",
        bulkActionIconClass: "text-nd_green-500",
      },
    }
  } else if failedCount + skippedCount == totalCount {
    {
      bulkActionModal: {
        modalHeading: `Transaction${pluralText(
            ~count={failedCount + skippedCount},
          )} Ignored Failed`,
        modalDescription: "Selected transactions could not be ignored. This summary will be cleared after you close this window. Download the report to retain a record.",
        modalConfirmButtonText: "Download Ignoring Report",
        modalConfirmButtonType: Primary,
        modalLoadingText: "",
      },
      bulkActionIcon: {
        bulkActionIconName: "nd-multiple-cross",
        bulkActionIconClass: "text-nd_red-400",
      },
    }
  } else {
    {
      bulkActionModal: {
        modalHeading: `Transaction${pluralText(~count=successCount)} Ignored Completed with Errors`,
        modalDescription: `${successCount->Int.toString}/${totalCount->Int.toString} transaction${pluralText(
            ~count=successCount,
          )} were ignored successfully. This summary will be cleared after you close this window. Download the report to retain a record.`,
        modalConfirmButtonText: "Download Ignoring Report",
        modalConfirmButtonType: Primary,
        modalLoadingText: "",
      },
      bulkActionIcon: {
        bulkActionIconName: "nd-alert-circle",
        bulkActionIconClass: "text-nd_orange-300",
      },
    }
  }
}
let getBulkActionSuccessModalConfig = (
  action: actionType,
  successCount: int,
  failedCount: int,
  skippedCount: int,
  totalCount: int,
): bulkActionModalConfig => {
  switch action {
  | BulkTransactionPost =>
    bulkActionPostingSuccessModalConfig(~successCount, ~failedCount, ~skippedCount, ~totalCount)
  | BulkTransactionVoid =>
    bulkActionVoidingSuccessModalConfig(~successCount, ~failedCount, ~skippedCount, ~totalCount)
  | UnknownBulkTransactionActionType => {
      bulkActionModal: {
        modalHeading: "",
        modalDescription: "",
        modalConfirmButtonText: "",
        modalConfirmButtonType: Secondary,
        modalLoadingText: "",
      },
      bulkActionIcon: {bulkActionIconName: "", bulkActionIconClass: ""},
    }
  }
}

let downloadBulkActionReport = (
  bulkActionResponses: array<ReconEngineExceptionsTypes.bulkActionResponse>,
  ~action: actionType,
) => {
  let headers = ["ID", "Status", "Status Detail"]
  let data = bulkActionResponses->Array.map(item => {
    [
      item.logical_id->Option.getOr("N/A"),
      (item.bulk_action_status :> string)->String.toUpperCase,
      item.bulk_action_status_detail->Option.getOr(""),
    ]
  })

  let csvContent = PapaParse.unparse({"fields": headers, "data": data})
  let timestamp = Date.now()->Js.Float.toString

  DownloadUtils.download(
    ~fileName=`${(action :> string)}_transaction_report_${timestamp}.csv`,
    ~content=csvContent,
    ~fileType="text/csv",
  )
}
