open VaultAPIKeysHelper

@react.component
let make = () => {
  <div>
    <PageUtils.PageHeading
      title="API Keys" subTitle="Manage API keys and credentials for integrated payment services"
    />
    <PublishableAndHashKeySection />
    <ApiKeysTable />
  </div>
}
