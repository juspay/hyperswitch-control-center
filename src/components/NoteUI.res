@react.component
let make = (~note: string, ~isInfo=false, ~textSize="text-fs-12") => {
  <div
    className={`ml-6 ${textSize} mb-5 block p-2 not-italic font-normal text-black dark:text-white bg-blue-info dark:bg-blue-info dark:bg-opacity-20`}
    style={ReactDOMStyle.make(~borderLeft="6px solid #2196F3", ~maxWidth="max-content", ())}>
    <div className="flex flex-row gap-2"> {note->React.string} </div>
  </div>
}
