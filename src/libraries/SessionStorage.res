@val @scope("sessionStorage")
external setItemInSession: (string, string) => unit = "setItem"

@val @scope("sessionStorage")
external getItemFromSession: string => Nullable.t<string> = "getItem"

@val @scope("sessionStorage")
external clearSession: unit => unit = "clear"
