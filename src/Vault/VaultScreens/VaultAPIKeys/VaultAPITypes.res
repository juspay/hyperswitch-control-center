type apiKeyExpiryType = Never | Custom

type apiKey = {
  key_id: string,
  name: string,
  description: string,
  prefix: string,
  created: string,
  expiration: apiKeyExpiryType,
  expiration_date: string,
}

type colType =
  | Name
  | Description
  | Prefix
  | Created
  | Expiration
  | CustomCell

type apiModalState = Create | Update | Loading | SettingApiModalError | Success
