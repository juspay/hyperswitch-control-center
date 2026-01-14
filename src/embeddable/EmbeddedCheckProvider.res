@react.component
let make = (~children) => {
  open Typography
  let isEmbeddable = (): bool => {
    Window.self !== Window.top
  }
  let isInIframe = isEmbeddable()
  if isInIframe {
    children
  } else {
    <div className="h-screen w-screen flex justify-center items-center p-4">
      <div className="max-w-lg w-full rounded-lg shadow-md border border-nd_gray-200 p-8">
        <div className="flex flex-col items-center text-center">
          <div className="mb-6">
            <Icon name="exclamation-circle" size=25 className="text-blue-500" />
          </div>
          <div className={`${heading.md.semibold} text-nd_gray-800 mb-3`}>
            {"Embedded Access Required"->React.string}
          </div>
          <div className={`${body.md.regular} text-nd_gray-600 leading-relaxed`}>
            {"Direct access isn't supported for this application. Please open it through the embedded interface in your platform."->React.string}
          </div>
        </div>
      </div>
    </div>
  }
}
