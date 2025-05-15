# Table Creation Memory Bank

This document outlines the steps to create a table with API integration and display it in the Hyperswitch Control Center.

## Steps

1.  **Create a new folder:** Create a new folder under the `src` directory to house the new component's files.
2.  **Create files:** Inside the new folder, create three files:
    *   `[ComponentName].res` (main component)
    *   `[ComponentName]Type.res` (type definitions)
    *   `[ComponentName]Entity.res` (entity definition)
3.  **Update Sidebar:** Modify `src/entryPoints/SidebarValues.res` to add a link to the new component in the sidebar.
4.  **Implement API call:** In `[ComponentName].res`, implement an API call using `useGetMethod` hook to fetch data.
5.  **Convert JSON:** Use `LogicUtils.getArrayDataFromJson` and `[ComponentName]Entity.itemToObjMapper` to convert the JSON data to the correct type.
6.  **Create Table:** Create a table in `[ComponentName].res` to render the columns of the JSON data. Use the `LoadedTableWithCustomColumns` component.
7.  **Implement Table Logic:** Implement the table logic, including data mapping, column definitions, and rendering.
8.  **Add PageLoaderWrapper:** Wrap the component with `PageLoaderWrapper` to handle loading and error states.
9.  **Define Recoil Atom:** Create a new recoil atom in `src/Recoils/TableAtoms.res` to manage the table columns.
10. **Add Mapping:** Add the mapping for the component inside `src/Orchestration/OrchestrationApp.res`.

## Code Snippets

*   **itemToObjMapper function:**

    ```rescript
    let itemToObjMapper = dict => {
      {
        name: LogicUtils.getString(dict, "name", ""),
        icon: LogicUtils.getString(dict, "icon", ""),
        link: LogicUtils.getString(dict, "link", ""),
      }
    }
    ```

*   **API call and data conversion:**

    ```rescript
    let fetchData = async () => {
      setScreenState(_ => PageLoaderWrapper.Loading)
      try {
        let url = getURL(~entityName=V1(TESTING_DATA), ~methodType=Get, ~queryParamerters=None)
        let json = await fetchData(url)
        let componentData = LogicUtils.getArrayDataFromJson(json, NewComponentEntity.itemToObjMapper)->Array.map(Nullable.make)

        setComponentData(_ => componentData)
        setScreenState(_ => PageLoaderWrapper.Success)
      } catch {
      | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch data"))
      }
    }
