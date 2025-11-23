module SegmentedProgressBar = {
  open Typography
  open InvoiceDetailsPageUtils
  @react.component
  let make = (~orderAmount: float, ~amountCaptured: float, ~className: string="") => {
    let percentage = getAmountPercentage(~orderAmount, ~amountCaptured)

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
            <div key={i->Int.toString} className="w-1 h-3 bg-nd_gray-300 rounded-sm" />
          })
          ->React.array}
        </div>
      </div>
      <span className={`ml-3 text-nd_gray-600 ${body.md.semibold}`}>
        {`${percentageInt->Int.toString}%`->React.string}
      </span>
    </div>
  }
}

module AttemptItem = {
  open RevenueRecoveryOrderTypes
  open Typography
  open InvoiceDetailsPageUtils
  @react.component
  let make = (~attempt: attempts, ~index: int, ~totalAttempts: int, ~isLast: bool) => {
    let (badgeClass, badgeText) = getStatusBadgeColor(attempt.status)
    let dotColor = getTimelineDotColor(attempt.status)
    let attemptNumber = totalAttempts - index

    <div className="pt-7">
      <div className="flex items-center justify-between relative">
        <RenderIf condition={!isLast}>
          <div
            className="border-l-2 border-nd_gray-200 border-dashed absolute left-4 top-8 h-full w-1"
          />
        </RenderIf>
        <div className="flex items-start gap-3">
          <div className="w-9 h-9 relative flex justify-center items-center">
            <div className={`w-2 h-2 rounded-full ${dotColor} z-10`} />
          </div>
          <div className="pt-2">
            <div className={`${body.sm.regular} flex gap-2 text-nd_gray-500 mb-2`}>
              {`#${attemptNumber->Int.toString}`->React.string}
              {<Table.DateCell
                textStyle={`${body.sm.regular} text-nd_gray-500`}
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
                  <div className={`${body.sm.semibold} text-nd_gray-500`}>
                    {"due to"->React.string}
                  </div>
                  <span
                    className="px-2 py-0.5 rounded-md border text-xs bg-nd_gray-100 text-nd_gray-700">
                    {attempt.error->React.string}
                  </span>
                  <div className={`${body.sm.semibold} text-nd_gray-500`}>
                    {`unable to recover ${attempt.net_amount->formatCurrency} `->React.string}
                  </div>
                </>
              } else {
                <div className={`${body.sm.semibold} text-nd_gray-500`}>
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
  open RevenueRecoveryOrderTypes
  open InvoiceDetailsPageUtils
  open RevenueRecoveryOrderUtils
  open Typography
  open LogicUtils
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
      <div className={`${heading.md.semibold} text-nd_gray-900 mb-6`}>
        {"Attempts History"->React.string}
      </div>
      <div className="pt-4">
        <div className="flex items-center justify-between cursor-pointer relative">
          <div
            className="border-l-2 border-nd_gray-300 border-dashed absolute left-4 top-8 h-full w-1"
          />
          <div className="flex items-center gap-3 z-10">
            <div className="bg-nd_gray-100 p-2 rounded-full border">
              <Icon name="juspay-logo" size=20 className="text-gray-600" />
            </div>
            <div className={`${body.md.semibold} text-nd_gray-600 uppercase`}>
              {"REVENUE RECOVERY IS ATTEMPTING RETRIES"->React.string}
            </div>
          </div>
          <div className="flex-1 border-t-1.5 mx-4" />
        </div>
      </div>
      <RenderIf condition={status != Recovered}>
        <div className="pt-7">
          <div className="flex items-center justify-between relative">
            <div
              className="border-l-2 border-nd_gray-300 border-dashed absolute left-4 top-8 h-full w-1"
            />
            <div className="flex items-center gap-3">
              <div className="w-9 h-9  relative flex justify-center items-center bg-white">
                <div className={"w-2 h-2 bg-nd_orange-300 rounded-full"} />
              </div>
              <div className={`${body.sm.semibold} text-nd_gray-600`}>
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
            <div className="flex items-center justify-between relative pt-7">
              <div
                className="border-l-2 border-nd_gray-200 border-dashed absolute left-4 top-8 h-full w-1"
              />
              <div className="flex items-start gap-3">
                <div className="w-9 h-9 relative flex justify-center items-center bg-white">
                  <Icon name="nd_recovery-calandar" size=18 className="text-nd_gray-600" />
                </div>
                <div className="pt-2">
                  <div className={`${body.sm.regular} flex gap-2 text-nd_gray-500 mb-2`}>
                    {`#${(internalAttempts->Array.length + 1)->Int.toString} • `->React.string}
                    {<Table.DateCell
                      textStyle={`${body.sm.regular} text-nd_gray-500 `}
                      timestamp=convertedTime
                      isCard=true
                    />}
                  </div>
                  <div className="flex items-center gap-2 flex-wrap">
                    <span
                      className={`px-1.5 py-0.5 rounded-md ${body.sm.semibold} bg-nd_purple-100 text-nd_purple-300 border border-nd_purple-200`}>
                      {"Scheduled"->React.string}
                    </span>
                    <div className={`${body.sm.semibold} text-nd_gray-500 flex gap-1`}>
                      {`Retry to recover ${order.order_amount->formatCurrency} on `->React.string}
                      {<Table.DateCell
                        textStyle={`${body.sm.semibold} text-nd_gray-500`}
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
      <div className="pt-7">
        <div className="flex items-center justify-between relative">
          <div
            className="border-l-2 border-nd_gray-200 border-dashed absolute left-4 top-8 h-full w-1"
          />
          <div className="flex items-center gap-3">
            <div className="w-9 h-9  relative flex justify-center items-center">
              <div className={"w-2 h-2 border-2 border-nd_gray-600 rounded-full"} />
            </div>
            <div className={`${body.sm.semibold} text-nd_gray-500 uppercase`}>
              {"Revenue Recovery Retry Attempts Started"->React.string}
            </div>
          </div>
        </div>
      </div>
      <RenderIf condition={merchantAttempts->Array.length > 0}>
        <div className="pt-7">
          <div className="flex items-center justify-between cursor-pointer relative">
            <div
              className="border-l-2 border-nd_gray-200 border-dashed absolute left-4 top-8 h-full w-1"
            />
            <div className="flex items-center gap-3 z-10">
              <div className="bg-nd_gray-100 p-2 rounded-full border">
                <Icon name="nd-merchant-retires" size=20 className="text-nd_gray-600" />
              </div>
              <div className={`${body.md.semibold} text-nd_gray-600 uppercase`}>
                {"MERCHANT RETRIES COMPLETED"->React.string}
              </div>
              <span
                className={`px-2 py-0.5 rounded-md border ${body.sm.semibold} bg-nd_gray-100 text-nd_gray-700`}>
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
