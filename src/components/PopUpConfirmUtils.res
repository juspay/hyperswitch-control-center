let containerBorderRadius = "rounded-xl"

let overlayStyle = "bg-grey-800 bg-opacity-70 backdrop-blur-sm"

let headerStyle = "text-2xl font-semibold"

let subHeaderStyle = "text-md font-medium leading-7 opacity-50 mt-2 w-full"
let modalWidth = "md:w-4/12 md:left-1/3"
let imageStyle = "w-12 h-12 my-auto border-gray-100"
let iconStyle = "align-middle fill-blue-950 self-center"

let getCloseIcon = onClick =>
  <div className="-mt-3 -mr-1" onClick>
    <Icon name="close" className="border-2 p-2 rounded-2xl bg-gray-100 cursor-pointer" size=30 />
  </div>
