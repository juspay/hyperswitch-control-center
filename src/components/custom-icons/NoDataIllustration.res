@react.component
let make = () => {
  let urlPrefix = LogicUtils.useUrlPrefix()

  <img src={`${urlPrefix}/icons/noDataIllustration.svg`} />
}
