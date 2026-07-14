type tab = {
  title: string,
  render: unit => React.element,
}

module FilterKeys = {
  let amountOption = "amount_option"
  let amount = "amount"
  let startAmount = "start_amount"
  let endAmount = "end_amount"
}

let isReservedKey = key => {
  [FilterKeys.amountOption, FilterKeys.amount]->Array.includes(key)
}

type entity =
  | Member
  | Merchant
  | Organization
  | Payment
  | PaymentAdvanced
  | Payout
  | Refund
  | Dispute

let entityToKey = (entity: entity) =>
  switch entity {
  | Payment => "PaymentViews"
  | PaymentAdvanced => "PaymentAdvancedViews"
  | Refund => "RefundViews"
  | Dispute => "DisputeViews"
  | Payout => "PayoutViews"
  | Merchant => "MerchantViews"
  | Organization => "OrganizationViews"
  | Member => "MemberViews"
  }

let entityToString = (entity: entity) =>
  switch entity {
  | Payment
  | PaymentAdvanced => "payment_views"
  | Refund => "refund_views"
  | Dispute => "dispute_views"
  | Payout => "payout_views"
  | Merchant => "merchant_views"
  | Organization => "organization_views"
  | Member => "member_views"
  }

type action =
  | Create
  | Update
  | Delete

let actionToString = action =>
  switch action {
  | Create => "Create"
  | Update => "Update"
  | Delete => "Delete"
  }

type savedView = {
  view_id: string,
  view_name: string,
  entity: string,
  version: UserInfoTypes.version,
  filters: JSON.t,
  created_at: string,
  updated_at: string,
}

type savedViewsResponse = {
  count: int,
  views: array<savedView>,
}

type filterKeyKind =
  | FlattenRoot
  | Prefixed(string)

let classifyFilterKey = (filterKey: string): filterKeyKind =>
  switch filterKey {
  | "amount_filter" | "" => FlattenRoot
  | filterKey => Prefixed(filterKey)
  }
