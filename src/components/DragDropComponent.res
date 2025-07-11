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
    let dest = Nullable.toOption(result["destination"])

    switch dest {
    | Some(a) => {
        let destination: draggableDefaultDestination = {
          index: a.index,
          droppableId: a.droppableId,
        }

        let isDestinationDisabled = switch isDragDisabled {
        | Some(disableFunction) =>
          switch listItems->Array.get(destination.index) {
          | Some(destinationItem) =>
            let isDisabled = disableFunction(destination.index, destinationItem)
            let sourceIndex = result["source"]["index"]

            let indexToGet = {
              sourceIndex > destination.index ? destination.index - 1 : destination.index
            }

            if isDisabled && destination.index > 0 {
              switch listItems->Array.get(indexToGet) {
              | Some(prevItem) => disableFunction(indexToGet, prevItem) ? isDisabled : false
              | None => isDisabled
              }
            } else {
              isDisabled
            }
          | None => false
          }
        | None => false
        }

        if !isDestinationDisabled {
          let (updatedList, hasChanged) = reorder(
            listItems,
            result["source"]["index"],
            destination.index,
          )
          if hasChanged {
            setListItems(updatedList)
          }
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
                      {keyExtractor(index, item, snapshot["isDragging"], isItemDisabled)}
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
