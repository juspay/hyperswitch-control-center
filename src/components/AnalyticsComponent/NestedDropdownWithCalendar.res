@react.component
let make = (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~options,
  ~title: string,
  ~dateRangeLimit: int=60,
  ~addMore: bool=true,
) => {
  let (startDateArr, setStartDateArr) = React.useState(_ => [""])
  let (endDateArr, setEndDateArr) = React.useState(_ => [""])
  let onClickAdd = _ => {
    setEndDateArr(prev => Js.Array.concat([""], prev))
    setStartDateArr(prev => Js.Array.concat([""], prev))
  }
  React.useEffect1(() => {
    setStartDateArr(_ => [""])
    setEndDateArr(_ => [""])
    None
  }, [input.value])

  let onClick = _ => {
    let newArr =
      startDateArr->Js.Array2.mapi((x, i) => (
        x,
        endDateArr->Belt.Array.get(i)->Belt.Option.getWithDefault(x),
      ))

    input.onChange(newArr->Identity.anyTypeToReactEvent)
  }

  let showCalendars = React.useMemo1(() => {
    input.value
    ->Js.Json.decodeArray
    ->Belt.Option.getWithDefault([])
    ->Belt.Array.get(0)
    ->Belt.Option.getWithDefault(Js.Json.null)
    ->Js.Json.decodeString
    ->Belt.Option.getWithDefault("") == "timeP" ||
      input.value
      ->Js.Json.decodeArray
      ->Belt.Option.getWithDefault([])
      ->Belt.Array.get(0)
      ->Belt.Option.getWithDefault(Js.Json.null)
      ->Js.Json.decodeArray
      ->Belt.Option.getWithDefault([])
      ->Belt.Array.get(0)
      ->Belt.Option.getWithDefault(Js.Json.null)
      ->Js.Json.decodeString
      ->Belt.Option.getWithDefault("")
      ->Js.Date.fromString
      ->Js.Date.getTime >= 0.0
  }, [input.value])
  <div className="flex">
    <NestedDropdown input options title />
    <UIUtils.RenderIf condition={showCalendars}>
      <div className="flex px-2">
        {startDateArr
        ->Js.Array2.mapi((_x, i) => {
          <div className="px-1">
            <DateRangePicker.Base
              startDateVal={startDateArr[i]->Belt.Option.getWithDefault("")}
              setStartDateVal={fn => {
                setStartDateArr(prev => {
                  let newArr = prev->Js.Array2.mapi(
                    (x2, i2) => {
                      if i2 == i {
                        fn(prev[i]->Belt.Option.getWithDefault(""))
                      } else {
                        x2
                      }
                    },
                  )

                  newArr
                })
              }}
              endDateVal={endDateArr[i]->Belt.Option.getWithDefault("")}
              setEndDateVal={fn => {
                setEndDateArr(prev => {
                  let newArr = prev->Js.Array2.mapi(
                    (x2, i2) => {
                      if i2 == i {
                        fn(prev[i]->Belt.Option.getWithDefault(""))
                      } else {
                        x2
                      }
                    },
                  )

                  newArr
                })
              }}
              showTime=false
              disablePastDates=false
              disableFutureDates=true
              predefinedDays=[]
              format="YYYY-MM-DDTHH:mm:ss.SSS[Z]"
              numMonths=1
              disableApply=true
              removeFilterOption=false
              textHideInMobileView=true
              showSeconds=true
              hideDate=false
              selectStandardTime=false
              dateRangeLimit
            />
          </div>
        })
        ->React.array}
        {addMore
          ? <Button
              buttonType={Secondary} text="Add" leftIcon={FontAwesome("plus")} onClick=onClickAdd
            />
          : React.null}
        <div className="pl-2">
          <Button buttonType=Primary text={`Compare`} onClick type_="submit" />
        </div>
      </div>
    </UIUtils.RenderIf>
  </div>
}
