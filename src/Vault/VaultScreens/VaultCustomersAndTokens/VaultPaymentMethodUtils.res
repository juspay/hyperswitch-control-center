type status = Enabled | Disabled

let statusToVariantMapper = (status: string) => {
  switch status {
  | "ENABLED" => Enabled
  | "DISABLED" => Disabled
  | _ => Disabled
  }
}
