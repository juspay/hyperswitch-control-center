@react.component
let make = (~value: string, ~setValue: (string => string) => unit, ~hasError: bool=false) => {
  let isBlendEnabled = BlendContext.useBlendEnabled()

  if isBlendEnabled {
    <div className="flex justify-center">
      <OTPInputBinding value onChange={str => setValue(_ => str)} error=hasError length=6 />
    </div>
  } else {
    <OtpInput value setValue hasError />
  }
}
