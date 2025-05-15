# Table Creation Memory Bank

This document outlines the steps to create a table with API integration and display it in the Hyperswitch Control Center.

## Steps

1.  **Create a new folder:**
    *   Create a new folder under the `src` directory to house the new component's files.
    *   Example: `mkdir src/NewComponent`

2.  **Create files:**
    *   Inside the new folder, create three files:
        *   `NewComponent.res`: This file will contain the main component logic.
        *   `NewComponentType.res`: This file will contain the type definitions for the component.
        *   `NewComponentEntity.res`: This file will contain the entity definition for the component.

3.  **Update Sidebar:**
    *   Modify `src/entryPoints/SidebarValues.res` to add a link to the new component in the sidebar.
    *   Add a `Link` component with the appropriate `name`, `icon`, and `link` properties.

4.  **Implement API call:**
    *   In `NewComponent.res`, implement an API call using the `useGetMethod` hook to fetch data.
    *   Use the `getURL` hook to construct the API endpoint URL.
    *   Wrap the API call in a `try...catch` block to handle potential errors.
    *   Set the `screenState` to `PageLoaderWrapper.Loading` before making the API call and to `PageLoaderWrapper.Success` after successfully fetching the data.
    *   If an error occurs, set the `screenState` to `PageLoaderWrapper.Error` with the error message.

5.  **Convert JSON:**
    *   Use `LogicUtils.getArrayDataFromJson` and `NewComponentEntity.itemToObjMapper` to convert the JSON data to the correct type.
    *   The `itemToObjMapper` function should map the JSON data to the component's entity type.

6.  **Create Table:**
    *   Create a table in `NewComponent.res` to render the columns of the JSON data.
    *   Use the `LoadedTableWithCustomColumns` component to display the table.
    *   Pass the appropriate props to the `LoadedTableWithCustomColumns` component, including:
        *   `title`: The title of the table.
        *   `hideTitle`: A boolean indicating whether to hide the title.
        *   `actualData`: The data to display in the table.
        *   `entity`: The entity definition for the table.
        *   `resultsPerPage`: The number of results to display per page.
        *   `showSerialNumber`: A boolean indicating whether to show the serial number column.
        *   `totalResults`: The total number of results.
        *   `offset`: The current offset.
        *   `setOffset`: A function to set the offset.
        *   `currrentFetchCount`: The current fetch count.
        *   `defaultColumns`: The default columns to display.
        *   `customColumnMapper`: The custom column mapper function.
        *   `showSerialNumberInCustomizeColumns`: A boolean indicating whether to show the serial number column in the customize columns modal.
        *   `showResultsPerPageSelector`: A boolean indicating whether to show the results per page selector.
        *   `sortingBasedOnDisabled`: A boolean indicating whether sorting is disabled.
        *   `showAutoScroll`: A boolean indicating whether to show the auto scroll.

7.  **Implement Table Logic:**
    *   Implement the table logic, including data mapping, column definitions, and rendering.
    *   Define the `defaultColumns` and `allColumns` arrays in `NewComponentEntity.res`.
    *   Implement the `getHeading` and `getCell` functions in `NewComponentEntity.res` to define the table headers and cells.

8.  **Add PageLoaderWrapper:**
    *   Wrap the component with `PageLoaderWrapper` to handle loading and error states.
    *   Pass the `screenState` prop to the `PageLoaderWrapper` component.

9.  **Define Recoil Atom:**
    *   Create a new recoil atom in `src/Recoils/TableAtoms.res` to manage the table columns.
    *   Example: `let newComponentMapDefaultCols = Recoil.atom("newComponentMapDefaultCols", NewComponentEntity.defaultColumns)`

10. **Add Mapping:**
    *   Add the mapping for the component inside `src/Orchestration/OrchestrationApp.res`.
    *   Add a case to the `switch` statement to render the new component when the appropriate route is matched.
    *   Example: `| list{"newcomponent"} => <NewComponent.make />`

## Code Snippets

*   **NewComponentType.res:**

    ```rescript
    type column =
      | Name
      | Icon
      | Link

    type componentData = {
      name: string,
      icon: string,
      link: string,
    }
    ```

*   **NewComponentEntity.res:**

    ```rescript
    open NewComponentType

    let defaultColumns = [
      Name,
      Icon,
      Link,
    ]

    let allColumns = [Name, Icon, Link]

    let getHeading = colType => {
      switch colType {
      | Name => Table.makeHeaderInfo(~key="name", ~title="Name")
      | Icon => Table.makeHeaderInfo(~key="icon", ~title="Icon")
      | Link => Table.makeHeaderInfo(~key="link", ~title="Link")
      }
    }

    let getCell = (componentData, colType): Table.cell => {
      switch colType {
      | Name => Text(componentData.name)
      | Icon => Text(componentData.icon)
      | Link => Text(componentData.link)
      }
    }

    let itemToObjMapper = dict => {
      open LogicUtils
      {
        name: LogicUtils.getString(dict, "name", ""),
        icon: LogicUtils.getString(dict, "icon", ""),
        link: LogicUtils.getString(dict, "link", ""),
      }
    }

    let componentEntity = EntityType.makeEntity(
      ~uri="",
      ~getObjects=json => {
        open LogicUtils
        getArrayDataFromJson(json, itemToObjMapper)
      },
      ~defaultColumns,
      ~allColumns,
      ~getHeading,
      ~getCell,
      ~dataKey="",
      ~getShowLink={componentData => GlobalVars.appendDashboardPath(~url=componentData.link)},
    )
    ```

*   **NewComponent.res:**

    ```rescript
    @react.component
    let make = () => {
      open NewComponentEntity
      open APIUtils
      open LogicUtils

      let getURL = useGetURL()
      let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
      let (componentData, setComponentData) = React.useState(_ => [])

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

      React.useEffect(() => {
        fetchData()->ignore
        None
      }, [])

      <PageLoaderWrapper screenState>
        <PageUtils.PageHeading title="New Component" subTitle="View new component data" />
        <LoadedTableWithCustomColumns
          title="New Component"
          hideTitle=true
          actualData=componentData
          entity={componentEntity}
          resultsPerPage=20
          showSerialNumber=true
          totalResults={componentData->Array.length}
          offset=0
          setOffset={_ => ()}
          currrentFetchCount={componentData->Array.length}
          defaultColumns={defaultColumns}
          customColumnMapper={TableAtoms.newComponentMapDefaultCols}
          showSerialNumberInCustomizeColumns=false
          showResultsPerPageSelector=false
          sortingBasedOnDisabled=false
          showAutoScroll=true
        />
      </PageLoaderWrapper>
    }
    ```

*   **src/Recoils/TableAtoms.res:**

    ```rescript
    let newComponentMapDefaultCols = Recoil.atom(
      "newComponentMapDefaultCols",
      NewComponentEntity.defaultColumns,
    )
    ```

*   **src/Orchestration/OrchestrationApp.res:**

    ```rescript
    | list{"newcomponent"} => <NewComponent.make />
