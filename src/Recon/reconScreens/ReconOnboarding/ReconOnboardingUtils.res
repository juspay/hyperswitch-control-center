let generateDropdownOptionsCustomComponent: array<OMPSwitchTypes.ompListTypes> => array<
  SelectBox.dropdownOption,
> = dropdownList => {
  let options: array<SelectBox.dropdownOption> = dropdownList->Array.map((
    item
  ): SelectBox.dropdownOption => {
    let option: SelectBox.dropdownOption = {
      label: item.name,
      value: item.id,
    }
    option
  })
  options
}

let columnGraphTooltipFormatter = (~title, ~metricType) => {
  open ColumnGraphTypes
  open LogicUtils

  (
    @this
    (this: pointFormatter) => {
      let title = `<div style="font-size: 16px; font-weight: bold;">${title}</div>`

      let defaultValue = {color: "", x: "", y: 0.0, point: {index: 0}, key: ""}
      let primartPoint = this.points->getValueFromArray(0, defaultValue)

      let getRowsHtml = (~iconColor, ~date, ~value, ~comparisionComponent="") => {
        let valueString = valueFormatter(value, metricType)
        `<div style="display: flex; align-items: center;">
            <div style="width: 10px; height: 10px; background-color:${iconColor}; border-radius:3px;"></div>
            <div style="margin-left: 8px;">${date}${comparisionComponent}</div>
            <div style="flex: 1; text-align: right; font-weight: bold;margin-left: 25px;">${valueString}</div>
        </div>`
      }

      let tableItems =
        [
          getRowsHtml(~iconColor=primartPoint.color, ~date=primartPoint.key, ~value=primartPoint.y),
        ]->Array.joinWith("")

      let content = `
          <div style=" 
          padding:5px 12px;
          display:flex;
          flex-direction:column;
          justify-content: space-between;
          gap: 7px;">
              ${title}
              <div style="
                margin-top: 5px;
                display:flex;
                flex-direction:column;
                gap: 7px;">
                ${tableItems}
              </div>
        </div>`

      `<div style="
    padding: 10px;
    width:fit-content;
    border-radius: 7px;
    background-color:#FFFFFF;
    padding:10px;
    box-shadow: 0px 4px 8px rgba(0, 0, 0, 0.2);
    border: 1px solid #E5E5E5;
    position:relative;">
        ${content}
    </div>`
    }
  )->asTooltipPointFormatter
}

let stackedBarGraphLabelFormatter = () => {
  open LogicUtils
  open StackedBarGraphTypes

  (
    @this
    (this: StackedBarGraphTypes.labelFormatter) => {
      let name = this.name
      let yData = this.yData->getValueFromArray(0, 0)
      let title = `<div style="font-size: 10px; font-weight: bold;">${name} | ${yData->Int.toString}</div>`
      title
    }
  )->asLabelFormatter
}

let pieGraphLabelFormatter = () => {
  open LogicUtils
  open StackedBarGraphTypes

  (
    @this
    this => {
      let name = this.name
      let yData = this.yData->getValueFromArray(0, 0)
      let title = `<div style="font-size: 10px; font-weight: bold;">${name} | ${yData->Int.toString}</div>`
      title
    }
  )->asLabelFormatter
}
