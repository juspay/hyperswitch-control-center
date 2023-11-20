type droppableFunctionReturn
type droppableMode = Standard | Virtual

module DragDropContext = {
  @module("react-beautiful-dnd") @react.component
  external make: (~children: React.element=?, ~onDragEnd: 'a => unit) => React.element =
    "DragDropContext"
}

module Droppable = {
  @module("react-beautiful-dnd") @react.component
  external make: (
    ~children: ('a, 'a) => React.element,
    ~droppableId: string,
    ~direction: string,
    ~\"type": string=?,
  ) => React.element = "Droppable"
}

module Draggable = {
  @module("react-beautiful-dnd") @react.component
  external make: (
    ~children: ('a, 'a) => React.element,
    ~draggableId: string,
    ~index: int,
  ) => React.element = "Draggable"
}
