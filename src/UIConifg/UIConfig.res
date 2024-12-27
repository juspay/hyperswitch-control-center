module ButtonConfig = {
  type borderRadius = {
    default: string,
    defaultPagination: string,
  }
  type textColor = {
    primaryOutline: string,
    primaryNormal: string,
    primaryDisabled: string,
    secondaryNormal: string,
    secondaryLoading: string,
    secondaryDisabled: string,
    secondaryNoBorder: string,
  }
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
    secondaryNoBorder: string,
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
  type backgroundColor = {sidebarNormal: string}
  type t = {backgroundColor: backgroundColor}
}

type t = {
  button: ButtonConfig.t,
  font: FontConfig.t,
  backgroundColor: string,
  primaryColor: string,
  secondaryColor: string,
  shadow: ShadowConfig.t,
  border: BorderConfig.t,
  sidebarColor: SidebarConfig.t,
}

let defaultUIConfig: t = {
  backgroundColor: "bg-background",
  button: {
    height: {
      medium: "h-fit",
      xSmall: "h-fit",
      small: "h-fit",
    },
    padding: {
      xSmall: "py-3 px-4",
      small: "py-3 px-4",
      smallPagination: "py-3 px-4 mr-1",
      smallDropdown: "py-3 px-4",
      medium: "py-3 px-4",
      mediumPagination: "py-3 px-4 mr-1",
      large: "py-3 px-4",
      xSmallText: "px-1",
      smallText: "px-1",
      mediumText: "px-1",
      largeText: "px-1",
    },
    border: {
      borderFirstWidthClass: "border focus:border-r",
      borderLastWidthClass: "border  focus:border-l",
      borderPrimaryOutlineBorderStyleClass: "border-1 border-blue-800",
      borderSecondaryLoadingBorderStyleClass: "border-border_gray",
      borderSecondaryBorderStyleClass: "border-border_gray border-opacity-20 dark:border-jp-gray-960 dark:border-opacity-100",
    },
    backgroundColor: {
      primaryNormal: "bg-button-primary-bg  hover:bg-button-primary-hoverbg focus:outline-none",
      primaryDisabled: "bg-button-primary-bg  opacity-60 dark:bg-jp-gray-950 dark:bg-opacity-50 border dark:border-jp-gray-disabled_border dark:border-opacity-50",
      primaryNoHover: "bg-button-primary-bg  hover:bg-button-primary-hoverbg focus:outline-none dark:text-opacity-50 text-opacity-50",
      primaryLoading: "bg-button-primary-bg ",
      primaryOutline: "mix-blend-normal",
      paginationNormal: "border-left-1 opacity-80 border-right-1 font-normal border-left-1 text-jp-gray-900 text-opacity-50 hover:text-jp-gray-900 focus:outline-none",
      paginationLoading: "border-left-1 border-right-1 font-normal border-left-1 bg-jp-gray-200 dark:bg-jp-gray-800 dark:bg-opacity-10",
      paginationDisabled: "border-left-1 border-right-1 font-normal border-left-1 bg-jp-gray-300 dark:bg-jp-gray-950 dark:bg-opacity-50 border dark:border-jp-gray-disabled_border dark:border-opacity-50",
      paginationNoHover: "bg-white border-left-1 border-right-1 font-normal text-jp-gray-900 text-opacity-75 hover:text-jp-gray-900 dark:text-jp-gray-text_darktheme dark:text-opacity-75",
      dropdownDisabled: "bg-gray-200 dark:bg-jp-gray-950 dark:bg-opacity-50 border dark:border-jp-gray-disabled_border dark:border-opacity-50",
      secondaryNormal: "bg-button-secondary-bg text-jp-gray-900 text-opacity-75 hover:bg-button-secondary-hoverbg hover:text-jp-gray-890  dark:bg-jp-gray-darkgray_background  dark:text-jp-gray-text_darktheme dark:text-opacity-50 focus:outline-none",
      secondaryNoBorder: "hover:bg-jp-gray-lightmode_steelgray hover:bg-opacity-40 dark:bg-jp-gray-darkgray_background dark:text-jp-gray-text_darktheme dark:text-opacity-50 dark:hover:bg-jp-gray-950 focus:outline-none",
      secondaryLoading: "bg-button-secondary-bg  dark:bg-jp-gray-darkgray_background",
      secondaryNoHover: "bg-button-secondary-bg text-jp-gray-900 text-opacity-50  hover:bg-button-secondary-hoverbg hover:text-jp-gray-890  dark:bg-jp-gray-darkgray_background dark:text-jp-gray-text_darktheme focus:outline-none dark:text-opacity-50 ",
    },
    borderRadius: {
      default: "rounded",
      defaultPagination: "rounded-md",
    },
    textColor: {
      primaryNormal: "text-white",
      primaryOutline: "text-button-primary-text",
      primaryDisabled: "text-jp-gray-600 dark:text-jp-gray-text_darktheme dark:text-opacity-25",
      secondaryNormal: "text-button-secondary-text hover:text-black dark:text-jp-gray-text_darktheme dark:hover:text-jp-gray-text_darktheme dark:hover:text-opacity-75",
      secondaryNoBorder: "text-jp-gray-900 ",
      secondaryLoading: "text-button-secondary-text hover:text-black dark:text-jp-gray-text_darktheme dark:text-opacity-75",
      secondaryDisabled: "text-jp-gray-600 dark:text-jp-gray-text_darktheme dark:text-opacity-25",
    },
  },
  font: {
    textColor: {
      primaryNormal: "text-typography",
    },
  },
  shadow: {
    shadowColor: {
      primaryNormal: "shadow-primary",
      primaryFocused: "focus:shadow-primary",
    },
  },
  border: {
    borderColor: {
      primaryNormal: "border border-outline",
      primaryFocused: "focus:border-outline",
    },
  },
  primaryColor: "primary",
  secondaryColor: "secondary",
  sidebarColor: {
    backgroundColor: {
      sidebarNormal: "bg-sidebar",
    },
  },
}
