type draggableDefaultDestination = {index: int, droppableId: string}
type draggableItem = React.element

let defaultDraggableDest = {
  index: 0,
  droppableId: "",
}
let getItemStyle = (isDragging, _draggableStyle) => {
  let b = ReactDOM.Style.make(
    ~userSelect="none",
    ~width="250px",
    ~height="100px",
    ~padding="100",
    ~margin="0 0 5px 0",
    ~color=isDragging ? "lightgreen" : "grey",
    (),
  )
  b
}
@react.component
let make = (
  ~isHorizontal=true,
  ~listItems: array<Js.Json.t>,
  ~setListItems: (array<Js.Json.t> => array<Js.Json.t>) => unit,
  ~keyExtractor: Js.Json.t => option<string>,
) => {
  let (list, setList) = React.useState(_ => listItems)
  let reorder = (currentState, startIndex, endIndex) => {
    Js.log("reorder trigger")
    if startIndex !== endIndex {
      let oldStateArray = Array.copy(currentState)
      let removed = Js.Array.removeCountInPlace(~pos=startIndex, ~count=1, oldStateArray)
      let _ = Js.Array.spliceInPlace(~pos=endIndex, ~remove=0, ~add=removed, oldStateArray)
      (oldStateArray, true)
    } else {
      (currentState, false)
    }
  }
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
      let (updatedList, hasChanged) = reorder(list, result["source"]["index"], res.index)
      if hasChanged {
        setList(_ => updatedList)
      }
    }
  }

  let onSubmit = () => {
    let updatedDict = Dict.make()
    Dict.set(updatedDict, "items", list)
    //TODO conversion
    // let transformedList = arrOfObjToArrOfObjValue(value=list, )
    setListItems(_ => list)
  }

  let directionClass = isHorizontal ? "flex-row" : "flex-col"
  let droppableDirection = isHorizontal ? "horizontal" : "vertical"
  <div>
    <div
      className={`w-min p-3 bg-jp-gray-50 dark:bg-jp-gray-950 rounded border border-jp-gray-500 dark:border-jp-gray-960 align-center justify-center rounded-t-none flex ${directionClass}`}>
      <span>
        <ReactBeautifulDND.DragDropContext onDragEnd={onDragEnd}>
          <ReactBeautifulDND.Droppable droppableId="droppable" direction={droppableDirection}>
            {(provided, _snapshot) => {
              React.cloneElement(
                <div className={`flex ${directionClass}`} ref={provided["innerRef"]}>
                  {list->Js.Array.mapi((item, index) => {
                    let val = keyExtractor(item)
                    switch val {
                    | Some(str) =>
                      <ReactBeautifulDND.Draggable
                        key={`item-${Belt.Int.toString(index)}`}
                        index={index}
                        draggableId={`item-${Belt.Int.toString(index)}`}>
                        {(provided, _snapshot) => {
                          React.cloneElement(
                            React.cloneElement(
                              <span
                                onDragStart={provided["onDragStart"]}
                                ref={provided["innerRef"]}
                                className={`flex ${directionClass} p-3 m-1 bg-jp-gray-50 dark:bg-jp-gray-950 rounded border border-jp-gray-500 dark:border-jp-gray-960 align-center justify-center rounded-t-none`}>
                                {React.string(str)}
                              </span>,
                              provided["draggableProps"],
                            ),
                            provided["dragHandleProps"],
                          )
                        }}
                      </ReactBeautifulDND.Draggable>

                    | None => React.null
                    }
                  }, _)->React.array}
                  {provided["placeholder"]}
                </div>,
                provided["droppableProps"],
              )
            }}
          </ReactBeautifulDND.Droppable>
        </ReactBeautifulDND.DragDropContext>
      </span>
    </div>
    <div className="pt-5 inline-block ">
      <Button text="Update" buttonType=Primary onClick={_ => onSubmit()} />
    </div>
  </div>
}
