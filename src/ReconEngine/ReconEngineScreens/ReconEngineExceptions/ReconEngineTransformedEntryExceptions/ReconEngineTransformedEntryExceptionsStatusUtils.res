open ReconEngineTypes
open ReconEngineTransformedEntryExceptionsTypes

/* Re-export the shared processing-entry status helpers from the Data status utils.
 We keep one source of truth for the colour/label mapping. */
let getEntryKind = ReconEngineDataStatusUtils.getEntryKind
let getEntryTagColor = ReconEngineDataStatusUtils.getEntryTagColor
let getEntryLabel = ReconEngineDataStatusUtils.getEntryLabel
let entryStatusToWire = ReconEngineDataStatusUtils.entryStatusToWire
let getNeedsReviewExplanation = ReconEngineDataStatusUtils.getNeedsReviewExplanation
let getNeedsReviewShort = ReconEngineDataStatusUtils.getNeedsReviewShort
let formatRelativeTime = ReconEngineDataStatusUtils.formatRelativeTime

/* Smart views for the Transformed Entry Exceptions listing. The Exceptions
   surface deliberately excludes terminal states (Processed/Archived/Void) —
   they have nothing for the merchant to do. */
type smartView =
  | NeedsReview
  | Pending
  | AllOpen

let allSmartViews: array<smartView> = [NeedsReview, Pending, AllOpen]

let smartViewLabel = (v: smartView): string =>
  switch v {
  | NeedsReview => "Needs Review"
  | Pending => "Pending"
  | AllOpen => "All Open"
  }

let smartViewStatuses = (v: smartView): array<processingEntryStatus> =>
  switch v {
  | NeedsReview => [NeedsManualReview]
  | Pending => [Pending]
  | AllOpen => [NeedsManualReview, Pending]
  }

let countByView = (entries: array<processingEntryType>): (int, int, int) => {
  entries->Array.reduce((0, 0, 0), ((needs, pend, all), e) => {
    let s = e.status
    let isNeeds = s === NeedsManualReview
    let isPend = s === Pending
    (needs + (isNeeds ? 1 : 0), pend + (isPend ? 1 : 0), all + (isNeeds || isPend ? 1 : 0))
  })
}

/* Recommended action by status — Edit is usually right for NeedsManualReview,
 while Pending entries are typically left alone or ignored. */
let getRecommendedResolution = (status: processingEntryStatus): resolvingException =>
  switch status {
  | NeedsManualReview => EditTransformedEntry
  | Pending => EditTransformedEntry
  | _ => NoTransformedEntryResolutionNeeded
  }

let resolutionLabel = (action: resolvingException): string =>
  switch action {
  | EditTransformedEntry => "Edit Entry"
  | VoidTransformedEntry => "Ignore Entry"
  | NoTransformedEntryResolutionNeeded => ""
  }

let resolutionIcon = (action: resolvingException): string =>
  switch action {
  | EditTransformedEntry => "nd-pencil-edit-line"
  | VoidTransformedEntry => "nd-delete-dustbin-02"
  | NoTransformedEntryResolutionNeeded => ""
  }

let resolutionHint = (action: resolvingException): string =>
  switch action {
  | EditTransformedEntry => "Correct the data so this entry can flow through reconciliation."
  | VoidTransformedEntry => "Remove this entry from reconciliation. Cannot be undone."
  | NoTransformedEntryResolutionNeeded => ""
  }
