module InfoSection = {
  @react.component
  let make = () => {
    <div className="w-full px-7 py-8">
      <div className="flex flex-col gap-2 ">
        <div className="text-3xl font-[600]"> {"165K"->React.string} </div>
      </div>
    </div>
  }
}

module NoteSection = {
  @react.component
  let make = () => {
    <div className="w-fit m-7 py-3 px-4 bg-[#F7D59B4D] rounded-lg flex gap-2 font-medium">
      <Icon name="info-vacent " size=16 />
      <p className="text-[#474D59] text-sm">
        {"Highest amount received was USD9,700 for the month of Aug. Lowest amount issued was ₹2,900 for the month of Aug"->React.string}
      </p>
    </div>
  }
}

@react.component
let make = () => {
  open GraphUtils
  open Highcharts
  open LineGraphUtils

  <div>
    <h2 className="font-[600] text-xl text-[#333333] pb-5">
      {"Payments Processed"->React.string}
    </h2>
    <Card>
      <InfoSection />
      <Chart options highcharts />
      <NoteSection />
    </Card>
  </div>
}
