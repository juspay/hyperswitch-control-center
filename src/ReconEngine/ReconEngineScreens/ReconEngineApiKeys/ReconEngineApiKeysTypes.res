type expiration = Never | DateTime(string)

type expirationChoice =
  | @as("never") NeverExpires
  | @as("custom") CustomDate

type apiKeyStatus =
  | @as("active") Active
  | @as("revoked") Revoked
  | @as("expired") Expired
  | @as("unknown") UnknownStatus

type apiKey = {
  id: string,
  name: string,
  description: string,
  prefix: string,
  status: apiKeyStatus,
  createdAt: string,
  expiresAt: expiration,
}

type action = Edit | Revoke
