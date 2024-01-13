type input = {mutable value: string}
type date = {toLocaleDateString: (. unit) => string}
type instance
type options = {
  formatter?: (input, date, instance) => unit,
  position?: [#tr | #tl | #br | #bl | #c],
}
@module("js-datepicker")
external datepicker: (. string, options) => unit = "default"
