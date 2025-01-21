module AnalyticsCard = {
  @react.component
  let make = (~title: string, ~value: option<string>) => {
    <div className="bg-white border rounded-lg p-6">
      <div className="flex flex-col justify-between items-center gap-4">
        <div className="text-sm font-medium text-gray-600 flex gap-2">
          <p> {title->React.string} </p>
          <Icon name="info-vacent" className="text-gray-400" />
        </div>
        <div className="text-2xl font-bold text-gray-800">
          {value->Option.getOr("0")->React.string}
        </div>
      </div>
    </div>
  }
}
