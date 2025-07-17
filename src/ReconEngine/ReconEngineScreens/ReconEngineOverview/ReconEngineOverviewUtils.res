open LogicUtils
open ReconEngineOverviewTypes

let defaultAccount = {
  account_name: "Unknown Account",
  account_id: "",
  currency: "",
  profile_id: "",
  initial_balance: {
    value: 0.0,
    currency: "USD",
  },
  pending_balance: {
    value: 0.0,
    currency: "USD",
  },
  posted_balance: {
    value: 0.0,
    currency: "USD",
  },
}

let defaultAccountDetails = {
  id: "",
  account_id: "Unknown Account",
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

    switch transaction.transaction_status {
    | "posted" => (
        sPosted +. creditAmount,
        tPosted +. debitAmount,
        sMismatched,
        tMismatched,
        sExpected,
        tExpected,
      )
    | "mismatched" => (
        sPosted,
        tPosted,
        sMismatched +. creditAmount,
        tMismatched +. debitAmount,
        sExpected,
        tExpected,
      )
    | "expected" => (
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

let getLineGraphOptions = () => {
  // Static data for posted and expected counts per day
  let categories = ["Jan 01", "Jan 02", "Jan 03", "Jan 04", "Jan 05", "Jan 06", "Jan 07"]

  let postedData = [120.0, 150.0, 180.0, 200.0, 175.0, 220.0, 250.0]
  let expectedData = [100.0, 140.0, 160.0, 190.0, 170.0, 210.0, 240.0]

  let lineGraphOptions: LineGraphTypes.lineGraphPayload = {
    chartHeight: LineGraphTypes.DefaultHeight,
    chartLeftSpacing: LineGraphTypes.DefaultLeftSpacing,
    categories,
    data: [
      {
        showInLegend: true,
        name: "Expected",
        data: postedData,
        color: "#8BC2F3",
      },
      {
        showInLegend: true,
        name: "Posted",
        data: expectedData,
        color: "#00D492",
      },
    ],
    title: {
      text: "",
      align: "left",
    },
    tooltipFormatter: getOverviewLineGraphTooltipFormatter,
    yAxisMaxValue: None,
    yAxisMinValue: None,
    yAxisFormatter: lineGraphYAxisFormatter,
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
