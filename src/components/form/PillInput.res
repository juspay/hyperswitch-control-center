@send external focus: Dom.element => unit = "focus"
@react.component
let make = (~name, ~initialItems: array<string>=[], ~placeholder, ~duplicateCheck=true) => {
  let form = ReactFinalForm.useForm()
  let (items, setItems) = React.useState(_ => initialItems)
  let (inputValue, setInputValue) = React.useState(_ => "")
  let (editInput, setEditInput) = React.useState(_ => "")
  let (editingItem, setEditingItem) = React.useState(_ => None)
  let (error, setError) = React.useState(_ => "")
  let (suggestion, setSuggestion) = React.useState(_ => None)
  let enterKeyCode = 14

  let handleInputChange = e => {
    let value = ReactEvent.Form.target(e)["value"]
    setInputValue(_ => value)
    setError(_ => "")

    if !CommonAuthUtils.isValidEmail(value) {
      setSuggestion(_ => Some(value))
    } else {
      setSuggestion(_ => None)
    }
  }

  let handleEditChange = e => {
    let value = ReactEvent.Form.target(e)["value"]
    setEditInput(_ => value)
    setError(_ => "")
  }

  let addItem = elem => {
    let trimmedItem = String.trim(elem)
    if trimmedItem->LogicUtils.isEmptyString {
      setInputValue(_ => "")
      setError(_ => "")
      setSuggestion(_ => None)
    }

    if duplicateCheck && Array.some(items, existingItem => existingItem == trimmedItem) {
      setError(_ => "Email already exists")
      setSuggestion(_ => None)
    } else if !CommonAuthUtils.isValidEmail(trimmedItem) {
      setItems(prev => Array.concat(prev, [trimmedItem]))
      form.change(name, [...items, elem]->Identity.genericTypeToJson)
      setInputValue(_ => "")
      setError(_ => "")
      setSuggestion(_ => None)
    } else {
      setError(_ => "Invalid Email")
      setSuggestion(_ => None)
    }
  }

  let handleSuggestionClick = () => {
    switch suggestion {
    | Some(suggestedEmail) => addItem(suggestedEmail)
    | None => ()
    }
  }

  let removeItem = itemToRemove => {
    form.change(name, items->Array.filter(ele => ele !== itemToRemove)->Identity.genericTypeToJson)
    setItems(prev => prev->Array.filter(item => item != itemToRemove))
  }

  let saveItem = itemToSave => {
    let trimmedEditInput = String.trim(editInput)
    let isDuplicate =
      duplicateCheck &&
      trimmedEditInput != itemToSave &&
      Array.some(items, existingItem => existingItem == trimmedEditInput)
    if isDuplicate {
      setError(_ => "Email already exists")
      setEditInput(_ => itemToSave)
    } else if !CommonAuthUtils.isValidEmail(trimmedEditInput) {
      setItems(prev => prev->Array.map(item => item == itemToSave ? trimmedEditInput : item))
      let updatedArray =
        items
        ->Array.filter(ele => ele !== itemToSave)
        ->Array.concat([trimmedEditInput])
      form.change(name, updatedArray->Identity.genericTypeToJson)
      setEditingItem(_ => None)
      setEditInput(_ => "")
      setError(_ => "")
    } else {
      setEditInput(_ => itemToSave)
      setError(_ => "Invalid Email")
    }
  }

  let handleKeyDown = e => {
    let key = e->ReactEvent.Keyboard.key
    let keyCode = e->ReactEvent.Keyboard.keyCode
    if key === "Enter" || keyCode === enterKeyCode {
      ReactEvent.Keyboard.preventDefault(e)
      switch suggestion {
      | Some(suggestedEmail) => addItem(suggestedEmail)
      | None => addItem(inputValue)
      }
    }
  }

  let handleEditKeydown = (item, ev) => {
    let key = ev->ReactEvent.Keyboard.key
    let keyCode = ev->ReactEvent.Keyboard.keyCode
    if key === "Enter" || keyCode === enterKeyCode {
      ReactEvent.Keyboard.preventDefault(ev)
      saveItem(item)
    }
  }

  let toggleEditingItem = (item, event) => {
    event->ReactEvent.Mouse.stopPropagation
    setEditingItem(_ => Some(item))
    setEditInput(_ => item)
  }

  let inputRef = React.useRef(Nullable.null)
  let handleContainerClick = () => {
    switch inputRef.current->Nullable.toOption {
    | Some(inputElement) => inputElement->focus
    | None => ()
    }
  }

  <div className="w-full cursor-text" onClick={_ => handleContainerClick()}>
    <div className="w-full flex flex-wrap gap-2 border p-2 text-sm rounded-md">
      {items
      ->Array.mapWithIndex((item, i) =>
        <div key={Int.toString(i)} className="flex flex-wrap gap-1 p-1 border rounded-md">
          <RenderIf condition={editingItem == Some(item)}>
            <input
              onClick={event => event->ReactEvent.Mouse.stopPropagation}
              type_="text"
              value={editInput}
              onBlur={_ => saveItem(item)}
              onInput=handleEditChange
              onKeyDown={ev => handleEditKeydown(item, ev)}
              className="rounded-md p-1 grow"
            />
          </RenderIf>
          <RenderIf condition={editingItem != Some(item)}>
            <div
              className="cursor-pointer px-2 py-1 grow"
              onClick={event => toggleEditingItem(item, event)}>
              {React.string(item)}
            </div>
          </RenderIf>
          <button onClick={_ => removeItem(item)} className="hover:bg-gray-300 rounded-md p-1">
            <Icon name="cross-outline" size=14 />
          </button>
        </div>
      )
      ->React.array}
      <div className="relative">
        <input
          ref={inputRef->ReactDOM.Ref.domRef}
          type_="text"
          value={inputValue}
          placeholder
          onChange=handleInputChange
          onKeyDown=handleKeyDown
          className="outline-hidden p-2 grow"
          name
        />
        <RenderIf condition={suggestion->Option.isSome}>
          <div
            onClick={_ => handleSuggestionClick()}
            className="absolute z-10 min-w-80 bg-white border rounded-md shadow-lg mt-1 cursor-pointer top-10 h-16">
            <div className="bg-gray-200 w-full h-[calc(100%-16px)] my-2 flex items-center px-4">
              <div className="flex items-center gap-2">
                <Icon name="user" size=14 className="text-primary-blue-600" />
                <span className="font-medium"> {React.string(suggestion->Option.getOr(""))} </span>
              </div>
            </div>
          </div>
        </RenderIf>
      </div>
    </div>
    <RenderIf condition={!(error->LogicUtils.isEmptyString)}>
      <div className="flex gap-1 mt-2">
        <Icon name="exclamation-circle" size=12 className="text-red-400" />
        <p className="text-red-400 text-xs"> {React.string(error)} </p>
      </div>
    </RenderIf>
  </div>
}
