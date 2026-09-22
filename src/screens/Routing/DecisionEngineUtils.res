open LogicUtils
open DecisionEngineTypes

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

let workspaceBasePath = "/routing/workspace"

let workspacePath = (~slug) => `${workspaceBasePath}/${slug}`

let workspaceUrl = (~slug, ~ruleId="") => {
  let query = ruleId->isNonEmptyString ? `?rule=${ruleId->encodeURIComponent}` : ""
  GlobalVars.appendDashboardPath(~url=`${workspacePath(~slug)}${query}`)
}

let sectionSlugFromPath = path => {
  let pathSegments = path->List.toArray
  switch pathSegments->Array.findIndex(seg => seg === "workspace") {
  | -1 => defaultSection.slug
  | idx => pathSegments->Array.get(idx + 1)->Option.getOr(defaultSection.slug)
  }
}
