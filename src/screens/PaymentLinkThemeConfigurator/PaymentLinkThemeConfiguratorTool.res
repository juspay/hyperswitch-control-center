@react.component
let make = () => {
  open LogicUtils
  let (_availableStyles, setAvailableStyles) = React.useState(_ => [])
  let businessProfileRecoilVal = Recoil.useRecoilValueFromAtom(
    HyperswitchAtom.businessProfileFromIdAtom,
  )

  React.useEffect(() => {
    let defaultPaymentLinkConfigValues = switch businessProfileRecoilVal.payment_link_config {
    | Some(config) => config
    | None => BusinessProfileMapper.paymentLinkConfigMapper(Dict.make())
    }

    let stylesDict = defaultPaymentLinkConfigValues.business_specific_configs
    let styles = getDictFromJsonObject(stylesDict)->Dict.keysToArray

    setAvailableStyles(_ =>
      styles->Array.map(
        styleId => {
          let dropdownOption: SelectBox.dropdownOption = {
            label: styleId,
            value: styleId,
          }
          dropdownOption
        },
      )
    )
    None
  }, [businessProfileRecoilVal])

  <div> {"Payment Link Theme Configurator Tool"->React.string} </div>
}
