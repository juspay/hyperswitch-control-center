module ButtonConfig = {
  type borderRadius = {
    default: string,
    defaultPagination: string,
  }
  type textColor = {primaryOutline: string, primaryNormal: string, primaryDisabled: string}
  type bGcolor = {
    primaryNormal: string,
    primaryDisabled: string,
    primaryNoHover: string,
    primaryOutline: string,
    primaryLoading: string,
    paginationNormal: string,
    paginationLoading: string,
    paginationDisabled: string,
    paginationNoHover: string,
    dropdownDisabled: string,
    secondaryNormal: string,
    secondaryLoading: string,
    secondaryNoHover: string,
  }

  type border = {
    borderFirstWidthClass: string,
    borderLastWidthClass: string,
    borderPrimaryOutlineBorderStyleClass: string,
    borderSecondaryLoadingBorderStyleClass: string,
    borderSecondaryBorderStyleClass: string,
  }

  type height = {
    medium: string,
    xSmall: string,
    small: string,
  }

  type padding = {
    xSmall: string,
    smallPagination: string,
    smallDropdown: string,
    small: string,
    medium: string,
    mediumPagination: string,
    large: string,
    xSmallText: string,
    smallText: string,
    mediumText: string,
    largeText: string,
  }
  type t = {
    height: height,
    padding: padding,
    border: border,
    backgroundColor: bGcolor,
    borderRadius: borderRadius,
    textColor: textColor,
  }
}

module FontConfig = {
  type textColor = {primaryNormal: string}
  type t = {textColor: textColor}
}
module ShadowConfig = {
  type shadowColor = {primaryNormal: string, primaryFocused: string}
  type t = {shadowColor: shadowColor}
}
module BorderConfig = {
  type borderColor = {primaryNormal: string, primaryFocused: string}
  type t = {borderColor: borderColor}
}

module SidebarConfig = {
  type backgroundColor = {primaryNormal: string}
  type t = {backgroundColor: backgroundColor}
}

type t = {
  button: ButtonConfig.t,
  font: FontConfig.t,
  backgroundColor: string,
  primaryColor: string,
  shadow: ShadowConfig.t,
  border: BorderConfig.t,
  sidebarColor: SidebarConfig.t,
}
