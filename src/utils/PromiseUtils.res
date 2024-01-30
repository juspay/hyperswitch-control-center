// Pollyfill for Promise.allSettled()
// Promise.allSettled() takes an iterable of promises and returns a single promise that is fulfilled with an array of promise settlement result

let allSettledPolyfill = (arr: array<promise<JSON.t>>) => {
  arr
  ->Array.map(promise =>
    promise
    ->Promise.then(val => {
      Promise.resolve(val)
    })
    ->Promise.catch(err => {
      switch err {
      | Js.Exn.Error(e) =>
        let err = Js.Exn.message(e)->Option.getOr("Failed to Fetch!")
        err->JSON.Encode.string
      | _ => JSON.Encode.null
      }->Promise.resolve
    })
  )
  ->Promise.all
}
