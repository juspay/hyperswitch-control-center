@react.component
let make = () => {
  open APIUtils
  open LogicUtils
  open ReconConfigurationUtils
  open VerticalStepIndicatorTypes
  open ReconConfigurationTypes
  open ReconOnboardingHelper

  let url = RescriptReactRouter.useUrl()
  let (showOnBoarding, setShowOnBoarding) = React.useState(_ => true)
  let (currentStep, setCurrentStep) = React.useState(() => {
    sectionId: (#orderDataConnection: sections :> string),
    subSectionId: None,
  })
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let {activeProduct} = React.useContext(ProductSelectionProvider.defaultContext)
  let getReconStatus = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let url = getURL(
        ~entityName=V1(USERS),
        ~userType=#USER_DATA,
        ~methodType=Post,
        ~queryParamerters=Some("keys=ReconStatus"),
      )
      let res = await fetchDetails(url)
      let reconStatusData =
        res
        ->getArrayDataFromJson(itemToObjMapperForReconStatusData)
        ->getValueFromArray(0, defaultReconStatusData)

      if reconStatusData.is_order_data_set && !reconStatusData.is_processor_data_set {
        setCurrentStep(_ => {
          sectionId: (#connectProcessors: sections :> string),
          subSectionId: None,
        })
      }

      if reconStatusData.is_processor_data_set && reconStatusData.is_order_data_set {
        setCurrentStep(_ => {sectionId: (#finish: sections :> string), subSectionId: None})
        setShowOnBoarding(_ => false)
      }

      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | Exn.Error(_e) => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch Recon Status!"))
    }
  }

  React.useEffect(() => {
    getReconStatus()->ignore
    None
  }, [])

  <PageLoaderWrapper screenState sectionHeight="!h-screen">
    {switch activeProduct {
    | Recon =>
      switch url.path->HSwitchUtils.urlPath {
      | list{"v2", "recon"} => <ReconOnboardingLanding />
      | list{"v2", "recon", "overview"} => <ReconOverviewContainer showOnBoarding />
      | list{"v2", "recon", "configuration"} =>
        <ReconConfigurationContainer setShowOnBoarding currentStep setCurrentStep />
      | list{"v2", "recon", "reports", ..._} => <ReconReportsContainer showOnBoarding />
      | _ => <EmptyPage path="/v2/recon/overview" />
      }
    | _ => React.null
    }}
  </PageLoaderWrapper>
}
