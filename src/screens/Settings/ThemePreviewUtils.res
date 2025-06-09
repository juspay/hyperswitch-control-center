// ThemePreviewUtils.res
open ThemePreviewTypes
open Typography
let defaultTheme = {
  themeName: "Default Theme",
  primaryColor: "#006DF9",
  sidebar: {
    primary: "#FCFCFD",
    textColor: "#525866",
    textColorPrimary: "#1C6DEA",
  },
  buttons: {
    primary: {
      backgroundColor: "#1272f9",
      textColor: "#ffffff",
      hoverBackgroundColor: "#0860dd",
    },
    secondary: {
      backgroundColor: "#f3f3f3",
      textColor: "#626168",
      hoverBackgroundColor: "#fcfcfd",
    },
  },
  faviconUrl: "",
  logoUrl: "",
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
    <label className="block text-sm font-medium text-gray-700"> {React.string(label)} </label>
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
let infoIcon = () => {
  <div className="w-4 h-4 rounded-full bg-gray-300 flex items-center justify-center cursor-help">
    <span className="text-xs text-gray-600"> {"?"->React.string} </span>
  </div>
}
let renderColorInput = (label: string, value: string, onChange: string => unit) => {
  <div className="space-y-3">
    <div className="flex items-center space-x-2">
      <span className={`${body.md.medium} text-gray-900`}> {React.string(label)} </span>
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

let renderImageUploader = (~asset: string, value: string, onChange: string => unit) => {
  <div className="flex flex-col gap-2">
    <span className={`${body.md.medium} text-gray-700`}> {`${asset} URL`->React.string} </span>
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
        customButtonStyle={`w-20 ${body.md.semibold} py-4`}
      />
    </div>
  </div>
}
