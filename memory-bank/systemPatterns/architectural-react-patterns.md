# Architectural and React Patterns

This document covers overarching architectural patterns and specific examples of React component implementations.

## Architectural Patterns

The codebase appears to use a modular architecture, with each module containing its own `App`, `Container`, and `Screens` directories. This suggests a pattern of feature-based modules.

### Example: `Hypersense`, `IntelligentRouting`, `Recon`, `RevenueRecovery`, `Vault`

These modules all follow a similar structure, with `App` files likely serving as the entry point, `Container` files managing state and logic, and `Screens` files defining the UI.

## React Components

The codebase uses React components extensively.

### Example: `HyperSwitchApp.res`

The `src/entryPoints/HyperSwitchApp.res` file defines the main application component.

- It uses `React.useEffect` hooks for:
  - Setting up the dashboard.
  - Applying the theme.
  - Updating the dashboard page state when the user group ACL changes.
  - Tracking page views with Mixpanel.
- It uses `React.useContext` to access global context values such as:
  - `showFeedbackModal` and `setShowFeedbackModal` from `GlobalProvider`.
  - `activeProduct` and `setActiveProductValue` from `ProductSelectionProvider`.
  - `getThemesJson` from `ThemeProvider`.
  - `logoURL` from `ThemeProvider`.
  - `userInfo` from `UserInfoProvider`.
- It uses `Recoil.useRecoilValueFromAtom` to access Recoil state values such as:
  - `merchantDetailsValueAtom` for merchant details.
  - `featureFlagAtom` for feature flag details.
- It uses `Recoil.useRecoilState` to manage Recoil state such as:
  - `userGroupACLAtom` for user group ACL.
- It uses `RescriptReactRouter.useUrl` to get the current URL.
- It uses `MerchantSpecificConfigHook.useMerchantSpecificConfig` to fetch merchant specific config.
- It uses `GroupACLHooks.useUserGroupACLHook` to fetch user group ACL.
- It uses `MerchantDetailsHook.useFetchMerchantDetails` to fetch merchant account details.
- It renders different content based on the `dashboardPageState`, `screenState`, `merchantDetailsTypedValue.product_type`, and `url.path`.
- It uses `RenderIf` components to conditionally render content.
- It uses `ErrorBoundary` to handle errors.
- It uses a `Navbar` component with header actions and left actions.
- It uses a `Sidebar` component for navigation.

### Example: `OrchestrationApp.res`

The `src/Orchestration/OrchestrationApp.res` file defines the main application component for the Orchestration product.

- It uses `React.useEffect` hooks (implicitly through `MerchantSpecificConfigHook.useMerchantSpecificConfig` and `GroupACLHooks.useUserGroupACLHook`) to:
  - Fetch merchant specific configurations.
  - Fetch user group ACL.
- It uses `Recoil.useRecoilValueFromAtom` to access Recoil state values such as:
  - `featureFlagAtom` for feature flag details.
- It uses `React.useContext` to access context values such as:
  - `checkUserEntity` from `UserInfoProvider`.
- It uses `MerchantSpecificConfigHook.useMerchantSpecificConfig` to access:
  - `useIsFeatureEnabledForMerchant` to check if a feature is enabled for a merchant.
  - `merchantSpecificConfig` to access merchant specific configurations.
- It uses `GroupACLHooks.useUserGroupACLHook` to access:
  - `userHasAccess` to check if a user has access to a specific group.
  - `hasAnyGroupAccess` to check if a user has access to any of the specified groups.
- It uses `RescriptReactRouter.useUrl` to get the current URL.
- It renders different container components based on the URL path, such as:
  - `MerchantAccountContainer` for merchant account related pages.
  - `ConnectorContainer` for connector related pages.
  - `APMContainer` for APM related pages.
  - `TransactionContainer` for transaction related pages.
  - `AnalyticsContainer` for analytics related pages.
  - `NewAnalyticsContainer` for new analytics related pages.
  - `UserManagementContainer` for user management related pages.
- It uses `AccessControl` components to conditionally render content based on user access and feature flag settings.
- It uses `EntityScaffold` to render entity lists and show pages.
- It uses `FilterContext` to provide a filter context for new analytics pages.
- It uses `UnauthorizedPage` to display an unauthorized page.
- It uses `HSwitchSettings` for account settings.
- It uses various tables such as `PaymentAttemptTable`, `PaymentIntentTable`, `RefundsTable`, and `DisputeTable` for displaying data.
