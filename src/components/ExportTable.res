@react.component
let make = (
  ~title: string,
  ~tableData: Js.Array2.t<Js.Nullable.t<'t>>,
  ~visibleColumns: Js.Array2.t<'colType>,
  ~colMapper,
  ~getHeading: 'colType => Table.header,
) => {
  let isMobileView = MatchMedia.useMobileChecker()
  let actualDataOrig =
    tableData
    ->Belt.Array.keepMap(item => item->Js.Nullable.toOption)
    ->Array.map(Identity.genericTypeToJson)

  let headerNames = visibleColumns->Belt.Array.keepMap(head => {
    let item = head->getHeading
    let title = head->colMapper
    title !== "" ? Some(item.title) : None
  })
  let initialValues = visibleColumns->Belt.Array.keepMap(head => {
    let title = head->colMapper
    title !== "" ? Some(title) : None
  })

  let handleDownloadClick = _ev => {
    let header = headerNames->Array.joinWith(",")

    let csv =
      actualDataOrig
      ->Array.map(allRows => {
        let allRowsDict = Js.Json.decodeObject(allRows)->Belt.Option.getWithDefault(Dict.make())
        initialValues
        ->Array.map(col => {
          let str =
            Dict.get(allRowsDict, col)->Belt.Option.getWithDefault(Js.Json.null)->Js.Json.stringify

          let strArr = str->Js.String2.split(".")

          let newStr = if (
            strArr->Array.length === 2 && str->Belt.Float.fromString->Belt.Option.isSome
          ) {
            let newDecimal =
              strArr
              ->Belt.Array.get(1)
              ->Belt.Option.getWithDefault("00")
              ->Js.String2.slice(~from=0, ~to_=2)
            strArr->Belt.Array.get(0)->Belt.Option.getWithDefault("0") ++ "." ++ newDecimal
          } else {
            str
          }
          newStr
        })
        ->Array.joinWith(",")
      })
      ->Array.joinWith("\n")
    let finalCsv = header ++ "\n" ++ csv
    let currentTime = Js.Date.now()->Js.Float.toString
    DownloadUtils.downloadOld(~fileName=`${title}_${currentTime}.csv`, ~content=finalCsv)
  }

  <Button
    text={isMobileView ? "" : "Export Table"}
    leftIcon={FontAwesome("download")}
    onClick=handleDownloadClick
    buttonType={Dropdown}
  />
}
