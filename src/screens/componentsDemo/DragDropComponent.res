type draggableDefaultDestination = {index: int, droppableId: string}
type draggableItem = React.element

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
@react.component
let make = (~isHorizontal=true, ~listItems, ~gap="", ~setListItems, ~keyExtractor) => {
  let onDragEnd = result => {
    // dropped outside the list
    let dest = Js.Nullable.toOption(result["destination"])

    switch dest {
    | Some(a) => {
        let res: draggableDefaultDestination = {
          index: a.index,
          droppableId: a.droppableId,
        }
        let (updatedList, hasChanged) = reorder(listItems, result["source"]["index"], res.index)
        if hasChanged {
          setListItems(updatedList)
        }
      }

    | _ => ()
    }
  }
  let directionClass = isHorizontal ? "flex-row" : "flex-col"
  let droppableDirection = isHorizontal ? "horizontal" : "vertical"
  <ReactBeautifulDND.DragDropContext onDragEnd={onDragEnd}>
    <ReactBeautifulDND.Droppable droppableId="droppable" direction={droppableDirection}>
      {(provided, _snapshot) => {
        React.cloneElement(
          <div className={`flex ${directionClass} ${gap} w-full`} ref={provided["innerRef"]}>
            {listItems
            ->Array.mapWithIndex((item, index) => {
              <ReactBeautifulDND.Draggable
                key={`item-${Belt.Int.toString(index)}`}
                index={index}
                draggableId={`item-${Belt.Int.toString(index)}`}>
                {(provided, snapshot) => {
                  let draggableElement =
                    <div onDragStart={provided["onDragStart"]} ref={provided["innerRef"]}>
                      {keyExtractor(index, item, snapshot["isDragging"])}
                    </div>
                  draggableElement
                  ->React.cloneElement(provided["draggableProps"])
                  ->React.cloneElement(provided["dragHandleProps"])
                }}
              </ReactBeautifulDND.Draggable>
            })
            ->React.array}
            {provided["placeholder"]}
          </div>,
          provided["droppableProps"],
        )
      }}
    </ReactBeautifulDND.Droppable>
  </ReactBeautifulDND.DragDropContext>
}
