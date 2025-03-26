@react.component
let make = (~setShowOnBoarding, ~currentStep, ~setCurrentStep) => {
  let {setShowSideBar} = React.useContext(GlobalProvider.defaultContext)

  let removeSidebar = () => {
    setShowSideBar(_ => false)
  }

  React.useEffect(() => {
    removeSidebar()
    None
  }, [])

  <ReconConfiguration setShowOnBoarding currentStep setCurrentStep />
}
