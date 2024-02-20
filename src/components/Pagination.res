external formEventToInt: ReactEvent.Form.t => int = "%identity"

@react.component
let make = (~resultsPerPage, ~totalResults, ~currentPage, ~paginate, ~btnCount=4) => {
  let pageNumbers = []

  let isMobileView = MatchMedia.useMobileChecker()
  let (dropDownVal, setDropDownVal) = React.useState(_ => "1-10")
  let total = Math.ceil(Int.toFloat(totalResults) /. Int.toFloat(resultsPerPage))->Float.toInt

  for x in 1 to total {
    Array.push(pageNumbers, x)->ignore
  }

  let pageToLeft =
    btnCount - (total - currentPage) < btnCount / 2
      ? btnCount / 2
      : btnCount - (total - currentPage)

  let arr = []
  for x in 1 to totalResults {
    arr->Array.push(x)->ignore
  }
  let rangeNum =
    arr
    ->Array.map(ele => {
      mod(ele, 10) === 0 ? Array.indexOf(arr, ele + 1) : 0
    })
    ->Array.filter(i => i !== 0)

  let ranges = []

  rangeNum->Array.forEach(ele => {
    ranges->Array.push((ele - 9)->Int.toString ++ "-" ++ ele->Int.toString)->ignore
  })
  let lastNum = rangeNum->Array.get(Array.length(rangeNum) - 1)->Option.getOr(0)
  if totalResults > lastNum {
    let start = lastNum + (totalResults - lastNum)
    start === totalResults
      ? ranges->Array.push(start->Int.toString)->ignore
      : ranges->Array.push(start->Int.toString ++ "-" ++ totalResults->Int.toString)->ignore
  }

  let startIndex = Math.Int.max(1, currentPage - pageToLeft)
  let endIndex = Math.Int.min(startIndex + btnCount, total)

  let nonEmpty = s => s >= startIndex && s <= endIndex

  let leftIcon: Button.iconType = Euler("LeftPagination")

  let rightIcon: Button.iconType = Euler("RightPagination")
  let buttonType: Button.buttonType = Pagination

  {
    if !isMobileView {
      <ButtonGroup>
        <Button
          leftIcon
          buttonType
          buttonState={if currentPage > 1 {
            Normal
          } else {
            Disabled
          }}
          customButtonStyle="!h-10"
          onClick={_evt => paginate(Math.Int.max(1, currentPage - 1))}
        />
        {pageNumbers
        ->Array.filter(nonEmpty)
        ->Array.mapWithIndex((number, idx) => {
          let isSelected = number == currentPage

          <Button
            key={idx->Int.toString}
            text={number->Int.toString}
            onClick={_evt => paginate(number)}
            buttonType
            customButtonStyle="!h-10 border-left-1 border-right-1"
            buttonState={if isSelected {
              NoHover
            } else {
              Normal
            }}
          />
        })
        ->React.array}
        <Button
          rightIcon
          buttonType
          onClick={_evt => paginate(currentPage + 1)}
          customButtonStyle="!h-10"
          buttonState={if currentPage < Array.length(pageNumbers) {
            Normal
          } else {
            Disabled
          }}
        />
      </ButtonGroup>
    } else {
      let dropDownOptions = ranges->Array.mapWithIndex((item, idx): SelectBox.dropdownOption => {
        {
          label: item,
          value: (idx + 1)->Int.toString,
        }
      })

      let selectInput: ReactFinalForm.fieldRenderPropsInput = {
        name: "dummy-name",
        onBlur: _ev => (),
        onChange: _evt => {
          let val = ranges->Array.get(_evt->formEventToInt - 1)->Option.getOr("1-10")
          setDropDownVal(_ => val)
          paginate(_evt->formEventToInt)
        },
        onFocus: _ev => (),
        value: ""->JSON.Encode.string,
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
}
