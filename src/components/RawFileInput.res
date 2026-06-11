open Typography

@react.component
let make = (
  ~buttonText: string,
  ~accept: string,
  ~inputId: string,
  ~onChange: ReactEvent.Form.t => unit,
) => {
  <div className="flex flex-col gap-2">
    <input type_="file" accept hidden=true onChange id={inputId} />
    <label
      htmlFor={inputId}
      className={`inline-flex items-center justify-center px-4 py-2 ${body.sm.medium} text-nd_gray-700 bg-white border border-nd_gray-300 rounded-md hover:bg-nd_gray-50 cursor-pointer transition`}>
      {React.string(buttonText)}
    </label>
  </div>
}
