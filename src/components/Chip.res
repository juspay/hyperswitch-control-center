@react.component
let make = (~values=[], ~showButton=false, ~onButtonClick=_ => (), ~converterFn=str => str) => {
  <UIUtils.RenderIf condition={values->Array.length !== 0}>
    <div className="flex flex-wrap flex-row">
      {values
      ->Array.map(value => {
        let onClick = _evt => {
          onButtonClick(value)
        }
        <div
          className="px-4 py-2 m-2 mr-0.5 rounded-full border border-gray-300 bg-gradient-to-b from-jp-gray-200 to-jp-gray-300 dark:from-jp-gray-950 dark:to-jp-gray-950 text-gray-500  hover:shadow dark:text-jp-gray-text_darktheme dark:text-opacity-50  flex align-center w-max cursor-pointer  transition duration-300 ease">
          {React.string(value->converterFn)}
          <UIUtils.RenderIf condition={showButton}>
            <div className="float-right cursor-pointer mt-0.5 ml-0.5 opacity-50">
              <Icon className="align-middle" size=14 name="times" onClick />
            </div>
          </UIUtils.RenderIf>
        </div>
      })
      ->React.array}
    </div>
  </UIUtils.RenderIf>
}
