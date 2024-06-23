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
  auth_methods->Array.map(item => {
    item->authMethodsToVariantMapper
  })
}
