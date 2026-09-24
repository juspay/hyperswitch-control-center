open AlertsTypes
open LogicUtils
open Typography

module AlertDetailRow = {
  @react.component
  let make = (~label, ~cell: Table.cell, ~stacked=false) => {
    <div
      className={stacked
        ? "flex flex-col gap-1.5 min-w-0"
        : "flex items-start gap-4 py-2.5 border-b border-nd_gray-150 last:border-b-0"}>
      <span className={`${body.sm.medium} text-nd_gray-500 ${stacked ? "" : "w-2/5 shrink-0"}`}>
        {label->React.string}
      </span>
      <div className={`${body.md.medium} text-nd_gray-600 min-w-0 break-words`}>
        <Table.TableCell cell textAlign=Table.Left />
      </div>
    </div>
  }
}

module AlertDetailsGrid = {
  @react.component
  let make = (
    ~alert: alert,
    ~columns: array<colType>,
    ~getHeading: colType => Table.header,
    ~getCell: (alert, colType) => Table.cell,
    ~children,
  ) => {
    <div className="grid grid-cols-2 md:grid-cols-4 gap-x-6 gap-y-6">
      {columns
      ->Array.mapWithIndex((colType, i) =>
        <AlertDetailRow
          key={Int.toString(i)}
          label={getHeading(colType).title}
          cell={getCell(alert, colType)}
          stacked=true
        />
      )
      ->React.array}
      children
    </div>
  }
}

module BlacklistScopeTooltip = {
  @react.component
  let make = (~isBlacklisted, ~fields: array<(string, JSON.t)>) => {
    <RenderIf condition=isBlacklisted>
      <ToolTip
        toolTipPosition=Top
        hoverOnToolTip=true
        toolTipFor={<span
          className="inline-flex cursor-default text-nd_gray-500" ariaLabel="Blacklist details">
          <Icon name="nd-info-circle" size=16 />
        </span>}
        descriptionComponent={<div className="min-w-64 max-h-52 overflow-auto p-1 text-white">
          <div className={`${body.sm.semibold} mb-2`}> {"Blacklist scope"->React.string} </div>
          <RenderIf condition={fields->isNonEmptyArray}>
            <div className={`flex flex-col gap-1 ${body.sm.regular}`}>
              {fields
              ->Array.map(((key, value)) =>
                <div className="flex gap-2" key>
                  <span> {`${key}:`->React.string} </span>
                  <span className="break-all"> {value->getStringFromJson("-")->React.string} </span>
                </div>
              )
              ->React.array}
            </div>
          </RenderIf>
          <RenderIf condition={fields->isEmptyArray}>
            <span className={`${body.sm.regular} text-white`}>
              {"No blacklist scope details"->React.string}
            </span>
          </RenderIf>
        </div>}
      />
    </RenderIf>
  }
}

module SnoozeWindowTooltip = {
  @react.component
  let make = (~hasSnooze, ~startTime, ~endTime) => {
    <RenderIf condition=hasSnooze>
      <ToolTip
        toolTipPosition=Top
        hoverOnToolTip=true
        toolTipFor={<span
          className="inline-flex cursor-default text-nd_gray-500" ariaLabel="Snooze details">
          <Icon name="nd-info-circle" size=16 />
        </span>}
        descriptionComponent={<div className="min-w-56 p-1 text-white">
          <div className={body.sm.semibold}> {"Stored snooze window"->React.string} </div>
          <div className={`mt-2 flex flex-col gap-1 ${body.sm.regular}`}>
            <div className="flex items-center gap-2">
              <span> {"Start:"->React.string} </span>
              <TableUtils.DateCell
                timestamp=startTime
                textAlign={TableUtils.Left}
                isCard=true
                textStyle={`${body.sm.regular} text-white`}
              />
            </div>
            <div className="flex items-center gap-2">
              <span> {"End:"->React.string} </span>
              <TableUtils.DateCell
                timestamp=endTime
                textAlign={TableUtils.Left}
                isCard=true
                textStyle={`${body.sm.regular} text-white`}
              />
            </div>
          </div>
        </div>}
      />
    </RenderIf>
  }
}

module Card = {
  @react.component
  let make = (~title, ~titleRight=React.null, ~children) => {
    <div
      className="flex flex-col gap-4 bg-white rounded-xl shadow-sm border border-nd_gray-150 p-5">
      <div className="flex justify-between items-center">
        <div className={`${heading.xs.semibold} text-nd_gray-800`}> {title->React.string} </div>
        titleRight
      </div>
      children
    </div>
  }
}

module ActionButtons = {
  @react.component
  let make = (~isBlacklisted, ~onBlacklist, ~onSnooze, ~onResolve) => {
    let authorization = AlertsHooks.useAlertsManageAccess()
    <div className="flex gap-2">
      <ACLButton
        authorization
        text={isBlacklisted ? "Remove blacklist" : "Blacklist"}
        buttonType=Secondary
        onClick={_ => onBlacklist()}
      />
      <ACLButton authorization text="Snooze" buttonType=Secondary onClick={_ => onSnooze()} />
      <ACLButton authorization text="Resolve" buttonType=Primary onClick={_ => onResolve()} />
    </div>
  }
}

module DimensionFields = {
  @react.component
  let make = (~keys: array<dimensionKey>, ~keysName, ~valuesName, ~label, ~buttonText) => {
    <>
      <FormRenderer.FieldRenderer
        field={FormRenderer.makeFieldInfo(
          ~label,
          ~name=keysName,
          ~customInput=InputFields.multiSelectInput(
            ~options=keys->Array.map((key): string => (key :> string))->SelectBox.makeOptions,
            ~buttonText,
            ~fullLength=true,
            ~marginTop="mt-0",
          ),
        )}
      />
      <ReactFinalForm.Field name=keysName>
        {fieldState =>
          <div className="flex flex-col gap-3">
            {fieldState.input.value
            ->getStrArrayFromJson
            ->Array.map(key =>
              <FormRenderer.FieldRenderer
                key
                field={FormRenderer.makeFieldInfo(
                  ~label=key,
                  ~name=`${valuesName}.${key}`,
                  ~customInput=InputFields.textInput(),
                )}
              />
            )
            ->React.array}
          </div>}
      </ReactFinalForm.Field>
    </>
  }
}
