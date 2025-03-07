open LogicUtils
open LogicUtilsTypes

module Card = {
  type props = {
    title: string,
    description: string,
    value: float,
    statType: valueType,
  }

  let make = (props: props) => {
    let valueString = valueFormatter(props.value, props.statType)
    <div className="bg-white border rounded-lg p-4">
      <div className="flex flex-col justify-between items-start gap-3">
        <div className="text-2xl font-bold text-gray-800"> {valueString->React.string} </div>
        <div className="flex flex-row items-center gap-4">
          <div className="text-sm font-medium text-gray-500"> {props.title->React.string} </div>
          <ToolTip description={props.title} toolTipPosition={ToolTip.Top} />
        </div>
      </div>
    </div>
  }
}
