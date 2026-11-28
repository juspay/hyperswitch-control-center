type resourceType = | @as("apple_pay_certificate") ApplePay | @as("google_pay") GooglePay

type step = ChooseType | ApplePayDownload | ApplePayUpload | GooglePayGenerate

type csrState =
  | NotGenerated
  | Generating
  | Generated({resourceId: string, csr: string})

type googlePayKeyState =
  | KeyNotGenerated
  | KeyGenerating
  | KeyGenerated({publicKey: string})

type selectedFile = {name: string, base64: string}

type resourceRequestorType = [#MerchantConnectorAccount | #Profile | #MerchantAccount]

type linkScope = Merchant | Profile

type resourceSummary = {
  id: string,
  displaySchema: Dict.t<JSON.t>,
  displayData: Dict.t<JSON.t>,
  createdAt: string,
  isLinked: bool,
}
