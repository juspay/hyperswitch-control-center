// Shared types for the embedded Decision Engine workspace and its sidebar navigation.

// One Decision Engine surface reachable from the dashboard. `slug` is the URL segment
// (/routing/workspace/<slug>) and doubles as the RoutingStack card target
// (decisionEngineRoutingTarget: "rule" | "volume" | "multi_objective" | "debit"); `dePath` is the
// page inside the DE the hand-off lands on; `inSidebar` marks the ones that form the sidebar's
// Decision Engine Routing group (analytics lives under the Analytics section instead).
type deSection = {
  slug: string,
  label: string,
  dePath: string,
  target: string,
  iconTag: option<string>,
  searchOptions: array<(string, string)>,
  inSidebar: bool,
}

// postMessage events carry an origin the shared jsonData shape doesn't expose.
type messageEventData = {data: JSON.t, origin: string}
external toMessageEvent: Webapi.Dom.Event.t => messageEventData = "%identity"
