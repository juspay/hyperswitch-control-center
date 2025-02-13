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
  type backgroundColor = {sidebarNormal: string, sidebarSecondary: string}
  type t = {
    backgroundColor: backgroundColor,
    primaryTextColor: string,
    secondaryTextColor: string,
    hoverColor: string,
    borderColor: string,
  }
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
      borderPrimaryOutlineBorderStyleClass: "border-1 border-primary-blue-50",
      borderSecondaryLoadingBorderStyleClass: "border-border_gray",
      borderSecondaryBorderStyleClass: "border-border_gray/20 dark:border-gray-800/100",
    },
    backgroundColor: {
      primaryNormal: "border-1.5 border-double border-transparent text-button-primary-text primary-gradient-button",
      primaryDisabled: "bg-button-primary-bg primary-gradient-button opacity-60 dark:bg-gray-900/50 dark:border-gray-950/50",
      primaryNoHover: "bg-button-primary-bg  hover:bg-button-primary-hoverbg focus:outline-hidden dark:text-gray-50/50 text-gray-800/50",
      primaryLoading: "bg-button-primary-bg ",
      primaryOutline: "mix-blend-normal border-primary",
      paginationNormal: "font-medium border-transparent text-gray-500  focus:outline-hidden text-gray-500",
      paginationLoading: "border-left-1 border-right-1 font-normal border-left-1 bg-gray-100 dark:bg-gray-500/10",
      paginationDisabled: "border-left-1 border-right-1 font-normal border-left-1  dark:bg-gray-900/50  dark:border-gray-950/50",
      paginationNoHover: "font-medium text-primary/1 hover:text-primary/70 bg-primary/10 border-transparent font-medium  dark:text-gray-50/75",
      dropdownDisabled: "bg-gray-200 dark:bg-gray-900/50 border dark:border-gray-950/50",
      secondaryNormal: "border-1.5 border-double border-transparent text-button-secondary-text secondary-gradient-border",
      secondaryNoBorder: "hover:bg-jp-gray-steel/40 dark:bg-jp-gray-darkgray_background dark:text-gray-50/50 dark:hover:bg-gray-900 focus:outline-hidden",
      secondaryLoading: "bg-button-secondary-bg  dark:bg-jp-gray-darkgray_background",
      secondaryNoHover: "bg-button-secondary-bg text-gray-800/50 hover:bg-button-secondary-hoverbg dark:bg-jp-gray-darkgray_background dark:text-gray-50/50 focus:outline-hidden",
    },
    borderRadius: {
      default: "rounded",
      defaultPagination: "rounded-md",
    },
    textColor: {
      primaryNormal: "text-button-primary-text",
      primaryOutline: "text-primary",
      primaryDisabled: "text-gray-300 dark:text-gray-50/25",
      secondaryNormal: "text-button-secondary-text dark:text-gray-50 dark:hover:text-gray-50/75",
      secondaryNoBorder: "text-gray-800 ",
      secondaryLoading: "text-button-secondary-text dark:text-gray-50/75",
      secondaryDisabled: "text-gray-300 dark:text-gray-50/25",
    },
  },
  font: {
    textColor: {
      primaryNormal: "text-primary",
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
  primaryColor: "bg-primary",
  secondaryColor: "bg-secondary",
  sidebarColor: {
    backgroundColor: {
      sidebarNormal: "bg-sidebar-primary",
      sidebarSecondary: "bg-sidebar-secondary md:bg-sidebar-secondary ",
    },
    primaryTextColor: "text-sidebar-primaryTextColor",
    secondaryTextColor: "text-sidebar-secondaryTextColor",
    hoverColor: "hover:bg-sidebar-hoverColor/20",
    borderColor: "border-sidebar-borderColor",
  },
}
