@react.component
let make = (~setShowOnBoarding) => {
  let {setShowSideBar} = React.useContext(GlobalProvider.defaultContext)

  let removeSidebar = () => {
    setShowSideBar(_ => false)
  }

  React.useEffect(() => {
    removeSidebar()
    None
  }, [])

  <ReconConfiguration setShowOnBoarding />
}
