@react.component
let make = (~currency) => {
  let appPrefix = LogicUtils.useUrlPrefix()
  <div className="flex flex-col justify-left mt-2" style={ReactDOMStyle.make(~width="100%", ())}>
    <h1
      className="text-xl mb-4" style={ReactDOMStyle.make(~marginLeft="15px", ~fontSize="20sp", ())}>
      {"Order Summary"->React.string}
    </h1>
    <div style={ReactDOMStyle.make(~fontWeight="400", ~fontSize="14px", ~textAlign="initial", ())}>
      <div className="flex flex-row justify-between h-auto ">
        <div className="flex flex-row w-3/4">
          <div className="w-full">
            <img
              className="w-15 h-15 my-auto border-gray-100 ml-3"
              src={`${appPrefix}/icons/tshirt.svg`}
              alt="tshirt"
            />
          </div>
          <div className="p-1 mr-8">
            <div
              className="flex not-italic font-bold text-xl pb-1 text-[#212529]"
              style={ReactDOMStyle.make(
                ~marginTop="8px",
                ~fontWeight="500",
                ~fontSize="16px",
                ~textAlign="initial",
                (),
              )}>
              {"HS Tshirt"->React.string}
            </div>
            <div className="text-start flex flex-row pb-1 gap-2">
              <div className="text-gray-400"> {"Size: "->React.string} </div>
              <span className="text-[#212121]"> {37->React.int} </span>
              <div className="text-gray-400" style={ReactDOMStyle.make(~marginLeft="15px", ())}>
                {"Qty:"->React.string}
              </div>
              <span className=" text-[#212121]"> {1->React.int} </span>
            </div>
          </div>
        </div>
        <div
          style={ReactDOMStyle.make(
            ~textAlign="initial",
            ~paddingRight="20px",
            ~marginTop="15px",
            (),
          )}>
          {`${currency} 654`->React.string}
        </div>
      </div>
      <hr className="mt-2" />
      <div className="flex flex-row justify-between h-auto p-3">
        <div className="font-normal text-base text-[#000000]"> {"Total Amount"->React.string} </div>
        <div className="font-bold mr-2"> {`${currency} 654`->React.string} </div>
      </div>
    </div>
  </div>
}
