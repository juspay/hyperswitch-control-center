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
      | Exn.Error(e) =>
        let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
        err->JSON.Encode.string
      | _ => JSON.Encode.null
      }->Promise.resolve
    })
  )
  ->Promise.all
}

let allSettledResultPolyfill = (arr: array<promise<'a>>) => {
  arr
  ->Array.map(promise =>
    promise
    ->Promise.then(val => Promise.resolve(Ok(val)))
    ->Promise.catch(err => {
      let msg = switch err {
      | Exn.Error(e) => Exn.message(e)->Option.getOr("Failed to Fetch!")
      | _ => "Unknown error"
      }
      Promise.resolve(Error(msg))
    })
  )
  ->Promise.all
}
