let mapV1DictToPaymentPayload: dict<JSON.t> => PaymentInterfaceTypes.order = input => {
  PaymentInterfaceUtilsV1.mapDictToPaymentPayload(
    input,
  )->PaymentInterfaceUtilsV1.mapPaymentV1ToCommonType
}

let mapV2DictToPaymentPayload: dict<JSON.t> => PaymentInterfaceTypes.order = input => {
  PaymentInterfaceUtilsV2.mapDictToPaymentPayload(
    input,
  )->PaymentInterfaceUtilsV2.mapPaymentV2ToCommonType
}

module type PaymentInterface = {
  type mapperInput
  type mapperOutput

  let mapDictToPaymentPayload: mapperInput => mapperOutput
}

module V1: PaymentInterface
  with type mapperInput = Dict.t<JSON.t>
  and type mapperOutput = PaymentInterfaceTypes.order = {
  type mapperInput = Dict.t<JSON.t>
  type mapperOutput = PaymentInterfaceTypes.order

  let mapDictToPaymentPayload = (dict: mapperInput): mapperOutput => mapV1DictToPaymentPayload(dict)
}

module V2: PaymentInterface
  with type mapperInput = Dict.t<JSON.t>
  and type mapperOutput = PaymentInterfaceTypes.order = {
  type mapperInput = Dict.t<JSON.t>
  type mapperOutput = PaymentInterfaceTypes.order

  let mapDictToPaymentPayload = (dict: mapperInput): mapperOutput => mapV2DictToPaymentPayload(dict)
}

type paymentInterfaceFCM<'a, 'b> = module(PaymentInterface with
  type mapperInput = 'a
  and type mapperOutput = 'b
)

let paymentInterfaceV1: paymentInterfaceFCM<Dict.t<JSON.t>, PaymentInterfaceTypes.order> = module(
  V1
)

let paymentInterfaceV2: paymentInterfaceFCM<Dict.t<JSON.t>, PaymentInterfaceTypes.order> = module(
  V2
)

let mapJsonDictToPaymentPayload = (
  type a b,
  module(L: PaymentInterface with type mapperInput = a and type mapperOutput = b),
  inp: a,
): b => {
  L.mapDictToPaymentPayload(inp)
}

let mapJsonDictToPaymentPayload = (
  version: UserInfoTypes.version,
  inp: dict<JSON.t>,
): PaymentInterfaceTypes.order => {
  switch version {
  | V1 => mapJsonDictToPaymentPayload(paymentInterfaceV1, inp)
  | V2 => mapJsonDictToPaymentPayload(paymentInterfaceV2, inp)
  }
}
