let allSettledPolyfill = (arr: array<promise<unit>>) => {
  let res = arr->Array.map(promise =>
    promise->Promise.then(val => {
      Promise.resolve(val)
    })
  )
  Promise.all(res)
}
