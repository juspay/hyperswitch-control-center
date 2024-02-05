type rec map = {entries: (. unit) => map}
@new external create: 't => map = "Map"
type object = {fromEntries: (. map) => JSON.t}
external object: object = "Object"
