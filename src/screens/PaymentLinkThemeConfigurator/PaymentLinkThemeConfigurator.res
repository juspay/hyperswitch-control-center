@react.component
let make = () => {
  <div className="flex flex-col gap-8">
    <PageUtils.PageHeading
      title="Payment Link Theme Configuration" subTitle="Configure and Preview payment link theme"
    />
    <PaymentLinkThemeConfiguratorTool />
  </div>
}
