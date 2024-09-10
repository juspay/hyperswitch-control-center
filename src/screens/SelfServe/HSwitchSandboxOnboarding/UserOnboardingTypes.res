type onboardingSteps =
  ChoosePlan | Connectors | SDKIntegration | IntegrationCheckList | AccountActivation
type languages = [
  | #Node
  | #Ruby
  | #Java
  | #Python
  | #Net
  | #Rust
  | #Shell
  | #HTML
  | #ReactJs
  | #Next
  | #Php
  | #Kotlin
  | #Go
  | #ChooseLanguage
]
type platforms = [#Web | #IOS | #Android | #Woocommerce | #BigCommerce | #ReactNative]
type buildHyperswitchTypes =
  MigrateFromStripe | IntegrateFromScratch | OnboardingDefault | WooCommercePlugin | SampleProjects
type stepperValueType = {
  collapsedText: string,
  renderComponent: React.element,
}

type sectionContentType = {
  headerIcon: string,
  headerText?: string,
  subText?: string,
  buttonText: string,
  customIconCss: string,
  openToNewWindow?: bool,
  url: string,
  isIconImg?: bool,
  imagePath?: string,
  frontEndLang?: string,
  backEndLang?: string,
  subTextCustomValues?: array<string>,
  buttonType?: Button.buttonType,
  displayFrontendLang?: string,
  displayBackendLang?: string,
  isSkipButton?: bool,
  isTileVisible?: bool,
  rightIcon?: React.element,
}
type migratestripecode = {
  from: string,
  to: string,
}
