// Pollyfill for Promise.allSettled()
// Promise.allSettled() takes an iterable of promises and returns a single promise that is fulfilled with an array of promise settlement result

let allSettledPolyfill = (arr: array<promise<unit>>) => {
  let res = arr->Array.map(promise =>
    promise->Promise.then(val => {
      Promise.resolve(val)
    })
  )
  Promise.all(res)
}
