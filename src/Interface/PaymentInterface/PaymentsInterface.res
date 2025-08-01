let mapV1DictToPaymentPayload: dict<JSON.t> => PaymentInterfaceTypesV1.order_v1 = input => {
  PaymentInterfaceUtilsV1.mapDictToPaymentPayload(input)
}

let mapV2DictToPaymentPayload: dict<JSON.t> => PaymentInterfaceTypesV2.order_v2 = input => {
  PaymentInterfaceUtilsV2.mapDictToPaymentPayload(input)
}

module type PaymentInterface = {
  type jsonPaymentDict
  type typedPaymentDict
  type commonPaymentDict

  let mapDictToTypedPaymentPayload: jsonPaymentDict => typedPaymentDict
  let mapDictToCommonPaymentPayload: jsonPaymentDict => commonPaymentDict
}

module V1: PaymentInterface
  with type jsonPaymentDict = Dict.t<JSON.t>
  and type typedPaymentDict = PaymentInterfaceTypesV1.order_v1
  and type commonPaymentDict = PaymentInterfaceTypes.order = {
  type jsonPaymentDict = Dict.t<JSON.t>
  type typedPaymentDict = PaymentInterfaceTypesV1.order_v1
  type commonPaymentDict = PaymentInterfaceTypes.order

  let mapDictToTypedPaymentPayload = (dict: jsonPaymentDict): typedPaymentDict =>
    mapV1DictToPaymentPayload(dict)
  let mapDictToCommonPaymentPayload = (dict: jsonPaymentDict): commonPaymentDict =>
    mapV1DictToPaymentPayload(dict)->PaymentInterfaceUtilsV1.mapPaymentV1ToCommonType
}

module V2: PaymentInterface
  with type jsonPaymentDict = Dict.t<JSON.t>
  and type typedPaymentDict = PaymentInterfaceTypesV2.order_v2
  and type commonPaymentDict = PaymentInterfaceTypes.order = {
  type jsonPaymentDict = Dict.t<JSON.t>
  type typedPaymentDict = PaymentInterfaceTypesV2.order_v2
  type commonPaymentDict = PaymentInterfaceTypes.order

  let mapDictToTypedPaymentPayload = (dict: jsonPaymentDict): typedPaymentDict =>
    mapV2DictToPaymentPayload(dict)
  let mapDictToCommonPaymentPayload = (dict: jsonPaymentDict): commonPaymentDict =>
    mapV2DictToPaymentPayload(dict)->PaymentInterfaceUtilsV2.mapPaymentV2ToCommonType
}

type paymentInterfaceFCM<'a, 'b, 'c> = module(PaymentInterface with
  type jsonPaymentDict = 'a
  and type typedPaymentDict = 'b
  and type commonPaymentDict = 'c
)

let paymentInterfaceV1: paymentInterfaceFCM<
  Dict.t<JSON.t>,
  PaymentInterfaceTypesV1.order_v1,
  PaymentInterfaceTypes.order,
> = module(V1)

let paymentInterfaceV2: paymentInterfaceFCM<
  Dict.t<JSON.t>,
  PaymentInterfaceTypesV2.order_v2,
  PaymentInterfaceTypes.order,
> = module(V2)

let mapJsonDictToTypedPaymentPayload = (
  type a b c,
  module(L: PaymentInterface with
    type jsonPaymentDict = a
    and type typedPaymentDict = b
    and type commonPaymentDict = c
  ),
  inp: a,
): b => {
  L.mapDictToTypedPaymentPayload(inp)
}

let mapJsonDictToCommonPaymentPayload = (
  type a b c,
  module(L: PaymentInterface with
    type jsonPaymentDict = a
    and type typedPaymentDict = b
    and type commonPaymentDict = c
  ),
  inp: a,
): c => {
  L.mapDictToCommonPaymentPayload(inp)
}
