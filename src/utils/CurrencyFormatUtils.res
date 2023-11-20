type currencyFormat =
  | IND
  | USD
  | DefaultConvert
/* Add more currencies here */

let getCountryCurrencyFromString = currency => {
  switch currency {
  | "IND" => IND
  | "USD" => USD
  | _ => DefaultConvert
  /* Add more currencies here */
  }
}
