let authMethodsToVariantMapper = value => {
  switch value {
  | "password" => #Email_Password
  | "okta" => #Okta
  | "google" => #Google
  | "github" => #Github
  | _ => #Email_Password
  }
}

let getAuthVariants = auth_methods => {
  open LogicUtils
  auth_methods->Array.map(item => {
    let dictFromJson = item->getDictFromJsonObject
    let val: SSOTypes.authMethodResponseType = {
      name: dictFromJson->getString("name", "")->authMethodsToVariantMapper,
      id: dictFromJson->getString("id", ""),
    }
    val
  })
}
