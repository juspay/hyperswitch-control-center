type displayOptions = {
  showPageHeading: bool,
  showColumnCustomisation: bool,
  showOMPViews: bool,
  showGenerateReports: bool,
  showSavedViews: bool,
}

let dashboardDisplayOptions = {
  showPageHeading: true,
  showColumnCustomisation: true,
  showOMPViews: true,
  showGenerateReports: true,
  showSavedViews: true,
}

let embeddableDisplayOptions = {
  showPageHeading: false,
  showColumnCustomisation: false,
  showOMPViews: false,
  showGenerateReports: false,
  showSavedViews: false,
}

let displayOptionsContext = React.createContext(dashboardDisplayOptions)

module Provider = {
  let make = React.Context.provider(displayOptionsContext)
}

let useDisplayOptions = () => React.useContext(displayOptionsContext)
