open LogicUtils
open ReconEngineSetupExplainerTypes

let ingestionNodeId = id => `ing-${id}`
let transformationNodeId = id => `trf-${id}`
let accountNodeId = id => `acc-${id}`
let ruleNodeId = id => `rule-${id}`

let columnX = (kind: explainerNodeKind): float => {
  switch kind {
  | IngestionNode => 0.0
  | TransformationNode => 680.0
  | AccountNode => 1360.0
  | RuleNode => 2040.0
  }
}

let verticalGap = 230.0

let edgeStroke: edgeStyleType = {stroke: "#94A3B8", strokeWidth: 1.5}

let getIngestionSourceLabel = (config: ReconEngineTypes.ingestionConfigType): string => {
  switch config.data
  ->getDictFromJsonObject
  ->getString("ingestion_type", "")
  ->String.toLowerCase {
  | "manual" => "Files are uploaded manually from the dashboard"
  | "sftp" | "sftp_internal" => "Files arrive automatically over SFTP"
  | "adyen" => "Adyen pushes settlement files automatically"
  | _ => "Files arrive from this data source"
  }
}

let getIngestionTypeBadge = (config: ReconEngineTypes.ingestionConfigType): string => {
  config.data
  ->getDictFromJsonObject
  ->getString("ingestion_type", "")
  ->snakeToTitle
}

let averageY = (ys: array<float>, ~fallback: float): float => {
  switch ys->Array.length {
  | 0 => fallback
  | length => ys->Array.reduce(0.0, (acc, y) => acc +. y) /. Int.toFloat(length)
  }
}

// Place a column of nodes as close as possible to the row of the nodes they
// connect to (desiredY), pushing colliding nodes down just enough to keep a
// minimum vertical gap. This keeps each chain in its own horizontal band.
let placeColumn = (items: array<'a>, ~desiredY: 'a => float): array<('a, float)> => {
  let prevY = ref(Float.Constants.negativeInfinity)
  items
  ->Array.map(item => (item, desiredY(item)))
  ->Array.toSorted(((_, y1), (_, y2)) => y1 -. y2)
  ->Array.map(((item, desired)) => {
    let y = Math.max(desired, prevY.contents +. verticalGap)
    prevY := y
    (item, y)
  })
}

let makeNode = (
  ~id,
  ~kind,
  ~label,
  ~description,
  ~badgeText="",
  ~isActive=true,
  ~showStatus=true,
  ~y: float,
  ~onNodeClick=None,
): nodeType => {
  id,
  nodeType: "explainerNode",
  position: {x: kind->columnX, y},
  data: {
    kind,
    label,
    description,
    badgeText,
    isActive,
    showStatus,
    onNodeClick,
  },
}

let makeEdge = (~source, ~target, ~label="", ~animated=false): edgeType => {
  id: `${source}-to-${target}`,
  source,
  target,
  edgeType: "smoothstep",
  label: ?(label->isNonEmptyString ? Some(label) : None),
  animated,
  markerEnd: {edgeMarkerType: ReactFlow.markerTypeArrowClosed},
  style: edgeStroke,
}

let generateSetupNodesAndEdges = (
  ~accounts: array<ReconEngineTypes.accountType>,
  ~ingestionConfigs: array<ReconEngineTypes.ingestionConfigType>,
  ~transformationConfigs: array<ReconEngineTypes.transformationConfigType>,
  ~rules: array<ReconEngineRulesTypes.rulePayload>,
  ~onNodeClick: option<(explainerNodeKind, string) => unit>=?,
): (array<nodeType>, array<edgeType>) => {
  let clickHandler = (kind, entityId) =>
    onNodeClick->Option.map(handler => () => handler(kind, entityId))

  // Nodes with no resolvable upstream link land below the real chains.
  let maxRows =
    [
      ingestionConfigs->Array.length,
      transformationConfigs->Array.length,
      accounts->Array.length,
      rules->Array.length,
    ]->Array.reduce(0, (acc, count) => Math.Int.max(acc, count))
  let orphanY = Int.toFloat(maxRows) *. verticalGap

  let ingestionYs = Dict.make()
  ingestionConfigs->Array.forEachWithIndex((config, index) =>
    ingestionYs->Dict.set(config.ingestion_id, Int.toFloat(index) *. verticalGap)
  )

  let placedTransformations =
    transformationConfigs->placeColumn(~desiredY=config =>
      ingestionYs->Dict.get(config.ingestion_id)->Option.getOr(orphanY)
    )
  let transformationYs = Dict.make()
  placedTransformations->Array.forEach(((config, y)) =>
    transformationYs->Dict.set(config.transformation_id, y)
  )

  let placedAccounts = accounts->placeColumn(~desiredY=account => {
    let feederYs =
      transformationConfigs
      ->Array.filter(config => config.account_id === account.account_id)
      ->Array.filterMap(config => transformationYs->Dict.get(config.transformation_id))
    let fallback =
      ingestionConfigs
      ->Array.find(config => config.account_id === account.account_id)
      ->Option.flatMap(config => ingestionYs->Dict.get(config.ingestion_id))
      ->Option.getOr(orphanY)
    feederYs->averageY(~fallback)
  })
  let accountYs = Dict.make()
  placedAccounts->Array.forEach(((account, y)) => accountYs->Dict.set(account.account_id, y))

  let placedRules = rules->placeColumn(~desiredY=rule => {
    let (sourceAccountId, targetAccounts) = ReconEngineRulesUtils.getSourceAndTargetAccountDetails(
      rule.strategy,
    )
    [sourceAccountId]
    ->Array.concat(targetAccounts->Array.map(target => target.account_id))
    ->Array.filterMap(accountId => accountYs->Dict.get(accountId))
    ->averageY(~fallback=orphanY)
  })

  // Second pass: re-center each data source between the transformations it
  // feeds, so a source with several transformations sits mid-band.
  let placedIngestions = ingestionConfigs->placeColumn(~desiredY=config => {
    let fedYs =
      transformationConfigs
      ->Array.filter(transformation => transformation.ingestion_id === config.ingestion_id)
      ->Array.filterMap(transformation =>
        transformationYs->Dict.get(transformation.transformation_id)
      )
    let fallback = ingestionYs->Dict.get(config.ingestion_id)->Option.getOr(orphanY)
    fedYs->averageY(~fallback)
  })

  let ingestionNodes =
    placedIngestions->Array.map(((config, y)) =>
      makeNode(
        ~id=config.ingestion_id->ingestionNodeId,
        ~kind=IngestionNode,
        ~label=config.name,
        ~description=config->getIngestionSourceLabel,
        ~badgeText=config->getIngestionTypeBadge,
        ~isActive=config.is_active,
        ~y,
        ~onNodeClick=clickHandler(IngestionNode, config.ingestion_id),
      )
    )

  let transformationNodes = placedTransformations->Array.map(((config, y)) => {
    let accountName = ReconEngineRulesUtils.getAccountName(config.account_id, accounts)
    makeNode(
      ~id=config.transformation_id->transformationNodeId,
      ~kind=TransformationNode,
      ~label=config.name,
      ~description=`Parses each file row into entries for ${accountName}`,
      ~isActive=config.is_active,
      ~y,
      ~onNodeClick=clickHandler(TransformationNode, config.transformation_id),
    )
  })

  let accountNodes =
    placedAccounts->Array.map(((account, y)) =>
      makeNode(
        ~id=account.account_id->accountNodeId,
        ~kind=AccountNode,
        ~label=account.account_name,
        ~description="Double-entry account holding this party's entries",
        ~badgeText=`${(account.account_type :> string)->capitalizeString} · ${account.currency}`,
        ~showStatus=false,
        ~y,
        ~onNodeClick=clickHandler(AccountNode, account.account_id),
      )
    )

  let ruleNodes = placedRules->Array.map(((rule, y)) => {
    let description =
      rule.rule_description->isNonEmptyString
        ? rule.rule_description
        : "Pairs entries across its source and target accounts"
    makeNode(
      ~id=rule.rule_id->ruleNodeId,
      ~kind=RuleNode,
      ~label=rule.rule_name,
      ~description,
      ~badgeText=ReconEngineRulesUtils.getReconStrategyDisplayName(rule.strategy),
      ~isActive=rule.is_active,
      ~y,
      ~onNodeClick=clickHandler(RuleNode, rule.rule_id),
    )
  })

  let ingestionIds = ingestionConfigs->Array.map(config => config.ingestion_id)
  let accountIds = accounts->Array.map(account => account.account_id)

  let transformationEdges = transformationConfigs->Array.flatMap(config => {
    let sourceEdges =
      ingestionIds->Array.includes(config.ingestion_id)
        ? [
            makeEdge(
              ~source=config.ingestion_id->ingestionNodeId,
              ~target=config.transformation_id->transformationNodeId,
              ~label="feeds",
            ),
          ]
        : []
    let targetEdges =
      accountIds->Array.includes(config.account_id)
        ? [
            makeEdge(
              ~source=config.transformation_id->transformationNodeId,
              ~target=config.account_id->accountNodeId,
              ~label="creates entries in",
            ),
          ]
        : []
    sourceEdges->Array.concat(targetEdges)
  })

  let transformedIngestionIds = transformationConfigs->Array.map(config => config.ingestion_id)

  let directIngestionEdges =
    ingestionConfigs
    ->Array.filter(config =>
      !(transformedIngestionIds->Array.includes(config.ingestion_id)) &&
      accountIds->Array.includes(config.account_id)
    )
    ->Array.map(config =>
      makeEdge(
        ~source=config.ingestion_id->ingestionNodeId,
        ~target=config.account_id->accountNodeId,
        ~label="posts to",
      )
    )

  let ruleEdges = rules->Array.flatMap(rule => {
    let (sourceAccountId, targetAccounts) = ReconEngineRulesUtils.getSourceAndTargetAccountDetails(
      rule.strategy,
    )
    let sourceEdges =
      accountIds->Array.includes(sourceAccountId)
        ? [
            makeEdge(
              ~source=sourceAccountId->accountNodeId,
              ~target=rule.rule_id->ruleNodeId,
              ~label="source entries",
              ~animated=true,
            ),
          ]
        : []
    let targetEdges =
      targetAccounts
      ->Array.filter(target => accountIds->Array.includes(target.account_id))
      ->Array.map(target => {
        let label = switch (target.split_value, target.split_type) {
        | (Some(value), Some("percentage")) => `target · ${(value *. 100.0)->Float.toString}%`
        | (Some(value), Some(_)) => `target · ${value->Float.toString}`
        | _ => "target entries"
        }
        makeEdge(
          ~source=target.account_id->accountNodeId,
          ~target=rule.rule_id->ruleNodeId,
          ~label,
          ~animated=true,
        )
      })
    sourceEdges->Array.concat(targetEdges)
  })

  let nodes =
    ingestionNodes
    ->Array.concat(transformationNodes)
    ->Array.concat(accountNodes)
    ->Array.concat(ruleNodes)

  // Stagger the bend distance per edge so parallel edges get their own
  // routing channel instead of merging into a single line.
  let edges =
    transformationEdges
    ->Array.concat(directIngestionEdges)
    ->Array.concat(ruleEdges)
    ->Array.mapWithIndex((edge, index) => {
      ...edge,
      pathOptions: {
        offset: 30.0 +. Int.toFloat(mod(index, 8)) *. 24.0,
        borderRadius: 8.0,
      },
    })

  (nodes, edges)
}
