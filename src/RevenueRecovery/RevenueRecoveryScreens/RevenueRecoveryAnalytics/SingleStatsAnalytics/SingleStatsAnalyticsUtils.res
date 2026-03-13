// Original values before split
let originalBudget = 3000.0
let originalUsed = 1380.0
let originalSpent = 1380.0
let originalRecovered = 72800.0
let originalPending = 87480.0

let calculateSplitValues = (newBudget: float) => {
  let splitPercentage = newBudget /. originalBudget
  let used = originalUsed *. splitPercentage
  let spent = originalSpent *. splitPercentage
  let recovered = originalRecovered *. splitPercentage
  let pending = originalPending *. splitPercentage
  (used, spent, recovered, pending)
}

let usedPercentage = (budget, used) => {
  if budget > 0.0 {
    used /. budget *. 100.0
  } else {
    0.0
  }
}
