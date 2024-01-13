external formEventToInt: ReactEvent.Form.t => int = "%identity"

@react.component
let make = (~resultsPerPage, ~totalResults, ~currentPage, ~paginate, ~btnCount=4) => {
  let pageNumbers = []

  let isMobileView = MatchMedia.useMobileChecker()
  let (dropDownVal, setDropDownVal) = React.useState(_ => "1-10")
  let total = Js.Math.ceil(Belt.Int.toFloat(totalResults) /. Belt.Int.toFloat(resultsPerPage))

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
    ranges->Array.push((ele - 9)->Belt.Int.toString ++ "-" ++ ele->Belt.Int.toString)->ignore
  })
  let lastNum = rangeNum->Belt.Array.get(Array.length(rangeNum) - 1)->Belt.Option.getWithDefault(0)
  if totalResults > lastNum {
    let start = lastNum + (totalResults - lastNum)
    start === totalResults
      ? ranges->Array.push(start->Belt.Int.toString)->ignore
      : ranges
        ->Array.push(start->Belt.Int.toString ++ "-" ++ totalResults->Belt.Int.toString)
        ->ignore
  }

  let startIndex = Js.Math.max_int(1, currentPage - pageToLeft)
  let endIndex = Js.Math.min_int(startIndex + btnCount, total)

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
          onClick={_evt => paginate(Js.Math.max_int(1, currentPage - 1))}
        />
        {pageNumbers
        ->Array.filter(nonEmpty)
        ->Array.mapWithIndex((number, idx) => {
          let isSelected = number == currentPage

          <Button
            key={idx->string_of_int}
            text={number->string_of_int}
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
          buttonState={if currentPage < Belt.Array.length(pageNumbers) {
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
}
