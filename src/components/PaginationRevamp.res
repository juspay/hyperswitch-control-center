external formEventToInt: ReactEvent.Form.t => int = "%identity"

@react.component
let make = (~resultsPerPage, ~totalResults, ~currentPage, ~paginate, ~btnCount=4) => {
  let pageNumbers = []
  let isMobileView = MatchMedia.useMobileChecker()
  let (dropDownVal, setDropDownVal) = React.useState(_ => "1-10")
  let total = Js.Math.ceil(Belt.Int.toFloat(totalResults) /. Belt.Int.toFloat(resultsPerPage))

  for x in 1 to total {
    Js.Array2.push(pageNumbers, x)->ignore
  }

  let pageToLeft =
    btnCount - (total - currentPage) < btnCount / 2
      ? btnCount / 2
      : btnCount - (total - currentPage)

  let arr = []
  for x in 1 to totalResults {
    arr->Js.Array2.push(x)->ignore
  }
  let rangeNum =
    arr
    ->Js.Array2.map(ele => {
      mod(ele, 10) === 0 ? Js.Array2.indexOf(arr, ele + 1) : 0
    })
    ->Js.Array2.filter(i => i !== 0)

  let ranges = []

  rangeNum->Js.Array2.forEach(ele => {
    ranges->Js.Array2.push((ele - 9)->Belt.Int.toString ++ "-" ++ ele->Belt.Int.toString)->ignore
  })
  let lastNum =
    rangeNum->Belt.Array.get(Js.Array2.length(rangeNum) - 1)->Belt.Option.getWithDefault(0)
  if totalResults > lastNum {
    let start = lastNum + (totalResults - lastNum)
    start === totalResults
      ? ranges->Js.Array2.push(start->Belt.Int.toString)->ignore
      : ranges
        ->Js.Array2.push(start->Belt.Int.toString ++ "-" ++ totalResults->Belt.Int.toString)
        ->ignore
  }

  let startIndex = Js.Math.max_int(1, currentPage - pageToLeft)
  let endIndex = Js.Math.min_int(startIndex + btnCount, total)

  let nonEmpty = s => s >= startIndex && s <= endIndex

  let buttonType: Button.buttonType = Secondary
  let leftArrowCursorClass = currentPage > 1 ? "cursor-pointer" : "cursor-not-allowed opacity-50"
  let leftArrowOnClick =
    currentPage > 1 ? _evt => paginate(Js.Math.max_int(1, currentPage - 1)) : _ => ()

  let rightArrowCursorClass =
    currentPage < Belt.Array.length(pageNumbers)
      ? "cursor-pointer"
      : "cursor-not-allowed opacity-50"
  let rightArrowOnClick =
    currentPage < Belt.Array.length(pageNumbers) ? _evt => paginate(currentPage + 1) : _ => ()

  let selectedClass = "text-fs-12 font-medium text-jp-2-light-primary-600 px-2.5 py-1 bg-jp-2-light-primary-100 rounded-lg"
  let nonSelectedClass = "text-fs-12 font-medium text-jp-2-light-gray-1200 hover:text-jp-2-light-primary-600 px-2.5 py-1 rounded-lg cursor-pointer"
  let pageOnclick = (isSelected, number) => {
    isSelected ? _ => () : _evt => paginate(number)
  }

  let pageInput1: ReactFinalForm.fieldRenderPropsInput = {
    name: "pageSelector-1",
    onBlur: _ev => (),
    onChange: ev => {
      ev->formEventToInt->paginate
    },
    onFocus: _ev => (),
    value: currentPage->Belt.Int.toFloat->Js.Json.number,
    checked: true,
  }
  let pageInput2: ReactFinalForm.fieldRenderPropsInput = {
    name: "pageSelector-2",
    onBlur: _ev => (),
    onChange: ev => {
      ev->formEventToInt->paginate
    },
    onFocus: _ev => (),
    value: currentPage->Belt.Int.toFloat->Js.Json.number,
    checked: true,
  }

  if !isMobileView {
    <div className="flex gap-3 items-center px-6">
      <Icon
        name="leftArrow"
        size=20
        className={`p-1.5 ${leftArrowCursorClass}`}
        onClick=leftArrowOnClick
      />
      {if total > 5 {
        let pageN = []
        if currentPage <= 3 {
          Js.Array2.pushMany(pageN, [1, 2, 3, 4, -2, total])->ignore
        } else if currentPage >= total - 2 {
          Js.Array2.pushMany(pageN, [1, -1, total - 3, total - 2, total - 1, total])->ignore
        } else {
          Js.Array2.pushMany(
            pageN,
            [1, -1, currentPage - 1, currentPage, currentPage + 1, -2, total],
          )->ignore
        }

        pageN
        ->Js.Array2.mapi((number, idx) => {
          let isSelected = number === currentPage

          if number < 0 {
            let input = number === -1 ? pageInput1 : pageInput2
            let prevValue = pageN->LogicUtils.getValueFromArr(idx - 1, 0)
            let nextValue = pageN->LogicUtils.getValueFromArr(idx + 1, 0)
            let dropDownOptions =
              Belt.Array.range(prevValue + 1, nextValue - 1)
              ->Js.Array2.map(int => int->Belt.Int.toString)
              ->SelectBox.makeOptions
            <div key={idx->string_of_int}>
              <SelectBox.BaseDropdown
                allowMultiSelect=false
                hideMultiSelectButtons=true
                buttonText="..."
                input
                baseComponent={<div className="font-semibold text-jp-2-gray-1200 cursor-pointer">
                  {"..."->React.string}
                </div>}
                options=dropDownOptions
                searchable=false
                showClearAll=false
                showSelectAll=false
              />
            </div>
          } else {
            <div
              key={idx->string_of_int}
              className={isSelected ? selectedClass : nonSelectedClass}
              onClick={pageOnclick(isSelected, number)}>
              {React.string(number->string_of_int)}
            </div>
          }
        })
        ->React.array
      } else {
        pageNumbers
        ->Js.Array2.filter(nonEmpty)
        ->Js.Array2.mapi((number, idx) => {
          let isSelected = number === currentPage

          <div
            key={idx->string_of_int}
            className={isSelected ? selectedClass : nonSelectedClass}
            onClick={pageOnclick(isSelected, number)}>
            {React.string(number->string_of_int)}
          </div>
        })
        ->React.array
      }}
      <Icon
        name="leftArrow"
        size=20
        className={`p-1.5 rotate-180 ${rightArrowCursorClass}`}
        onClick=rightArrowOnClick
      />
    </div>
  } else {
    let dropDownOptions = ranges->Js.Array2.mapi((item, idx): SelectBox.dropdownOption => {
      {
        label: item,
        value: (idx + 1)->Belt.Int.toString,
      }
    })

    let selectInput: ReactFinalForm.fieldRenderPropsInput = {
      name: "dummy-name",
      onBlur: _ev => (),
      onChange: _evt => {
        let val =
          ranges->Belt.Array.get(_evt->formEventToInt - 1)->Belt.Option.getWithDefault("1-10")
        setDropDownVal(_ => val)
        paginate(_evt->formEventToInt)
      },
      onFocus: _ev => (),
      value: ""->Js.Json.string,
      checked: true,
    }

    <SelectBox.BaseDropdown
      options=dropDownOptions
      searchable=false
      input=selectInput
      hideMultiSelectButtons=true
      deselectDisable=true
      buttonType
      allowMultiSelect=false
      buttonText=dropDownVal
    />
  }
}
