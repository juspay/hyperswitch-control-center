@val @scope("localStorage")
external getItem: string => Js.Nullable.t<string> = "getItem"

@val @scope("localStorage")
external setItemOrig: (string, string) => unit = "setItem"

@val @scope("localStorage")
external removeItem: string => unit = "removeItem"

@val @scope("localStorage")
external clear: unit => unit = "clear"

module InternalStorage = {
  type listener = unit => unit
  let listeners: array<listener> = []
  let addEventListener = fn => {
    if !{listeners->Js.Array2.includes(fn)} {
      listeners->Js.Array2.push(fn)->ignore
    }
  }
  let removeEventListener = fn => {
    let index = listeners->Js.Array2.findIndex(x => x === fn)
    if index !== -1 {
      listeners->Js.Array2.spliceInPlace(~pos=index, ~remove=1, ~add=[])->ignore
    }
  }

  let sendEvents = () => {
    listeners->Js.Array2.forEach(fn => fn())
  }
}

let setItem = (key, val) => {
  setItemOrig(key, val)
  InternalStorage.sendEvents()
}

let useStorageValue = key => {
  let (value, setValue) = React.useState(() => getItem(key))

  React.useEffect0(() => {
    let oldValue = ref(getItem(key))
    let handleStorage = _ => {
      let newValue = getItem(key)

      if oldValue.contents !== newValue {
        setValue(_ => newValue)
        oldValue.contents = newValue
      }
    }

    InternalStorage.addEventListener(handleStorage)
    Window.addEventListener3("storage", handleStorage, true)

    Some(
      () => {
        InternalStorage.removeEventListener(handleStorage)
        Window.removeEventListener("storage", handleStorage)
      },
    )
  })

  React.useMemo2(() => {
    /* LocalStorage. */ getItem(key)->Js.Nullable.toOption
  }, (key, value))
}
