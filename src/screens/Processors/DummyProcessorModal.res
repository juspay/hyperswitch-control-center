open ProcessorCards

@react.component
let make = (
  ~processorModal,
  ~setProcessorModal,
  ~showIcons,
  ~urlPrefix,
  ~configuredConnectors,
  ~connectorsAvailableForIntegration,
) => {
  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let showTestProcessor = featureFlagDetails.testProcessors

  <UIUtils.RenderIf condition={processorModal}>
    <Modal
      modalHeading="Connect a Dummy Processor"
      showModal=processorModal
      setShowModal=setProcessorModal
      modalClass="w-1/2 m-auto">
      <ProcessorCards
        connectorsAvailableForIntegration
        configuredConnectors
        showTestProcessor
        showIcons
        urlPrefix
        showAllConnectors=false
        connectorType=ConnectorTypes.Processor
      />
    </Modal>
  </UIUtils.RenderIf>
}
