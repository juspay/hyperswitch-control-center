open ThemePreviewTypes
open Typography
let defaultTheme = ThemeProvider.newDefaultConfig
let renderInfoIcon = (~info) => {
  <ToolTip
    description=info
    toolTipFor={<Icon name="question-circle-unfilled" size=14 />}
    toolTipPosition=ToolTip.Right
  />
}
let sidebarItems = [
  {label: "Module Name", active: false},
  {label: "Section #1", active: false},
  {label: "Section #2", active: true},
  {label: "Section #3", active: false},
]
let inputClassCSS = `flex-1 px-3 py-2 border border-nd_br_gray-200 text-nd_gray-600 rounded-md focus:outline-none focus:ring-1 focus:ring-blue-500 shadow-sm ${body.md.medium}`
let renderTextInput = (label: string, value: string, onChange: string => unit) => {
  <div className="flex flex-col gap-2">
    <div className="flex flex-row gap-2 items-center">
      <span className={`${body.md.medium} text-gray-700`}> {React.string(label)} </span>
      {renderInfoIcon(~info=`Enter a name for your theme.`)}
    </div>
    <input
      type_="text"
      value
      onChange={e => {
        let target = ReactEvent.Form.target(e)
        onChange(target["value"])
      }}
      className={`${inputClassCSS}`}
      placeholder="Enter theme name"
    />
  </div>
}

let renderColorInput = (label: string, value: string, onChange: string => unit) => {
  <div className="space-y-3">
    <div className="flex items-center space-x-2">
      <div className="flex flex-row gap-2 items-center">
        <span className={`${body.md.medium} text-gray-900`}> {React.string(label)} </span>
        {renderInfoIcon(~info=`This will effect your ${label}`)}
      </div>
    </div>
    <div className="relative">
      <div
        className="flex items-center bg-white border border-gray-200 rounded-lg overflow-hidden shadow-sm hover:border-gray-300 transition-colors">
        <div className="flex items-center px-3 py-2 border-gray-200">
          <div
            className="w-6 h-6 rounded border border-gray-200 shadow-sm cursor-pointer"
            style={ReactDOM.Style.make(~backgroundColor=value, ())}
          />
        </div>
        <input
          type_="color"
          value
          onChange={e => {
            let target = ReactEvent.Form.target(e)
            onChange(target["value"])
          }}
          className="absolute opacity-0 cursor-pointer"
        />
        <input
          type_="text"
          value
          onChange={e => {
            let target = ReactEvent.Form.target(e)
            onChange(target["value"])
          }}
          className={`flex-1 ${body.md.medium} text-nd_gray-600 outline-none focus:ring-0`}
          placeholder="#1C6DEA"
        />
      </div>
    </div>
  </div>
}

let renderImageUploader = (~asset: string, value: option<string>, onChange) => {
  let value = value->Option.getOr("")
  <div className="flex flex-col gap-2">
    <div className="flex flex-row gap-2 items-center">
      <span className={`${body.md.medium} text-gray-700`}> {`${asset} URL`->React.string} </span>
      {renderInfoIcon(~info=`Provide a URL to your ${asset} image.`)}
    </div>
    <div className="flex items-center gap-3">
      <input
        type_="url"
        value
        onChange={e => {
          let target = ReactEvent.Form.target(e)
          onChange(target["value"])
        }}
        className={`${inputClassCSS}`}
        placeholder={`Enter your ${asset} URL`}
      />
      <Button
        text="Upload"
        buttonType=Secondary
        buttonState=Normal
        buttonSize=Small
        customButtonStyle={`w-20 ${body.sm.semibold} py-4`}
      />
    </div>
  </div>
}
