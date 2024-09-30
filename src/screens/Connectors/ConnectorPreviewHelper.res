module InfoField = {
  @react.component
  let make = (~label, ~str) => {
    <div>
      <h2 className="text-lg font-semibold"> {label->React.string} </h2>
      <h3 className=" break-words"> {str->React.string} </h3>
    </div>
  }
}

module PreviewCreds = {
  @react.component
  let make = (~connectorAccountFields, ~connectorInfo: ConnectorTypes.connectorPayload) => {
    let label = ""
    let str = ""

    // <div>
    //   <h2 className="text-lg font-semibold"> {label->React.string} </h2>
    //   <h3 className=" break-words"> {str->React.string} </h3>
    // </div>

    {
      switch connectorInfo.account_details {
      | HeaderKey(authKeys) => {
          let json = authKeys->Identity.genericTypeToDictOfJson
        }
      | BodyKey(bodyKey) => ()
      | SignatureKey(signatureKey) => ()
      | MultiAuthKey(multiAuthKey) => ()
      | CurrencyAuthKey(currencyAuthKey) => ()
      | CertificateAuth(certificateAuth) => ()
      | UnKnownAuthType(d) => ()
      }
    }
  }
}
