## API Call Structure in ReScript

This document provides a template for making API calls in ReScript. It covers the essential parts of the API call structure, excluding the component rendering part.

### Core Components

1.  **State Management:**

    ```rescript
    let (screenState, setScreenState) = React.useState(() => PageLoaderWrapper.Loading)
    let (apiData, setApiData) = React.useState(() => JSON.Encode.null)
    ```

2.  **URL Generation:**

    ```rescript
    open APIUtils
    let getUrl = useGetURL()
    let url = getUrl(~entityName=V1(USERS), ~userType=#ROLE_INFO, ~methodType=Get)
    ```

    *   `entityName`:  The name of the entity to fetch (e.g., `USERS`). You will need to provide this.
    *   `userType`: The type of user (e.g., `#ROLE_INFO`).
    *   `methodType`: The HTTP method to use (e.g., `Get`). You will need to provide this.

3.  **Data Fetching:**

    ```rescript
    let fetchData = useGetMethod()

    let fetchData = async () => {
      try {
        setScreenState(_ => PageLoaderWrapper.Loading)
        let data = await fetchData(url)
        setApiData(_ => data)
        setScreenState(_ => PageLoaderWrapper.Success)
      } catch {
      | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch data"))
      }
    }
    ```

4.  **useEffect Hook:**

    ```rescript
    React.useEffect(() => {
      fetchData()->ignore
      None
    }, [])
    ```

### Usage

1.  Import necessary modules:

    ```rescript
    open APIUtils
    ```

2.  Define state variables for screen state and API data.
3.  Use `useGetURL` hook to generate the API URL.
4.  Use `useGetMethod` hook to fetch data from the API.
5.  Wrap the component with `PageLoaderWrapper` to handle loading and error states.

### Notes

*   Ensure that the `entityName` and `methodType` are correctly defined in `src/APIUtils/APIUtilsTypes.res`.
*   The `PageLoaderWrapper` component is used to display loading and error states.
*   The `fetchData` function is an asynchronous function that fetches data from the API and updates the state variables.
