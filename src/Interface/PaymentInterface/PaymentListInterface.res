open LogicUtils

let mapJsonToOrdersListV1 = (arrayJson: array<JSON.t>): array<PaymentInterfaceTypes.order> => {
  arrayJson->Array.map(order =>
    order
    ->getDictFromJsonObject
    ->PaymentInterfaceUtilsV1.mapDictToPaymentPayload
    ->PaymentInterfaceUtilsV1.mapPaymentV1ToCommonType
  )
}

let mapJsonToOrdersListV2 = (arrayJson: array<JSON.t>): array<PaymentInterfaceTypes.order> => {
  arrayJson->Array.map(order =>
    order
    ->getDictFromJsonObject
    ->PaymentInterfaceUtilsV2.mapDictToPaymentPayload
    ->PaymentInterfaceUtilsV2.mapPaymentV2ToCommonType
  )
}

module type PaymentInterface = {
  type mapperInput
  type mapperOutput

  let mapJsonToOrdersList: mapperInput => mapperOutput
}

module V1: PaymentInterface
  with type mapperInput = array<JSON.t>
  and type mapperOutput = array<PaymentInterfaceTypes.order> = {
  type mapperInput = array<JSON.t>
  type mapperOutput = array<PaymentInterfaceTypes.order>

  let mapJsonToOrdersList = (arrayJson: mapperInput): mapperOutput =>
    mapJsonToOrdersListV1(arrayJson)
}

module V2: PaymentInterface
  with type mapperInput = array<JSON.t>
  and type mapperOutput = array<PaymentInterfaceTypes.order> = {
  type mapperInput = array<JSON.t>
  type mapperOutput = array<PaymentInterfaceTypes.order>

  let mapJsonToOrdersList = (arrayJson: mapperInput): mapperOutput =>
    mapJsonToOrdersListV2(arrayJson)
}

type paymentInterfaceFCM<'a, 'b> = module(PaymentInterface with
  type mapperInput = 'a
  and type mapperOutput = 'b
)

let paymentInterfaceV1: paymentInterfaceFCM<
  array<JSON.t>,
  array<PaymentInterfaceTypes.order>,
> = module(V1)

let paymentInterfaceV2: paymentInterfaceFCM<
  array<JSON.t>,
  array<PaymentInterfaceTypes.order>,
> = module(V2)

let mapJsonToOrdersList = (
  type a b,
  module(L: PaymentInterface with type mapperInput = a and type mapperOutput = b),
  inp: a,
): b => {
  L.mapJsonToOrdersList(inp)
}

let mapJsonToOrdersObject = (json: JSON.t, interface): PaymentInterfaceTypes.ordersObject => {
  let dict = json->getDictFromJsonObject

  let count = dict->getInt("count", 0)
  let total_count = dict->getInt("total_count", 0)
  let jsonArray = dict->getArrayFromDict("data", [])

  // convert json array to array of PaymentInterfaceTypes.order (common type)
  let data = mapJsonToOrdersList(interface, jsonArray)

  {count, data, total_count}
}
