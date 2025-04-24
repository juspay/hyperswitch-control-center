open TypographyType
let createFontStyle = (variant, size, weight) => {
  let fontSize = switch (variant, size) {
  | (Display, Xl) => "text-fs-72 leading-78"
  | (Display, Lg) => "text-fs-64 leading-70"
  | (Display, Md) => "text-fs-56 leading-64"
  | (Display, Sm) => "text-fs-48 leading-56"
  | (Heading, Xxl) => "text-fs-40 leading-46"
  | (Heading, Xl) => "text-fs-32 leading-38"
  | (Heading, Lg) => "text-fs-24 leading-32"
  | (Heading, Md) => "text-fs-20 leading-26"
  | (Heading, Sm) => "text-fs-18 leading-24"
  | (Body, Lg) => "text-fs-16 leading-24"
  | (Body, Md) => "text-fs-14 leading-20"
  | (Body, Sm) => "text-fs-12 leading-18"
  | (Body, Xs) => "text-fs-10 leading-14"
  | (Code, Lg) => "text-fs-14 leading-18"
  | (Code, Md) => "text-fs-12 leading-18"
  | (Code, Sm) => "text-fs-10 leading-14"
  | _ => ""
  }

  let fontWeight = switch weight {
  | SemiBold => "font-semibold"
  | Medium => "font-medium"
  | Regular => "font-normal"
  | Light => "font-light"
  }

  let fontFamily = switch variant {
  | Display | Body => "font-inter-style"
  | Heading
  | Code => "font-jetbrain-mono"
  }

  fontSize ++ " " ++ fontWeight ++ " " ++ fontFamily
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

let typographyTokens: textConfig = {
  display: createSizeStyles(Display),
  heading: createSizeStyles(Heading),
  body: createSizeStyles(Body),
  code: createSizeStyles(Code),
}
