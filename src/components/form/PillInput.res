@react.component
let make = (~name, ~initialItems: array<string>=[], ~placeholder, ~duplicateCheck=true) => {
  let form = ReactFinalForm.useForm()
  let (items, setItems) = React.useState(() => initialItems)
  let (inputValue, setInputValue) = React.useState(() => "")
  //to get edited input val
  let (editInput, setEditInput) = React.useState(() => "")
  //to keep track item getting edited
  let (editingItem, setEditingItem) = React.useState(() => None)
  let (error, setError) = React.useState(() => "")

  let handleInputChange = e => {
    let value = ReactEvent.Form.target(e)["value"]
    setInputValue(_ => value)
    setError(_ => "")
  }

  let handleEditChange = e => {
    let value = ReactEvent.Form.target(e)["value"]
    setEditInput(_ => value)
    setError(_ => "")
  }

  let addItem = item => {
    let trimmedItem = String.trim(item)
    if trimmedItem == "" {
      setInputValue(_ => "")
      setError(_ => "")
    }
    if duplicateCheck && Array.some(items, existingItem => existingItem == trimmedItem) {
      setError(_ => "Email already exists")
    } else if !CommonAuthUtils.isValidEmail(trimmedItem) {
      setItems(prev => Array.concat(prev, [trimmedItem]))
      form.change(name, items->Array.concat([item])->Identity.genericTypeToJson)
      setInputValue(_ => "")
      setError(_ => "")
    } else {
      setError(_ => "Invalid Email")
    }
  }

  let removeItem = itemToRemove => {
    form.change(name, items->Array.filter(ele => ele !== itemToRemove)->Identity.genericTypeToJson)
    setItems(prev => prev->Array.filter(item => item != itemToRemove))
  }

  let saveItem = itemToSave => {
    let trimmedEditInput = String.trim(editInput)
    if (
      duplicateCheck &&
      trimmedEditInput != itemToSave &&
      Array.some(items, existingItem => existingItem == trimmedEditInput)
    ) {
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
    open ReactEvent.Keyboard
    let key = e->key
    let keyCode = e->keyCode
    if key === "Enter" || keyCode === 13 {
      ReactEvent.Keyboard.preventDefault(e)
      addItem(inputValue)
    }
  }
  // Toggle editing mode for an item
  let toggleEditingItem = item => {
    setEditingItem(_ => Some(item))
    setEditInput(_ => item)
  }

  <div className="w-full">
    <div className="w-full flex flex-wrap gap-2 border p-2 text-sm rounded-md">
      {items
      ->Array.mapWithIndex((item, i) =>
        switch editingItem {
        | Some(selected) if selected == item =>
          <div key={Int.toString(i)} className="flex flex-wrap gap-1 p-1 border text-sm rounded-md">
            <input
              type_="text"
              value={editInput}
              onBlur={_ => saveItem(item)}
              onInput=handleEditChange
              onKeyDown={ev => {
                open ReactEvent.Keyboard
                let key = ev->key
                let keyCode = ev->keyCode
                if key === "Enter" || keyCode === 13 {
                  ReactEvent.Keyboard.preventDefault(ev)
                  saveItem(item)
                }
              }}
              className="rounded-md p-1 text-sm flex-grow"
            />
            <button
              onClick={_ => removeItem(item)} className="ml-2 hover:bg-gray-300 rounded-md p-1">
              <Icon name="cross-outline" size=14 />
            </button>
          </div>
        | _ =>
          <div key={Int.toString(i)} className="flex flex-wrap gap-1 p-1 border text-sm rounded-md">
            <div
              className="cursor-pointer rounded-md px-2 py-1 text-sm text-gray-600 flex-grow"
              onClick={_ => toggleEditingItem(item)}>
              {React.string(item)}
            </div>
            <button
              onClick={_ => removeItem(item)} className="ml-2 hover:bg-gray-300 rounded-md p-1">
              <Icon name="cross-outline" size=14 />
            </button>
          </div>
        }
      )
      ->React.array}
      <input
        type_="text"
        value={inputValue}
        placeholder
        onChange=handleInputChange
        onKeyDown=handleKeyDown
        className="outline-none p-2 flex-grow"
        name
      />
    </div>
    {error != ""
      ? <div className="flex gap-1">
          <Icon name="exclamation-circle" size=14 className="!text-red-500 mt-1" />
          <p className="text-red-700 text-sm mt-1"> {React.string(error)} </p>
        </div>
      : React.null}
  </div>
}
