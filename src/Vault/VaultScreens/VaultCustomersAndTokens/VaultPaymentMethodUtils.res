type status = Enabled | Disabled

type connectorTokenStatus = Active | Inactive

let statusToVariantMapper = (status: string) => {
  switch status {
  | "ENABLED" => Enabled
  | "DISABLED" => Disabled
  | _ => Disabled
  }
}

let connectrTokensStatusToVariantMapper = (connectorTokenStatus: string) => {
  switch connectorTokenStatus->String.toLowerCase {
  | "active" => Active
  | "inactive" => Inactive
  | _ => Inactive
  }
}
