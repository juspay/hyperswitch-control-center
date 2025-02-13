let config: UIConfig.t = {
  primaryColor: "primary",
  secondaryColor: "secondary",
  backgroundColor: "bg-primary",
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
      borderPrimaryOutlineBorderStyleClass: "border-1",
      borderSecondaryLoadingBorderStyleClass: "border-border_gray",
      borderSecondaryBorderStyleClass: "border-border_gray/20 dark:border-gray-800 /100",
    },
    backgroundColor: {
      primaryNormal: "bg-button-primary-bg  hover:bg-button-primary-hoverbg focus:outline-hidden",
      primaryDisabled: "bg-button-primary-bg  opacity-60 dark:bg-gray-900/50 border dark:border-gray-950/50",
      primaryNoHover: "bg-button-primary-bg  hover:bg-button-primary-hoverbg focus:outline-hidden dark:text-gray-50/50 text-gray-800/50",
      primaryLoading: "bg-button-primary-bg ",
      primaryOutline: "mix-blend-normal",
      paginationNormal: "border-left-1 opacity-80 border-right-1 font-normal border-left-1 text-gray-800/50 hover:text-gray-800 focus:outline-hidden",
      paginationLoading: "border-left-1 border-right-1 font-normal border-left-1 bg-gray-100 dark:bg-gray-500/10",
      paginationDisabled: "border-left-1 border-right-1 font-normal border-left-1 bg-gray-150 dark:bg-gray-900/50 border dark:border-gray-950/50",
      paginationNoHover: "bg-white border-left-1 border-right-1 font-normal text-gray-800/75 hover:text-gray-800 dark:text-gray-50/75",
      dropdownDisabled: "bg-gray-200 dark:bg-gray-900/50 border dark:border-gray-950/50",
      secondaryNormal: "bg-button-secondary-bg hover:bg-button-secondary-hoverbg dark:bg-jp-gray-darkgray_background dark:text-gray-50/50 focus:outline-hidden",
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
      primaryOutline: "text-button-primary-text",
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
      primaryNormal: "focus:shadow-primary",
      primaryFocused: "focus:shadow-primary",
    },
  },
  border: {
    borderColor: {
      primaryNormal: "border border-primary",
      primaryFocused: "focus:border-primary",
    },
  },
  sidebarColor: {
    backgroundColor: {
      sidebarNormal: "bg-sidebar-primary",
      sidebarSecondary: "bg-sidebar-secondary",
    },
    primaryTextColor: "text-sidebar-primaryTextColor",
    secondaryTextColor: "text-sidebar-secondaryTextColor",
    hoverColor: "hover:bg-sidebar-hoverColor",
    borderColor: "border border-sidebar-borderColor",
  },
}
