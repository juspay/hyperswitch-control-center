open TypographyTypes
let createFontStyle = (variant, size, weight) => {
  let fontSize = switch variant {
  | Display =>
    switch size {
    | Xl => "text-fs-72 leading-78"
    | Lg => "text-fs-64 leading-70"
    | Md => "text-fs-56 leading-64"
    | Sm => "text-fs-48 leading-56"
    | _ => ""
    }
  | Heading =>
    switch size {
    | Xxl => "text-fs-40 leading-46"
    | Xl => "text-fs-32 leading-38"
    | Lg => "text-fs-24 leading-32"
    | Md => "text-fs-20 leading-26"
    | Sm => "text-fs-18 leading-24"
    | _ => ""
    }
  | Body =>
    switch size {
    | Lg => "text-fs-16 leading-24"
    | Md => "text-fs-14 leading-20"
    | Sm => "text-fs-12 leading-18"
    | Xs => "text-fs-10 leading-14"
    | _ => ""
    }
  | Code =>
    switch size {
    | Lg => "text-fs-14 leading-18"
    | Md => "text-fs-12 leading-18"
    | Sm => "text-fs-10 leading-14"
    | _ => ""
    }
  }

  let fontWeight = switch weight {
  | SemiBold => "font-semibold"
  | Medium => "font-medium"
  | Regular => "font-normal"
  | Light => "font-light"
  }

  let fontFamily = switch variant {
  | Display | Body | Heading => "font-inter-style"
  | Code => "font-jetbrain-mono"
  }

  `${fontSize} ${fontWeight} ${fontFamily}`
}

let createWeightStyles = (variant, size) => {
  {
    semibold: createFontStyle(variant, size, SemiBold),
    medium: createFontStyle(variant, size, Medium),
    regular: createFontStyle(variant, size, Regular),
    light: createFontStyle(variant, size, Light),
  }
}

let createSizeStyles = variant => {
  {
    xxl: createWeightStyles(variant, Xxl),
    xl: createWeightStyles(variant, Xl),
    lg: createWeightStyles(variant, Lg),
    md: createWeightStyles(variant, Md),
    sm: createWeightStyles(variant, Sm),
    xs: createWeightStyles(variant, Xs),
  }
}
