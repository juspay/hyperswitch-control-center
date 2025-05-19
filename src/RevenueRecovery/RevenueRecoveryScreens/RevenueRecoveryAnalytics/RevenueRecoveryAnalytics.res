@react.component
let make = () => {
  let customTitleStyle = "py-0 !pt-0"

  <div className={`flex flex-col mx-auto h-full w-full min-h-[50vh]`}>
    <div className="flex justify-between items-center">
      <PageUtils.PageHeading
        title="Overview" subTitle="Viewing data of: April, 2025" customTitleStyle
      />
    </div>
  </div>
}
