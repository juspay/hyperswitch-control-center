@react.component
let make = (~setShowOnBoarding) => {
  let {setShowSideBar} = React.useContext(GlobalProvider.defaultContext)

  let goToLanding = () => {
    setShowSideBar(_ => false)
  }

  React.useEffect(() => {
    goToLanding()
    None
  }, [])

  <ReconConfiguration setShowOnBoarding />
}
