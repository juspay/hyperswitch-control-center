type rec map = {entries: (. unit) => map}
external changeType: Js.Json.t => 't = "%identity"
@new external create: 't => map = "Map"
type object = {fromEntries: (. map) => Js.Json.t}
external object: object = "Object"
