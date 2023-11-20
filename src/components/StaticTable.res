type view = Table | Card

let getValue = (val: Table.cell) => {
  switch val {
  | Label(label) => label.title
  | Text(str) => str === "No Value" ? "" : str
  | _ => ""
  }
}

let getValueWithType = (val: Table.cell) => {
  switch val {
  | Label(label) => (label.title, "numeric")
  | Text(str) => (str, str->Belt.Float.fromString->Js.Option.isSome ? "numeric" : "string")
  | _ => ("", "")
  }
}

let sortRows = (
  rowData: array<Js.Array2.t<Table.cell>>,
  key,
  sortOrder: Table.sortOrder,
  heading,
) => {
  let index = heading->Js.Array2.findIndex((head: Table.header) => head.key === key)
  rowData->Js.Array2.sortInPlaceWith((item1, item2) => {
    if index === -1 {
      1
    } else {
      let (value1, type1) = item1->Js.Array2.unsafe_get(index)->getValueWithType
      let (value2, type2) = item2->Js.Array2.unsafe_get(index)->getValueWithType
      if type1 === "numeric" || type2 === "numeric" {
        let (value1, value2) = (
          value1->Belt.Float.fromString->Belt.Option.getWithDefault(-1.0),
          value2->Belt.Float.fromString->Belt.Option.getWithDefault(-1.0),
        )
        if value1 === value2 {
          0
        } else if value1 > value2 {
          sortOrder === DEC ? 1 : -1
        } else if sortOrder === DEC {
          -1
        } else {
          1
        }
      } else if value1 === value2 {
        0
      } else if value1 > value2 {
        sortOrder === DEC ? 1 : -1
      } else if sortOrder === DEC {
        -1
      } else {
        1
      }
    }
  })
}

let filterRows = (
  rowData: array<Js.Array2.t<Table.cell>>,
  filterObj: array<Table.filterObject>,
) => {
  rowData->Js.Array2.filter(item => {
    filterObj->Js.Array2.reduce((acc, filterOfColumn) => {
      if (
        filterOfColumn.options->Js.Array2.length === 0 ||
          filterOfColumn.selected->Js.Array2.length === 0
      ) {
        true && acc
      } else {
        switch filterOfColumn.key->Belt.Int.fromString {
        | Some(index) =>
          switch item->Js.Array2.findi((_, idx) => idx === index) {
          | Some(val) => {
              let rowOfColumn = val->getValue
              filterOfColumn.selected->Js.Array2.includes(rowOfColumn) && acc
            }

          | None => true && acc
          }
        | None => true && acc
        }
      }
    }, true)
  })
}

@react.component
let make = (
  ~tableHeading=?,
  ~data,
  ~handleRowClick,
  ~heading,
  ~getRowFromData,
  ~sortedObj=?,
  ~filterObj=?,
  ~resultsPerPage=5,
  ~showPagination=true,
) => {
  let isMobileView = MatchMedia.useMatchMedia("(max-width: 700px)")
  let (dataView, setDataView) = React.useState(_ => isMobileView ? Card : Table)
  let (offset, setOffset) = React.useState(() => 0)
  let (sortedObj, setSortedObj) = React.useState(() => sortedObj)
  let initialFilterObj = filterObj
  let (filterObj, setFilterObj) = React.useState(() => filterObj)
  let totalResults = {data->Js.Array.length}
  let resultsPerPage = showPagination ? resultsPerPage : totalResults

  let start = offset + 1
  let toNum = resultsPerPage + start > totalResults ? totalResults : resultsPerPage + start - 1
  let currentPage = offset / resultsPerPage + 1

  React.useEffect1(() => {
    setDataView(_prev => isMobileView ? Card : Table)
    None
  }, [isMobileView])

  let paginate = React.useCallback3(pageNumber => {
    let total = Js.Math.ceil(Belt.Int.toFloat(totalResults) /. Belt.Int.toFloat(resultsPerPage))
    let defaultPageNumber = Js.Math.min_int(total, pageNumber)
    let page = defaultPageNumber
    let newOffset = (page - 1) * resultsPerPage
    setOffset(_ => newOffset)
  }, (setOffset, resultsPerPage, totalResults))

  let rows = data->Belt.Array.keepMap(getRowFromData)

  let heading = heading->Js.Array2.mapi((head: Table.header, index) => {
    let getValue = row =>
      row->Belt.Array.get(index)->Belt.Option.mapWithDefault("", Table.getTableCellValue)

    let default = switch rows[0] {
    | Some(row) => getValue(row)
    | None => ""
    }
    let head: Table.header = {
      ...head,
      showSort: head.showSort &&
      rows->Js.Array2.length > 0 &&
      rows->Js.Array2.some(row => getValue(row) !== default),
    }
    head
  })

  let rows = rows->Js.Array2.slice(~start=offset, ~end_=toNum)

  let filteredRows = switch filterObj {
  | Some(obj: array<Table.filterObject>) => filterRows(rows, obj)
  | None => rows
  }

  let sortedRows = switch sortedObj {
  | Some(obj: Table.sortedObject) => sortRows(filteredRows, obj.key, obj.order, heading)
  | None => filteredRows
  }

  <>
    {switch tableHeading {
    | Some(head) => <div className="font-bold text-3xl"> {React.string(head)} </div>
    | None => React.null
    }}
    {if sortedRows->Js.Array2.length > 0 {
      <div className="w-full overflow-x-scroll">
        {switch dataView {
        | Table =>
          <Table
            heading
            rows={sortedRows}
            onRowClick=handleRowClick
            offset
            showScrollBar=true
            ?sortedObj
            setSortedObj
            ?filterObj
          />
        | Card => <CardTable heading rows={sortedRows} onRowClick=handleRowClick offset />
        }}
        {if showPagination {
          <div className="flex flex-row justify-between mt-4">
            <div className="text-gray-500 my-4">
              {React.string(
                `Showing ${start->string_of_int} to ${toNum->string_of_int} of ${totalResults->string_of_int} `,
              )}
            </div>
            {if totalResults > resultsPerPage {
              <div className="flex flex-row">
                <Pagination totalResults currentPage resultsPerPage paginate />
              </div>
            } else {
              React.null
            }}
          </div>
        } else {
          React.null
        }}
      </div>
    } else if rows->Js.Array2.length > 0 {
      <div
        className="flex flex-col flex-1 items-center justify-center text-center text-2xl font-bold w-full m-4 gap-4">
        {React.string("No Data Found!!")}
        <Button
          leftIcon={FontAwesome("arrow-alt-circle-left")}
          onClick={_ => setFilterObj(_ => initialFilterObj)}
          text="Clear filters"
        />
      </div>
    } else {
      React.null
    }}
  </>
}
