open HyperswitchAtom
open APIUtils

let fetchMerchantDetailsV1 = async (~setMerchantDetailsValue) => {
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  try {
    let accountUrl = getURL(~entityName=APIUtilsTypes.V1(MERCHANT_ACCOUNT), ~methodType=Get)
    let merchantDetailsJSON = await fetchDetails(accountUrl, ~version=V1)
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

let fetchMerchantDetailsV2 = async (~setMerchantDetailsValue) => {
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  try {
    let accountUrl = getURL(~entityName=APIUtilsTypes.V2(MERCHANT_ACCOUNT), ~methodType=Get)
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
  let setMerchantDetailsValue = HyperswitchAtom.merchantDetailsValueAtom->Recoil.useSetRecoilState

  async (~version: UserInfoTypes.version=V1) => {
    switch version {
    | V1 => await fetchMerchantDetailsV1(~setMerchantDetailsValue)
    | V2 => await fetchMerchantDetailsV2(~setMerchantDetailsValue)
    }
  }
}

let useMerchantDetailsValue = () => Recoil.useRecoilValueFromAtom(merchantDetailsValueAtom)
