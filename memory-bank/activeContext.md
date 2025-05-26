# Hyperswitch Control Center - Active Context

## Current Focus Areas

This document tracks the current focus areas and recent changes in the Hyperswitch Control Center project. It should be updated regularly to reflect the most recent development status.

- **AuthModule/ProductSelection:**
  - Modifications to `src/entryPoints/AuthModule/ProductSelection/ProductSelectionProvider.res` related to product selection logic.
- **Recoils:**
  - Updates to `src/Recoils/TableAtoms.res` for managing table state using Recoil.
- **Sidebar:**
  - Modifications to `src/entryPoints/SidebarValues.res` related to sidebar values and navigation.
- **Revenue Recovery:**
  - Development of `src/RevenueRecovery/RevenueRecoveryScreens/RevenueRecoveryOverview/RevenueRecoveryOverview.res` for the Revenue Recovery overview screen.
- **Customers:**
  - Updates to `src/screens/Customers/Customers.res` and `src/screens/Customers/CustomersEntity.res` related to customer management.
- **Routing:**
  - Modifications to `src/screens/Routing/HistoryEntity.res` related to routing history.
- **Transaction Disputes:**
  - Updates to `src/screens/Transaction/Disputes/DisputesEntity.res` related to transaction disputes.
- **Review and Refinement:**
  - Updating the main index file (`memory-bank/rescriptSyntaxGuide.md`) to accurately reflect populated content.
  - Deleting the redundant `memory-bank/thematic/rescript/jsxSyntax.md` file after content migration.
- **Broader Code Scan & Augmentation:**
  - Scanning the `src/` directory for diverse examples of ReScript syntax.
  - Augmenting the following syntax documents with new, codebase-specific examples:
    - `memory-bank/thematic/rescript/syntax/typesAndDataStructures.md`: Added more examples of polymorphic variants, including those with payloads.
- **Context7 MCP Server Setup:**
  - Successfully installed and configured the `github.com/upstash/context7-mcp` server.
  - Installation involved creating a Dockerfile and building a Docker image, as initial attempts with `npx`, `bunx`, and `deno` were unsuccessful.
  - The server's `resolve-library-id` tool was tested successfully for "react" and "rescript".
  - The server is now available for fetching up-to-date library documentation.
  - MCP settings file (`/Users/jeeva.ramachandran/Library/Application Support/Code/User/globalStorage/saoudrizwan.claude-dev/settings/cline_mcp_settings.json`) was updated with the Docker configuration:
    ```json
    "github.com/upstash/context7-mcp": {
      "command": "docker",
      "args": ["run", "-i", "--rm", "context7-mcp"],
      "disabled": false,
      "autoApprove": []
    }
    ```
    - `memory-bank/thematic/rescript/syntax/patternMatching.md`: Added a new section on matching polymorphic variants with examples.
    - `memory-bank/thematic/rescript/syntax/functionsAndBindings.md`: Added further examples of the pipe operator and a codebase-specific example for `let rec`.
    - `memory-bank/thematic/rescript/syntax/jsInterop.md`: Updated with specific codebase examples for various `@bs.*` attributes (`@bs.val`, `@bs.module`, `@bs.send`, `@bs.get`, `@bs.set`, `@bs.new`, `@obj`) and `"%identity"`.
    - `memory-bank/thematic/rescript/syntax/commonStdLib.md`: Added examples for `Belt.Float.toString`, `Belt.Int.toString`, and `Belt.Array.zipBy`.
    - `memory-bank/thematic/rescript/syntax/modules.md`: Replaced generic nested module example with specific examples from `src/components/Tabs.res`.
    - `memory-bank/thematic/rescript/syntax/jsxPatterns.md`: Reviewed and deemed sufficiently detailed from previous work.
- **Overall Goal:** To create a comprehensive and practical ReScript syntax reference based on patterns observed in the Hyperswitch Control Center codebase.
- **Memory Bank Enhancement (TestComponent Learnings):** Updating the guide `memory-bank/thematic/TableComponentPage/creatingNewTablePage.md` with troubleshooting tips and corrections (e.g., `Table.header` type, `itemToObjMapper` signature, module routing references) derived from the recent `TestComponent` page implementation.
- **Connector Addition (Worldpayxml):**
  - Added `WORLDPAYXML` to `processorTypes` in `src/screens/Connectors/ConnectorTypes.res`.
  - Updated `src/screens/Connectors/ConnectorUtils.res` to include `WORLDPAYXML` in `connectorList`, defined `worldpayxmlInfo`, and updated `getConnectorNameString`, `getConnectorNameTypeFromString`, `getProcessorInfo`, and `getDisplayNameForProcessor`.

### Current Sprint Priorities

1. **API Integration Enhancements**

   - Standardizing API call patterns across the application following the established ReScript pattern
   - Implementing consistent error handling with PageLoaderWrapper integration
   - Enhancing type safety with improved response type definitions
   - Refining API hook usage patterns for better reusability

2. **Payment Processing Workflow**

- `src/entryPoints/AuthModule/ProductSelection/ProductSelectionProvider.res`
- `src/Recoils/TableAtoms.res`
- `src/entryPoints/SidebarValues.res`
- `src/RevenueRecovery/RevenueRecoveryScreens/RevenueRecoveryOverview/RevenueRecoveryOverview.res`
- `src/screens/Customers/Customers.res`
- `src/screens/Customers/CustomersEntity.res`
- `src/screens/Routing/HistoryEntity.res`
- `src/screens/Transaction/Disputes/DisputesEntity.res`
- `src/screens/Connectors/ConnectorTypes.res`
- `src/screens/Connectors/ConnectorUtils.res`
  - Refining payment management interfaces
  - Optimizing refund and dispute handling flows
  - Enhancing payment status visualization

3. **Intelligent Routing**

   - Enhancing rule-based routing configuration interfaces
   - Implementing performance simulation and visualization tools
   - Creating intuitive drag-and-drop UI for complex routing scenarios
   - Optimizing routing rule evaluation performance

4. **Dashboard Performance**
   - Implementing optimized data fetching with cancelable API requests
   - Enhancing component virtualization for large data sets
   - Refining code splitting strategies for faster initial load
   - Improving state management performance with selective Recoil atom updates

### Recent Changes

#### Latest Features Added

- Enhanced analytics dashboard with customizable visualization options
- Streamlined connector integration workflow with guided setup
- Added support for regional payment processors and methods
- Implemented granular feature flag system with user-level overrides
- Introduced PageLoaderWrapper component for standardized loading states

#### Refactoring and Improvements

- Consolidated API utility functions with improved typing and error handling
- Standardized component prop interfaces with comprehensive .resi files
- Migrated to ReScript 11.1.1 with enhanced compiler performance
- Enhanced theme customization with runtime theme switching capabilities
- Improved API response handling with standardized loader states

#### Technical Debt Addressed

- Fixed inconsistent error handling patterns
- Improved type definitions for better type safety
- Consolidated duplicate code in utility functions
- Addressed performance bottlenecks in data-heavy components

## Current Development Environment

- ReScript Compiler Version: 11.1.1
- React Version: 18.2.0
- Node.js Recommended Version: 18.x
- Package Manager: Yarn 3.2.1
- Recommended IDE: VSCode with ReScript extension 1.4.0

## Known Issues and Constraints

1. **Performance Challenges**

   - Large data sets may cause rendering slowdowns in some analytics views
   - Initial load time on low-end devices may be suboptimal

2. **Browser Compatibility**

   - Optimized for Chrome, Firefox, Safari, and Edge
   - Some visual inconsistencies may appear in older browsers

3. **API Limitations**
   - Some advanced filtering capabilities dependent on API improvements
   - Rate limits may affect high-volume operations

## Next Milestone Goals

1. **Payment Method Management**

   - Enhanced saved payment method management for customers
   - Better visualization of payment method performance

2. **Advanced Analytics**

   - Implement advanced filtering capabilities
   - Add customizable dashboard widgets
   - Provide deeper insights into payment performance

3. **Multi-tenant Capabilities**

   - Improve organization and merchant management
   - Enhance user permission systems
   - Support for more complex organizational hierarchies

4. **Backend Integration**
   - Tighter integration with Hyperswitch backend services
   - Support for upcoming API enhancements

## Active Experiments

1. **UI/UX Improvements**

   - Testing alternative navigation patterns for complex workflows
   - Evaluating different visualization approaches for payment data

2. **Performance Optimizations**

   - Evaluating code splitting strategies for faster initial load
   - Testing various caching mechanisms for API responses

3. **Developer Experience**
   - Exploring improved development tooling
   - Evaluating test coverage expansion

## Recent Decisions

1. **Architecture**

   - Continued commitment to ReScript for type safety benefits
   - Adoption of more granular component composition patterns
   - Standardization of data fetching with PageLoaderWrapper pattern
   - Consistent API call structure with central type definitions

2. **UI/UX**

   - Emphasis on accessibility improvements across all components
   - Standardized mobile-first approach for all new components
   - Commitment to comprehensive dark mode support
   - Implementation of skeleton loaders for better perceived performance

3. **Technical**
   - Standardized approach to API response handling with typed responses
   - Consolidated state management patterns using Recoil with atom families
   - Improved feature flag implementation for better runtime customization
   - Formalized error handling with consistent user feedback mechanisms
