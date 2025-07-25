type weight = SemiBold | Medium | Regular | Light | Bold
type size = Xxl | Xl | Lg | Md | Sm | Xs
type variant = Display | Heading | Body | Code

type fontStyle = string

type weightStyles = {
  semibold: fontStyle,
  medium: fontStyle,
  regular: fontStyle,
  light: fontStyle,
  bold: fontStyle,
}

type sizeStyles = {
  xxl: weightStyles,
  xl: weightStyles,
  lg: weightStyles,
  md: weightStyles,
  sm: weightStyles,
  xs: weightStyles,
}
