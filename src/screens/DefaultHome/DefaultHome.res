@react.component
let make = () => {
  open PageUtils
  open DefaultHomeUtils
  // let count = 0
  // let merchantCount = 1

  <div className="flex flex-1 flex-col gap-8 w-full h-screen items-center">
    <div className="flex flex-col w-full gap-3 items-center justify-center cursor-pointer">
      <PageHeading
        customHeadingStyle="flex flex-col items-center"
        title="Hi, there 👋🏻"
        customTitleStyle="text-fs-32 leading-38 text-center font-semibold"
      />
      /* TODO: TO BE ADDED LATER ONCE SERVICE AND MERCHANT COUNT IS THERE */
      // <div className="font-sm">
      //   <span className="text-nd_gray-400 leading-21 font-medium whitespace-pre">
      //     <span> {count->Int.toString->React.string} </span>
      //     {" Services Connected   |   "->React.string}
      //     <span> {merchantCount->Int.toString->React.string} </span>
      //     {" Merchant ID   "->React.string}
      //   </span>
      //   <span className={"text-primary leading-21 font-semibold"}>
      //     {"Set Up Profile "->React.string}
      //   </span>
      // </div>
    </div>
    <div className="flex gap-4 w-1034-px">
      {defaultHomeActionArray
      ->Array.map(item =>
        <DefaultActionItem
          heading=item.heading description=item.description img=item.imgSrc action=item.action
        />
      )
      ->React.array}
    </div>
    <div className="flex flex-col gap-6">
      <p className="text-fs-20 leading-24 w-1034-px font-semibold">
        {"Explore composable services"->React.string}
      </p>
      <div className="grid grid-cols-2 gap-8">
        {defaultHomeCardsArray
        ->Array.map(item =>
          <DefaultHomeCard
            heading=item.heading description=item.description img=item.imgSrc action=item.action
          />
        )
        ->React.array}
      </div>
    </div>
  </div>
}
