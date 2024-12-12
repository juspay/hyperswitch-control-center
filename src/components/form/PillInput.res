@react.component
let make = (~name, ~initialItems: array<string>=[], ~placeholder, ~duplicateCheck=true) => {
  let form = ReactFinalForm.useForm()
  let (items, setItems) = React.useState(_ => initialItems)
  let (inputValue, setInputValue) = React.useState(_ => "")
  let (editInput, setEditInput) = React.useState(_ => "")
  let (editingItem, setEditingItem) = React.useState(_ => None)
  let (error, setError) = React.useState(_ => "")
  let (suggestion, setSuggestion) = React.useState(_ => None)

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
    let key = e->ReactEvent.Keyboard.key
    let keyCode = e->ReactEvent.Keyboard.keyCode
    if key === "Enter" || keyCode === 13 {
      ReactEvent.Keyboard.preventDefault(e)
      switch suggestion {
      | Some(suggestedEmail) => addItem(suggestedEmail)
      | None => addItem(inputValue)
      }
    }
  }

  let toggleEditingItem = item => {
    setEditingItem(_ => Some(item))
    setEditInput(_ => item)
  }

  <div className="w-full ">
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
                let key = ev->ReactEvent.Keyboard.key
                let keyCode = ev->ReactEvent.Keyboard.keyCode
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
      <div className="relative">
        <input
          type_="text"
          value={inputValue}
          placeholder
          onChange=handleInputChange
          onKeyDown=handleKeyDown
          className="max-w-fit outline-none p-2 flex-grow"
          name
        />
        {switch suggestion {
        | Some(suggestedEmail) =>
          <div
            onClick={_ => handleSuggestionClick()}
            className="absolute z-10  w-full min-w-80 bg-white border border-gray-300 rounded-md shadow-lg mt-1 cursor-pointer top-10 h-16">
            <div className="bg-gray-200 w-full h-[calc(100%-16px)] my-2 flex items-center px-4">
              <div className="flex items-center gap-2">
                <img alt="user_icon" src={`/icons/user_icon.svg`} className="h-6 w-6" />
                <span className="font-medium"> {React.string(suggestedEmail)} </span>
              </div>
            </div>
          </div>
        | None => React.null
        }}
      </div>
    </div>
    <RenderIf condition={!(error->LogicUtils.isEmptyString)}>
      <div className="flex gap-1">
        <Icon name="exclamation-circle" size=14 className="!text-red-500 mt-1" />
        <p className="text-red-700 text-sm mt-1"> {React.string(error)} </p>
      </div>
    </RenderIf>
  </div>
}
