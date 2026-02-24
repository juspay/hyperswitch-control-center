let getEntityTypeFromStep = stepNum =>
  switch stepNum {
  | 1 => "organization"
  | 2 => "merchant"
  | 3 => "profile"
  | _ => ""
  }
