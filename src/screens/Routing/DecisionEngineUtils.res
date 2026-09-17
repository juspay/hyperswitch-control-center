// Shared data + helpers for the embedded Decision Engine workspace, used by the workspace screen,
// the sidebar (DecisionEngine Routing group + Analytics → Routing) and RoutingStack.
open LogicUtils
open DecisionEngineTypes

// The Decision Engine surfaces, in the order the sidebar lists them. `analytics` is reached from
// the Analytics section's "Routing" entry (inSidebar=false), so it is excluded from the Routing
// group. Decision Simulator is compiled out of the DE's production build, so gate it on the DE's
// simulator flag before shipping to prod.
let sections = [
  {
    slug: "analytics",
    label: "Analytics",
    dePath: "/analytics",
    target: "rule",
    iconTag: None,
    searchOptions: [("View routing analytics", "")],
    inSidebar: false,
  },
  {
    slug: "audit",
    label: "Decision Audit",
    dePath: "/audit",
    target: "rule",
    iconTag: None,
    searchOptions: [("View decision audit", "")],
    inSidebar: true,
  },
  {
    slug: "multi_objective",
    label: "Multi Objective",
    dePath: "/routing/sr",
    target: "multi_objective",
    iconTag: None,
    searchOptions: [("Configure multi objective routing", "")],
    inSidebar: true,
  },
  {
    slug: "rule",
    label: "Rule-Based",
    dePath: "/routing/rules",
    target: "rule",
    iconTag: None,
    searchOptions: [("Create new rule based routing", "")],
    inSidebar: true,
  },
  {
    slug: "volume",
    label: "Volume Split",
    dePath: "/routing/volume",
    target: "volume",
    iconTag: None,
    searchOptions: [("Create new volume based routing", "")],
    inSidebar: true,
  },
  {
    slug: "debit",
    label: "Debit Routing",
    dePath: "/routing/debit",
    target: "debit",
    iconTag: None,
    searchOptions: [("Configure debit routing", "")],
    inSidebar: true,
  },
  {
    slug: "ab-testing",
    label: "A/B Testing",
    dePath: "/routing/ab-testing",
    target: "rule",
    iconTag: Some("betaTag"),
    searchOptions: [("Run A/B tests on routing", "")],
    inSidebar: true,
  },
  {
    slug: "simulator",
    label: "Decision Simulator",
    dePath: "/decisions/simulator",
    target: "rule",
    iconTag: None,
    searchOptions: [("Simulate routing decisions", "")],
    inSidebar: true,
  },
]

let defaultSection = {
  slug: "rule",
  label: "Rule-Based",
  dePath: "/routing/rules",
  target: "rule",
  iconTag: None,
  searchOptions: [],
  inSidebar: true,
}

// The DE reports paths like /routing/rules/<id>/edit — attribute them to the section whose
// dePath is the longest matching prefix.
let sectionForDePath = path => {
  let pathOnly = path->String.split("?")->Array.get(0)->Option.getOr("")
  sections->Array.reduce(None, (acc, s) => {
    let matches =
      pathOnly === s.dePath || (s.dePath !== "/" && pathOnly->String.startsWith(`${s.dePath}/`))
    switch (matches, acc) {
    | (false, _) => acc
    | (true, None) => Some(s)
    | (true, Some(prev)) =>
      s.dePath->String.length > prev.dePath->String.length ? Some(s) : Some(prev)
    }
  })
}

// The single source of the workspace path, so RoutingStack, the sidebar and the workspace agree.
let workspaceBasePath = "/routing/workspace"

// Raw path for a section (no dashboard prefix) — used for sidebar `link` fields, which the
// sidebar renderer prefixes itself.
let workspacePath = (~slug) => `${workspaceBasePath}/${slug}`

// Fully-qualified URL for RescriptReactRouter navigation.
let workspaceUrl = (~slug, ~ruleId="") => {
  let query = ruleId->isNonEmptyString ? `?rule=${ruleId->encodeURIComponent}` : ""
  GlobalVars.appendDashboardPath(~url=`${workspacePath(~slug)}${query}`)
}

// The section slug is the path segment after "workspace": /routing/workspace/<slug>.
let sectionSlugFromPath = path => {
  let pathSegments = path->List.toArray
  switch pathSegments->Array.findIndex(seg => seg === "workspace") {
  | -1 => defaultSection.slug
  | idx => pathSegments->Array.get(idx + 1)->Option.getOr(defaultSection.slug)
  }
}
