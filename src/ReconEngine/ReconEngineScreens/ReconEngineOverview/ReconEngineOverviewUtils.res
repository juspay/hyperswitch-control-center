open LogicUtils
open ReconEngineOverviewTypes

let defaultAccount = {
  account_name: "",
  account_id: "",
  currency: "",
  profile_id: "",
  initial_balance: {
    value: 0.0,
    currency: "",
  },
  pending_balance: {
    value: 0.0,
    currency: "",
  },
  posted_balance: {
    value: 0.0,
    currency: "",
  },
}

let defaultAccountDetails = {
  id: "",
  account_id: "",
}

let getAmountPayload = dict => {
  {
    value: dict->getFloat("value", 0.0),
    currency: dict->getString("currency", ""),
  }
}

let accountItemToObjMapper = dict => {
  {
    account_name: dict->getString("account_name", ""),
    account_id: dict->getString("account_id", ""),
    profile_id: dict->getString("profile_id", ""),
    currency: dict->getDictfromDict("initial_balance")->getString("currency", ""),
    initial_balance: dict
    ->getDictfromDict("initial_balance")
    ->getAmountPayload,
    pending_balance: dict
    ->getDictfromDict("pending_balance")
    ->getAmountPayload,
    posted_balance: dict
    ->getDictfromDict("posted_balance")
    ->getAmountPayload,
  }
}

let accountRefItemToObjMapper = dict => {
  {
    id: dict->getString("id", ""),
    account_id: dict->getString("account_id", ""),
  }
}

let reconRuleItemToObjMapper = dict => {
  {
    rule_id: dict->getString("rule_id", ""),
    rule_name: dict->getString("rule_name", ""),
    rule_description: dict->getString("rule_description", ""),
    sources: dict
    ->getArrayFromDict("sources", [])
    ->Array.map(item => item->getDictFromJsonObject->accountRefItemToObjMapper),
    targets: dict
    ->getArrayFromDict("targets", [])
    ->Array.map(item => item->getDictFromJsonObject->accountRefItemToObjMapper),
  }
}

let getAccountNameAndCurrency = (accountData: array<accountType>, accountId: string): (
  string,
  string,
) => {
  let account =
    accountData
    ->Array.find(account => account.account_id === accountId)
    ->Option.getOr(defaultAccount)
  (account.account_name, account.currency->LogicUtils.isEmptyString ? "N/A" : account.currency)
}

let formatAmountWithCurrency = (amount: float, currency: string) => {
  let roundedAmount = (amount *. 100.0)->Math.round /. 100.0
  `${roundedAmount->Float.toString} ${currency}`
}

let getTransactionTypeFromString = (
  status: string,
): ReconEngineTransactionsTypes.transactionStatus => {
  switch status {
  | "posted" => Posted
  | "mismatched" => Mismatched
  | "expected" => Expected
  | "archived" => Archived
  | _ => None
  }
}

let calculateAccountAmounts = (
  transactionsData: array<ReconEngineTransactionsTypes.transactionPayload>,
) => {
  let (
    sourcePosted,
    targetPosted,
    sourceMismatched,
    targetMismatched,
    sourceExpected,
    targetExpected,
  ) = transactionsData->Array.reduce((0.0, 0.0, 0.0, 0.0, 0.0, 0.0), (
    (sPosted, tPosted, sMismatched, tMismatched, sExpected, tExpected),
    transaction,
  ) => {
    // Use pre-calculated credit_amount and debit_amount instead of iterating through entries
    let creditAmount = transaction.credit_amount.value
    let debitAmount = transaction.debit_amount.value

    switch transaction.transaction_status->getTransactionTypeFromString {
    | Posted => (
        sPosted +. creditAmount,
        tPosted +. debitAmount,
        sMismatched,
        tMismatched,
        sExpected,
        tExpected,
      )
    | Mismatched => (
        sPosted,
        tPosted,
        sMismatched +. creditAmount,
        tMismatched +. debitAmount,
        sExpected,
        tExpected,
      )
    | Expected => (
        sPosted,
        tPosted,
        sMismatched,
        tMismatched,
        sExpected +. creditAmount,
        tExpected +. debitAmount,
      )
    | _ => (sPosted, tPosted, sMismatched, tMismatched, sExpected, tExpected)
    }
  })

  let totalSourceAmount = sourcePosted +. sourceMismatched +. sourceExpected
  let totalTargetAmount = targetPosted +. targetMismatched +. targetExpected
  let variance = Math.abs(totalSourceAmount -. totalTargetAmount)

  (totalSourceAmount, totalTargetAmount, variance)
}

// Stacked Bar Graph Data
let getStackedBarGraphData = (~postedCount: int, ~mismatchedCount: int, ~expectedCount: int) => {
  open StackedBarGraphTypes
  {
    categories: ["Transactions"],
    data: [
      {
        name: "Posted",
        data: [postedCount->Int.toFloat],
        color: "#7AB891",
      },
      {
        name: "Mismatched",
        data: [mismatchedCount->Int.toFloat],
        color: "#EA8A8F",
      },
      {
        name: "Expected",
        data: [expectedCount->Int.toFloat],
        color: "#8BC2F3",
      },
    ],
    labelFormatter: StackedBarGraphUtils.stackedBarGraphLabelFormatter(~statType=Default),
  }
}

// Line Graph Data
let getOverviewLineGraphTooltipFormatter = (
  @this
  (this: LineGraphTypes.pointFormatter) => {
    let title = `<div style="font-size: 16px; font-weight: bold;">Transaction Count</div>`

    let defaultValue: LineGraphTypes.point = {
      color: "",
      x: "",
      y: 0.0,
      point: {index: 0},
      series: {name: ""},
    }

    let primaryPoint = this.points->getValueFromArray(0, defaultValue)
    let secondaryPoint = this.points->getValueFromArray(1, defaultValue)

    let getRowHtml = (~iconColor, ~name, ~value) => {
      let valueString = value->Float.toString
      `<div style="display: flex; align-items: center;">
              <div style="width: 10px; height: 10px; background-color:${iconColor}; border-radius:3px;"></div>
              <div style="margin-left: 8px;">${name}</div>
              <div style="flex: 1; text-align: right; font-weight: bold;margin-left: 25px;">${valueString}</div>
          </div>`
    }

    let tableItems =
      [
        getRowHtml(
          ~iconColor=primaryPoint.color,
          ~name=primaryPoint.series.name,
          ~value=primaryPoint.y,
        ),
        getRowHtml(
          ~iconColor=secondaryPoint.color,
          ~name=secondaryPoint.series.name,
          ~value=secondaryPoint.y,
        ),
      ]->Array.joinWith("")

    let content = `
            <div style=" 
            padding:5px 12px;
            display:flex;
            flex-direction:column;
            justify-content: space-between;
            gap: 7px;">
                ${title}
                <div style="
                  margin-top: 5px;
                  display:flex;
                  flex-direction:column;
                  gap: 7px;">
                  ${tableItems}
                </div>
          </div>`

    `<div style="
      padding: 10px;
      width:fit-content;
      border-radius: 7px;
      background-color:#FFFFFF;
      padding:10px;
      box-shadow: 0px 4px 8px rgba(0, 0, 0, 0.2);
      border: 1px solid #E5E5E5;
      position:relative;">
          ${content}
      </div>`
  }
)->LineGraphTypes.asTooltipPointFormatter

let lineGraphYAxisFormatter = (
  @this
  (this: LineGraphTypes.yAxisFormatter) => {
    this.value->Int.toString
  }
)->LineGraphTypes.asTooltipPointFormatter

let calculateTransactionCounts = (
  transactionsData: array<ReconEngineTransactionsTypes.transactionPayload>,
) => {
  transactionsData->Array.reduce((0, 0, 0), ((posted, mismatched, expected), transaction) => {
    switch transaction.transaction_status->getTransactionTypeFromString {
    | Posted => (posted + 1, mismatched, expected)
    | Mismatched => (posted, mismatched + 1, expected)
    | Expected => (posted, mismatched, expected + 1)
    | _ => (posted, mismatched, expected)
    }
  })
}

let processLineGraphData = (
  transactionsData: array<ReconEngineTransactionsTypes.transactionPayload>,
) => {
  let getCountFromDate = (groupedByDate, date, status) => {
    groupedByDate
    ->getObj(date, Dict.make())
    ->getInt(status, 0)
    ->Int.toFloat
  }

  let getMonthAbbreviation = monthStr => {
    switch monthStr {
    | "01" => "Jan"
    | "02" => "Feb"
    | "03" => "Mar"
    | "04" => "Apr"
    | "05" => "May"
    | "06" => "Jun"
    | "07" => "Jul"
    | "08" => "Aug"
    | "09" => "Sep"
    | "10" => "Oct"
    | "11" => "Nov"
    | "12" => "Dec"
    | _ => "Jan"
    }
  }

  let groupedByDate = transactionsData->Array.reduce(Dict.make(), (acc, transaction) => {
    let dateStr = transaction.created_at->String.slice(~start=0, ~end=10) // Extract YYYY-MM-DD
    let currentDateData = acc->getObj(dateStr, Dict.make())

    switch transaction.transaction_status->getTransactionTypeFromString {
    | Posted => {
        let currentCount = currentDateData->getInt("posted", 0)
        currentDateData->Dict.set("posted", (currentCount + 1)->JSON.Encode.int)
      }
    | Expected => {
        let currentCount = currentDateData->getInt("expected", 0)
        currentDateData->Dict.set("expected", (currentCount + 1)->JSON.Encode.int)
      }
    | Mismatched => {
        let currentCount = currentDateData->getInt("mismatched", 0)
        currentDateData->Dict.set("mismatched", (currentCount + 1)->JSON.Encode.int)
      }
    | Archived => {
        let currentCount = currentDateData->getInt("archived", 0)
        currentDateData->Dict.set("archived", (currentCount + 1)->JSON.Encode.int)
      }
    | _ => ()
    }

    acc->Dict.set(dateStr, currentDateData->JSON.Encode.object)
    acc
  })

  let sortedDates = groupedByDate->Dict.keysToArray->Array.toSorted(String.compare)
  let categories = sortedDates->Array.map(date => {
    let parts = date->String.split("-")
    let month = parts->getValueFromArray(1, "01")->getMonthAbbreviation
    let day = parts->getValueFromArray(2, "01")
    `${month} ${day}`
  })

  let postedData = sortedDates->Array.map(date => getCountFromDate(groupedByDate, date, "posted"))
  let expectedData =
    sortedDates->Array.map(date => getCountFromDate(groupedByDate, date, "expected"))

  let lineGraphOptions: LineGraphTypes.lineGraphPayload = {
    chartHeight: LineGraphTypes.DefaultHeight,
    chartLeftSpacing: LineGraphTypes.DefaultLeftSpacing,
    categories,
    data: [
      {
        showInLegend: true,
        name: "Posted",
        data: postedData,
        color: "#7AB891",
      },
      {
        showInLegend: true,
        name: "Expected",
        data: expectedData,
        color: "#8BC2F3",
      },
    ],
    title: {
      text: "",
      align: "left",
    },
    tooltipFormatter: getOverviewLineGraphTooltipFormatter,
    yAxisMaxValue: None,
    yAxisMinValue: None,
    yAxisFormatter: LineGraphUtils.lineGraphYAxisFormatter(~statType=Default),
    legend: {
      useHTML: true,
      labelFormatter: LineGraphUtils.valueFormatter,
      align: "left",
      verticalAlign: "top",
      floating: false,
      margin: 30,
    },
  }

  lineGraphOptions
}
