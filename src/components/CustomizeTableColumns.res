let makeFieldInfo = FormRenderer.makeFieldInfo
@react.component
let make = (
  ~allHeadersArray=[],
  ~visibleColumns=[],
  ~setColumns,
  ~getHeading: 'colType => Table.header,
  ~defaultColumns,
  ~showModal,
  ~setShowModal,
  ~isModalView=true,
  ~orderdColumnBasedOnDefaultCol: bool=false,
  ~sortingBasedOnDisabled=true,
  ~showSerialNumber=true,
) => {
  let heading = allHeadersArray

  let headingDict =
    heading
    ->Js.Array2.mapi((item, index) => (
      getHeading(item).title,
      index->Belt.Int.toFloat->Js.Json.number,
    ))
    ->Js.Dict.fromArray

  let sortByOrderOderedArr = (a, b) => {
    let positionInHeader = headingDict->LogicUtils.getInt(getHeading(a).title, 0)
    let positionInHeading = headingDict->LogicUtils.getInt(getHeading(b).title, 0)
    if positionInHeader < positionInHeading {
      -1
    } else if positionInHeader > positionInHeading {
      1
    } else {
      0
    }
  }

  let defaultColumnsString = defaultColumns->Js.Array2.map(head => getHeading(head).title)
  let initalHeadingData = heading->Js.Array2.map(head => {
    let columnName = getHeading(head).title
    let isDisabled = defaultColumnsString->Js.Array2.includes(columnName)
    let options: SelectBox.dropdownOption = {
      label: columnName,
      value: columnName,
      isDisabled,
    }
    options
  })
  let initialValues = visibleColumns->Js.Array2.map(head => getHeading(head).title)

  let onSubmit = values => {
    let getHeadingCol = text => {
      let index = heading->Js.Array2.map(head => getHeading(head).title)->Js.Array2.indexOf(text)
      heading[index]
    }

    let headers = values->Belt.Array.keepMap(getHeadingCol)
    let headers = orderdColumnBasedOnDefaultCol
      ? headers->Js.Array2.copy->Js.Array2.sortInPlaceWith(sortByOrderOderedArr)
      : headers

    setColumns(_ => headers)
  }

  <SelectModal
    modalHeading="Table Columns"
    showModal
    setShowModal
    onSubmit
    initialValues
    isModalView
    options=initalHeadingData
    sortingBasedOnDisabled
    showSerialNumber
  />
}
