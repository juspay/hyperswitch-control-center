open Typography
open ReconEngineSetupExplainerTypes

let getStageTag = (kind: explainerNodeKind): string => {
  switch kind {
  | IngestionNode => "Step 1 · Data Source"
  | TransformationNode => "Step 2 · Transformation"
  | AccountNode => "Step 3 · Account"
  | RuleNode => "Step 4 · Recon Rule"
  }
}

@react.component
let make = (~data: explainerNodeData) => {
  open ReactFlow

  let onClick = _ => {
    switch data.onNodeClick {
    | Some(clickHandler) => clickHandler()
    | None => ()
    }
  }

  let cursorClass = data.onNodeClick->Option.isSome ? "cursor-pointer" : ""

  <div
    className={`flex flex-col rounded-xl border border-nd_gray-200 bg-white w-80 relative p-4 ${cursorClass}`}
    onClick>
    <HandleComponent \"type"="target" position={positionLeft} />
    <HandleComponent \"type"="source" position={positionRight} />
    <div className="absolute -top-0 -left-0">
      <div
        className={`${body.xs.medium} text-nd_gray-600 bg-nd_gray-100 px-3 py-1 rounded-tl-xl border border-t-0 border-l-0 border-nd_gray-200 rounded-br-xl`}>
        {data.kind->getStageTag->React.string}
      </div>
    </div>
    <div className="flex flex-row items-center justify-between gap-2 pt-6">
      <p className={`${body.md.semibold} text-nd_gray-800 truncate`}>
        {data.label->React.string}
      </p>
      <RenderIf condition={data.showStatus}>
        {data.isActive
          ? <p
              className={`${body.xs.medium} text-nd_green-600 bg-nd_green-50 px-2 py-0.5 rounded-full`}>
              {"Active"->React.string}
            </p>
          : <p
              className={`${body.xs.medium} text-nd_gray-500 bg-nd_gray-100 px-2 py-0.5 rounded-full`}>
              {"Inactive"->React.string}
            </p>}
      </RenderIf>
    </div>
    <RenderIf condition={data.badgeText->LogicUtils.isNonEmptyString}>
      <p className={`${body.xs.medium} text-nd_gray-400 mt-1`}> {data.badgeText->React.string} </p>
    </RenderIf>
    <p className={`${body.sm.medium} text-nd_gray-500 mt-2`}> {data.description->React.string} </p>
  </div>
}
