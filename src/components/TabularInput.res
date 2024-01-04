external ffInputToTableInput: ReactFinalForm.fieldRenderPropsInput => ReactFinalForm.fieldRenderPropsCustomInput<
  array<array<string>>,
> = "%identity"

module FieldInputRenderer = {
  @react.component
  let make = (~item, ~input: ReactFinalForm.fieldRenderPropsInput) => {
    <td> {item(input)} </td>
  }
}

module TableCell = {
  @react.component
  let make = (~onClick, ~elemIndex, ~isLast, ~fields, ~onChange, ~keyValue) => {
    <tr
      key={Belt.Int.toString(elemIndex)}
      className=" h-full rounded-md bg-white dark:bg-jp-gray-lightgray_background transition duration-300 ease-in-out text-sm text-jp-gray-800 dark:text-jp-gray-text_darktheme dark:text-opacity-75">
      {fields
      ->Array.mapWithIndex((itm, i) => {
        let input: ReactFinalForm.fieldRenderPropsInput = {
          name: `input`,
          onBlur: _ev => (),
          onChange: ev => {
            let event = ev->ReactEvent.Form.target
            onChange(elemIndex, i, event["value"])
          },
          onFocus: _ev => (),
          value: (keyValue[elemIndex]->Belt.Option.getWithDefault([]))[i]
          ->Belt.Option.getWithDefault("")
          ->Js.Json.string,
          checked: true,
        }
        <FieldInputRenderer item=itm input key={Belt.Int.toString(i)} />
      })
      ->React.array}
      <td className="mt-2 ml-5">
        <Button
          text={isLast ? "Add Row" : "Remove"}
          buttonState=Normal
          buttonSize=Small
          leftIcon={isLast ? FontAwesome("plus-circle") : FontAwesome("minus-circle")}
          onClick={onClick(elemIndex, isLast)}
        />
      </td>
    </tr>
  }
}

module TableHeading = {
  @react.component
  let make = (~heading) => {
    <th>
      <div
        className={`flex flex-row justify-between px-4 py-3 bg-gradient-to-b from-jp-gray-450 to-jp-gray-350 dark:from-jp-gray-950  dark:to-jp-gray-950 text-jp-gray-800 dark:text-jp-gray-text_darktheme dark:text-opacity-75 whitespace-pre `}>
        <div className="font-bold text-sm"> {heading->React.string} </div>
      </div>
    </th>
  }
}

module TableStructure = {
  @react.component
  let make = (~children, ~headings) => {
    <div>
      <table className="table-auto w-full h-full" colSpan=0>
        <thead>
          <tr
            className="h-full rounded-md bg-white dark:bg-jp-gray-lightgray_background hover:bg-jp-gray-table_hover dark:hover:bg-jp-gray-100 dark:hover:bg-opacity-10 transition duration-300 ease-in-out text-sm text-jp-gray-800 dark:text-jp-gray-text_darktheme dark:text-opacity-75">
            {headings
            ->Array.mapWithIndex((heading, i) => {
              <TableHeading heading key={Js.Int.toString(i)} />
            })
            ->React.array}
          </tr>
          {children->React.Children.map(element => {
            element
          })}
        </thead>
      </table>
    </div>
  }
}

@react.component
let make = (~input: ReactFinalForm.fieldRenderPropsInput, ~headings, ~fields) => {
  let tableInput = input->ffInputToTableInput
  let currentValue = React.useMemo1(() => {
    switch tableInput.value->Js.Json.decodeArray {
    | Some(str) =>
      str->Array.map(item => {
        switch item->Js.Json.decodeArray {
        | Some(a) =>
          a->Array.map(
            itm => {
              LogicUtils.getStringFromJson(itm, "")
            },
          )

        | None => []
        }
      })
    | None => []
    }
  }, [tableInput.value])

  let dummyInitialState = [{fields->Array.map(_ => {""})}]
  let initialState = Array.length(currentValue) > 0 ? currentValue : dummyInitialState
  let (keyValue, setKeyValue) = React.useState(() => initialState)

  let onKeyUp = tableInput.onChange

  let onChange = (elemIndex, coloumnIndex, value) => {
    let a = keyValue->Array.mapWithIndex((itm, index) => {
      if index == elemIndex {
        itm->Array.mapWithIndex((val, k) => {
          if k == coloumnIndex {
            value
          } else {
            val
          }
        })
      } else {
        itm
      }
    })

    onKeyUp(a)
    setKeyValue(_ => a)
  }

  let onClick = (elemIndex, isLast, _) => {
    let value = if isLast {
      Array.concat(initialState, dummyInitialState)
    } else {
      Array.filterWithIndex(initialState, (_, index) => index !== elemIndex)
    }

    setKeyValue(_ => value)
    onKeyUp(value)
  }
  <TableStructure headings>
    {initialState
    ->Array.mapWithIndex((_, i) => {
      let isLast = {i == Array.length(initialState) - 1}
      <TableCell onClick elemIndex=i isLast fields onChange keyValue />
    })
    ->React.array}
  </TableStructure>
}
