@react.component
let make = (
  ~accept: string,
  ~inputId: string,
  ~onChange: ReactEvent.Form.t => unit,
  ~resetKey: string="0",
) => {
  <>
    <input key={resetKey} type_="file" accept hidden=true onChange id={inputId} />
    <label
      htmlFor={inputId}
      className="w-12 h-12 shrink-0 bg-white border border-dashed border-nd_gray-300 rounded-lg flex items-center justify-center cursor-pointer hover:border-nd_gray-400 transition">
      <Icon name="nd-upload" size=16 className="text-nd_gray-600" />
    </label>
  </>
}
