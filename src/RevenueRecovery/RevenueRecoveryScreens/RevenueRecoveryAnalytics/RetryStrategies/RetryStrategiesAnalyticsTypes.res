type declineTypes = [
  | #soft_declines
  | #hard_declines
]

type recoveredType = {
  declineType: declineTypes,
  value: float,
}
