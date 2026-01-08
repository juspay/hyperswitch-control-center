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
    id: dict->getOptionString("id"),
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

/*
 Note: This is to show "OR" between the buttons in AuthSelect page 
 Theres a special case where we are not rendering component in case of magic link as login with password handles both 
*/

/* Determines whether a specific auth method should be rendered in the UI. */
let shouldRenderMethod = (
  currentValue: authMethodResponseType,
  authMethods: array<authMethodResponseType>,
  emailFeatureFlagEnabled: bool,
) => {
  switch currentValue.auth_method.\"type" {
  | MAGIC_LINK =>
    emailFeatureFlagEnabled &&
    !(authMethods->Array.some(value => value.auth_method.\"type" == PASSWORD))
  | _ => true
  }
}

/* This check ensures OR is rendered only when there is another visible auth option ahead. */
let checkToRenderOr = (
  authMethods: array<authMethodResponseType>,
  index: int,
  emailFeatureFlagEnabled: bool,
) => {
  authMethods[index]->Option.mapOr(false, currentValue => {
    if !shouldRenderMethod(currentValue, authMethods, emailFeatureFlagEnabled) {
      false
    } else {
      authMethods
      ->Array.sliceToEnd(~start=index + 1)
      ->Array.some(value => shouldRenderMethod(value, authMethods, emailFeatureFlagEnabled))
    }
  })
}
