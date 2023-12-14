type val =
  StringArray(array<string>) | String(string) | IntArray(array<int>) | Int(int) | Bool(bool)

type gateway = {
  gateway_name: string,
  distribution: int,
  disableFallback: bool,
}
type volumeBasedDistribution = {
  gateways: array<gateway>,
  isEnforceGatewayPriority: bool,
}

type formState = CreateConfig | EditConfig | EditReplica | ViewConfig

let getGateways = dict => {
  dict
  ->LogicUtils.getArrayFromDict("gateways", [])
  ->Belt.Array.keepMap(Js.Json.decodeObject)
  ->Js.Array2.map(ob => {
    {
      gateway_name: LogicUtils.getString(ob, "gateway_name", ""),
      distribution: LogicUtils.getInt(ob, "distribution", 0),
      disableFallback: LogicUtils.getBool(ob, "disableFallback", false),
    }
  })
}

let volumeBasedDistributionMapper = dict => {
  switch Js.Dict.get(dict, "volumeBasedDistribution")->Belt.Option.flatMap(Js.Json.decodeObject) {
  | Some(dict) => {
      gateways: dict->getGateways,
      isEnforceGatewayPriority: dict->LogicUtils.getBool("isEnforceGatewayPriority", false),
    }
  | None => {
      gateways: [],
      isEnforceGatewayPriority: false,
    }
  }
}

type status = ACTIVE | APPROVED | PENDING | REJECTED
type configType = RuleBased | CodeBased

let logicStatusToStr = status =>
  switch status {
  | ACTIVE => "ACTIVE"
  | APPROVED => "APPROVED"
  | PENDING => "PENDING"
  | REJECTED => "REJECTED"
  }

let getColorOnStatus = status =>
  switch status {
  | ACTIVE => Table.LabelGreen
  | APPROVED => Table.LabelGreen
  | PENDING => Table.LabelOrange
  | REJECTED => Table.LabelRed
  }

let getAvailableName = (presentNames, name) => {
  let index = Belt.Array.range(0, presentNames->Js.Array2.length)->Js.Array2.findIndex(index => {
    !Js.Array2.includes(presentNames, `${name}-copy-${index->string_of_int}`)
  })
  `${name}-copy-${index->string_of_int}`
}
