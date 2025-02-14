@react.component
let make = (~values=[], ~showButton=false, ~onButtonClick=_ => (), ~converterFn=str => str) => {
  <RenderIf condition={values->Array.length !== 0}>
    <div className="flex flex-wrap flex-row">
      {values
      ->Array.map(value => {
        let onClick = _ => {
          onButtonClick(value)
        }
        <div
          className="px-4 py-2 m-2 mr-0.5 rounded-full border border-gray-300 bg-gradient-to-b from-gray-100 to-gray-150 dark:from-gray-900 dark:to-gray-900 text-gray-500  hover:shadow-sm dark:text-gray-50/50  flex align-center w-max cursor-pointer  transition duration-300 ease">
          {React.string(value->converterFn)}
          <RenderIf condition={showButton}>
            <div className="float-right cursor-pointer mt-0.5 ml-0.5 opacity-50">
              <Icon className="align-middle" size=14 name="times" onClick />
            </div>
          </RenderIf>
        </div>
      })
      ->React.array}
    </div>
  </RenderIf>
}
