type step = Download | Upload

type csrState =
  | NotGenerated
  | Generating
  | Generated({resourceId: string, csr: string})

type selectedFile = {name: string, base64: string}

type resourceRequestorType = MerchantConnectorAccount | Profile | MerchantAccount
type resourceSummary = {
  id: string,
  displaySchema: Dict.t<JSON.t>,
  displayData: Dict.t<JSON.t>,
  createdAt: string,
  isLinked: bool,
}
