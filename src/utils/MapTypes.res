type rec map = {entries: (. unit) => map}
external changeType: JSON.t => 't = "%identity"
@new external create: 't => map = "Map"
type object = {fromEntries: (. map) => JSON.t}
external object: object = "Object"
