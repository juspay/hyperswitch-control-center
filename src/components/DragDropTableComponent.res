type draggableDefaultDestination = {index: int, droppableId: string}
type draggableItem = React.element

let reorder = (currentState, startIndex, endIndex) => {
  if startIndex !== endIndex {
    let oldStateArray = Array.copy(currentState)
    let removed = Js.Array.removeCountInPlace(~pos=startIndex, ~count=1, oldStateArray)
    oldStateArray->Array.splice(~start=endIndex, ~remove=0, ~insert=removed)
    (oldStateArray, true)
  } else {
    (currentState, false)
  }
}
@react.component
let make = (
  ~isHorizontal=true,
  ~listItems,
  ~gap="",
  ~setListItems,
  ~keyExtractor,
  ~isDragDisabled: option<(int, 'a) => bool>=?,
) => {
  let onDragEnd = result => {
    // dropped outside the list

    let dest = Nullable.toOption(result["destination"])

    switch dest {
    | Some(a) => {
        let res: draggableDefaultDestination = {
          index: a.index,
          droppableId: a.droppableId,
        }

        // NEW: Check if destination is a valid drop target
        let isDestinationDisabled = switch isDragDisabled {
        | Some(disableFunction) =>
          // Check if the item at destination index is disabled
          switch listItems->Array.get(res.index) {
          | Some(destinationItem) => disableFunction(res.index, destinationItem)
          | None => false
          }
        | None => false
        }

        // Only perform reorder if destination is not disabled
        if !isDestinationDisabled {
          let (updatedList, hasChanged) = reorder(listItems, result["source"]["index"], res.index)
          if hasChanged {
            setListItems(updatedList)
          }
        }
        // If destination is disabled, do nothing (drag will snap back)
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
              let isItemDisabled = switch isDragDisabled {
              | Some(disableFunction) => disableFunction(index, item)
              | None => false
              }
              <ReactBeautifulDND.Draggable
                key={`item-${Int.toString(index)}`}
                index={index}
                draggableId={`item-${Int.toString(index)}`}
                isDragDisabled=isItemDisabled>
                {(provided, snapshot) => {
                  let draggableElement =
                    <div onDragStart={provided["onDragStart"]} ref={provided["innerRef"]}>
                      <div className="flex">
                        {isItemDisabled
                          ? <div />
                          : <Icon name="grip-vertical" size=14 className={"cursor-pointer"} />}
                        {keyExtractor(index, item, snapshot["isDragging"])}
                      </div>
                    </div>

                  // Apply draggableProps first
                  let elementWithDraggableProps =
                    draggableElement->React.cloneElement(provided["draggableProps"])

                  // Only apply dragHandleProps if not null (when drag is enabled)
                  switch provided["dragHandleProps"]->Nullable.toOption {
                  | Some(dragHandleProps) =>
                    elementWithDraggableProps->React.cloneElement(dragHandleProps)
                  | None => elementWithDraggableProps // When isDragDisabled=true
                  }
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
