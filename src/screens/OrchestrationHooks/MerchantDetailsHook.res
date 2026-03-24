open HyperswitchAtom

let fetchMerchantDetailsV1 = async (~getURL, ~fetchDetails, ~setMerchantDetailsValue) => {
  try {
    let accountUrl = getURL(~entityName=V1(MERCHANT_ACCOUNT), ~methodType=Get)
    let merchantDetailsJSON = await fetchDetails(accountUrl)
    let jsonToTypedValue =
      merchantDetailsJSON->MerchantAccountDetailsMapper.getMerchantDetails(~version=V1)
    setMerchantDetailsValue(_ => jsonToTypedValue)
    jsonToTypedValue
  } catch {
  | Exn.Error(e) => {
      let err = Exn.message(e)->Option.getOr("Failed to fetch merchant details!")
      Exn.raiseError(err)
    }
  }
}

let fetchMerchantDetailsV2 = async (~getURL, ~fetchDetails, ~setMerchantDetailsValue) => {
  try {
    let accountUrl = getURL(~entityName=V2(MERCHANT_ACCOUNT), ~methodType=Get)
    let merchantDetailsJSON = await fetchDetails(accountUrl, ~version=V2)
    let jsonToTypedValue =
      merchantDetailsJSON->MerchantAccountDetailsMapper.getMerchantDetails(~version=V2)
    setMerchantDetailsValue(_ => jsonToTypedValue)
    jsonToTypedValue
  } catch {
  | Exn.Error(e) => {
      let err = Exn.message(e)->Option.getOr("Failed to fetch merchant details!")
      Exn.raiseError(err)
    }
  }
}

let useFetchMerchantDetails = () => {
  let getURL = APIUtils.useGetURL()
  let setMerchantDetailsValue = HyperswitchAtom.merchantDetailsValueAtom->Recoil.useSetRecoilState
  let fetchDetails = APIUtils.useGetMethod()

  async (~version: UserInfoTypes.version=V1) => {
    switch version {
    | V1 => await fetchMerchantDetailsV1(~getURL, ~fetchDetails, ~setMerchantDetailsValue)
    | V2 => await fetchMerchantDetailsV2(~getURL, ~fetchDetails, ~setMerchantDetailsValue)
    }
  }
}

let useMerchantDetailsValue = () => Recoil.useRecoilValueFromAtom(merchantDetailsValueAtom)
