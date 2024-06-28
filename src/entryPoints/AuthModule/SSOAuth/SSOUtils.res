open SSOTypes

let authMethodsNameToVariantMapper = value => {
  switch value->String.toLowerCase {
  | "password" => #Password
  | "magic_link" => #Magic_Link
  | "okta" => #Okta
  | "google" => #Google
  | "github" => #Github
  | _ => #Password
  }
}
let authMethodsTypeToVariantMapper = value => {
  switch value->String.toLowerCase {
  | "password" => PASSWORD
  | "magic_link" => MAGIC_LINK
  | "open_id_connect" => OPEN_ID_CONNECT
  | _ => PASSWORD
  }
}

let getTypedValueFromResponse: Dict.t<JSON.t> => SSOTypes.authMethodResponseType = dict => {
  open LogicUtils
  let authMethodsDict = dict->getDictfromDict("auth_method")
  {
    id: dict->getString("id", ""),
    auth_id: dict->getString("auth_id", ""),
    auth_method: {
      \"type": authMethodsDict->getString("type", "")->authMethodsTypeToVariantMapper,
      name: {
        let name = authMethodsDict->getOptionString("name")
        switch name {
        | Some(value) => value->authMethodsNameToVariantMapper
        | None => authMethodsDict->getString("type", "")->authMethodsNameToVariantMapper
        }
      },
    },
    allow_signup: dict->getBool("allow_signup", false),
  }
}

let getAuthVariants = auth_methods => {
  open LogicUtils
  auth_methods->Array.map(item => {
    let dictFromJson = item->getDictFromJsonObject
    dictFromJson->getTypedValueFromResponse
  })
}

let ssoDefaultValue = (values: AuthProviderTypes.preLoginType): AuthProviderTypes.preLoginType => {
  {
    token: values.token,
    token_type: "sso",
    email_token: values.email_token,
  }
}
