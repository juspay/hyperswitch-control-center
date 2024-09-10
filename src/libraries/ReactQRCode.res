@module("react-qr-code") @react.component
external make: (
  ~value: string=?,
  ~style: string=?,
  ~size: int=?,
  ~viewBox: string=?,
) => React.element = "default"
