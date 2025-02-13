module Heading = {
  @react.component
  let make = (~heading) => {
    open ConnectorPaymentMethodV3Utils
    <div className="flex gap-2.5 items-center">
      <div className="p-2 bg-white border rounded-md">
        <Icon name={heading->pmIcon} />
      </div>
      <p className="font-semibold"> {heading->LogicUtils.snakeToTitle->React.string} </p>
    </div>
  }
}

module PaymentMethodTypes = {
  @react.component
  let make = (
    ~index,
    ~label,
    ~pmtData,
    ~pmIndex,
    ~pmtIndex,
    ~pm,
    ~connector,
    ~showCheckbox=true,
    ~onClick=None,
    ~isInEditState=false,
  ) => {
    let handleClick = () => {
      switch onClick {
      | Some(onClick) => onClick()
      | None => ()
      }
    }
    open FormRenderer
    <RenderIf condition={showCheckbox}>
      <AddDataAttributes key={index->Int.toString} attributes=[("data-testid", `${label}`)]>
        <div key={index->Int.toString} className={"flex gap-1.5 items-center"}>
          <RenderIf condition={!isInEditState}>
            <div onClick={_ => handleClick()}>
              <FieldRenderer
                field={PMTSelection.valueInput(
                  ~pmtData,
                  ~pmIndex,
                  ~pmtIndex=pmtIndex->Int.toString,
                  ~pm,
                  ~connector,
                )}
              />
            </div>
          </RenderIf>
          <p className="mt-4"> {label->React.string} </p>
        </div>
      </AddDataAttributes>
    </RenderIf>
  }
}

module HeadingSection = {
  @react.component
  let make = (~index, ~pm, ~availablePM, ~pmIndex, ~pmt, ~showSelectAll=true) => {
    open FormRenderer
    <div className="border-nd_gray-150 rounded-t-xl overflow-hidden">
      <div className="flex justify-between bg-nd_gray-50 p-4 border-b">
        <Heading heading=pmt />
        <RenderIf condition={showSelectAll}>
          <div className="flex gap-2 items-center">
            <AddDataAttributes
              key={index->Int.toString}
              attributes=[("data-testid", pm->String.concat("_")->String.concat("select_all"))]>
              <FieldRenderer
                field={PMSelectAll.selectAllValueInput(
                  ~availablePM,
                  ~pmIndex=pmIndex->Int.toString,
                  ~pm,
                  ~pmt,
                )}
              />
            </AddDataAttributes>
          </div>
        </RenderIf>
      </div>
    </div>
  }
}
