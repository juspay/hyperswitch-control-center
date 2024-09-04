module TransactionViewCard = {
  @react.component
  let make = (~view, ~count="", ~onViewClick, ~isActiveView) => {
    open TransactionViewUtils

    let textClass = isActiveView ? "text-blue-500" : "font-semibold text-jp-gray-700"
    let countTextClass = isActiveView ? "text-blue-500" : "font-semibold text-jp-gray-900"
    let borderClass = isActiveView ? "border-blue-500" : ""

    <div
      className={`flex flex-col justify-center flex-auto gap-1 bg-white text-semibold border rounded-md px-4 py-2.5 w-14 my-8 cursor-pointer hover:bg-gray-50 ${borderClass}`}
      onClick={_ => onViewClick(view)}>
      <p className={textClass}> {view->getViewsDisplayName->React.string} </p>
      <RenderIf condition={!(count->LogicUtils.isEmptyString)}>
        <p className={countTextClass}> {count->React.string} </p>
      </RenderIf>
    </div>
  }
}

module PaymentTransactionView = {
  @react.component
  let make = () => {
    open APIUtils
    open LogicUtils
    open TransactionViewUtils
    let getURL = useGetURL()
    let fetchDetails = useGetMethod()
    let showToast = ToastState.useShowToast()
    let {updateExistingKeys, filterValueJson, filterKeys, setfilterKeys} =
      FilterContext.filterContext->React.useContext
    let (paymentCountRes, setPaymentCountRes) = React.useState(_ => Dict.make()->JSON.Encode.object)
    let (activeView: TransactionViewTypes.viewTypes, setActiveView) = React.useState(_ =>
      TransactionViewTypes.All
    )

    let updateViewsFilterValue = (view: TransactionViewTypes.viewTypes) => {
      let customFilterKey = "status"
      let customFilter = `[${view->getViewsString(paymentCountRes)}]`

      updateExistingKeys(Dict.fromArray([(customFilterKey, customFilter)]))

      switch view {
      | All => {
          let updateFilterKeys = filterKeys->Array.filter(item => item != "status")
          setfilterKeys(_ => updateFilterKeys)
        }
      | _ => {
          if !(filterKeys->Array.includes("status")) {
            filterKeys->Array.push("status")
          }
          setfilterKeys(_ => filterKeys)
        }
      }
    }

    let onViewClick = (view: TransactionViewTypes.viewTypes) => {
      setActiveView(_ => view)
      updateViewsFilterValue(view)
    }

    let defaultDate = HSwitchRemoteFilter.getDateFilteredObject(~range=30)
    let startTime =
      filterValueJson->getString(OrderUIUtils.startTimeFilterKey, defaultDate.start_time)
    let endTime = filterValueJson->getString(OrderUIUtils.endTimeFilterKey, defaultDate.end_time)

    let getAggregate = async () => {
      try {
        let url = getURL(
          ~entityName=ORDERS_AGGREGATE,
          ~methodType=Get,
          ~queryParamerters=Some(`start_time=${startTime}&end_time=${endTime}`),
        )
        let response = await fetchDetails(url)
        setPaymentCountRes(_ => response)
      } catch {
      | _ =>
        showToast(~toastType=ToastError, ~message="Failed to fetch views count", ~autoClose=true)
      }
    }

    let setActiveViewOnLoad = () => {
      let appliedStatusFilter =
        filterValueJson->JSON.Encode.object->getDictFromJsonObject->getArrayFromDict("status", [])

      if appliedStatusFilter->Array.length == 1 {
        let statusValue =
          appliedStatusFilter->getValueFromArray(0, ""->JSON.Encode.string)->JSON.Decode.string

        let status = statusValue->Option.getOr("")
        setActiveView(_ => status->getViewTypeFromString)
      } else {
        setActiveView(_ => All)
      }
    }

    React.useEffect(() => {
      setActiveViewOnLoad()
      None
    }, [])

    React.useEffect(() => {
      getAggregate()->ignore
      None
    }, (startTime, endTime))

    let paymentViewsUI =
      paymentViewsArray
      ->Array.mapWithIndex((item, i) =>
        <TransactionViewCard
          key={i->Int.toString}
          view={item}
          count={paymentCount(item, paymentCountRes)->Int.toString}
          onViewClick
          isActiveView={item == activeView}
        />
      )
      ->React.array

    paymentViewsUI
  }
}
