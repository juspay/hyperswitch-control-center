let useThemeFormValues = () => {
  let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
    ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
  )

  React.useMemo(() => {
    open LogicUtils
    let formValues = formState.values->getDictFromJsonObject
    let themeName = formValues->getString("theme_name", "Default Theme")
    let themeData = formValues->getDictfromDict("theme_data")
    let settings = themeData->getDictfromDict("settings")

    let colorsDict = settings->getDictfromDict("colors")
    let colors: HyperSwitchConfigTypes.colorPalette = {
      primary: colorsDict->getString("primary", "#006DF9"),
      secondary: colorsDict->getString("secondary", "#303E5F"),
      background: colorsDict->getString("background", "#006df9"),
    }

    let sidebarDict = settings->getDictfromDict("sidebar")
    let sidebar: HyperSwitchConfigTypes.sidebarConfig = {
      primary: sidebarDict->getString("primary", "#FCFCFD"),
      textColor: sidebarDict->getString("textColor", "#525866"),
      textColorPrimary: sidebarDict->getString("textColorPrimary", "#1C6DEA"),
    }

    let buttonsDict = settings->getDictfromDict("buttons")
    let primaryButtonDict = buttonsDict->getDictfromDict("primary")
    let secondaryButtonDict = buttonsDict->getDictfromDict("secondary")

    let buttons: HyperSwitchConfigTypes.buttonConfig = {
      primary: {
        backgroundColor: primaryButtonDict->getString("backgroundColor", "#1272f9"),
        textColor: primaryButtonDict->getString("textColor", "#ffffff"),
        hoverBackgroundColor: primaryButtonDict->getString("hoverBackgroundColor", "#0860dd"),
      },
      secondary: {
        backgroundColor: secondaryButtonDict->getString("backgroundColor", "#f3f3f3"),
        textColor: secondaryButtonDict->getString("textColor", "#626168"),
        hoverBackgroundColor: secondaryButtonDict->getString("hoverBackgroundColor", "#fcfcfd"),
      },
    }

    (themeName, colors, sidebar, buttons)
  }, [formState.values])
}
