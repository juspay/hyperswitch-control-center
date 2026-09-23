open Typography

module FormSection = {
  @react.component
  let make = (~title, ~children) => {
    <div className="flex flex-col gap-4">
      <div className={`${heading.sm.semibold} text-nd_gray-700`}> {title->React.string} </div>
      <div className="flex flex-col gap-4 border border-nd_gray-150 bg-white rounded-xl p-5">
        children
      </div>
    </div>
  }
}

module FieldRow = {
  @react.component
  let make = (~fields) => {
    <div className="grid grid-cols-1 md:grid-cols-2 gap-x-8 gap-y-2">
      {fields
      ->Array.mapWithIndex((field, index) =>
        <FormRenderer.FieldRenderer key={index->Int.toString} field fieldWrapperClass="w-full" />
      )
      ->React.array}
    </div>
  }
}
