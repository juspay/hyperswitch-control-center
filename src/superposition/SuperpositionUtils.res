open SuperpositionTypes

let getDimensionsForFixedContext = entity =>
  switch entity {
  | Org => "organization_id"
  | Merchant => "processor_merchant_id"
  | Profile => "profile_id"
  }
