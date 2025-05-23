# Guide: Creating a New Page with a Table Component

This document outlines the step-by-step process for creating a new page in the Hyperswitch Control Center that fetches data from an API and displays it in a table using the `LoadedTableWithCustomColumns` component. This guide is based on the patterns observed and implemented while creating pages like "Customers" and "TestCline".

## 1. Prerequisites & Information Gathering

Before starting, ensure you have the following information:

-   **`folderName`**: The name for the new directory under `src/` (e.g., `MyNewPage`). This will also be part of the filenames.
-   **`apiEntityName`**: A unique name for your API entity, used in API utility files (e.g., `MY_NEW_ENTITY`). This should be in all caps.
-   **`apiPath`**: The specific API endpoint path (e.g., `/v1/my-data`, `/beta/items`).
-   **`apiVersion`**: The API version (`V1` or `V2`). This determines where the entity is defined in `APIUtilsTypes.res`.
-   **`defaultJSON` Structure**: A sample JSON object representing a single item from your API's list response. This is crucial for defining ReScript types.
    *Example:*
    ```json
    {
      "item_id": "xyz-123",
      "item_name": "Sample Item",
      "quantity": 100,
      "is_available": true,
      "created_date": "2023-10-26T10:00:00Z"
    }
    ```

## 2. Step-by-Step Implementation

### Step 2.1: API Configuration

These changes connect your new page to the backend API.

**A. Update `src/APIUtils/APIUtilsTypes.res`:**

   Add your `apiEntityName` to the appropriate entity type based on `apiVersion`.

   -   If `apiVersion` is `V1`, add to `entityName`:
       ```rescript
       // src/APIUtils/APIUtilsTypes.res
       type entityName =
         | ... // existing entities
         | MY_NEW_ENTITY // Your new entity name
       ```
   -   If `apiVersion` is `V2`, add to `v2entityNameType`:
       ```rescript
       // src/APIUtils/APIUtilsTypes.res
       type v2entityNameType =
         | ... // existing v2 entities
         | MY_NEW_ENTITY // Your new entity name
       ```

**B. Update `src/APIUtils/APIUtils.res`:**

   Map your `apiEntityName` to its `apiPath` within the `useGetURL` hook, inside the `switch entityName` (or `switch entityNameType` for V1) block.

   ```rescript
   // src/APIUtils/APIUtils.res
   // Inside the V1(entityNameType) switch, if apiVersion is V1:
   switch entityNameType {
   // ... other cases
   | MY_NEW_ENTITY => "/your/api/path" // e.g., "/cline"
   // ... other cases
   }
   ```

### Step 2.2: Create PageType File

This file defines the data structures for your page.

   -   **File Path:** `src/<folderName>/<folderName>PageType.res` (e.g., `src/MyNewPage/MyNewPageType.res`)
   -   **Content:**
       ```rescript
       // src/MyNewPage/MyNewPageType.res

       // 1. Define the record type for a single item from the API
       //    (Derived from your defaultJSON structure)
       type myNewPageItem = {
         item_id: string,
         item_name: string,
         quantity: int,
         is_available: bool,
         created_date: string, // Or use a date type if further manipulation is needed
       }

       // 2. Define a polymorphic variant for table column identifiers
       type myNewPageColsType =
         | ItemId
         | ItemName
         | Quantity
         | IsAvailable
         | CreatedDate
       ```

### Step 2.3: Create PageEntity File

This file contains the logic for table rendering and data mapping.

   -   **File Path:** `src/<folderName>/<folderName>PageEntity.res` (e.g., `src/MyNewPage/MyNewPageEntity.res`)
   -   **Content Structure:**
       ```rescript
       // src/MyNewPage/MyNewPageEntity.res
       open MyNewPageType // Open the types defined in the previous step
       open LogicUtils    // For utility functions like getString, getInt, etc.
       open Table         // Ensure Table module is open for Table.header, Table.cell etc.

       // 1. Define default and all columns for the table
       let defaultColumns: array<myNewPageColsType> = [ItemId, ItemName, Quantity, IsAvailable]
       let allColumns: array<myNewPageColsType> = [ItemId, ItemName, Quantity, IsAvailable, CreatedDate]

       // 2. Define table headings
       let getHeading = (colType: myNewPageColsType): Table.header => { // Corrected type
         switch colType {
         | ItemId => Table.makeHeaderInfo(~key="item_id", ~title="Item ID")
         | ItemName => Table.makeHeaderInfo(~key="item_name", ~title="Name")
         | Quantity => Table.makeHeaderInfo(~key="quantity", ~title="Qty.")
         | IsAvailable => Table.makeHeaderInfo(~key="is_available", ~title="Available")
         | CreatedDate => Table.makeHeaderInfo(~key="created_date", ~title="Created On")
         }
       }

       // 3. Define cell rendering logic
       let getCell = (item: myNewPageItem, colType: myNewPageColsType): Table.cell => {
         switch colType {
         | ItemId => Text(item.item_id)
         | ItemName => Text(item.item_name)
         | Quantity => Text(item.quantity->Int.toString) // Convert numbers to string for Text cell
         | IsAvailable => Text(item.is_available->getStringFromBool) // Use LogicUtils.getStringFromBool
         | CreatedDate => Text(item.created_date) // Consider Date(item.created_date) if it's a timestamp
         }
       }

       // 4. Implement the JSON-to-ReScript object mapper
       //    This function converts a JSON object from the API into your typed record.
       //    Refer to `src/utils/LogicUtils.res` for helper functions.
       //    Ensure this mapper takes Js.Dict.t<JSON.t> if used with LogicUtils.getArrayDataFromJson
       let itemToObjMapper = (dict: Js.Dict.t<JSON.t>): myNewPageItem => {
         {
           item_id: dict->getString("item_id", ""), // Provide default values
           item_name: dict->getString("item_name", "N/A"),
           quantity: dict->getInt("quantity", 0),
           is_available: dict->getBool("is_available", false),
           created_date: dict->getString("created_date", ""),
         }
       }

       // 5. Implement the function to get an array of typed items from JSON
       //    This often uses `LogicUtils.getArrayDataFromJson`.
       let getMyNewPageData = (json: JSON.t): array<myNewPageItem> => {
         LogicUtils.getArrayDataFromJson(json, itemToObjMapper)
         // If API response is not a direct array but nested, e.g., {"data": [...]},
         // you might need: json->LogicUtils.getDictFromJsonObject->LogicUtils.getArrayFromDict("data", [])-> ...
       }

       // 6. Define the table entity using EntityType.makeEntity
       let myNewPageEntity = EntityType.makeEntity(
         ~uri="", // Optional: Base URI for links, if any
         ~getObjects=getMyNewPageData,
         ~defaultColumns,
         ~allColumns,
         ~getHeading,
         ~getCell,
         ~dataKey="", // Optional: If API data is nested under a key (e.g., "items")
         ~getShowLink= (item: myNewPageItem) => // Optional: For row click to details page
           GlobalVars.appendDashboardPath(~url=`/my-new-page/${item.item_id}`),
         // Add other parameters as needed (e.g., ~searchKeys, ~canFilter)
       )
       ```

### Step 2.4: Create Page Component File

This is the main React component for your new page.

   -   **File Path:** `src/<folderName>/<folderName>Page.res` (e.g., `src/MyNewPage/MyNewPagePage.res`)
   -   **Content Structure (referencing `memory-bank/thematic/rescript/apiCallStructure.md`):**
       ```rescript
       // src/MyNewPage/MyNewPagePage.res
       open APIUtils
       open MyNewPageEntity // From previous step
       // MyNewPageType is implicitly opened by MyNewPageEntity if structured correctly

       @react.component
       let make = () => {
         let getURL = useGetURL()
         let fetchDetails = useGetMethod() // Or useUpdateMethod for POST/PUT etc.
         let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
         let (pageData, setPageData) = React.useState(_ => []) // To store array<myNewPageItem>

         // Pagination state (if needed)
         let (offset, setOffset) = React.useState(_ => 0)
         let resultsPerPage = 20 // Or from config/state

         // API call function
         let getMyNewPageList = async () => {
           setScreenState(_ => PageLoaderWrapper.Loading)
           try {
             let apiUrl = getURL(
               ~entityName=V1(MY_NEW_ENTITY), // Or V2(MY_NEW_ENTITY)
               ~methodType=Get,
               // ~queryParamerters=Some(`limit=${resultsPerPage->Int.toString}&offset=${offset->Int.toString}`), // For pagination
             )
             let responseJson = await fetchDetails(apiUrl)

             // Assuming API returns a direct array. Adjust if nested.
             let data = getMyNewPageData(responseJson) // Uses function from PageEntity.res

             setPageData(_ => data)
             setScreenState(_ => PageLoaderWrapper.Success)
           } catch {
           | Exn.Error(e) =>
             let errorMessage = Exn.message(e)->Option.getOr("Failed to fetch data.")
             setScreenState(_ => PageLoaderWrapper.Error(errorMessage))
           }
         }

         // Fetch data on component mount (and when offset changes, if paginated)
         React.useEffect(() => {
           getMyNewPageList()->ignore
           None
         }, [offset]) // Add `offset` to dependency array if using it

         // Render JSX
         <PageLoaderWrapper screenState>
           <PageUtils.PageHeading title="My New Page Title" subTitle="Description of my new page" />
           <LoadedTableWithCustomColumns
             title="My New Page Data" // Often hidden if PageHeading is used
             hideTitle=true
             actualData={pageData->Array.map(Nullable.make)} // Important: map to Nullable
             entity={myNewPageEntity}
             resultsPerPage
             showSerialNumber=true
             totalResults={pageData->Array.length} // For client-side pagination or if API gives total
             offset
             setOffset
             currrentFetchCount={pageData->Array.length}
             defaultColumns={MyNewPageEntity.defaultColumns} // From PageEntity.res
             customColumnMapper={TableAtoms.myNewPageMapDefaultCols} // Atom to be created next
             // Other props as needed...
           />
         </PageLoaderWrapper>
       }
       ```

### Step 2.5: Update Recoil Atoms for Table State

This allows for features like customizable column visibility.

   -   **File Path:** `src/Recoils/TableAtoms.res`
   -   **Action:** Add a new atom for your page's table.
       ```rescript
       // src/Recoils/TableAtoms.res
       // Potentially need: open MyNewPageEntity

       let myNewPageMapDefaultCols = Recoil.atom(
         "myNewPageMapDefaultCols", // Unique key
         MyNewPageEntity.defaultColumns, // Default columns from your PageEntity file
       )
       ```
       *Ensure `MyNewPageEntity.defaultColumns` is accessible. You might need to add `open MyNewPageEntity` at the top of `TableAtoms.res` or qualify it fully if not already done for other entities.*

### Step 2.6: Integrate into Application (Navigation & Routing)

Make your new page accessible.

**A. Add to Sidebar (`src/entryPoints/SidebarValues.res`):**

   Locate the appropriate section in the sidebar configuration and add a new entry for your page.
   
   For a simple link in a section (like Operations):
   ```rescript
   // src/entryPoints/SidebarValues.res
   // Inside an existing section like operations
   let myNewPage = userHasResourceAccess => {
     SubLevelLink({
       name: "My New Page",
       link: `/my-new-page`,
       access: userHasResourceAccess(~resourceAccess=MyResource), // Use appropriate resource
       searchOptions: [("View my new page data", "")],
     })
   }
   
   // Then add your link to the appropriate array:
   let links = [payments, refunds, disputes]
   // Add your page to the links array
   links->Array.push(myNewPage(userHasResourceAccess))->ignore
   ```
   
   For a standalone link in the main sidebar:
   ```rescript
   // In the sidebar array within useGetHsSidebarValues
   Locate the `useGetHsSidebarValues` hook (or similar structure) and add a new `Link` or `Section` entry for your page.

   ```rescript
   // src/entryPoints/SidebarValues.res
   // Inside the `sidebar` array within `useGetHsSidebarValues`
   let sidebar = [
     // ... other sidebar items
     Link({
       name: "My New Page",
       icon: "nd-your-icon-name", // Choose an appropriate icon
       link: "/my-new-page",      // This will be the route
       access: Access,            // Or specific access control
       selectedIcon: "nd-your-icon-name-fill",
     }),
     // ... other sidebar items
   ]
   ```

**B. Add Route (`src/Orchestration/OrchestrationApp.res`):**

   Add a new case to the main router `switch` statement to render your page component.

   ```rescript
   // src/Orchestration/OrchestrationApp.res
   
   // Inside the switch url.path->HSwitchUtils.urlPath block:
   switch url.path->HSwitchUtils.urlPath {
   // ... other routes
   | list{"my-new-page", ...remainingPath} => 
     <AccessControl 
       authorization={userHasAccess(~groupAccess=YourGroupAccess)} 
       isEnabled={true}>
       <MyNewPagePage />
     </AccessControl>
   // Ensure your page component is imported or opened, e.g.:
   // open MyNewPagePage - though often not needed if using <MyNewPagePage /> directly

   // Inside the `switch url.path->HSwitchUtils.urlPath` block:
   switch url.path->HSwitchUtils.urlPath {
   // ... other routes
   | list{"my-new-page", ..._} => <MyNewPagePage /> // Or <MyNewPagePage.make />
   // ... other routes
   }
   ```

   For pages that need detail views (like showing a single item's details):
   ```rescript
   | list{"my-new-page", ...remainingPath} =>
     <AccessControl 
       authorization={userHasAccess(~groupAccess=YourGroupAccess)} 
       isEnabled={true}>
       <EntityScaffold
         entityName="My New Page"
         remainingPath
         access=Access
         renderList={() => <MyNewPagePage />}
         renderShow={(id, _) => <ShowMyNewPageItem id />}
       />
     </AccessControl>
   ```

## 3. Testing and Refinement

-   Run the application (`npm run start` or similar).
-   Navigate to your new page via the sidebar or by directly entering the URL.
-   Verify:
    -   API data is fetched correctly.
    -   The table displays data as expected.
    -   Column headings and cell rendering are correct.
    -   Pagination (if implemented) works.
    -   No console errors or ReScript warnings.
-   Refine types, mappers, and rendering logic as needed.

## 4. Key Considerations & Common Patterns

-   **`LogicUtils.res`**: Heavily utilize functions from `src/utils/LogicUtils.res` for safe data extraction (`getString`, `getInt`, `getBool`, `getArrayDataFromJson`, `getStringFromBool`, etc.) and other common transformations.
-   **`Table.cell` Types**: Ensure data passed to `Text()` is a string. Convert numbers and booleans appropriately (e.g., `item.count->Int.toString`, `item.isActive->getStringFromBool`). For more complex rendering (chips, links within cells), use `CustomCell()`.
-   **Pagination**: If server-side pagination is required, the API call needs to include `limit` and `offset` query parameters. The API response should ideally provide `totalResults`. The `offset` state in the page component will need to be part of the `useEffect` dependency array to refetch data when the page changes.
-   **Error Handling**: Robust `try...catch` blocks in API calls are essential for good user experience.
-   **Code Style**: Adhere to existing project conventions for naming and formatting.
-   **Memory Bank Updates**: After successfully creating the component, consider if any new patterns or reusable logic should be documented in the broader Memory Bank.

This guide provides a comprehensive template. Adapt it based on the specific requirements of your new page and the structure of the API response.

## 5. Common Pitfalls & Troubleshooting / Key Learnings

Based on recent implementations, here are some key points and common issues to watch out for:

### A. Table Type Definitions

- **Cell and Header Types:** The `getCell` function returns `Table.cell` and the `getHeading` function creates `Table.header` objects (using `Table.makeHeaderInfo`).
- **Custom Cell Rendering:** For complex cell content beyond simple text or dates, use the `CustomCell` constructor with a React component:
  ```rescript
  | CustomerId =>
    CustomCell(
      <HelperComponents.CopyTextCustomComp
        customTextCss="w-36 truncate whitespace-nowrap"
        displayValue={Some(customersData.customer_id)}
        copyValue={Some(customersData.customer_id)}
      />,
      "",
    )
  ```

### B. JSON to ReScript Record Mapping (`itemToObjMapper`)

The `itemToObjMapper` function is crucial for converting raw JSON objects from your API into typed ReScript records:

```rescript
// Well-structured example from CustomersEntity.res
let itemToObjMapper = dict => {
  open LogicUtils
  {
    customer_id: dict->getString("customer_id", ""),
    name: dict->getString("name", ""),
    email: dict->getString("email", ""),
    // ... other fields
  }
}
```

- **Correct Usage with `LogicUtils`**: Open the `LogicUtils` module to access helper functions.
- **Default Values**: Always provide sensible default values for fields that might be missing.
- **Complex Objects**: For nested objects, use functions like `getJsonObjectFromDict` to preserve the structure.

### C. Integrating Into Navigation Flow

When adding your page to the application:

1. **Sidebar Entry**: Add an entry in the appropriate section in `SidebarValues.res`.
2. **Route Handling**: Add a route case in `OrchestrationApp.res`.
3. **Access Control**: Wrap your component with `<AccessControl>` if authorization is required.
4. **Entity Scaffold**: Use `<EntityScaffold>` for pages that have both list and detail views.

### D. Working with Nullable Data

The `LoadedTableWithCustomColumns` component expects data as `array<Nullable.t<'a>>`, so always remember to map your data:

```rescript
actualData={pageData->Array.map(Nullable.make)}
```

This pattern allows for proper handling of potentially null items in the table.

### E. Real-World Example

The Customers page implementation provides a good reference:

- `CustomersType.res` defines the data structure
- `CustomersEntity.res` handles data transformation and presentation
- In `OrchestrationApp.res`, the route is defined with `EntityScaffold`
- In `SidebarValues.res`, it's included in the Operations section

By following these patterns consistently, your new table page will integrate seamlessly with the rest of the application.
### A. Table Type Definitions (`Table.header`, `Table.cell`)

-   **Header Type:** When defining your `getHeading` function, the correct return type for each header object (created by `Table.makeHeaderInfo(...)`) is `Table.header`.
    *   **Incorrect Example in Guide (Corrected Above):** `let getHeading = (colType): Table.headerInfo => { ... }`
    *   **Correct:** `let getHeading = (colType): Table.header => { ... }`
    *   Ensure `open Table` is at the top of your `PageEntity.res` file to make `Table.header` and `Table.cell` types available.

### B. JSON to ReScript Record Mapping (`itemToObjMapper`)

The `itemToObjMapper` function is crucial for converting raw JSON objects from your API into typed ReScript records. Pay close attention to its signature and how it interacts with `LogicUtils` helper functions.

-   **Mapper Signature for `LogicUtils.getArrayDataFromJson`:**
    The `LogicUtils.getArrayDataFromJson(jsonArray, mapperFunc)` utility expects `mapperFunc` to have the signature:
    `Js.Dict.t<JSON.t> => yourRecordType`.
    *   **Correct `itemToObjMapper` definition:**
        ```rescript
        let itemToObjMapper = (dict: Js.Dict.t<JSON.t>): myNewPageItem => {
          // 'dict' is already a dictionary, no need to convert from JSON.t here
          {
            item_id: dict->getString("item_id", ""),
            item_name: dict->getString("item_name", "N/A"),
            // ... other fields using dict->getString, dict->getInt, etc.
          }
        }
        ```
    *   **Common Mistake:** Defining `itemToObjMapper` as `(jsonItem: JSON.t) => ...` and then trying to convert `jsonItem` to a dictionary *inside* the mapper. While this works for the `LogicUtils.getString` calls, it makes the mapper incompatible with `LogicUtils.getArrayDataFromJson`.

-   **Using `LogicUtils` for Field Extraction:**
    Inside `itemToObjMapper` (which now receives `dict: Js.Dict.t<JSON.t>`), use functions like:
    *   `dict->getString("fieldName", "defaultValue")`
    *   `dict->getInt("fieldName", 0)`
    *   `dict->getBool("fieldName", false)`
    *   `dict->getArrayFromDict("arrayFieldName", [])` (if a field is an array)

### C. Module Referencing in Routes (e.g., `OrchestrationApp.res`)

When adding a route for your new page component (e.g., defined in `src/MyNewPage/MyPageComponent.res`):

-   If your `rescript.json` has `"namespace": false` (which is common), modules are not automatically namespaced by their parent directory names for global access.
-   The module defined by `src/MyNewPage/MyPageComponent.res` is `MyPageComponent`.
-   **Correct JSX in Router:** `<MyPageComponent />`
-   **Incorrect:** `<MyNewPage.MyPageComponent />` (This would only be correct if `MyNewPage` was an explicitly defined module or namespace that contains `MyPageComponent`).
