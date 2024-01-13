type draggableDefaultDestination = {index: int, droppableId: string}

let defaultDraggableDest = {
  index: 0,
  droppableId: "",
}

let reorder = (currentState, startIndex, endIndex) => {
  if startIndex !== endIndex {
    let oldStateArray = Array.copy(currentState)
    let removed = Js.Array.removeCountInPlace(~pos=startIndex, ~count=1, oldStateArray)
    let _ = Js.Array.spliceInPlace(~pos=endIndex, ~remove=0, ~add=removed, oldStateArray)
    (oldStateArray, true)
  } else {
    (currentState, false)
  }
}

let spreadProps = React.cloneElement

module DraggableItem = {
  @react.component
  let make = (~directionClass, ~str, ~index) => {
    open ReactBeautifulDND
    <Draggable index={index} draggableId={`item-${Belt.Int.toString(index)}`}>
      {(provided, _snapshot) => {
        {
          <span
            onDragStart={provided["onDragStart"]}
            ref={provided["innerRef"]}
            className={`flex ${directionClass} p-3 m-1 bg-jp-gray-50 dark:bg-jp-gray-950 rounded border border-jp-gray-500 dark:border-jp-gray-960 align-center justify-center rounded-t-none`}>
            {React.string(str)}
          </span>
        }
        ->spreadProps(provided["draggableProps"])
        ->spreadProps(provided["dragHandleProps"])
      }}
    </Draggable>
  }
}

type props = {
  isHorizontal?: bool,
  listItems: array<Js.Json.t>,
  setListItems: (array<Js.Json.t> => array<Js.Json.t>) => unit,
  keyExtractor: Js.Json.t => option<string>,
}

let default = (props: props) => {
  let {listItems, setListItems, keyExtractor} = props

  let isHorizontal = props.isHorizontal->Belt.Option.getWithDefault(true)

  let onDragEnd = result => {
    // dropped outside the list
    let dest = Js.Nullable.toOption(result["destination"])
    let hasCorrectDestination = switch dest {
    | None => false
    | Some(_a) => true
    }
    if hasCorrectDestination {
      let res = switch dest {
      | Some(a) => {
          let retValue: draggableDefaultDestination = {
            index: a.index,
            droppableId: a.droppableId,
          }
          retValue
        }

      | _ => defaultDraggableDest
      }
      let (updatedList, hasChanged) = reorder(listItems, result["source"]["index"], res.index)
      if hasChanged {
        setListItems(_ => updatedList)
      }
    }
  }
  let directionClass = isHorizontal ? "flex-row" : "flex-col"
  let droppableDirection = isHorizontal ? "horizontal" : "vertical"
  let values = listItems->Belt.Array.keepMap(keyExtractor)

  open ReactBeautifulDND

  <div
    className={`w-min p-3 bg-jp-gray-50 dark:bg-jp-gray-950 rounded border border-jp-gray-500 dark:border-jp-gray-960 align-center justify-center rounded-t-none flex ${directionClass}`}>
    <DragDropContext onDragEnd={onDragEnd}>
      <Droppable droppableId="droppable" direction={droppableDirection}>
        {(provided, _snapshot) => {
          {
            <div className={`flex ${directionClass}`} ref={provided["innerRef"]}>
              {values
              ->Array.mapWithIndex((str, index) => {
                <DraggableItem key={`item-${Belt.Int.toString(index)}`} directionClass str index />
              })
              ->React.array}
              {provided["placeholder"]}
            </div>
          }->spreadProps(provided["droppableProps"])
        }}
      </Droppable>
    </DragDropContext>
  </div>
}
