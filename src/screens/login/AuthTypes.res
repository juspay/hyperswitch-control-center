type authorization = NoAccess | Read | ReadWrite | Checker
open LogicUtils

let getAccessTypeFromString = str => {
  switch str {
  | "R" => Read
  | "Read" => Read
  | "RW" => ReadWrite
  | "ReadWrite" => ReadWrite
  | "Write" => ReadWrite
  | "CHECKER" => Checker
  | _ => NoAccess
  }
}

let getAccessTypeFromBool = boolean => {
  switch boolean {
  | true => ReadWrite
  | false => NoAccess
  }
}

let getArrayData = (dict, key) => {
  switch Js.Dict.get(dict, key) {
  | Some(value) =>
    switch value->Js.Json.decodeArray {
    | Some(arr) =>
      let loginRoleArray = arr->Js.Array2.reduce((acc, item) => {
        switch item->Js.Json.decodeString {
        | Some(str) =>
          let _ = Js.Array2.push(acc, str)
        | None => ()
        }
        acc
      }, [])
      loginRoleArray
    | None => []
    }
  | None => []
  }
}

let getAccessType = (accessType: Js.Nullable.t<string>) => {
  switch accessType->Js.Nullable.toOption {
  | Some(str) => getAccessTypeFromString(str)
  | None => NoAccess
  }
}

let getConvertedAuthInfoType = (dict, key) => {
  let access = getString(dict, key, "NA")
  getAccessType(access->Js.Nullable.return)
}

let bestOf = (authorizations: array<authorization>) => {
  authorizations->Js.Array2.includes(ReadWrite)
    ? ReadWrite
    : authorizations->Js.Array2.includes(Checker)
    ? Checker
    : authorizations->Js.Array2.includes(Read)
    ? Read
    : NoAccess
}

let worstOf = (authorizations: array<authorization>) => {
  authorizations->Js.Array2.includes(NoAccess)
    ? NoAccess
    : authorizations->Js.Array2.includes(Read)
    ? Read
    : authorizations->Js.Array2.includes(Checker)
    ? Checker
    : ReadWrite
}
