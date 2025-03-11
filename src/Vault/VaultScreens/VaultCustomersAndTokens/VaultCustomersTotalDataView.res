module TotalNumbersViewCard = {
  @react.component
  let make = (~title, ~count) => {
    <div
      className={`flex flex-col justify-center  gap-1 bg-white text-semibold border rounded-md pt-3 px-4 pb-2.5 w-306-px my-8 cursor-pointer hover:bg-gray-50 border-nd_gray-150`}>
      <p className="font-medium text-xs text-nd_gray-400"> {title->React.string} </p>
      <RenderIf condition={!(count->LogicUtils.isEmptyString)}>
        <p className="font-semibold text-2xl text-nd_gray-600"> {count->React.string} </p>
      </RenderIf>
    </div>
  }
}

@react.component
let make = () => {
  <div className="flex flex-row gap-2">
    <TotalNumbersViewCard title="Total Customers" count="10" />
    <TotalNumbersViewCard title="Total Vaulted Payment Methods" count="20" />
  </div>
}
