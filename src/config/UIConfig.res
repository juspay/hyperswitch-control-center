module ButtonConfig = {
  type borderRadius = {
    default: string,
    defaultPagination: string,
  }
  type textColor = {primaryOutline: string}
  type bGcolor = {
    primaryNormal: string,
    primaryDisabled: string,
    primaryNoHover: string,
    primaryOutline: string,
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

type t = {button: ButtonConfig.t}

let defaultUIConfig: t = {
  button: {
    height: {
      medium: "h-12",
      xSmall: "h-8",
      small: "h-10",
    },
    padding: {
      xSmall: "px-1",
      smallPagination: "px-2",
      smallDropdown: "px-2",
      small: "px-2",
      medium: "px-3",
      mediumPagination: "px-3",
      large: "",
      xSmallText: "px-3",
      smallText: "px-2",
      mediumText: "px-1",
      largeText: "px-4",
    },
    border: {
      borderFirstWidthClass: "border border-r-0 focus:border-r",
      borderLastWidthClass: "border border-l-0 focus:border-l",
      borderPrimaryOutlineBorderStyleClass: "border-[1px] border-[#0099FF]",
      borderSecondaryLoadingBorderStyleClass: "border-jp-gray-950 border-opacity-20 dark:border-jp-gray-960 dark:border-opacity-100",
      borderSecondaryBorderStyleClass: "border-jp-gray-950 border-opacity-20 dark:border-jp-gray-960 dark:border-opacity-100",
    },
    backgroundColor: {
      primaryNormal: "bg-blue-900 hover:shadow hover:shadow-blue-900/50 hover:from-blue-750 hover:to-blue-900 focus:outline-none",
      primaryDisabled: "bg-jp-gray-300 dark:bg-jp-gray-950 dark:bg-opacity-50 border dark:border-jp-gray-disabled_border dark:border-opacity-50",
      primaryNoHover: "bg-blue-900 hover:shadow hover:shadow-blue-900/50 hover:from-blue-750 hover:to-blue-900 focus:outline-none",
      primaryOutline: "mix-blend-normal bg-[rgba(0,153,255,0.08)]",
      paginationNormal: "border-left-1 border-right-1 font-normal border-left-1 text-jp-gray-900 text-opacity-50 hover:text-jp-gray-900 bg-gradient-to-b from-jp-gray-450 to-jp-gray-350 dark:from-jp-gray-950 dark:to-jp-gray-950 dark:text-jp-gray-text_darktheme dark:text-opacity-50 focus:outline-none",
      paginationLoading: "border-left-1 border-right-1 font-normal border-left-1 bg-jp-gray-200 dark:bg-jp-gray-800 dark:bg-opacity-10",
      paginationDisabled: "border-left-1 border-right-1 font-normal border-left-1 bg-jp-gray-300 dark:bg-jp-gray-950 dark:bg-opacity-50 border dark:border-jp-gray-disabled_border dark:border-opacity-50",
      paginationNoHover: "border-left-1 border-right-1 font-normal border-left-1 text-jp-gray-900 text-opacity-75 hover:text-jp-gray-900 bg-gradient-to-b from-jp-gray-450 to-jp-gray-300 dark:from-jp-gray-900 dark:to-jp-gray-950 dark:text-jp-gray-text_darktheme dark:text-opacity-75",
      dropdownDisabled: "focus:outline-none dark:active:shadow-none",
      secondaryNormal: "bg-white text-jp-gray-900 text-opacity-75 hover:shadow hover:text-jp-gray-900 hover:text-opacity-75 dark:bg-jp-gray-darkgray_background dark:hover:bg-jp-gray-950 dark:text-jp-gray-text_darktheme dark:text-opacity-50 focus:outline-none",
      secondaryLoading: "bg-white dark:bg-jp-gray-darkgray_background",
      secondaryNoHover: "bg-white text-jp-gray-900 text-opacity-50 hover:shadow hover:text-opacity-75 dark:bg-jp-gray-darkgray_background dark:text-jp-gray-text_darktheme focus:outline-none dark:text-opacity-50 ",
    },
    borderRadius: {
      default: "rounded-md",
      defaultPagination: "",
    },
    textColor: {
      primaryOutline: "text-[#0099FF]",
    },
  },
}
