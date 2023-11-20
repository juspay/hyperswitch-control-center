let getSideBarOptionStyle = (isSelected, isNewTheme) =>
  if isNewTheme {
    if isSelected {
      "text-fs-14 font-bold text-white"
    } else {
      "text-fs-14 font-medium text-jp-2-gray-60"
    }
  } else if isSelected {
    "text-base font-semibold text-black dark:text-jp-gray-text_darktheme"
  } else {
    "text-base font-semibold text-infra-gray-700 dark:text-jp-gray-text_darktheme text-opacity-40 dark:text-opacity-40"
  }

let getSelectedIconColor = (isSelected, isNewTheme) =>
  isNewTheme ? isSelected ? "text-white brightness-200" : "text-jp-2-gray-60" : ""

let defaultIconColor = (isAnySubItemSelected, isNewTheme) =>
  isNewTheme ? isAnySubItemSelected ? "text-white" : "text-jp-2-gray-60" : ""

let getSidebarSubOptionStyle = (isSelected, isNewTheme) =>
  if isNewTheme {
    if isSelected {
      "text-white text-base"
    } else {
      "text-jp-2-gray-60 text-base"
    }
  } else {
    "text-base pl-10"
  }

let textColor = isNewTheme => isNewTheme ? "text-white" : "dark:text-blue-800"

let getIconSize = buttonType => {
  switch buttonType {
  | "small" => 16
  | "medium" => 18
  | _ => 20
  }
}

let hoverColor = (isSelected, isNewTheme) =>
  if isNewTheme {
    `rounded-lg ${!isSelected
        ? "hover:bg-jp-gray-text_darktheme hover:bg-opacity-5"
        : "hover:bg-none"}`
  } else {
    "rounded-lg dark:hover:bg-jp-gray-text_darktheme dark:hover:bg-opacity-5"
  }

let getSelectedClass = (isExpanded, isNewTheme) =>
  if isNewTheme {
    isExpanded ? "bg-sidebar-slected py-1" : ""
  } else {
    "dark:bg-jp-gray-text_darktheme dark:bg-opacity-5"
  }
