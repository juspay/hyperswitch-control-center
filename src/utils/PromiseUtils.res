// Pollyfill for Promise.allSettled()
// Promise.allSettled() takes an iterable of promises and returns a single promise that is fulfilled with an array of promise settlement result

let allSettledPolyfill = (arr: array<promise<Js.Json.t>>) => {
  let res = arr->Array.map(promise =>
    promise
    ->Promise.then(val => {
      Promise.resolve(val)
    })
    ->Promise.catch(_ => {
      Js.Json.null->Js.Promise.resolve
    })
  )
  Promise.all(res)
}
