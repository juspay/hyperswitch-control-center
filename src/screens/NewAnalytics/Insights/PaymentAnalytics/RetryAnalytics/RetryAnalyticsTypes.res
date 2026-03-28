type normalizedDeclineCols =
  | Standardised_Code
  | Error_Category
  | Decline_Count
  | Decline_Percentage

type normalizedDeclineObject = {
  standardised_code: string,
  error_category: string,
  count: int,
  percentage: float,
}
