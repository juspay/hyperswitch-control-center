module Heading = {
  @react.component
  let make = (~heading) => {
    open ConnectorPaymentMethodV2Utils
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
    ~formValues: ConnectorTypes.connectorPayloadCommonType,
  ) => {
    let handleClick = () => {
      switch onClick {
      | Some(onClick) => onClick()
      | None => ()
      }
    }
    open FormRenderer
    <RenderIf key={index->Int.toString} condition={showCheckbox}>
      <AddDataAttributes key={index->Int.toString} attributes=[("data-testid", `${label}`)]>
        <div key={index->Int.toString} className={"flex gap-1.5 items-center"}>
          <div className="cursor-pointer" onClick={_ => handleClick()}>
            <FieldRenderer
              field={PMTSelection.valueInput(
                ~pmtData,
                ~pmIndex,
                ~pmtIndex=pmtIndex->Int.toString,
                ~pm,
                ~connector,
                ~formValues,
              )}
            />
          </div>
          <p className="mt-4"> {label->React.string} </p>
        </div>
      </AddDataAttributes>
    </RenderIf>
  }
}

module HeadingSection = {
  @react.component
  let make = (
    ~index,
    ~pm,
    ~availablePM: array<ConnectorTypes.paymentMethodConfigTypeCommon>,
    ~pmIndex,
    ~pmt,
    ~showSelectAll,
  ) => {
    open FormRenderer

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
  }
}

module SelectedPMT = {
  @react.component
  let make = (~pmtData: array<ConnectorTypes.paymentMethodConfigTypeCommon>, ~index, ~pm) => {
    open LogicUtils
    open ConnectorPaymentMethodV2Utils
    <RenderIf condition={pmtData->Array.length > 0}>
      <div
        className="border border-nd_gray-150 rounded-xl overflow-hidden"
        key={`${index->Int.toString}-debit`}>
        <div className="flex justify-between bg-nd_gray-50 p-4 border-b">
          <Heading heading=pm />
        </div>
        <div className="flex gap-8 p-6 flex-wrap">
          {pmtData
          ->Array.mapWithIndex((data, i) => {
            let label = switch pm->getPMTFromString {
            | Credit | Debit => data.card_networks->Array.joinWith(",")
            | _ => data.payment_method_subtype->snakeToTitle
            }
            <AddDataAttributes key={i->Int.toString} attributes=[("data-testid", `${label}`)]>
              <div key={i->Int.toString} className={"flex gap-1.5 items-center"}>
                <p className="mt-4"> {label->React.string} </p>
              </div>
            </AddDataAttributes>
          })
          ->React.array}
        </div>
      </div>
    </RenderIf>
  }
}
