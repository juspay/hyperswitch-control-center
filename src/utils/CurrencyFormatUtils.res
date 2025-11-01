open LogicUtils

type currencyFormat =
  | IND
  | USD
  | DefaultConvert

let removeTrailingZero = (numeric_str: string) => {
  numeric_str->Float.fromString->Option.getOr(0.)->Float.toString
}

let shortNum = (~labelValue: float, ~numberFormat: currencyFormat, ~presision: int=2) => {
  let value = Math.abs(labelValue)

  switch numberFormat {
  | IND =>
    switch value {
    | v if v >= 1.0e+7 =>
      `${Float.toFixedWithPrecision(v /. 1.0e+7, ~digits=presision)->removeTrailingZero}Cr`
    | v if v >= 1.0e+5 =>
      `${Float.toFixedWithPrecision(v /. 1.0e+5, ~digits=presision)->removeTrailingZero}L`
    | v if v >= 1.0e+3 =>
      `${Float.toFixedWithPrecision(v /. 1.0e+3, ~digits=presision)->removeTrailingZero}K`
    | _ => Float.toFixedWithPrecision(labelValue, ~digits=presision)->removeTrailingZero
    }
  | USD | DefaultConvert =>
    switch value {
    | v if v >= 1.0e+9 =>
      `${Float.toFixedWithPrecision(v /. 1.0e+9, ~digits=presision)->removeTrailingZero}B`
    | v if v >= 1.0e+6 =>
      `${Float.toFixedWithPrecision(v /. 1.0e+6, ~digits=presision)->removeTrailingZero}M`
    | v if v >= 1.0e+3 =>
      `${Float.toFixedWithPrecision(v /. 1.0e+3, ~digits=presision)->removeTrailingZero}K`
    | _ => Float.toFixedWithPrecision(labelValue, ~digits=presision)->removeTrailingZero
    }
  }
}

let latencyShortNum = (~labelValue: float, ~includeMilliseconds=?) => {
  if labelValue !== 0.0 {
    let value = Int.fromFloat(labelValue)
    let value_days = value / 86400
    let years = value_days / 365
    let months = mod(value_days, 365) / 30
    let days = mod(mod(value_days, 365), 30)
    let hours = value / 3600
    let minutes = mod(value, 3600) / 60
    let seconds = mod(mod(value, 3600), 60)

    let year_disp = if years >= 1 {
      `${String.make(years)}Y `
    } else {
      ""
    }
    let month_disp = if months > 0 {
      `${String.make(months)}M `
    } else {
      ""
    }
    let day_disp = if days > 0 {
      `${String.make(days)}D `
    } else {
      ""
    }
    let hr_disp = if hours > 0 {
      `${String.make(hours)}H `
    } else {
      ""
    }
    let min_disp = if minutes > 0 {
      `${String.make(minutes)}M `
    } else {
      ""
    }
    let millisec_disp = if (
      (labelValue < 1.0 || (includeMilliseconds->Option.getOr(false) && labelValue < 60.0)) &&
        labelValue > 0.0
    ) {
      `.${String.make(mod((labelValue *. 1000.0)->Int.fromFloat, 1000))}`
    } else {
      ""
    }
    let sec_disp = if seconds > 0 || millisec_disp->isNonEmptyString {
      `${String.make(seconds)}${millisec_disp}S `
    } else {
      ""
    }

    if days > 0 {
      year_disp ++ month_disp ++ day_disp
    } else {
      year_disp ++ month_disp ++ day_disp ++ hr_disp ++ min_disp ++ sec_disp
    }
  } else {
    "0"
  }
}

let getDefaultNumberFormat = _ => {
  USD
}

let indianShortNum = labelValue => {
  shortNum(~labelValue, ~numberFormat=getDefaultNumberFormat())
}

let getTypeValue = value => {
  switch value {
  | "all_currencies" => #all_currencies
  | _ => #none
  }
}

let formatCurrency = currency => {
  switch currency->getTypeValue {
  | #all_currencies => "USD*"
  | _ => currency->String.toUpperCase
  }
}

let valueFormatter = (value, statType: LogicUtilsTypes.valueType, ~currency="", ~suffix="") => {
  let amountSuffix = currency->formatCurrency

  let percentFormat = value => {
    `${Float.toFixedWithPrecision(value, ~digits=2)}%`
  }

  switch statType {
  | Amount => `${value->indianShortNum} ${amountSuffix}`
  | AmountWithSuffix => `${currency} ${value->Float.toFixedWithPrecision(~digits=2)} ${suffix}`
  | Rate => value->Js.Float.isNaN ? "-" : value->percentFormat
  | Volume => value->indianShortNum
  | Latency => latencyShortNum(~labelValue=value)
  | LatencyMs => latencyShortNum(~labelValue=value, ~includeMilliseconds=true)
  | FormattedAmount => formatAmount(value->Float.toInt, currency)
  | Default => value->Float.toString
  }
}
