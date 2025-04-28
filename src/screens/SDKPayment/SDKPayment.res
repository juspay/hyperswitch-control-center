@react.component
let make = (~isLoading) => {
  isLoading ? <img alt="blurry-sdk" src={`/assets/BlurrySDK.svg`} /> : React.string("SDK Payment")
}
