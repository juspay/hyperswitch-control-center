open ReconEngineRevampedTypes
open LogicUtils

let reconStatusTypeFromString = str =>
  switch str {
  | "running" => Running
  | "stopped" => Stopped
  | _ => Stopped
  }

let reconStatusResponseMapper: Dict.t<JSON.t> => reconStatusResponse = dict => {
  {
    status: dict->getString("status", "stopped")->reconStatusTypeFromString,
  }
}
