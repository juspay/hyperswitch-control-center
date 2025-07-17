# React Hooks Dependency Arrays in ReScript (Hyperswitch Control Center)

This document details how to correctly specify dependency arrays for React hooks like `useEffect`, `useCallback`, and `useMemo`, especially when dealing with mixed data types.

## useEffect Dependencies

### Basic useEffect with Dependencies

```rescript
@react.component
let make = (~userId: string) => {
  let (userData, setUserData) = React.useState(_ => None)

  // Effect with single dependency
  React.useEffect1(() => {
    let fetchUser = async () => {
      // Fetch user data
      let data = await getUserData(userId)
      setUserData(_ => Some(data))
    }
    fetchUser()->ignore
    None
  }, [userId])

  // Render component
  <div> {React.string("User component")} </div>
}
```

### Multiple Dependencies

```rescript
@react.component
let make = (~userId: string, ~includeProfile: bool, ~refreshToken: int) => {
  let (data, setData) = React.useState(_ => None)

  // Effect with multiple dependencies
  React.useEffect3(() => {
    let fetchData = async () => {
      let userData = await getUserData(userId)
      let profileData = if includeProfile {
        Some(await getProfileData(userId))
      } else {
        None
      }
      setData(_ => Some((userData, profileData)))
    }
    fetchData()->ignore
    None
  }, (userId, includeProfile, refreshToken))

  <div> {React.string("Component with multiple deps")} </div>
}
```

### Complex Dependencies

```rescript
type filterOptions = {
  status: string,
  dateRange: (float, float),
  limit: int,
}

@react.component
let make = (~filters: filterOptions, ~sortBy: string) => {
  let (payments, setPayments) = React.useState(_ => [])

  // Effect with complex object dependencies
  React.useEffect2(() => {
    let fetchPayments = async () => {
      let data = await getPayments(~filters, ~sortBy, ())
      setPayments(_ => data)
    }
    fetchPayments()->ignore
    None
  }, (filters, sortBy))

  <div> {React.string("Payments list")} </div>
}
```

## useCallback Dependencies

### Basic useCallback

```rescript
@react.component
let make = (~onSave: string => unit, ~userId: string) => {
  let (formData, setFormData) = React.useState(_ => "")

  // Callback with dependencies
  let handleSubmit = React.useCallback2(() => {
    if String.length(formData) > 0 {
      onSave(formData)
    }
  }, (formData, onSave))

  <form onSubmit={_ => handleSubmit()}>
    <input
      value={formData}
      onChange={event => {
        let value = ReactEvent.Form.target(event)["value"]
        setFormData(_ => value)
      }}
    />
    <button type_="submit"> {React.string("Save")} </button>
  </form>
}
```

### useCallback with Complex Dependencies

```rescript
type apiConfig = {
  baseUrl: string,
  timeout: int,
  retries: int,
}

@react.component
let make = (~config: apiConfig, ~authToken: option<string>) => {
  let (isLoading, setIsLoading) = React.useState(_ => false)

  // Callback that depends on config and auth token
  let makeApiCall = React.useCallback2(endpoint => {
    async () => {
      setIsLoading(_ => true)
      try {
        let headers = switch authToken {
        | Some(token) => [("Authorization", `Bearer ${token}`)]
        | None => []
        }

        let response = await fetch(`${config.baseUrl}/${endpoint}`, {
          headers: headers,
          timeout: config.timeout,
        })

        let data = await response->Fetch.Response.json
        setIsLoading(_ => false)
        data
      } catch {
      | _ => {
          setIsLoading(_ => false)
          Exn.raiseError("API call failed")
        }
      }
    }
  }, (config, authToken))

  <div> {React.string("API component")} </div>
}
```

## useMemo Dependencies

### Basic useMemo

```rescript
@react.component
let make = (~items: array<string>, ~searchTerm: string) => {
  // Memoized filtered items
  let filteredItems = React.useMemo2(() => {
    items->Belt.Array.filter(item =>
      item->Js.String2.toLowerCase->Js.String2.includes(
        searchTerm->Js.String2.toLowerCase
      )
    )
  }, (items, searchTerm))

  <ul>
    {filteredItems
    ->Belt.Array.mapWithIndex((item, index) =>
        <li key={Int.toString(index)}> {React.string(item)} </li>
      )
    ->React.array}
  </ul>
}
```

### useMemo with Complex Calculations

```rescript
type payment = {
  id: string,
  amount: float,
  currency: string,
  status: string,
  createdAt: float,
}

type summaryData = {
  totalAmount: float,
  averageAmount: float,
  paymentCount: int,
  statusCounts: Js.Dict.t<int>,
}

@react.component
let make = (~payments: array<payment>, ~currency: string) => {
  // Expensive calculation memoized
  let summary = React.useMemo2(() => {
    let filteredPayments = payments->Belt.Array.filter(p => p.currency == currency)

    let totalAmount = filteredPayments
      ->Belt.Array.reduce(0.0, (acc, payment) => acc +. payment.amount)

    let paymentCount = Belt.Array.length(filteredPayments)
    let averageAmount = if paymentCount > 0 {
      totalAmount /. Int.toFloat(paymentCount)
    } else {
      0.0
    }

    let statusCounts = Js.Dict.empty()
    filteredPayments->Belt.Array.forEach(payment => {
      let currentCount = statusCounts
        ->Js.Dict.get(payment.status)
        ->Belt.Option.getOr(0)
      statusCounts->Js.Dict.set(payment.status, currentCount + 1)
    })

    {
      totalAmount,
      averageAmount,
      paymentCount,
      statusCounts,
    }
  }, (payments, currency))

  <div>
    <h3> {React.string(`Summary for ${currency}`)} </h3>
    <p> {React.string(`Total: ${Float.toString(summary.totalAmount)}`)} </p>
    <p> {React.string(`Average: ${Float.toString(summary.averageAmount)}`)} </p>
    <p> {React.string(`Count: ${Int.toString(summary.paymentCount)}`)} </p>
  </div>
}
```

## Handling Different Data Types in Dependencies

### Option Types in Dependencies

```rescript
@react.component
let make = (~userId: option<string>, ~config: option<apiConfig>) => {
  let (data, setData) = React.useState(_ => None)

  // Effect with optional dependencies
  React.useEffect2(() => {
    switch (userId, config) {
    | (Some(id), Some(cfg)) => {
        let fetchData = async () => {
          let result = await getUserData(id, cfg)
          setData(_ => Some(result))
        }
        fetchData()->ignore
      }
    | _ => setData(_ => None)
    }
    None
  }, (userId, config))

  <div> {React.string("Component with optional deps")} </div>
}
```

### Array Dependencies

```rescript
@react.component
let make = (~userIds: array<string>, ~batchSize: int) => {
  let (users, setUsers) = React.useState(_ => [])

  // Effect with array dependency
  React.useEffect2(() => {
    let fetchUsers = async () => {
      let batches = userIds
        ->Belt.Array.sliceToEnd(0)
        ->Belt.Array.reduce([], (acc, userId) => {
          let lastBatch = acc->Belt.Array.get(Belt.Array.length(acc) - 1)
          switch lastBatch {
          | Some(batch) when Belt.Array.length(batch) < batchSize => {
              let updatedBatch = Belt.Array.concat(batch, [userId])
              let withoutLast = acc->Belt.Array.slice(~offset=0, ~len=Belt.Array.length(acc) - 1)
              Belt.Array.concat(withoutLast, [updatedBatch])
            }
          | _ => Belt.Array.concat(acc, [[userId]])
          }
        })

      let allUsers = []
      for batch in batches {
        let batchUsers = await getUsersBatch(batch)
        allUsers->Js.Array2.pushMany(batchUsers)->ignore
      }

      setUsers(_ => allUsers)
    }

    if Belt.Array.length(userIds) > 0 {
      fetchUsers()->ignore
    }
    None
  }, (userIds, batchSize))

  <div> {React.string("Batch user loader")} </div>
}
```

### Record Dependencies

```rescript
type searchParams = {
  query: string,
  filters: array<string>,
  sortBy: string,
  sortOrder: string,
}

@react.component
let make = (~searchParams: searchParams, ~pageSize: int) => {
  let (results, setResults) = React.useState(_ => [])
  let (isLoading, setIsLoading) = React.useState(_ => false)

  // Effect with record dependency
  React.useEffect2(() => {
    let search = async () => {
      setIsLoading(_ => true)
      try {
        let data = await searchAPI(~params=searchParams, ~pageSize, ())
        setResults(_ => data)
      } catch {
      | _ => setResults(_ => [])
      } finally {
        setIsLoading(_ => false)
      }
    }

    if String.length(searchParams.query) > 0 {
      search()->ignore
    } else {
      setResults(_ => [])
    }
    None
  }, (searchParams, pageSize))

  if isLoading {
    <div> {React.string("Loading...")} </div>
  } else {
    <div> {React.string(`Found ${Int.toString(Belt.Array.length(results))} results`)} </div>
  }
}
```

## Common Patterns and Best Practices

### Stable References for Functions

```rescript
@react.component
let make = (~onDataChange: array<string> => unit) => {
  let (items, setItems) = React.useState(_ => [])

  // Stable callback reference
  let handleItemAdd = React.useCallback1(newItem => {
    setItems(prevItems => {
      let updatedItems = Belt.Array.concat(prevItems, [newItem])
      onDataChange(updatedItems)
      updatedItems
    })
  }, [onDataChange])

  let handleItemRemove = React.useCallback1(itemToRemove => {
    setItems(prevItems => {
      let updatedItems = prevItems->Belt.Array.filter(item => item !== itemToRemove)
      onDataChange(updatedItems)
      updatedItems
    })
  }, [onDataChange])

  <div>
    <button onClick={_ => handleItemAdd("New Item")}>
      {React.string("Add Item")}
    </button>
    {items
    ->Belt.Array.mapWithIndex((item, index) =>
        <div key={Int.toString(index)}>
          <span> {React.string(item)} </span>
          <button onClick={_ => handleItemRemove(item)}>
            {React.string("Remove")}
          </button>
        </div>
      )
    ->React.array}
  </div>
}
```

### Avoiding Unnecessary Re-renders

```rescript
type expensiveData = {
  processedItems: array<string>,
  calculations: Js.Dict.t<float>,
  metadata: Js.Dict.t<string>,
}

@react.component
let make = (~rawData: array<string>, ~processingOptions: processingConfig) => {
  // Memoize expensive processing
  let processedData = React.useMemo2(() => {
    // Expensive data processing
    let processedItems = rawData
      ->Belt.Array.map(item => processItem(item, processingOptions))
      ->Belt.Array.filter(item => isValidItem(item))

    let calculations = Js.Dict.empty()
    processedItems->Belt.Array.forEach(item => {
      let value = calculateValue(item)
      calculations->Js.Dict.set(item, value)
    })

    let metadata = generateMetadata(processedItems, processingOptions)

    {
      processedItems,
      calculations,
      metadata,
    }
  }, (rawData, processingOptions))

  // Memoize render-heavy components
  let expensiveComponent = React.useMemo1(() => {
    <ExpensiveVisualization data={processedData} />
  }, [processedData])

  <div>
    <h2> {React.string("Data Analysis")} </h2>
    {expensiveComponent}
  </div>
}
```

### Custom Hooks with Dependencies

```rescript
// Custom hook for API data fetching
let useApiData = (~endpoint: string, ~params: option<Js.Dict.t<string>>) => {
  let (data, setData) = React.useState(_ => None)
  let (isLoading, setIsLoading) = React.useState(_ => false)
  let (error, setError) = React.useState(_ => None)

  React.useEffect2(() => {
    let fetchData = async () => {
      setIsLoading(_ => true)
      setError(_ => None)

      try {
        let queryString = switch params {
        | Some(p) => {
            let pairs = p->Js.Dict.entries->Belt.Array.map(((key, value)) => `${key}=${value}`)
            "?" ++ pairs->Js.Array2.joinWith("&")
          }
        | None => ""
        }

        let response = await fetch(`${endpoint}${queryString}`)
        let json = await response->Fetch.Response.json
        setData(_ => Some(json))
      } catch {
      | Exn.Error(e) => {
          let message = Exn.message(e)->Belt.Option.getOr("Unknown error")
          setError(_ => Some(message))
        }
      } finally {
        setIsLoading(_ => false)
      }
    }

    fetchData()->ignore
    None
  }, (endpoint, params))

  (data, isLoading, error)
}

// Usage of custom hook
@react.component
let make = (~userId: string, ~includeProfile: bool) => {
  let params = Js.Dict.fromArray([
    ("userId", userId),
    ("includeProfile", includeProfile ? "true" : "false"),
  ])

  let (userData, isLoading, error) = useApiData(~endpoint="/api/user", ~params=Some(params))

  switch (isLoading, error, userData) {
  | (true, _, _) => <div> {React.string("Loading...")} </div>
  | (false, Some(err), _) => <div> {React.string(`Error: ${err}`)} </div>
  | (false, None, Some(data)) => <UserDisplay data />
  | (false, None, None) => <div> {React.string("No data")} </div>
  }
}
```

### Dependency Array Optimization

```rescript
@react.component
let make = (~config: {baseUrl: string, timeout: int}, ~filters: array<string>) => {
  let (data, setData) = React.useState(_ => [])

  // Extract stable values to avoid unnecessary re-renders
  let baseUrl = config.baseUrl
  let timeout = config.timeout

  // Memoize filters array to avoid reference changes
  let stableFilters = React.useMemo1(() => filters, [filters])

  React.useEffect3(() => {
    let fetchData = async () => {
      let response = await fetchWithConfig(~baseUrl, ~timeout, ~filters=stableFilters, ())
      setData(_ => response)
    }
    fetchData()->ignore
    None
  }, (baseUrl, timeout, stableFilters))

  <div> {React.string("Component with optimized deps")} </div>
}
```

## Common Pitfalls and Solutions

### 1. Object Reference Changes

```rescript
// ❌ Bad - object recreated on every render
@react.component
let make = (~userId: string) => {
  let config = {baseUrl: "/api", timeout: 5000} // New object every render!

  React.useEffect2(() => {
    // This will run on every render
    fetchUserData(userId, config)
    None
  }, (userId, config))

  <div />
}

// ✅ Good - stable object reference
@react.component
let make = (~userId: string) => {
  let config = React.useMemo0(() => {
    {baseUrl: "/api", timeout: 5000}
  })

  React.useEffect2(() => {
    fetchUserData(userId, config)
    None
  }, (userId, config))

  <div />
}
```

### 2. Function Dependencies

```rescript
// ❌ Bad - function recreated every render
@react.component
let make = (~onSuccess: string => unit) => {
  let handleSubmit = data => {
    // Process data
    onSuccess(data)
  }

  React.useEffect1(() => {
    // This effect runs every render because handleSubmit changes
    setupEventListener(handleSubmit)
    None
  }, [handleSubmit])

  <div />
}

// ✅ Good - stable function reference
@react.component
let make = (~onSuccess: string => unit) => {
  let handleSubmit = React.useCallback1(data => {
    // Process data
    onSuccess(data)
  }, [onSuccess])

  React.useEffect1(() => {
    setupEventListener(handleSubmit)
    None
  }, [handleSubmit])

  <div />
}
```

## Best Practices

1. **Use the correct hook variant** (`useEffect1`, `useEffect2`, etc.) based on the number of dependencies
2. **Include all dependencies** that are used inside the hook callback
3. **Memoize complex objects and arrays** to avoid unnecessary re-renders
4. **Use useCallback for function dependencies** to maintain stable references
5. **Extract primitive values** from objects when possible to reduce dependency complexity
6. **Avoid inline object/array creation** in dependency arrays
7. **Use custom hooks** to encapsulate complex dependency logic
8. **Consider useMemo for expensive calculations** that depend on specific values
9. **Be careful with optional dependencies** - handle None cases appropriately
10. **Test dependency arrays** to ensure effects run when expected and not when they shouldn't
