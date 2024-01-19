// Pollyfill for Promise.allSettled()
// Promise.allSettled() takes an iterable of promises and returns a single promise that is fulfilled with an array of promise settlement result

let allSettledPolyfill = (arr: array<promise<Js.Json.t>>) => {
  arr
  ->Array.map(promise =>
    promise
    ->Promise.then(val => {
      Promise.resolve(val)
    })
    ->Promise.catch(err => {
      switch err {
      | Js.Exn.Error(e) =>
        let err = Js.Exn.message(e)->Option.getWithDefault("Failed to Fetch!")
        err->Js.Json.string
      | _ => Js.Json.null
      }->Promise.resolve
    })
  )
  ->Promise.all
}
