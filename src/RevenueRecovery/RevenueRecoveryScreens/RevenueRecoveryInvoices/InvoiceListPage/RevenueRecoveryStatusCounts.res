@react.component
let make = () => {
  open APIUtils
  open LogicUtils
  open Typography
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let showToast = ToastAdapter.useShowToast()
  let {transactionEntity} = React.useContext(UserInfoProvider.defaultContext).getResolvedUserInfo()
  let {updateExistingKeys, removeKeys, filterValueJson, filterValue, filterKeys, setfilterKeys} =
    FilterContext.filterContext->React.useContext
  let (statusWithCount, setStatusWithCount) = React.useState(_ => Dict.make())
  let (total, setTotal) = React.useState(_ => 0)
  let statusKey = RevenueRecoveryOrderUtils.recoveryStatusFilterKey

  // The date filter only stores its keys once the user picks a range, so fall back to the same
  // default range the list filters use
  let (startTime, endTime) = React.useMemo(() => {
    let defaultDate = HSwitchRemoteFilter.getDateFilteredObject(~range=30)
    (
      filterValueJson->getString(OrderUIUtils.startTimeFilterKey(V2), defaultDate.start_time),
      filterValueJson->getString(OrderUIUtils.endTimeFilterKey(V2), defaultDate.end_time),
    )
  }, filterValue)

  let loadCounts = async () => {
    try {
      let url = getURL(
        ~entityName=V2(V2_RECOVERY_AGGREGATE),
        ~methodType=Get,
        ~queryParameters=Some(`start_time=${startTime}&end_time=${endTime}`),
      )
      let response = await fetchDetails(url, ~version=V2)
      let responseDict = response->getDictFromJsonObject
      setStatusWithCount(_ => responseDict->getDictfromDict("status_with_count"))
      setTotal(_ => responseDict->getInt("total_count", 0))
    } catch {
    | _ =>
      showToast(~toastType=ToastError, ~message="Failed to fetch status counts", ~autoClose=true)
    }
  }

  React.useEffect(() => {
    if startTime->isNonEmptyString && endTime->isNonEmptyString {
      loadCounts()->ignore
    }
    None
  }, (startTime, endTime, transactionEntity))

  let appliedStatuses = filterValueJson->getStrArrayFromDict(statusKey, [])

  let onClick = status => {
    switch status {
    | Some(value) =>
      updateExistingKeys(Dict.fromArray([(statusKey, `[${value}]`)]))
      setfilterKeys(_ =>
        filterKeys->Array.includes(statusKey) ? filterKeys : [...filterKeys, statusKey]
      )
    | None => removeKeys([statusKey])
    }
  }

  let card = (~label, ~count, ~isActive, ~status) =>
    <div
      key=label
      className={`flex min-w-0 flex-col justify-center flex-auto gap-1 bg-white border rounded-md px-4 py-2.5 cursor-pointer hover:bg-nd_gray-50 ${isActive
          ? "border-primary"
          : ""}`}
      onClick={_ => onClick(status)}>
      <p
        className={`${body.md.semibold} truncate ${isActive
            ? "text-primary"
            : "text-nd_gray-700"}`}>
        {label->React.string}
      </p>
      <p className={`${body.md.semibold} ${isActive ? "text-primary" : "text-nd_gray-900"}`}>
        {count->Int.toString->React.string}
      </p>
    </div>

  <div className="flex flex-wrap gap-3 mb-6">
    {card(~label="All", ~count=total, ~isActive=appliedStatuses->isEmptyArray, ~status=None)}
    {RevenueRecoveryOrderUtils.recoveryMetricStatuses
    ->Array.map(status =>
      card(
        ~label=status->snakeToTitle,
        ~count=statusWithCount->getInt(status, 0),
        ~isActive=appliedStatuses == [status],
        ~status=Some(status),
      )
    )
    ->React.array}
  </div>
}
