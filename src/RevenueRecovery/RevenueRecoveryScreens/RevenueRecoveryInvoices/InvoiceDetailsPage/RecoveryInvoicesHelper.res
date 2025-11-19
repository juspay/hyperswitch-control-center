module SegmentedProgressBar = {
  open Typography
  @react.component
  let make = (~orderAmount: float, ~amountCaptured: float, ~className: string="") => {
    // Calculate percentage: (amount_captured / order_amount) * 100
    let percentage = if orderAmount <= 0.0 {
      0.0
    } else {
      let calculated = amountCaptured /. orderAmount *. 100.0

      // Clamp between 0 and 100
      if calculated < 0.0 {
        0.0
      } else if calculated > 100.0 {
        100.0
      } else {
        calculated
      }
    }

    let percentageInt = percentage->Float.toInt
    let percentageString = percentage->Float.toString

    <div className={`flex items-center w-fit ${className}`}>
      <div className="flex-1 flex items-center relative">
        <RenderIf condition={percentageInt > 0}>
          <div
            className="bg-nd_primary_blue-500 h-3 rounded-sm absolute left-0 top-0"
            style={width: `${percentageString}%`}
          />
        </RenderIf>
        <div className="flex-1 flex gap-1">
          {Array.make(~length=20, 0)
          ->Array.map(i => {
            <div key={i->Int.toString} className="w-1 h-3 bg-gray-300 rounded-sm" />
          })
          ->React.array}
        </div>
      </div>
      <span className={`ml-3 text-gray-600 ${body.md.semibold}`}>
        {`${percentageInt->Int.toString}%`->React.string}
      </span>
    </div>
  }
}

open RevenueRecoveryOrderTypes
open RevenueRecoveryOrderUtils
open LogicUtils
open Typography

let formatCurrency = (amount: float) => {
  let dollars = amount /. 100.0
  `$${dollars->Float.toFixedWithPrecision(~digits=2)}`
}

let parseAttemptStatus = (attempt: attempts) =>
  attempt.attempt_triggered_by->String.toUpperCase->attemptTriggeredByVariantMapper

let isInternalAttempt = (attempt: attempts) => {
  attempt->parseAttemptStatus == INTERNAL
}

let isExternalAttempt = (attempt: attempts) => {
  attempt->parseAttemptStatus != INTERNAL
}

let getStatusBadgeColor = (status: string) => {
  switch status->HSwitchOrderUtils.paymentAttemptStatusVariantMapper {
  | #CHARGED => (
      "bg-green-100 text-nd_green-600  border border-nd_green-200",
      "Recovered successfully",
    )
  | #FAILURE => ("bg-red-100 text-nd_red-500 border border-nd_red-200 ", "Failed")
  | _ => ("bg-orange-100 text-orange-700", "Pending")
  }
}

let getTimelineDotColor = (status: string) => {
  switch status->HSwitchOrderUtils.paymentAttemptStatusVariantMapper {
  | #CHARGED => "bg-nd_green-500"
  | #FAILURE => "bg-nd_red-500"
  | _ => "bg-orange-500"
  }
}

module AttemptItem = {
  @react.component
  let make = (~attempt: attempts, ~index: int, ~totalAttempts: int, ~isLast: bool) => {
    let (badgeClass, badgeText) = getStatusBadgeColor(attempt.status)
    let dotColor = getTimelineDotColor(attempt.status)
    let attemptNumber = totalAttempts - index

    <div className="pt-7">
      <div className="flex items-center justify-between relative">
        <RenderIf condition={!isLast}>
          <div
            className="border-l-2 border-gray-300 border-dashed absolute left-4 top-8 h-full w-1"
          />
        </RenderIf>
        <div className="flex items-start gap-3">
          <div className="w-9 h-9 relative flex justify-center items-center">
            <div className={`w-2 h-2 rounded-full ${dotColor} z-10`} />
          </div>
          <div className="pt-2">
            <div className={`${body.sm.regular} flex gap-2 text-gray-500 mb-2`}>
              {`#${attemptNumber->Int.toString}`->React.string}
              {<Table.DateCell
                textStyle={`${body.sm.regular} text-gray-500`}
                timestamp={attempt.created}
                isCard=true
              />}
            </div>
            <div className="flex items-center gap-2 flex-wrap">
              <span className={`px-1.5 py-0.5 rounded-md ${body.sm.semibold} ${badgeClass}`}>
                {badgeText->React.string}
              </span>
              {if attempt.status->HSwitchOrderUtils.paymentAttemptStatusVariantMapper == #FAILURE {
                <>
                  <div className={`${body.sm.semibold} text-gray-500`}>
                    {"due to"->React.string}
                  </div>
                  <span className="px-2 py-0.5 rounded-md border text-xs bg-gray-100 text-gray-700">
                    {attempt.error->React.string}
                  </span>
                  <div className={`${body.sm.semibold} text-gray-500`}>
                    {`unable to recover ${attempt.net_amount->formatCurrency} `->React.string}
                  </div>
                </>
              } else {
                <div className={`${body.sm.semibold} text-gray-500`}>
                  {"in this attempt"->React.string}
                </div>
              }}
            </div>
          </div>
        </div>
      </div>
    </div>
  }
}

module AttemptsHistory = {
  @react.component
  let make = (~order, ~attemptsList, ~processTracker: option<Dict.t<JSON.t>>) => {
    let attempts = attemptsList
    let internalAttempts = attempts->Array.filter(isInternalAttempt)
    let merchantAttempts = attempts->Array.filter(isExternalAttempt)

    let scheduledTime = switch processTracker {
    | Some(dict) =>
      let scheduleTime = dict->getString("schedule_time_for_payment", "")
      scheduleTime->isNonEmptyString ? Some(scheduleTime) : None
    | None => None
    }

    let status = order.status->statusVariantMapper

    <div className="bg-white p-1">
      <div className={`${heading.md.semibold} text-gray-900 mb-6`}>
        {"Attempts History"->React.string}
      </div>
      <div className="pt-4">
        <div className="flex items-center justify-between cursor-pointer relative">
          <div
            className="border-l-2 border-gray-300 border-dashed absolute left-4 top-8 h-full w-1"
          />
          <div className="flex items-center gap-3">
            <div className="bg-gray-100 p-2 rounded-full border">
              <Icon name="juspay-logo" size=20 className="text-gray-600" />
            </div>
            <div className={`${body.md.semibold} text-gray-500 uppercase`}>
              {"REVENUE RECOVERY IS ATTEMPTING RETRIES"->React.string}
            </div>
          </div>
          <div className="flex-1 border-t-1.5 mx-4" />
        </div>
      </div>
      <RenderIf
        condition={order.status->RevenueRecoveryOrderUtils.statusVariantMapper != Recovered}>
        <div className="pt-4">
          <div className="flex items-center justify-between relative">
            <div
              className="border-l-2 border-gray-300 border-dashed absolute left-4 top-8 h-full w-1"
            />
            <div className="flex items-center gap-3">
              <div className="w-9 h-9  relative flex justify-center items-center">
                <div className={"w-2 h-2 bg-orange-500 rounded-full"} />
              </div>
              <div className={`${body.sm.semibold} text-gray-700`}>
                {`Attempting retries to recover ${(order.order_amount -. order.amount_captured)
                    ->formatCurrency}`->React.string}
              </div>
            </div>
          </div>
        </div>
      </RenderIf>
      {switch status {
      | Scheduled | Processing =>
        switch scheduledTime {
        | Some(time) => {
            let convertedTime = time->RevenueRecoveryOrderUtils.convertScheduleTimeToUTC
            <div className="flex items-center justify-between relative pt-4">
              <div
                className="border-l-2 border-gray-300 border-dashed absolute left-4 top-8 h-full w-1"
              />
              <div className="flex items-start gap-3">
                <div className="w-9 h-9 relative flex justify-center items-center bg-white">
                  <Icon name="nd_recovery-calandar" size=18 className="text-gray-600" />
                </div>
                <div className="pt-2">
                  <div className={`${body.sm.regular} flex gap-2 text-gray-500 mb-2`}>
                    {`#${(internalAttempts->Array.length + 1)->Int.toString} • `->React.string}
                    {<Table.DateCell
                      textStyle={`${body.sm.regular} text-gray-500 `}
                      timestamp=convertedTime
                      isCard=true
                    />}
                  </div>
                  <div className="flex items-center gap-2 flex-wrap">
                    <span
                      className={`px-1.5 py-0.5 rounded-md ${body.sm.semibold} bg-purple-100 text-purple-700 border border-purple-500`}>
                      {"Scheduled"->React.string}
                    </span>
                    <div className={`${body.sm.semibold} text-gray-500 flex gap-1`}>
                      {`Retry to recover ${order.order_amount->formatCurrency} on `->React.string}
                      {<Table.DateCell
                        textStyle={`${body.sm.semibold} text-gray-500`}
                        timestamp=convertedTime
                        isCard=true
                      />}
                    </div>
                  </div>
                </div>
              </div>
            </div>
          }
        | _ => React.null
        }
      | _ => React.null
      }}
      <RenderIf condition={internalAttempts->Array.length > 0}>
        {internalAttempts
        ->Array.mapWithIndex((attempt, index) => {
          <AttemptItem
            key={attempt.id}
            attempt
            index
            totalAttempts={internalAttempts->Array.length}
            isLast={false}
          />
        })
        ->React.array}
      </RenderIf>
      <div className="pt-4">
        <div className="flex items-center justify-between relative">
          <div
            className="border-l-2 border-gray-300 border-dashed absolute left-4 top-8 h-full w-1"
          />
          <div className="flex items-center gap-3">
            <div className="w-9 h-9  relative flex justify-center items-center">
              <div className={"w-2 h-2 border-2 border-gray-700 rounded-full"} />
            </div>
            <div className={`${body.sm.semibold} text-gray-500 uppercase`}>
              {"Revenue Recovery Retry Attempts Started"->React.string}
            </div>
          </div>
        </div>
      </div>
      <RenderIf condition={merchantAttempts->Array.length > 0}>
        <div className="pt-4">
          <div className="flex items-center justify-between cursor-pointer relative">
            <div
              className="border-l-2 border-gray-300 border-dashed absolute left-4 top-8 h-full w-1"
            />
            <div className="flex items-center gap-3 z-10">
              <div className="bg-gray-100 p-2 rounded-full border">
                <Icon name="nd-merchant-retires" size=20 className="text-gray-600" />
              </div>
              <div className={`${body.md.semibold} text-gray-500 uppercase`}>
                {"MERCHANT RETRIES COMPLETED"->React.string}
              </div>
              <span
                className={`px-2 py-0.5 rounded-md border ${body.sm.semibold} bg-gray-100 text-gray-700`}>
                {`${merchantAttempts->Array.length->Int.toString} Retries`->React.string}
              </span>
            </div>
            <div className="flex-1 border-t-1.5 mx-4" />
          </div>
        </div>
        <RenderIf condition={merchantAttempts->Array.length > 0}>
          {merchantAttempts
          ->Array.mapWithIndex((attempt, index) => {
            <AttemptItem
              key={attempt.id}
              attempt
              index
              totalAttempts={merchantAttempts->Array.length}
              isLast={index === merchantAttempts->Array.length - 1}
            />
          })
          ->React.array}
        </RenderIf>
      </RenderIf>
    </div>
  }
}
